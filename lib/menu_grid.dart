import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/login.dart';

class BillMenu extends StatefulWidget {
  final int canteenid;
  final bool isTamil;
  final Map<int, Map<String, dynamic>> bill;
  final List<int> searchitems;
  final Function(List<int>) onSearchUpdate;
  final Function(Map<int, Map<String, dynamic>>) onBillUpdate;
  const BillMenu(this.canteenid, this.isTamil, this.searchitems, this.onSearchUpdate, this.bill, this.onBillUpdate, {super.key});

  @override
  State<BillMenu> createState() => Billmenu();
}

class Billmenu extends State<BillMenu> {

  @override
  void initState() {
    if(items.isEmpty){
      getallitems(widget.canteenid);
    }
    super.initState();
  }

  final isPortrait = Platform.isAndroid;
  Map<int, Map<String, dynamic>> item = {};
  Map<int, Map<String, dynamic>> get items {
  var sortedEntries = item.entries.toList();
  sortedEntries.sort((a, b) => a.value["name"].toLowerCase().replaceAll(' ', '').compareTo(b.value["name"].toLowerCase().replaceAll(' ', '')));
   return {for (var entry in sortedEntries) entry.key: entry.value};
  }

  Set<int> get availableid =>
    items.entries.where((entry) => entry.value['available'] == true && (entry.value['stocks'] == -1 || entry.value['stocks'] >= 1)).map((entry) => entry.key).toSet();

  Set<int> get navailableid =>
    items.entries.where((entry) => entry.value['available'] == false || (entry.value['stocks'] != -1 && entry.value['stocks'] == 0)).map((entry) => entry.key).toSet();

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
          itemCount: (widget.searchitems.isNotEmpty)?widget.searchitems.length:availableid.length,
          itemBuilder: (BuildContext context, int index) {
            int itemId = (widget.searchitems.isNotEmpty)?widget.searchitems.elementAt(index):availableid.elementAt(index);
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
                          items[itemId]?['name'] ?? "Unknown Item",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isTamil ? FontWeight.w600 : FontWeight.bold,
                            color: _getStockColor(items[itemId]?['stocks'], Colors.white),
                          ),
                        ),
                        Text(
                          "₹${items[itemId]?['price'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isTamil ? FontWeight.w600 : FontWeight.bold,
                            color: _getStockColor(items[itemId]?['stocks'], Colors.white),
                          ),
                        ),
                        Text(
                          "Stock: ${items[itemId]?['stocks'] == -1 ? 'Unlimited' : items[itemId]?['stocks'].toString()}",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: widget.isTamil ? FontWeight.w600 : FontWeight.bold,
                            color: _getStockColor(items[itemId]?['stocks'], Colors.white),
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
                                  'name': items[itemId]?['name'],
                                  'price': items[itemId]?['price']*(widget.bill[itemId]?['count'] - 1),
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
                                  'name': items[itemId]?['name'],
                                  'price': items[itemId]?['price']*(widget.bill[itemId]?['count'] + 1),
                                  'count': widget.bill[itemId]?['count'] + 1,
                                  'id': itemId,
                                };
                                widget.onBillUpdate(widget.bill);
                                }
                                else{
                                widget.bill[itemId] = {
                                  'name': items[itemId]?['name'],
                                  'price': items[itemId]?['price'],
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
  void getallitems(int id) async{
  if (!mounted) return;
  try{
  final response = await http.get(Uri.parse("https://proj-xs.fly.dev/canteen/$canteenId/items"));
      if (response.statusCode == 200){
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        List<dynamic> dataList = decodedJson["data"];
        if (mounted){
        setState(() {
          item.clear();
          for (var item1 in dataList) {
            item[item1["item_id"]] = {
              "name": item1["name"],
              "price": item1["price"],
              "is_veg": item1["is_veg"],
              "available": item1["is_available"],
              "stocks": item1["stock"]
            };
          }
          debugPrint(item.toString());
          if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Fetched Successfully"), backgroundColor: Colors.cyanAccent));
          }
    });
  }
}
else{
  if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Getting Items : ${response.statusCode}"), backgroundColor: Colors.redAccent));
  }}
  } on Exception catch (e){
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e"), backgroundColor: Colors.redAccent));
  }
  }
  }
}

