import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auto_fetch_mixin.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

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
        for (var order in dataList){
        orders[order["item_id"]] = {
          "name": order["item_name"],
          "count": order["num_ordered"],
        };
        }
      });
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Items Fetched Successfully")));
    }
    }
    else{
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Received")));
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: ((MediaQuery.of(context).size.width)/4)),
            child: Card(
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Order Items:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
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
                                Text("x${orders[orderId]?['count']}", style: TextStyle(fontSize: 20)),
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


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     floatingActionButton: FloatingActionButton(onPressed: getorders, child: Icon(Icons.add),),
  //     body: Padding(
  //       padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: ((MediaQuery.of(context).size.width)/4)),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Flexible(
  //                 child: ListView.builder(
  //                   padding: EdgeInsets.symmetric(horizontal: 10.0),
  //                   itemCount: 1,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     int orderId = orders.keys.elementAt(index);
  //                     return Align(
  //                       alignment: Alignment.center,
  //                       child: Card(
  //                         margin: EdgeInsets.symmetric(vertical: 8),
  //                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //                         child: Padding(
  //                           padding: EdgeInsets.all(25.0),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               // Row(
  //                                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                 // children: [
  //                                   Text("Order Items:", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w600)),
  //                                   // Row(
  //                                   //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                                   //   children: [
  //                                   //     Text("Timing: ", style: TextStyle(fontSize: 19.00, fontWeight: FontWeight.w600)),
  //                                   //     Text("${orders[orderId]?['time']}", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w700, color: Colors.cyan)),
  //                                   //   ],
  //                                   // ),
  //                               //   ],
  //                               // ),
  //                               SizedBox(height: 10.00),
  //                               // generateList(orderId),

  //                           ]
  //                         )
  //                           )
  //                         ),
  //                     );
  //                     }
  //                   )
  //                 ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget generateList(int orderId) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: [
  //       Column(
  //         children: List.generate(orders[orderId]?['name'].length, (i) {
  //         return Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
  //             Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 SizedBox(width: 5.00),
  //                 // orders[orderId]?['time'][i] ? Icon(Icons.verified, color: Colors.green) : Icon(Icons.cancel, color: Colors.red),
  //                 SizedBox(width: 10.00),
  //                 Expanded(
  //                   child:
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: [
  //                         SizedBox(width: 120, child: Text("${orders[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
  //                         SizedBox(width: 20.00),
  //                         SizedBox(width: 50, child: Text("x${orders[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 40.00,),
  //                     ],
  //                   ),
  //                 ],
  //               );
  //             },
  //           )),
  //         SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color: Color.fromRGBO(75, 75, 75, 1)))
  //     ],
  //   );
  // }
// }
