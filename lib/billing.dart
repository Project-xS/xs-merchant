import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/menu_grid.dart';

import 'package:merchant/tally_view.dart';
import 'package:merchant/billing/bill_summary_view.dart';

class Billing extends StatefulWidget {
  final String name;
  final bool isPortrait;
  final bool isTamil;
  final int canteenId;
  const Billing(
    this.name,
    this.isPortrait,
    this.isTamil,
    this.canteenId, {
    super.key,
  });

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focus = FocusNode();
  Map<int, Map<String, dynamic>> bill = {};
  Map<int, Map<String, dynamic>> item = {};
  List<int> searchitems = [];
  int billIndex = 1;
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    void updateBillItems(updatedBill) {
      setState(() {
        bill = updatedBill;
      });
    }

    final theme = Theme.of(context);

    return Focus(
      autofocus: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          toolbarHeight: 50.00,
          title: Text(
            "Billing:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: SearchBar(
                                controller: controller,
                                backgroundColor: WidgetStateProperty.all(
                                  theme.colorScheme.surfaceContainerHighest,
                                ),
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 10),
                                ),
                                leading: Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary,
                                ),
                                hintText: AppLocalizations.of(
                                  context,
                                )!.search_name,
                                hintStyle: WidgetStatePropertyAll(
                                  TextStyle(color: theme.colorScheme.primary),
                                ),
                                onChanged: (value) async {
                                  if (value.isEmpty) {
                                    setState(() {
                                      searchitems.clear();
                                    });
                                    return;
                                  }
                                  await Future.delayed(
                                    Duration(milliseconds: 300),
                                  );
                                  try {
                                    final response = await ApiClient.get(
                                      '/search/${Uri.encodeComponent(value)}',
                                    );
                                    if (response.statusCode != 200) {
                                      final msg =
                                          ApiClient.tryExtractErrorMessage(
                                            response,
                                          ) ??
                                          'Search failed: ${response.statusCode}';
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(msg),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                      return;
                                    }
                                    Map<String, dynamic> decodedJson =
                                        jsonDecode(response.body);
                                    List<dynamic> idList = decodedJson["data"];
                                    setState(() {
                                      searchitems.clear();
                                      for (var i in idList) {
                                        int? itemId = i["item_id"] is int
                                            ? i["item_id"]
                                            : int.tryParse(
                                                i["item_id"].toString(),
                                              );

                                        if (itemId != null &&
                                            i["is_available"] == true) {
                                          searchitems.add(itemId);
                                        }
                                      }
                                      debugPrint(searchitems.toString());
                                    });
                                  } on Exception catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error performing search : $e",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                  }
                                },
                                trailing: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        controller.clear();
                                        searchitems.clear();
                                        focus.requestFocus(focus);
                                      });
                                    },
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: _isGridView
                                    ? BillMenu(
                                        widget.canteenId,
                                        widget.isTamil,
                                        searchitems,
                                        bill,
                                        updateBillItems,
                                      )
                                    : TallyView(
                                        widget.canteenId,
                                        widget.isTamil,
                                        searchitems,
                                        bill,
                                        updateBillItems,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: BillSummaryView(
                  bill: bill,
                  onBillUpdate: updateBillItems,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
