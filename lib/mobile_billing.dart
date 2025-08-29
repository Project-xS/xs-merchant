import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/posprint.dart';
import 'package:merchant/tally_view.dart';

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
    int subtotal = 0;
    bill.forEach((key, value) {
      subtotal += (value['price'] ?? 0) as int;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.billing),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SearchBar(
                controller: controller,
                backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
                padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
                leading: Icon(Icons.search, color: theme.colorScheme.primary),
                hintText: AppLocalizations.of(context)!.search_name,
                hintStyle: WidgetStatePropertyAll(TextStyle(color: theme.colorScheme.primary)),
                onChanged: (value) async {
                  if (value.isEmpty) {
                    setState(() => searchitems.clear());
                    return;
                  }
                  await Future.delayed(const Duration(milliseconds: 300));
                  try {
                    final response = await http.get(Uri.parse("https://proj-xs.fly.dev/search/${widget.canteenId}/$value"));
                    Map<String, dynamic> decodedJson = jsonDecode(response.body);
                    List<dynamic> idList = decodedJson["data"];
                    setState(() {
                      searchitems.clear();
                      for (var i in idList) {
                        int? itemId = i["item_id"] is int ? i["item_id"] : int.tryParse(i["item_id"].toString());
                        if (itemId != null && i["is_available"] == true) {
                          searchitems.add(itemId);
                        }
                      }
                    });
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent));
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
                  )
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
                child: Column(
                  children: [
                    Text("Total: ₹$subtotal", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      onPressed: bill.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PrintBill(bill: bill)),
                              );
                            },
                      child: Text("Print Bill", style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}