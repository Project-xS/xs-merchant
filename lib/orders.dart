import 'package:flutter/material.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/l10n/app_localizations.dart';

class Orders extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const Orders(this.portrait, this.isTamil, this.canteenId, {super.key});
  @override
  State<Orders> createState() => OrdersState();
}

class OrdersState extends State<Orders> with OrderFetchMixin<Orders>{
  Map<String, Map<String, dynamic>> orders = {};

  @override
  int get canteenIdForOrders => widget.canteenId;

  @override
  void onOrdersUpdated(Map<String, Map<String, dynamic>> orders) {
    if (mounted) {
      setState(() {
        this.orders = orders;
      });
    }
  }

  @override
  void onOrderFetchError(dynamic error) {
    debugPrint("OrdersState Fetch Error: $error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton.extended(
            onPressed: () {
              triggerOrderFetch();
            },
            backgroundColor: Theme.of(context).colorScheme.secondary,
            label: Text(AppLocalizations.of(context)!.refresh,
                style: Theme.of(context).textTheme.labelLarge),
            icon: const Icon(Icons.refresh)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppLocalizations.of(context)!.delivery_time,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                String orderTime = orders.keys.elementAt(index);
                return generateList(orderTime);
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget generateList(String orderTime) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width * 0.9,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
