          //quick_usb: ^0.4.0
            //For billing if needed
              //flutter_esc_pos_utils: ^1.0.1 
              //flutter_pos_printer_platform_image_3: ^1.2.4 
            //Rfid
                //Windows
              //flutter_barcode_listener: ^0.1.4 //Look like it will work Link: https://medium.com/@lubianca.samora/flutter-search-with-rfid-scanner-e0b1c13e9d5b
              //rd126_reader_platform_interface: 1.0.0 
              //honeywell_rfid_reader_platform_interface: ^0.0.3
              //mfrc522: ^0.0.5
                //Android and IOS
                //flutter_document_reader_core_fullrfid: ^7.5.887
import 'package:flutter/material.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  Map<int, Map<String, dynamic>> orderhistory = {
    1: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [1, 2, 2], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
    2: {'name': ['Chicken Rice', 'Veg Fried Rice'], 'count': [2, 1], 'price': [100, 100], 'status': [null, null], 'submitted': false},
    3: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 2], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
    4: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 1], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
    5: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 1], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
    6: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [1, 2, 2], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
    7: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [2, 1, 1], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
    8: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 3], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
    9: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 4], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
    10: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 4], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
  };

  List<int> searchResults = [];

  List<int> get filteredKeys => orderhistory.keys
    .where((key) => orderhistory[key]?['submitted'] != false)
    .toList();

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
          orderverfication();
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
    //Remove filteredKeys getter at line 38 for showing all the orders and not the submitted ones
    return Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                // For Showing all items, itemCount: (searchResults.isEmpty)?orderhistory.length:searchResults.length,
                itemCount: (searchResults.isEmpty)?(filteredKeys.isNotEmpty)?filteredKeys.length:1:(searchResults.isNotEmpty)?searchResults.length:1,
                itemBuilder: (BuildContext context, int index) {
                  // int orderId = (searchResults.isEmpty)?orderhistory.keys.elementAt(index):searchResults.elementAt(index);
                  int orderId = (searchResults.isEmpty && filteredKeys.isNotEmpty)?filteredKeys[index]:(filteredKeys.isEmpty)?0:(searchResults.isNotEmpty)?searchResults.elementAt(index):0;
                  return Align(
                    alignment: Alignment.center,
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(25.0),
                        //Just column thing is enough if we need all items orderhistory to be shown
                        child: (orderId == 0) ? Text("No order delivered", style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.w700)) : 
                        Column(
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
                  orderhistory[orderId]?['status'][i] == true ? Icon(Icons.verified, color: Colors.green) : orderhistory[orderId]?['status'][i] == null ? Icon(Icons.question_mark, color: Colors.yellow) : Icon(Icons.cancel, color: Colors.red),
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

  void orderverfication(){
    int to = 0;
    TextEditingController controller = TextEditingController(); 
   showDialog(context: context, builder: (BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text("Item Delivery:", style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 500,
            height: 500,
            child: Column(
              children: [
                    SearchBar(
            backgroundColor: WidgetStateProperty.all(Colors.black),
            autoFocus: true,
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10.0)),
            controller: controller,
            leading : Icon(Icons.verified),
            hintText: "Click here and then Tap the ID",
            trailing: [
              IconButton(icon: Icon(Icons.clear),
                onPressed: (){
                    controller.clear();
                    },
                    ),IconButton(icon: Icon(Icons.done), 
                      onPressed:() {
                        setState(() {
                        to = int.tryParse(controller.text) ?? 0;    
                        });
                    },
                    ),
                    IconButton(icon: Icon(Icons.restart_alt),
                      onPressed: (){
                        setState(() {
                          to = 0;
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
              onSubmitted: (value) {
                setState(() {
                  to = int.tryParse(controller.text) ?? 0;    
                });
              },),
            SizedBox(
              width: 500,
              height: 430,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.0),
                    Expanded(
                      child: (to == 0 || !orderhistory.keys.any((e) => e == to)) ? Center(child: Text("Not Found", style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.w600))) : ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          int orderId = to;
                          List<bool?> currentStatus = List<bool?>.from(orderhistory[orderId]?['status']);
                          bool? isSubmitted = orderhistory[orderId]?['submitted'] ?? false;
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10.0),
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Order Items:", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w600)),
                                          Text("#$orderId", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w600, color: Colors.cyan)),
                                        ],
                                      ),
                                      SizedBox(height: 15.00),
                                      SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
                                      Column(
                                        children: List.generate(orderhistory[orderId]?['name'].length, (i) {
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: isSubmitted == true
                                                        ? null
                                                        : () {
                                                            setState(() {
                                                              if (currentStatus[i] == null || currentStatus[i] == false) {
                                                                currentStatus[i] = true;
                                                              } else if (currentStatus[i] == true) {
                                                                currentStatus[i] = false;
                                                              }
                                                              else{
                                                                currentStatus[i] = null;
                                                              }
                                                            });
                                                          },
                                                    icon: currentStatus[i] == null
                                                        ? Icon(Icons.question_mark, color: Colors.yellow)
                                                        : currentStatus[i] == true
                                                            ? Icon(Icons.verified, color: Colors.green)
                                                            : Icon(Icons.cancel, color: Colors.red),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Expanded(child: Text("${orderhistory[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00))),
                                                        Expanded(child: Text("x${orderhistory[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00))),
                                                        Checkbox(
                                                          tristate: true,
                                                          value: currentStatus[i],
                                                          onChanged: isSubmitted == true
                                                              ? null
                                                              : (value) {
                                                                  setState(() {
                                                                    currentStatus[i] = value;
                                                                  });
                                                                },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
                                            ],
                                          );
                                        }),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  Text("All:", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.w500)),
                                                  Checkbox(
                                                    tristate: true,
                                                    value: currentStatus.every((e) => e == null) ? null : currentStatus.every((e) => e == true) ? true :false,
                                                    onChanged: isSubmitted == true
                                                        ? null
                                                        : (value) {
                                                            setState(() {
                                                              bool isAllTrue = currentStatus.every((e) => e == true);
                                                              bool isAllFalse = currentStatus.every((e) => e == false);
                                                              if (isAllTrue == false && isAllFalse == false){
                                                                currentStatus = List.filled(currentStatus.length, false);
                                                              } else if (isAllTrue) {
                                                                currentStatus = List.filled(currentStatus.length, null);
                                                              } else if (isAllFalse) {
                                                                currentStatus = List.filled(currentStatus.length, true);
                                                              } else {
                                                                currentStatus = List.filled(currentStatus.length, false);
                                                              }
                                                            });
                                                          },
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 15.00),
                                              TextButton(
                                                style: ButtonStyle(
                                                  backgroundColor: WidgetStateProperty.all(Colors.black),
                                                  foregroundColor: WidgetStateProperty.all(Colors.white),
                                                  padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                                                  fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                                                  overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                                                ),
                                                onPressed: isSubmitted == true
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                            showDialog(context: context, builder:(context) {
                                                              return AlertDialog(
                                                                title: Text("Are you sure to Accept/Reject/Hold the Order?", style: TextStyle(fontWeight: FontWeight.w700)),
                                                                content: SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text("Note: This can be done only once and make it hold to deliver later.", style: TextStyle(color: Colors.red, fontSize: 20.00, fontWeight: FontWeight.w800, backgroundColor: Colors.white)),
                                                                      SizedBox(height: 10.00),
                                                                      for (int i = 0; i < orderhistory[orderId]?['name'].length; i++)
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(child: Text("${orderhistory[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.w500, color: (currentStatus[i] == true) ? Colors.green : (currentStatus[i] == null) ? Colors.yellow : Colors.red))),
                                                                            Expanded(child: Text("x${orderhistory[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.w500, color: (currentStatus[i] == true) ? Colors.green : (currentStatus[i] == null) ? Colors.yellow : Colors.red))),
                                                                            Text((currentStatus[i] == true) ? "Accept" : (currentStatus[i] == null) ? "Deliver Later" : "Reject", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.bold, color: (currentStatus[i] == true) ? Colors.green : (currentStatus[i] == null) ? Colors.yellow : Colors.red)),
                                                                          ],
                                                                        ),
                                                                        SizedBox(height: 10.00)
                                                                    ],
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      TextButton(
                                                                        style: ButtonStyle(
                                                                          backgroundColor: WidgetStatePropertyAll(Colors.red),
                                                                          foregroundColor: WidgetStatePropertyAll(Colors.black),
                                                                          padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                                                                          fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                                                                          overlayColor: WidgetStatePropertyAll(Colors.redAccent),
                                                                        ),
                                                                        onPressed: () {
                                                                          Navigator.pop(context, false);
                                                                        },
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [Icon(Icons.close, color: Colors.black), 
                                                                          Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600))])
                                                                      ),
                                                                      TextButton(
                                                                        style: ButtonStyle(
                                                                          backgroundColor: WidgetStateProperty.all(Colors.black),
                                                                          foregroundColor: WidgetStateProperty.all(Colors.white),
                                                                          padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                                                                          fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                                                                          overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                                                                        ),
                                                                        onPressed: () {
                                                                          setState(() {
                                                                            bool isAllTrue = currentStatus.every((e) => e == true);
                                                                            bool isAllFalse = currentStatus.every((e) => e == false);
                                                                            if (isAllTrue == false && isAllFalse == false){
                                                                              orderhistory[orderId]?['submitted'] = null;
                                                                              orderhistory[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                              isSubmitted = orderhistory[orderId]?['submitted'];
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text("Made order(s) to be delivered later", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),),
                                                                                backgroundColor: Colors.yellowAccent,
                                                                                )
                                                                              );
                                                                            }
                                                                            else if (isAllFalse){
                                                                            orderhistory[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                            orderhistory[orderId]?['submitted'] = true;
                                                                            isSubmitted = orderhistory[orderId]?['submitted'] ?? false;
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                content: Text("Rejected the whole order", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),),
                                                                                backgroundColor: Colors.redAccent,
                                                                                ));
                                                                        }else{
                                                                          orderhistory[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                            orderhistory[orderId]?['submitted'] = true;
                                                                            isSubmitted = orderhistory[orderId]?['submitted'] ?? false;
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                content: Text("Accepted the whole order", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),),
                                                                                backgroundColor: Colors.green,
                                                                                ));
                                                                        }
                                                                        });
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                          //can remove buildSearchlist when we need to show everything
                                                                          buildSearchList([]);
                                                                        },
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [Icon(Icons.check, color: Colors.greenAccent), 
                                                                          Text("Submit", style: TextStyle(fontWeight: FontWeight.w600))]),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                          // else{
                                                          //   ScaffoldMessenger.of(context).showSnackBar(
                                                          //     SnackBar(
                                                          //       content: Text("Make the order #$orderId either Accept or Reject", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),),
                                                          //       backgroundColor: Colors.redAccent,
                                                          //       )
                                                          //     );
                                                          // }
                                                        });
                                                      },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Icon(Icons.check, color: Colors.greenAccent),
                                                    SizedBox(width: 5.00),
                                                    Text("Submit", style: TextStyle(fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
                    
            ],),
          )
        );
      }
    );
  }
   );
      }
}