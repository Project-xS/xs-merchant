import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  Map<int, Map<String, dynamic>> orders = {
    1: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [1, 2, 2], 'status': [null, null, null], 'submitted': false},
    2: {'name': ['Chicken Rice', 'Veg Fried Rice'], 'count': [2, 1], 'status': [null, null], 'submitted': false},
    3: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 2], 'status': [null, null, null], 'submitted': false},
    4: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 1], 'status': [null, null, null], 'submitted': false},
    5: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 1], 'status': [null, null, null], 'submitted': false},
    6: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [1, 2, 2], 'status': [null, null, null], 'submitted': false},
    7: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [2, 1, 1], 'status': [null, null, null], 'submitted': false},
    8: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 3], 'status': [null, null, null], 'submitted': false},
    9: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 4], 'status': [null, null, null], 'submitted': false},
    10: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 4], 'status': [null, null, null], 'submitted': false},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 10.00,
        backgroundColor: Colors.cyan,
        onPressed: () {
          debugPrint("hi");
        },
        child: Icon(Icons.domain_verification_rounded, color: Colors.black),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 320),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: orders.length,
                  itemBuilder: (BuildContext context, int index) {
                    int orderId = orders.keys.elementAt(index);
                    List<bool?> currentStatus = List<bool?>.from(orders[orderId]?['status']);
                    bool isSubmitted = orders[orderId]?['submitted'] ?? false;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              width: MediaQuery.of(context).size.width - 100.00,
                              alignment: Alignment.center,
                              child: Column(
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
                                  Column(
                                    children: List.generate(orders[orderId]?['name'].length, (i) {
                                      return Row(
                                        children: [
                                          IconButton(
                                            onPressed: isSubmitted
                                                ? null
                                                : () {
                                                    setState(() {
                                                      if (currentStatus[i] == null || currentStatus[i] == true) {
                                                        currentStatus[i] = true;
                                                      } else if (currentStatus[i] == true) {
                                                        currentStatus[i] = false;
                                                      }
                                                    });
                                                  },
                                            icon: orders[orderId]?['status'][i] == null
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
                                                Expanded(child: Text("${orders[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00))),
                                                Expanded(child: Text("x${orders[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00))),
                                                Checkbox(
                                                  tristate: true,
                                                  value: currentStatus[i],
                                                  onChanged: isSubmitted
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
                                                value: currentStatus[0],
                                                onChanged: isSubmitted
                                                    ? null
                                                    : (value) {
                                                        setState(() {
                                                          bool isAllTrue = currentStatus.every((e) => e == true);
                                                          bool isAllFalse = currentStatus.every((e) => e == false);
                                                          if (isAllTrue) {
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
                                            onPressed: isSubmitted
                                                ? null
                                                : () {
                                                    setState(() {
                                                      if (!currentStatus.contains(null)){
                                                        showDialog(context: context, builder:(context) {
                                                          return AlertDialog(
                                                            title: Text("Are you sure to Accept or Reject the Order?", style: TextStyle(fontWeight: FontWeight.w700)),
                                                            content: SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text("Note: This can be done only once", style: TextStyle(color: Colors.red, fontSize: 20.00, fontWeight: FontWeight.w800, backgroundColor: Colors.white)),
                                                                  SizedBox(height: 10.00),
                                                                  for (int i = 0; i < orders[orderId]?['name'].length; i++)
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Expanded(child: Text("${orders[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.w500, color: (currentStatus[i] == true) ? Colors.green : Colors.red))),
                                                                        Expanded(child: Text("x${orders[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.w500, color: (currentStatus[i] == true) ? Colors.green : Colors.red))),
                                                                        Text((currentStatus[i] == true) ? "Accept" : "Reject", style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.bold, color: (currentStatus[i] == true) ? Colors.green : Colors.red)),
                                                                      ],
                                                                    ),
                                                                    SizedBox(height: 10.00)
                                                                ],
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context, false);
                                                                },
                                                                child: Text("Cancel"),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    orders[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                    orders[orderId]?['submitted'] = true;
                                                                    isSubmitted = orders[orderId]?['submitted'] ?? false;
                                                                  });
                                                                  Navigator.pop(context, true);
                                                                },
                                                                child: Text("Confirm"),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                      }
                                                      else{
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text("Make the order #$orderId either Accept or Reject", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),),
                                                            backgroundColor: Colors.redAccent,
                                                            )
                                                          );
                                                      }
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
                              ),
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
    );
  }
}
