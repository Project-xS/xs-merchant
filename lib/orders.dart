import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/l10n/app_localizations.dart';

class Orders extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  const Orders(this.portrait, this.isTamil, {super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with AutoFetchMixin{
  // Map<int, Map<String, dynamic>> orders = {
  //   1: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken', 'Rasam'], 'time':'07:00', 'count': [10,500,20,70]},
  //   2: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken', 'Sambar'], 'time':'11:15', 'count': [30,500,20,90]},
  //   3: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken', 'Rice'], 'time':'12:00', 'count': [60,500,20,10]},
  //   4: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken', 'Sambar'], 'time':'3:00', 'count': [90,500,20,90]},
  // };
  Map<int, Map<String, dynamic>> orders = {};

  @override
  void fetchData(){
    getorders();
  }


  void getorders() async{
    if(!mounted) return;
    try{
    final response = await http.get(Uri.parse("https://proj-xs.fly.dev/orders"));
    if(response.statusCode == 200){
      // debugPrint("${jsonDecode(response.body)}");
      Map<String, dynamic> decodedJson = jsonDecode(response.body);
      List<dynamic> dataList = decodedJson["data"];
      setState(() {
        // String time = decodedJson["time"];
        for (var order in dataList){
        orders[order["item_id"]] = {
          "name": order["item_name"],
          "count": order["num_ordered"],
          // "time": time
        };
        }
      });
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Items Fetched Successfully")));
    }
    }
    else{
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Fetching Order Items: ${response.statusCode}")));
    }
    }
    }
    on Exception catch (e){
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
    }
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        getorders();
      },
      backgroundColor: Colors.cyan,
      label: Text(AppLocalizations.of(context)!.refresh, style: TextStyle(fontWeight: (widget.isTamil)?FontWeight.w900:FontWeight.w600, color: Colors.black)),
      icon: Icon(Icons.refresh, color: Colors.black)) ,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.00, horizontal: ((widget.portrait)?(MediaQuery.of(context).size.width)/7:(MediaQuery.of(context).size.width)/3)),
            child: Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.order_items, style: TextStyle(fontSize: 22, fontWeight:(widget.isTamil)?FontWeight.w600:FontWeight.w500)),
                    SizedBox(height: 10),
                    Column(
                      children: List.generate(orders.length, (i) {
                        int orderId = orders.keys.elementAt(i);
                        return Column(
                          children: [
                            Divider(thickness: 2, color: Color.fromRGBO(75, 75, 75, 1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${i+1}. " "${orders[orderId]?['name']}", style: TextStyle(fontSize: 20)),
                                Text("x ${orders[orderId]?['count']}", style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                    Divider(thickness: 2, color: Color.fromRGBO(75, 75, 75, 1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}