import 'dart:collection';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/main.dart';
import 'package:merchant/menupage.dart';

class BillMenu extends StatefulWidget {
  final int canteenId;
  final bool isTamil;
  final Map<int, Map<String, dynamic>> bill;
  final List<int> searchitems;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;
  const BillMenu(this.canteenId, this.isTamil, this.searchitems, this.bill, this.onBillUpdate, {super.key});

  @override
  State<BillMenu> createState() => Billmenu();
}

class Billmenu extends State<BillMenu> with AutoFetchMixin<BillMenu> {
  Map<int, Map<String, dynamic>> itemData = {};
  LinkedHashSet<int> availableIdData = LinkedHashSet();
  LinkedHashSet<int> notAvailableIdData = LinkedHashSet();

  @override
  int get canteenIdToFetch => widget.canteenId;

  Map<int, Map<String, dynamic>> get item => itemData;
  Set<int> get availableid => availableIdData;
  Set<int> get navailableid => notAvailableIdData;
  Map<int, Map<String, dynamic>> get items => itemData;

  @override
  void initState() {
    if ((timer == null || !timer!.isActive) && GlobalMenuCache.items.isEmpty) {
      fetchAndCacheAndNotify();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 6;
        if (constraints.maxWidth < 580) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 650) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 830) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth < 1100){
          crossAxisCount = 5;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (widget.searchitems.isNotEmpty)
              ? widget.searchitems.length
              : GlobalMenuCache.availableid.length,
          itemBuilder: (BuildContext context, int index) {
            int itemId = (widget.searchitems.isNotEmpty)
                ? widget.searchitems.elementAt(index)
                : GlobalMenuCache.availableid.elementAt(index);
            final item = GlobalMenuCache.items[itemId];
            if (item == null) return const SizedBox.shrink();

            return BillMenuItemCard(
              itemId: itemId,
              item: item,
              isTamil: widget.isTamil,
              bill: widget.bill,
              onBillUpdate: widget.onBillUpdate,
            );
          },
        );
      },
    );
  }
}

class BillMenuItemCard extends StatefulWidget {
  final int itemId;
  final Map<String, dynamic> item;
  final bool isTamil;
  final Map<int, Map<String, dynamic>> bill;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;

  const BillMenuItemCard({
    super.key,
    required this.itemId,
    required this.item,
    required this.isTamil,
    required this.bill,
    required this.onBillUpdate,
  });

  @override
  State<BillMenuItemCard> createState() => _BillMenuItemCardState();
}

class _BillMenuItemCardState extends State<BillMenuItemCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            child: MenupageState().showImage(widget.itemId, widget.item['available'] ?? false),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color.fromARGB(153, 0, 0, 0),
                    Color.fromARGB(255, 0, 0, 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 0.7, 0.8],
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 20,
            child: SizedBox(
              height: 48,
              child: Image.asset(
                widget.item['is_veg']
                    ? "assets/images/veg.png"
                    : "assets/images/nonveg.png",
                width: 24,
                height: 24,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    widget.item['name'] ?? "Unknown Item",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${widget.item['price'] ?? 'N/A'}",
                        style: TextStyle(
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Stock: ${widget.item['stocks'] == -1 ? '∞' : widget.item['stocks']}",
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                        onPressed: !(widget.bill.containsKey(widget.itemId))
                            ? null
                            : () {
                                setState(() {
                                  int count = widget.bill[widget.itemId]?['count'] ?? 0;
                                  if (count - 1 <= 0) {
                                    if (widget.bill.keys.contains(widget.itemId)) {
                                      widget.bill.removeWhere(
                                          (key, value) => key == widget.itemId);
                                      widget.onBillUpdate(widget.bill);
                                    }
                                  } else {
                                    count -= 1;
                                    widget.bill[widget.itemId] = {
                                      'name': widget.item['name'],
                                      'price': widget.item['price'] * count,
                                      'count': count,
                                      'id': widget.itemId,
                                    };
                                    widget.onBillUpdate(widget.bill);
                                  }
                                });
                              },
                        ),
                    Text(
                      (widget.bill[widget.itemId]?['count'] ?? 0).toString(),
                      style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: theme.colorScheme.primary, size: 28),
                      onPressed: () {
                        setState(() {
                          int count = widget.bill[widget.itemId]?['count'] ?? 0;
                          if (widget.bill.values
                              .where((element) =>
                                  element['id'] == widget.itemId)
                              .isNotEmpty) {
                            count += 1;
                            widget.bill[widget.itemId] = {
                              'name': widget.item['name'],
                              'price': widget.item['price'] * count,
                              'count': count,
                              'id': widget.itemId,
                            };
                            widget.onBillUpdate(widget.bill);
                          } else {
                            widget.bill[widget.itemId] = {
                              'name': widget.item['name'],
                              'price': widget.item['price'],
                              'count': 1,
                              'id': widget.itemId,
                            };
                            widget.onBillUpdate(widget.bill);
                          }
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
