import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/models/order_models.dart';
import 'package:merchant/realtime/sse_realtime_client.dart';

class Orders extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const Orders(this.portrait, this.isTamil, this.canteenId, {super.key});
  @override
  State<Orders> createState() => OrdersState();
}

class OrdersState extends State<Orders> with OrderFetchMixin<Orders> {
  Map<String, List<ActiveOrderItem>> orders = {};
  SseRealtimeClient? _ordersSseClient;
  Timer? _ordersFallbackTimer;
  bool _ordersFallbackNoticeShown = false;
  bool _isSlowNetwork = false;
  int? _latestLatencyMetricMs;

  @override
  int get canteenIdForOrders => widget.canteenId;

  @override
  bool get enableOrderAutoFetchTimer => false;

  @override
  void initState() {
    super.initState();
    _startOrdersSse();
  }

  @override
  void dispose() {
    _stopOrdersFallback();
    _ordersSseClient?.stop();
    super.dispose();
  }

  void _startOrdersSse() {
    _ordersSseClient?.stop();
    _ordersSseClient = SseRealtimeClient(
      path: ApiConstants.canteenOrderEvents,
      eventTypes: {'status', 'canteen_aggregated_order_update'},
      onMessage: _handleOrdersSseMessage,
      onConnectionStateChanged: _handleOrdersConnectionState,
      onHealthUpdated: _handleOrdersHealth,
      onFatalError: _handleOrdersFatalError,
    )..start();
  }

  void _handleOrdersConnectionState(SseConnectionState state) {
    if (!mounted) return;
    if (state == SseConnectionState.connected) {
      _stopOrdersFallback();
      _ordersFallbackNoticeShown = false;
      return;
    }

    if (state == SseConnectionState.reconnecting ||
        state == SseConnectionState.failed) {
      _startOrdersFallback();
    }
  }

  void _handleOrdersHealth(SseNetworkHealth health) {
    if (!mounted) return;
    setState(() {
      _isSlowNetwork = health.isSlowNetwork;
      _latestLatencyMetricMs = health.metricMs;
    });
  }

  void _handleOrdersFatalError(Object error, StackTrace stackTrace) {
    debugPrint('[orders-sse] fatal error: $error');
    _startOrdersFallback();
    if (!mounted || _ordersFallbackNoticeShown) return;
    _ordersFallbackNoticeShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Realtime order updates disconnected. Falling back to periodic refresh.',
        ),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  void _startOrdersFallback() {
    if (_ordersFallbackTimer != null) return;
    _ordersFallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      triggerOrderFetch();
    });
    triggerOrderFetch();
  }

  void _stopOrdersFallback() {
    _ordersFallbackTimer?.cancel();
    _ordersFallbackTimer = null;
  }

  void _handleOrdersSseMessage(SseMessage message) {
    if (message.event == 'status') {
      return;
    }
    if (message.event != 'canteen_aggregated_order_update') {
      return;
    }

    try {
      final decoded = jsonDecode(message.data);
      if (decoded is! Map<String, dynamic>) return;
      final timeBand = decoded['time_band'];
      final rawItems = decoded['items'];
      if (timeBand is! String || rawItems is! List) return;

      final List<ActiveOrderItem> updatedItems = [];
      for (final raw in rawItems) {
        if (raw is! Map<String, dynamic>) continue;
        final itemId = _asInt(raw['item_id']);
        final numOrdered = _asInt(raw['num_ordered']);
        if (itemId == null || numOrdered == null) continue;

        final fallbackName =
            _itemNameFromCurrentOrders(timeBand, itemId) ??
            GlobalMenuCache.items[itemId]?.name ??
            'Item #$itemId';
        final itemName = raw['item_name'] is String
            ? raw['item_name'] as String
            : fallbackName;

        updatedItems.add(
          ActiveOrderItem(
            itemId: itemId,
            itemName: itemName,
            numOrdered: numOrdered,
          ),
        );
      }

      final next = Map<String, List<ActiveOrderItem>>.from(orders);
      next[timeBand] = updatedItems;
      onOrdersUpdated(next);
    } catch (e) {
      debugPrint('[orders-sse] unable to parse event payload: $e');
    }
  }

  String? _itemNameFromCurrentOrders(String timeBand, int itemId) {
    final items = orders[timeBand];
    if (items == null) return null;
    for (final item in items) {
      if (item.itemId == itemId) return item.itemName;
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  void onOrdersUpdated(Map<String, List<ActiveOrderItem>> fetchedOrders) {
    if (!mounted) return;
    setState(() {
      orders = _sortOrdersMap(fetchedOrders);
    });
  }

  Map<String, List<ActiveOrderItem>> _sortOrdersMap(
    Map<String, List<ActiveOrderItem>> fetchedOrders,
  ) {
    final sortedKeys = fetchedOrders.keys.toList()
      ..sort((a, b) {
        if (a == b) return 0;
        if (a == "Instant") return 1;
        if (b == "Instant") return -1;
        try {
          final format = DateFormat("hh:mm a");
          final timeA = format.parse(a);
          final timeB = format.parse(b);
          return timeA.compareTo(timeB);
        } catch (e) {
          return a.compareTo(b);
        }
      });
    return {for (var key in sortedKeys) key: fetchedOrders[key]!};
  }

  @override
  void onOrderFetchError(dynamic error) {
    debugPrint("OrdersState Fetch Error: $error");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            triggerOrderFetch();
          },
          backgroundColor: theme.colorScheme.secondary,
          label: Text(
            AppLocalizations.of(context)!.refresh,
            style: theme.textTheme.labelLarge,
          ),
          icon: const Icon(Icons.refresh),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isSlowNetwork) _buildSlowNetworkBanner(theme),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.delivery_time,
              style: theme.textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderTime = orders.keys.elementAt(index);
                return generateList(orderTime);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlowNetworkBanner(ThemeData theme) {
    final metricLabel = _latestLatencyMetricMs != null
        ? 'Latency signal: $_latestLatencyMetricMs ms'
        : 'Latency signal: unavailable';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.16),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.network_check, color: Colors.orangeAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Network appears slow. Live order updates may be delayed. $metricLabel',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget generateList(String orderTime) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 600
            ? 600
            : MediaQuery.of(context).size.width * 0.9,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.timing} ${(orderTime == "Instant") ? AppLocalizations.of(context)!.instant : orderTime}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...List.generate(orders[orderTime]!.length, (i) {
                  final item = orders[orderTime]![i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          "x${item.numOrdered}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
