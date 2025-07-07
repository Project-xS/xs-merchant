import 'dart:collection';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/main.dart';
import 'package:merchant/menupage.dart';

int crossAxisCount = 6;

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

  Map<int, Map<String, dynamic>> get item => itemData;
  Set<int> get availableid => availableIdData;
  Set<int> get navailableid => notAvailableIdData;
  Map<int, Map<String, dynamic>> get items => itemData;

  @override
  void initState() {
    if((timer == null || !timer!.isActive) && GlobalMenuCache.items.isEmpty){
      fetchAndCacheAndNotify(widget.canteenId);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        crossAxisCount = 6;
        if (constraints.maxWidth < 580) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 650) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth < 830) {
          crossAxisCount = 5;
        }
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: (crossAxisCount == 3)?0.59:(crossAxisCount == 4)?0.5:(constraints.maxWidth < 730 && crossAxisCount == 5)?0.45:(constraints.maxWidth < 900 && crossAxisCount == 6)?0.45:0.5,
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
                      color: const Color.fromARGB(45, 0, 234, 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        SizedBox(height:5),
                        MenupageState().showImage(itemId),
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
                        StatefulBuilder(
                          builder: (context, stateset) {
                            int count = widget.bill[itemId]?['count'] ?? 0;
                            return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [                        
                            ElevatedButton(              
                              style: ButtonStyle(
                                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                fixedSize: WidgetStatePropertyAll(Size.square(40)),
                                minimumSize: WidgetStatePropertyAll(Size.square(40))
                                ),              
                              onPressed: !(widget.bill.containsKey(itemId))? null :(){
                                stateset(() {                                  
                                if (count - 1 <= 0){
                                  if (widget.bill.keys.contains(itemId)){
                                    widget.bill.removeWhere((key, value) => key == itemId);
                                    widget.onBillUpdate(widget.bill);
                                  }
                                  widget.bill.remove(itemId);
                                  debugPrint(widget.bill.toString());
                                }
                                else{
                                  count -= 1;
                                  widget.bill[itemId] = {
                                    'name': GlobalMenuCache.items[itemId]?['name'],
                                    'price': GlobalMenuCache.items[itemId]?['price']*count,
                                    'count': count,
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
                                style: ButtonStyle(
                                  padding: WidgetStatePropertyAll(EdgeInsets.zero),
                                  fixedSize: WidgetStatePropertyAll(Size.square(40)),
                                  minimumSize: WidgetStatePropertyAll(Size.square(40))
                                ),
                                onPressed: (){
                                  stateset(() {
                                  if(widget.bill.values.where((element) => element['id'] == itemId).isNotEmpty){
                                    count += 1;                                
                                    widget.bill[itemId] = {
                                    'name': GlobalMenuCache.items[itemId]?['name'],
                                    'price': GlobalMenuCache.items[itemId]?['price']*count,
                                    'count': count,
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
                          ],);
                          }
                        )
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
    if (stocks == -1 || stocks == null || stocks >= 300) return Colors.white;
    if (stocks > 0) return Colors.limeAccent;
    return Colors.red;
  }
}