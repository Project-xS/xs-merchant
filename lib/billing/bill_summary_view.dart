import 'package:flutter/material.dart';
import 'package:merchant/billing/edit_bill_item_dialog.dart';
import 'package:merchant/posprint.dart';

class BillSummaryView extends StatelessWidget {
  final Map<int, Map<String, dynamic>> bill;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;

  const BillSummaryView({
    super.key,
    required this.bill,
    required this.onBillUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int subtotal = 0;
    bill.forEach((key, value) {
      subtotal += (value['price'] ?? 0) as int;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          " Bill: ",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Text(
                "Item",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "Count",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "Price",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(flex: 1, child: SizedBox()),
          ],
        ),
        const Divider(),
        Expanded(
          child: bill.isEmpty
              ? Center(
                  child: Text(
                    "No Items",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: bill.length,
                  itemBuilder: (context, index) {
                    int i = bill.keys.elementAt(index);
                    final item = bill[i]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          Text("${index + 1}. "),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: Text(
                              item['name'],
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item['count'].toString(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "₹${item['price']}",
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return EditBillItemDialog(
                                    item: item,
                                    onUpdate: (quantity) {
                                      final pricePerItem =
                                          (item['price'] / item['count'])
                                              .toInt();
                                      final updatedItem = {
                                        ...item,
                                        'count': quantity,
                                        'price': pricePerItem * quantity,
                                      };
                                      final updatedBill =
                                          Map<int, Map<String, dynamic>>.from(
                                            bill,
                                          );
                                      updatedBill[i] = updatedItem;
                                      onBillUpdate(updatedBill);
                                    },
                                    onDelete: () {
                                      final updatedBill =
                                          Map<int, Map<String, dynamic>>.from(
                                            bill,
                                          );
                                      updatedBill.remove(i);
                                      onBillUpdate(updatedBill);
                                    },
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.edit, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: theme.textTheme.titleLarge),
                  Text(
                    "₹$subtotal",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: bill.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrintBill(bill: bill),
                            ),
                          );
                        },
                  icon: const Icon(Icons.print),
                  label: const Text("Print Bill"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
