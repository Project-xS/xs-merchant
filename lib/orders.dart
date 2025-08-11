import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/l10n/app_localizations.dart';

class Orders extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const Orders(this.portrait, this.isTamil, this.canteenId, {super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with OrderFetchMixin<Orders>{
  Map<String, Map<String, dynamic>> orders = {};

  @override
  int get canteenIdForOrders => widget.canteenId;

  @override
  void onOrdersUpdated(Map<String, Map<String, dynamic>> orders) {
    if (!mounted) return;
    setState(() {
      orders = orders;
    });
  }

  @override
  void onOrderFetchError(dynamic error) {
    debugPrint("OrdersState Fetch Error: $error");
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

    ButtonStyle _getButtonStyle(BuildContext context, bool isPrimary,
      {bool isYellow = false}) {
    Color color;
    if (isYellow) {
      color = Colors.yellowAccent;
    } else {
      color = isPrimary ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error;
    }

    return ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
            horizontal: 24, vertical: 22),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) return Colors.black;
          return color;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) return color;
          return Colors.black;
        },
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton.extended(
            onPressed: () {
              getorders();
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            label: Text(AppLocalizations.of(context)!.refresh,
                style: Theme.of(context).textTheme.labelLarge),
            icon: const Icon(Icons.refresh)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.delivery_time,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                String orderTime = orders.keys.elementAt(index);
                return generateList(orderTime);
              },
              childCount: orders.length,
            ),
          ),
        ],
      ),
    );
  }
  Widget generateList(String orderTime) {
    bool loading = false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.timing} ${(orderTime == "Instant") ? AppLocalizations.of(context)!.instant : orderTime}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...List.generate(orders[orderTime]!['name'].length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orders[orderTime]!['name'][i],
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      "x${orders[orderTime]!['count'][i]}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: _getButtonStyle(context, true),
                  onPressed: (loading)
                      ? null
                      : () async {
                          setState(() {
                            loading = true;
                          });
                          try {
                            await verifyOrder(orderTime);
                          } finally {
                            if (mounted) {
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                        },
                  child: (loading)
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white)),
                            SizedBox(width: 8),
                            Text("Verifying..."),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(Icons.check),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.verify),
                          ],
                        ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> verifyOrder(String orderTime) async {
    try {
      final response = await http.post(
        Uri.parse("https://proj-xs.fly.dev/orders/verify"),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "canteen_id": widget.canteenId,
          "delivery_time": orderTime,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Order Verified Successfully"),
              backgroundColor: Colors.cyanAccent));
          setState(() {
            orders.remove(orderTime);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Error Verifying Order: ${response.statusCode}"),
              backgroundColor: Colors.redAccent));
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent));
      }
    }
  }
}