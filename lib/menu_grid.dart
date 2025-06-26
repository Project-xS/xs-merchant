import 'dart:collection';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/main.dart';

class BillMenu extends StatefulWidget {
  final int canteenId;
  final bool isTamil;
  final Map<int, Map<String, dynamic>> bill;
  final List<int> searchitems;
  final Function(LinkedHashSet<int>) onSearchUpdate;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;
  const BillMenu(this.canteenId, this.isTamil, this.searchitems, this.onSearchUpdate, this.bill, this.onBillUpdate, {super.key});

  @override
  State<BillMenu> createState() => Billmenu();
}

class Billmenu extends State<BillMenu> with AutoFetchMixin<BillMenu>{

  Map<int, Map<String, dynamic>> itemData = {};
  LinkedHashSet<int> availableIdData = LinkedHashSet();
  LinkedHashSet<int> notAvailableIdData = LinkedHashSet();

  @override
  int get canteenIdToFetch => widget.canteenId;

  @override
  void onDataUpdated(Map<int, Map<String, dynamic>> items, LinkedHashSet<int> available, LinkedHashSet<int> notAvailable) {
    setState(() {
      itemData = items;
      availableIdData = available;
      notAvailableIdData = notAvailable;
    });
  }

  Map<int, Map<String, dynamic>> get item => itemData;
  Set<int> get availableid => availableIdData;
  Set<int> get navailableid => notAvailableIdData;
  Map<int, Map<String, dynamic>> get items => itemData;

  @override
  void onFetchError(dynamic error) {
    debugPrint("MenupageState Fetch Error: $error");
  }

  @override
  void initState() {
    // if(GlobalMenuCache.items.isEmpty || widget.searchitems.isEmpty){
    //   fetchAndCacheAndNotify(widget.canteenId);
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 6;
        if (Platform.isAndroid) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 750) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 1300) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth < 1500) {
          crossAxisCount = 5;
        }
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (widget.searchitems.isNotEmpty)?widget.searchitems.length:GlobalMenuCache.availableid.length,
          itemBuilder: (BuildContext context, int index) {
            int itemId = (widget.searchitems.isNotEmpty)?widget.searchitems.elementAt(index):GlobalMenuCache.availableid.elementAt(index);
            return GridTile(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Flexible(
                          child: AspectRatio(
                            aspectRatio: 1.6,
                            child: Icon(Icons.fastfood, size: 40), 
                          ),
                        ),
                        Text(
                          GlobalMenuCache.items[itemId]?['name'] ?? "Unknown Item",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isTamil ? FontWeight.w600 : FontWeight.bold,
                            color: _getStockColor(GlobalMenuCache.items[itemId]?['stocks'], Colors.white),
                          ),
                        ),
                        Text(
                          "₹${GlobalMenuCache.items[itemId]?['price'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isTamil ? FontWeight.w600 : FontWeight.bold,
                            color: _getStockColor(GlobalMenuCache.items[itemId]?['stocks'], Colors.white),
                          ),
                        ),
                        Text(
                          "Stock: ${GlobalMenuCache.items[itemId]?['stocks'] == -1 ? 'Unlimited' : GlobalMenuCache.items[itemId]?['stocks'].toString()}",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isTamil ? FontWeight.w600 : FontWeight.bold,
                            color: _getStockColor(GlobalMenuCache.items[itemId]?['stocks'], Colors.white),
                          ),
                        ),
                        const SizedBox(height: 5, width: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [                        
                          ElevatedButton(                            
                            onPressed: !(widget.bill.containsKey(itemId))? null :(){
                              setState(() {                                  
                              if (widget.bill[itemId]?['count']-1 <= 0){
                                if (widget.bill.keys.contains(itemId)){
                                  widget.bill.removeWhere((key, value) => key == itemId);
                                  widget.onBillUpdate(widget.bill);
                                }
                                widget.bill.remove(itemId);
                                debugPrint(widget.bill.toString());
                              }
                              else{
                                widget.bill[itemId] = {
                                  'name': GlobalMenuCache.items[itemId]?['name'],
                                  'price': GlobalMenuCache.items[itemId]?['price']*(widget.bill[itemId]?['count'] - 1),
                                  'count': widget.bill[itemId]?['count']-1,
                                  'id': itemId,
                                };
                                widget.onBillUpdate(widget.bill);
                                debugPrint(widget.bill.toString());
                                }
                            });
                            } ,
                            child: Icon(Icons.remove)),
                            const SizedBox(height: 5, width: 10),
                            Text(widget.bill[itemId]?['count'].toString() ?? "0"),
                            const SizedBox(height: 5, width: 10),
                            ElevatedButton(
                              onPressed: (){
                                setState(() {
                                if(widget.bill.values.where((element) => element['id'] == itemId).isNotEmpty){                                  
                                  widget.bill[itemId] = {
                                  'name': GlobalMenuCache.items[itemId]?['name'],
                                  'price': GlobalMenuCache.items[itemId]?['price']*(widget.bill[itemId]?['count'] + 1),
                                  'count': widget.bill[itemId]?['count'] + 1,
                                  'id': itemId,
                                };
                                widget.onBillUpdate(widget.bill);
                                }
                                else{
                                widget.bill[itemId] = {
                                  'name': GlobalMenuCache.items[itemId]?['name'],
                                  'price': GlobalMenuCache.items[itemId]?['price'],
                                  'count': 1,
                                  'id': itemId,
                                };
                                widget.onBillUpdate(widget.bill);
                                debugPrint(widget.bill.toString());
                                }
                              });
                              }, 
                              child: Icon(Icons.add)),
                        ],)
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStockColor(int? stocks, Color defaultColor) {
    if (stocks == -1 || stocks == null || stocks >= 300) return defaultColor;
    if (stocks > 0) return Colors.limeAccent;
    return Colors.red;
  }
}