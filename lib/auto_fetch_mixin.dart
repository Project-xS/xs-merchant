import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/models/menu_item.dart';
import 'package:merchant/models/order_models.dart';
import 'package:merchant/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:merchant/common/notification_service.dart';

mixin AutoFetchMixin<T extends StatefulWidget> on State<T> {
  Timer? timer;
  Map<int, MenuItem> fetchedItems = {};
  LinkedHashSet<int> fetchedAid = LinkedHashSet();
  LinkedHashSet<int> fetchedNaid = LinkedHashSet();
  Map<String, Map<String, dynamic>> orders = {};
  int sort = 1;
  int get canteenIdToFetch;
  bool get enableAutoFetchTimer => true;
  Duration get autoFetchInterval => const Duration(minutes: 1, seconds: 30);

  @override
  void initState() {
    if (enableAutoFetchTimer && timer?.isActive == null) {
      startAutoFetch();
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startAutoFetch() {
    timer?.cancel();
    timer = Timer.periodic(autoFetchInterval, (timer) {
      debugPrint("Timer over, fetching");
      fetchAndCacheAndNotify();
    });
  }

  bool isLoading = false;

  // uncomment below for caching
  Future<void> fetchAndCacheAndNotify() async {
    if (!mounted) return;

    // Only set loading to true if we don't have items yet (initial load)
    // or if we want to show loading on refresh.
    // For auto-fetch in background, maybe we don't want full screen shimmer?
    // But user reported "no spinner", implying they want to see loading.
    // Let's set it if the cache is empty.
    if (GlobalMenuCache.items.isEmpty) {
      setState(() {
        isLoading = true;
      });
    }

    final url = "/menu/items";
    // final cacheManager = JsonCacheManager.instance;
    // dynamic combinedJson;

    try {
      if (kDebugMode) {
        debugPrint('[menu] GET $url');
      }
      final response = await ApiClient.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        debugPrint("Fetched: ${decodedJson.toString()}");
        List<dynamic>? dataList = decodedJson["data"];
        if (!mounted) return;

        if (dataList == null) {
          debugPrint("Error: 'data' field is null in response");
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          return;
        }

        Map<int, MenuItem> tempFetchedItems = {};
        LinkedHashSet<int> tempFetchedAid = LinkedHashSet();
        LinkedHashSet<int> tempFetchedNaid = LinkedHashSet();

        for (var item1 in dataList) {
          try {
            final menuItem = MenuItem.fromJson(item1);
            if (menuItem.available == true &&
                (menuItem.stock == -1 || menuItem.stock >= 1)) {
              tempFetchedAid.add(menuItem.id);
            } else {
              tempFetchedNaid.add(menuItem.id);
            }
            tempFetchedItems[menuItem.id] = menuItem;
          } catch (itemError) {
            debugPrint(
              "Error parsing individual item: $itemError, item data: $item1",
            );
          }
        }
        if (!mounted) return;

        // Perform stock check and notification
        try {
          final l10n = AppLocalizations.of(context);
          final notificationProvider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );

          await NotificationService.checkAndNotifyStock(
            tempFetchedItems.values.toList(),
            titleBuilder: l10n != null
                ? (item) => l10n.stock_alert_title
                : null,
            bodyBuilder: l10n != null
                ? (item) => l10n.stock_alert_body(item.name, item.stock)
                : null,
            onNotify: (item, title, body) {
              notificationProvider.addNotification(
                InAppNotification(
                  id: item.id,
                  title: title,
                  message: body,
                  timestamp: DateTime.now(),
                ),
              );
            },
            onStockHealthy: (item) {
              notificationProvider.removeNotification(item.id);
            },
          );
        } catch (notifError) {
          debugPrint("Notification service error: $notifError");
        }

        setState(() {
          fetchedItems = tempFetchedItems;
          fetchedAid = tempFetchedAid;
          fetchedNaid = tempFetchedNaid;

          GlobalMenuCache.items = fetchedItems;
          GlobalMenuCache.availableid = fetchedAid;
          GlobalMenuCache.navailableid = fetchedNaid;

          applySorting(
            GlobalMenuCache.items,
            sort,
            GlobalMenuCache.availableid,
            GlobalMenuCache.navailableid,
          );
          isLoading = false;
        });
      } else {
        if (mounted && Scaffold.maybeOf(context) != null) {
          final msg = ApiClient.tryExtractErrorMessage(response);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg ?? "Error Getting Items : ${response.statusCode}",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        if (kDebugMode) {
          debugPrint(
            '[menu] non-200: ${response.statusCode} body=${response.body}',
          );
        }

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      if (mounted && Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (kDebugMode) debugPrint('[menu] exception: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  dynamic applySorting(
    Map<int, MenuItem> dataToSort,
    int s,
    LinkedHashSet<int> availableId,
    LinkedHashSet<int> navailableId,
  ) {
    List<int> avail = availableId.toList();
    List<int> navail = navailableId.toList();

    int Function(int, int) getComparator(int sortOption) {
      return (idA, idB) {
        MenuItem? itemA = dataToSort[idA];
        MenuItem? itemB = dataToSort[idB];

        if (itemA == null || itemB == null) return 0;

        if (sortOption == 1) {
          return itemA.name
              .toLowerCase()
              .replaceAll(' ', '')
              .compareTo(itemB.name.toLowerCase().replaceAll(' ', ''));
        } else if (sortOption == 2) {
          return itemB.price.compareTo(itemA.price);
        } else if (sortOption == 3) {
          int getPriority(MenuItem item) {
            if (item.stock == 0 && item.available == true) return 0;
            if (item.stock == 0 && item.available == false) return 1;
            if (item.stock == -1) return 3;
            return 2;
          }

          int priorityA = getPriority(itemA);
          int priorityB = getPriority(itemB);

          if (priorityA != priorityB) {
            return priorityA.compareTo(priorityB);
          }
          if (priorityA == 2) {
            return itemA.stock.compareTo(itemB.stock);
          }
          return 0;
        }
        return 0;
      };
    }

    avail.sort(getComparator(s));
    navail.sort(getComparator(s));

    if (mounted) {
      setState(() {
        fetchedAid = LinkedHashSet<int>.from(avail);
        fetchedNaid = LinkedHashSet<int>.from(navail);
        GlobalMenuCache.items = fetchedItems;
        GlobalMenuCache.availableid = fetchedAid;
        GlobalMenuCache.navailableid = fetchedNaid;
        sort = s;
      });
    }
  }
}

mixin OrderFetchMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;

  int get canteenIdForOrders;
  bool get triggerInitialOrderFetch => true;
  bool get enableOrderAutoFetchTimer => true;
  Duration get orderAutoFetchInterval =>
      const Duration(minutes: 1, seconds: 30);
  void onOrdersUpdated(Map<String, List<ActiveOrderItem>> orders);
  void onOrderFetchError(dynamic error);

  @override
  void initState() {
    super.initState();
    if (triggerInitialOrderFetch) {
      triggerOrderFetch();
    }
    if (enableOrderAutoFetchTimer) {
      _startOrderAutoFetchTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrderAutoFetchTimer() {
    _timer = Timer.periodic(orderAutoFetchInterval, (timer) {
      triggerOrderFetch();
    });
  }

  Future<void> triggerOrderFetch() async {
    final int id = canteenIdForOrders;
    if (kDebugMode) debugPrint("Fetching orders for canteen ID: $id");
    try {
      final response = await ApiClient.get(ApiConstants.orders);

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        Map<String, dynamic> dataList = decodedJson["data"];

        Map<String, List<ActiveOrderItem>> fetchedOrders = {};
        for (String time in dataList.keys) {
          final items = (dataList[time] as List<dynamic>)
              .map((e) => ActiveOrderItem.fromJson(e as Map<String, dynamic>))
              .toList();
          fetchedOrders[time] = items;
        }
        onOrdersUpdated(fetchedOrders);
        // No success toast for order fetch; keep UI quiet on background refresh.
      } else {
        if (mounted && Scaffold.maybeOf(context) != null) {
          final msg = ApiClient.tryExtractErrorMessage(response);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg ?? "Error Fetching Order Details: ${response.statusCode}",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        onOrderFetchError("Failed to fetch orders: ${response.statusCode}");
      }
    } on Exception catch (e) {
      if (mounted && Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      onOrderFetchError(e);
    }
  }
}
