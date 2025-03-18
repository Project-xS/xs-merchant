import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/menupage.dart';

class Orders extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const Orders(this.portrait, this.isTamil, this.canteenId, {super.key});
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
  Map<String, Map<String, dynamic>> orders = {};

  @override
  void fetchData(){
    getorders();
  }


  void getorders() async{
    if(!mounted) return;
    try{
    final response = await http.get(Uri.parse("https://proj-xs.fly.dev/orders?canteen_id=${widget.canteenId}"));
    if(response.statusCode == 200){
      Map<String, dynamic> decodedJson = jsonDecode(response.body);
      Map<String, dynamic> dataList = decodedJson["data"];
      setState(() {
        orders.clear();
        for (String time in dataList.keys){ 
          List<String> name = [];
          List<int> count = [];
          for (var order in dataList[time]){
            name.add(order["item_name"]);
            count.add(order["num_ordered"]);
          }
          orders[time] = {
            'name': name,
            'count': count,
          };
        }
      });
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Details Fetched Successfully"), backgroundColor: Colors.cyanAccent));
    }
    }
    else{
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Fetching Order Details: ${response.statusCode}"), backgroundColor: Colors.redAccent));
    }
    }
    }
    on Exception catch (e){
      if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e"), backgroundColor: Colors.redAccent));
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: ((widget.portrait)?0:(MediaQuery.of(context).size.width)/4)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.delivery_time, style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.bold)),
            Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    itemCount: orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      String orderTime = orders.keys.elementAt(index);
                      return Align(
                        alignment: Alignment.center,
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: EdgeInsets.all(25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: RichText(text: 
                                  TextSpan(children: [
                                    TextSpan(text: AppLocalizations.of(context)!.timing), 
                                    TextSpan(text: (orderTime == "Instant")?AppLocalizations.of(context)!.instant:orderTime, style: TextStyle(color: Colors.cyan))
                                    ],
                                  style: TextStyle(fontSize: 19.00, fontWeight: FontWeight.w600))),
                                ),
                                SizedBox(height: 10.00),
                                generateList(orderTime),
                            ]
                          )
                            )
                          ),
                      );
                      }
                    )
                  ),
          ],
        ),
      ),
    );
  }
  Widget generateList(String orderTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          children: List.generate(orders[orderTime]?['name'].length, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 5.00),
                  // orders[orderId]?['time'][i] ? Icon(Icons.verified, color: Colors.green) : Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 10.00),
                  Expanded(
                    child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(width: 120, child: Text("${orders[orderTime]?['name'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
                          SizedBox(width: 20.00),
                          SizedBox(width: 50, child: Text("x${orders[orderTime]?['count'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.00,),
                      ],
                    ),

                  ],
                );
              },
            )),
          SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color: Color.fromRGBO(75, 75, 75, 1)))
      ],

    );
  }
}





//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.00, horizontal: ((widget.portrait)?(MediaQuery.of(context).size.width)/7:(MediaQuery.of(context).size.width)/3)),
//             child: Card(
//               margin: EdgeInsets.all(16),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(AppLocalizations.of(context)!.order_items, style: TextStyle(fontSize: 22, fontWeight:(widget.isTamil)?FontWeight.w600:FontWeight.w500)),
//                     SizedBox(height: 10),
//                     Column(
//                       children: List.generate(orders.length, (i) {
//                         String orderTime = orders.keys.elementAt(i);
//                         return Column(
//                           children: [
//                             Divider(thickness: 2, color: Color.fromRGBO(75, 75, 75, 1)),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("${i+1}. " "${orders[orderTime]?['name']}", style: TextStyle(fontSize: 20)),
//                                 Text("x ${orders[orderTime]?['count']}", style: TextStyle(fontSize: 20)),
//                               ],
//                             ),
//                           ],
//                         );
//                       }),
//                     ),
//                     Divider(thickness: 2, color: Color.fromRGBO(75, 75, 75, 1)),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }