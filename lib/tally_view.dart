import 'package:flutter/material.dart';
import 'package:merchant/main.dart';

class TallyView extends StatefulWidget {
  final int canteenId;
  final bool isTamil;
  final Map<int, Map<String, dynamic>> bill;
  final List<int> searchitems;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;

  const TallyView(this.canteenId, this.isTamil, this.searchitems, this.bill, this.onBillUpdate, {super.key});

  @override
  State<TallyView> createState() => _TallyViewState();
}

class _TallyViewState extends State<TallyView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemIds = widget.searchitems.isNotEmpty ? widget.searchitems : GlobalMenuCache.availableid.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemIds.length,
      itemBuilder: (context, index) {
        final itemId = itemIds[index];
        final item = GlobalMenuCache.items[itemId];
        if (item == null) return const SizedBox.shrink();
        final bool isEven = index % 2 == 0;
        final Color? rowColor = isEven ? const Color.fromARGB(25, 158, 158, 158) : null;
        final count = widget.bill[itemId]?['count'] ?? 0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: rowColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${item['price']}",
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton.filled(
                        icon: const Icon(Icons.remove),
                        iconSize: 20,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.error
                        ),
                        onPressed: !(widget.bill.containsKey(itemId))
                            ? null
                            : () {
                                setState(() {
                                  int currentCount = widget.bill[itemId]?['count'] ?? 0;
                                  if (currentCount - 1 <= 0) {
                                    widget.bill.remove(itemId);
                                  } else {
                                    widget.bill[itemId]!['count'] = currentCount - 1;
                                    widget.bill[itemId]!['price'] = item['price'] * (currentCount - 1);
                                  }
                                  widget.onBillUpdate(widget.bill);
                                });
                              },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          count.toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary
                        ),
                        onPressed: () {
                          setState(() {
                            int currentCount = widget.bill[itemId]?['count'] ?? 0;
                            if (currentCount == 0) {
                              widget.bill[itemId] = {
                                'name': item['name'],
                                'price': item['price'],
                                'count': 1,
                                'id': itemId,
                              };
                            } else {
                              widget.bill[itemId]!['count'] = currentCount + 1;
                              widget.bill[itemId]!['price'] = item['price'] * (currentCount + 1);
                            }
                            widget.onBillUpdate(widget.bill);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
