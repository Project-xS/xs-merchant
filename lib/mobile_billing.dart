import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/l10n/app_localizations.dart';

import 'package:merchant/tally_view.dart';
import 'package:merchant/billing/bill_summary_view.dart';

class MobileBilling extends StatefulWidget {
  final String name;
  final bool isTamil;
  final int canteenId;
  const MobileBilling(this.name, this.isTamil, this.canteenId, {super.key});

  @override
  State<MobileBilling> createState() => _MobileBillingState();
}

class _MobileBillingState extends State<MobileBilling> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focus = FocusNode();
  Map<int, Map<String, dynamic>> bill = {};
  List<int> searchitems = [];

  void updateBillItems(Map<int, Map<String, dynamic>> updatedBill) {
    setState(() {
      bill = updatedBill;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.billing)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SearchBar(
                controller: controller,
                backgroundColor: WidgetStateProperty.all(
                  theme.colorScheme.surfaceContainerHighest,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 10),
                ),
                leading: Icon(Icons.search, color: theme.colorScheme.primary),
                hintText: AppLocalizations.of(context)!.search_name,
                hintStyle: WidgetStatePropertyAll(
                  TextStyle(color: theme.colorScheme.primary),
                ),
                onChanged: (value) async {
                  if (value.isEmpty) {
                    setState(() => searchitems.clear());
                    return;
                  }
                  await Future.delayed(const Duration(milliseconds: 300));
                  try {
                    final response = await ApiClient.get(
                      '/search/${Uri.encodeComponent(value)}',
                    );
                    if (response.statusCode != 200) {
                      final msg =
                          ApiClient.tryExtractErrorMessage(response) ??
                          'Search failed: ${response.statusCode}';
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      return;
                    }
                    Map<String, dynamic> decodedJson = jsonDecode(
                      response.body,
                    );
                    List<dynamic> idList = decodedJson["data"];
                    setState(() {
                      searchitems.clear();
                      for (var i in idList) {
                        int? itemId = i["item_id"] is int
                            ? i["item_id"]
                            : int.tryParse(i["item_id"].toString());
                        if (itemId != null && i["is_available"] == true) {
                          searchitems.add(itemId);
                        }
                      }
                    });
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                trailing: [
                  IconButton(
                    icon: Icon(Icons.clear, color: theme.colorScheme.primary),
                    onPressed: () {
                      setState(() {
                        controller.clear();
                        searchitems.clear();
                        focus.requestFocus();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: TallyView(
                  widget.canteenId,
                  widget.isTamil,
                  searchitems,
                  bill,
                  updateBillItems,
                ),
              ),
            ),
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 300, // Fixed height for mobile view bill summary
                  child: BillSummaryView(
                    bill: bill,
                    onBillUpdate: updateBillItems,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
