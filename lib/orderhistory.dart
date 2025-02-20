import 'package:flutter/material.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  Map<int, Map<String, dynamic>> orderhistory = {
    1: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [1, 2, 2], 'price': [100, 100, 150], 'status': [false, true, true]},
    2: {'name': ['Chicken Rice', 'Veg Fried Rice'], 'count': [2, 1], 'price': [100, 100], 'status': [true, true], 'submitted': false},
    3: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 2], 'price': [100, 100, 50], 'status': [false, true, false]},
    4: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 1], 'price': [100, 100, 150], 'status': [true, false, true]},
    5: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 1], 'price': [100, 100, 50], 'status': [true, true, true]},
    6: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [1, 2, 2], 'price': [100, 100, 50], 'status': [false, false, true]},
    7: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [2, 1, 1], 'price': [100, 100, 150], 'status': [true, true, true]},
    8: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 3], 'price': [100, 100, 50], 'status': [false, true, false]},
    9: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 4], 'price': [100, 100, 150], 'status': [true, false, false]},
    10: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 4], 'price': [100, 100, 50], 'status': [true, true, false]},
  };

  List<int> searchResults = [];

  void search(String query) {
    setState(() {
      searchResults = [];
      if (query.isNotEmpty) {
        int? orderId = int.tryParse(query);
        if (orderId != null && orderhistory.containsKey(orderId)) {
          searchResults.add(orderId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 10.00,
        backgroundColor: Colors.cyan,
        onPressed: (){
          //Connection and Verification
          //quick_usb: ^0.4.0
            //For billing if needed
              //flutter_esc_pos_utils: ^1.0.1 
              //flutter_pos_printer_platform_image_3: ^1.2.4 
            //Rfid
                //Windows
              //rd126_reader_platform_interface 1.0.0 
              //honeywell_rfid_reader_platform_interface: ^0.0.3
              //mfrc522: ^0.0.5
                //Android and IOS
                //flutter_document_reader_core_fullrfid: ^7.5.887
        },
        child: Icon(Icons.room_service, color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: ((MediaQuery.of(context).size.width)/4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.00),
                child:Column(
          children: [
            SearchBar(
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 15.00)),
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  hintText: "Enter Order Number to Search",
                  leading: Padding(padding: EdgeInsets.symmetric(vertical: 5.00, horizontal: 12.00), child: Icon(Icons.search, color: Colors.grey,)),
                  trailing: [
                    IconButton(icon: Icon(Icons.clear),
                      onPressed: (){
                          controller.clear();
                          },
                          ),IconButton(icon: Icon(Icons.done), 
                            onPressed:() {
                              search(controller.text);
                          },
                          ),
                          IconButton(icon: Icon(Icons.restart_alt),
                            onPressed: (){
                              setState(() {
                                searchResults.clear();
                                buildSearchList([]);
                              });
                            }),
                           SizedBox(width:10.00)],
                        onChanged: (value){
                          String filteredValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (value != filteredValue) {
                              controller.value = TextEditingValue(
                                text: filteredValue,
                                selection: TextSelection.collapsed(offset: filteredValue.length),
                              );
                            }
                          },
                        onSubmitted: search,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            Container(
              child: searchResults.isNotEmpty
                  ? buildSearchList(searchResults)
                  : buildSearchList([]),
            ),
          ]
          )
        )
      )
    );
  }

  Flexible buildSearchList(List<int>searchResults) {
    return Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                itemCount: (searchResults.isEmpty)?orderhistory.length:searchResults.length,
                itemBuilder: (BuildContext context, int index) {
                  int orderId = (searchResults.isEmpty)?orderhistory.keys.elementAt(index):searchResults.elementAt(index);
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Order Items:", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    Text("Order ID: ", style: TextStyle(fontSize: 19.00, fontWeight: FontWeight.w600)),
                                    Text("#$orderId", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w700, color: Colors.cyan)),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10.00),
                            generateList(orderId),
                        ]
                      )
                        )
                      ),
                  );
                  }
                )
              );
  }

  Widget generateList(int orderId) {
    int sum = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          children: List.generate(orderhistory[orderId]?['name'].length, (i) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 5.00),
                  orderhistory[orderId]?['status'][i] ? Icon(Icons.verified, color: Colors.green) : Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 10.00),
                  Expanded(
                    child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 120, child: Text("${orderhistory[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
                          SizedBox(width: 20.00),
                          SizedBox(width: 30, child: Text("x${orderhistory[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
                          SizedBox(width: 80, child: Text("${orderhistory[orderId]?['count'][i]} x ${orderhistory[orderId]?['price'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
                          SizedBox(width: 40,
                            child: (orderhistory[orderId]?['status'][i] == true)
                                  ? Text(
                                      () {
                                        int total = orderhistory[orderId]?['count'][i] * orderhistory[orderId]?['price'][i];
                                        sum += total;
                                        return "$total";
                                      }(),
                                      style: TextStyle(fontSize: 18.00),
                                    )
                                  : Text("0", style: TextStyle(fontSize: 18.00)),
                          ),
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
          SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color: Color.fromRGBO(75, 75, 75, 1))),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Total:", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w500)),
              Text(" $sum", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w600, color: Colors.cyan)),
            ],
          ),
      ],
    );
  }
  }