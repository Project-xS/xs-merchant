import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';

import 'package:merchant/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchant/history/history_order_card.dart';
import 'package:merchant/history/verification_dialog.dart';
import 'package:merchant/history/qr_scan_dialog.dart';

class OrderHistory extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const OrderHistory(this.portrait, this.isTamil, this.canteenId, {super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory>
    with AutomaticKeepAliveClientMixin {
  Map<int, Map<String, dynamic>> orderhistory = {};

  List<int> searchResults = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
    _clearOrderHistoryIfNewDay();
  }

  Set<int> get deliverlater => orderhistory.entries
      .where((entry) => entry.value['submitted'] == null)
      .map((entry) => entry.key)
      .toSet();

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final orderHistoryString = prefs.getString('orderHistory');
    if (orderHistoryString != null && mounted) {
      setState(() {
        Map<String, dynamic> decoded = jsonDecode(orderHistoryString);
        orderhistory = decoded.map(
          (key, value) =>
              MapEntry(int.parse(key), Map<String, dynamic>.from(value)),
        );
      });
    }
  }

  Future<void> _saveOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, Map<String, dynamic>> deliverlaterOrders = Map.fromEntries(
      orderhistory.entries.where((entry) => entry.value['submitted'] == null),
    );

    final encoded = deliverlaterOrders.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    final orderHistoryString = json.encode(encoded);

    await prefs.setString('orderHistory', orderHistoryString);
  }

  void _clearOrderHistoryIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    String lastClearedDate = prefs.getString('lastClearedDate') ?? '';
    String today = DateTime.now().toIso8601String().split("T")[0];
    if (lastClearedDate != today) {
      if (mounted) {
        setState(() {
          orderhistory.clear();
        });
      }
      await prefs.remove('orderHistory');
      await prefs.setString('lastClearedDate', today);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cleared yesterday's order details successfully"),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    }
  }

  void search(String query) {
    setState(() {
      searchResults = [];
      if (query.isNotEmpty) {
        int? orderId = int.tryParse(query);
        if (orderId != null && orderhistory.containsKey(orderId)) {
          searchResults.add(orderId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    TextEditingController controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 900 ? 720.0 : double.infinity;

    Widget alignSection(Widget child) {
      return Align(
        alignment: Alignment.center,
        child: SizedBox(width: contentWidth, child: child),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  alignSection(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Verification",
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Scan a QR code or enter RFID/User ID to verify an order.",
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Verify Order",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Use QR scanning when available. On PC, use a hardware scanner (acts like keyboard input).",
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: qrVerification,
                                      icon: const Icon(Icons.qr_code_scanner),
                                      label: const Text("Scan QR"),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: orderverfication,
                                      icon: const Icon(Icons.badge),
                                      label: const Text("Enter RFID / ID"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Deliver Later Queue",
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Orders saved for later delivery appear here.",
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        SearchBar(
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 15.00),
                          ),
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.search,
                          hintText: AppLocalizations.of(context)!.s_order,
                          leading: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5.00,
                              horizontal: 12.00,
                            ),
                            child: Icon(
                              Icons.search,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          trailing: [
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.clear();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.done),
                              onPressed: () {
                                search(controller.text);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.restart_alt),
                              onPressed: () {
                                setState(() {
                                  searchResults.clear();
                                  buildSearchList([]);
                                });
                              },
                            ),
                            const SizedBox(width: 10.00),
                          ],
                          onChanged: (value) {
                            String filteredValue = value.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            if (value != filteredValue) {
                              controller.value = TextEditingValue(
                                text: filteredValue,
                                selection: TextSelection.collapsed(
                                  offset: filteredValue.length,
                                ),
                              );
                            }
                          },
                          onSubmitted: search,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildSearchList(searchResults),
        ],
      ),
    );
  }

  SliverList buildSearchList(List<int> searchResults) {
    final keys = searchResults.isEmpty ? deliverlater.toList() : searchResults;
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (keys.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text("No deliver-later orders right now"),
            ),
          );
        }
        final orderId = keys[index];
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: HistoryOrderCard(
              orderId: orderId,
              orderData: orderhistory[orderId]!,
            ),
          ),
        );
      }, childCount: keys.isEmpty ? 1 : keys.length),
    );
  }

  void markdelivered(
    bool submit,
    int orderId, {
    bool showSuccessSnackBar = true,
  }) async {
    try {
      final action = submit ? 'delivered' : 'cancelled';
      final response = await ApiClient.put(
        ApiConstants.orderAction(orderId, action),
      );
      if (response.statusCode == 200) {
        if (mounted && showSuccessSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Order $orderId ${(submit) ? "Delivered" : "Cancelled"} Successfully",
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error Submiting order : ${response.statusCode}"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void orderverfication() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VerificationDialog(
          isPortrait: widget.portrait,
          canteenId: widget.canteenId,
          onOrderFetched: (orderId, data) {
            setState(() {
              orderhistory[orderId] = data;
              _saveOrderHistory();
            });
          },
          onMarkDelivered: (submit, orderId) {
            markdelivered(submit, orderId);
            // Clear search results to refresh view if needed
            setState(() {
              searchResults.clear();
            });
          },
        );
      },
    );
  }

  void qrVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QrScanDialog(
          onDeliver: (orderId) {
            markdelivered(true, orderId, showSuccessSnackBar: false);
            setState(() {
              searchResults.clear();
            });
          },
        );
      },
    );
  }
}
