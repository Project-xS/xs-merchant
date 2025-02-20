import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  Map<int, Map<String, dynamic>> orders = {
    1: {'name': 'Chicken Rice', 'time':['0900','1115','1200'], 'count': 150},
    2: {'name': 'Veg Fried Rice', 'time':['0900','1115','1200'], 'count': 75},
    3: {'name': 'Rice', 'time':['0900','1115','1200'], 'count': 10},
    4: {'name': 'Rasam', 'time':['0900','1115','1200'], 'count': 2},
    5: {'name': 'Sambar', 'time':['0900','1115','1200'], 'count': 5},
    6: {'name': 'Parotta', 'time':['0900','1115','1200'], 'count': 20},
    7: {'name': 'Chilli Chicken', 'time':['0900','1115','1200'], 'count': 50},
    8: {'name': 'Noodles', 'time':['0900','1115','1200'], 'count': 60},
    9: {'name': 'Chicken Noodles', 'time':['0900','1115','1200'], 'count': 50},
    10: {'name': 'Chappathi', 'time':['0900','1115','1200'], 'count': 10}
  };

  
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