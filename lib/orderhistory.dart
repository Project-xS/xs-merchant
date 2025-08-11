import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistory extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const OrderHistory(this.portrait, this.isTamil, this.canteenId, {super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> with AutomaticKeepAliveClientMixin{
  Map<int, Map<String, dynamic>> orderhistory = {};

  List<int> searchResults = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
    _clearOrderHistoryIfNewDay();
  }

  Set<int> get deliverlater => orderhistory.entries
      .where((entry) => entry.value['submitted'] == null)
      .map((entry) => entry.key)
      .toSet();

  Future<void> _loadOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final orderHistoryString = prefs.getString('orderHistory');
    if (orderHistoryString != null && mounted) {
      setState(() {
        Map<String, dynamic> decoded = jsonDecode(orderHistoryString);
        orderhistory = decoded.map((key, value) =>
            MapEntry(int.parse(key), Map<String, dynamic>.from(value)));
      });
    }
  }

  Future<void> _saveOrderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, Map<String, dynamic>> deliverlaterOrders = Map.fromEntries(
      orderhistory.entries.where((entry) => entry.value['submitted'] == null),
    );

    final encoded = deliverlaterOrders.map(
        (key, value) => MapEntry(key.toString(), value));
    final orderHistoryString = json.encode(encoded);

    await prefs.setString('orderHistory', orderHistoryString);
  }


  void _clearOrderHistoryIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    String lastClearedDate = prefs.getString('lastClearedDate') ?? '';
    String today = DateTime.now().toIso8601String().split("T")[0];
    if (lastClearedDate != today) {
      if (mounted) {
        setState(() {
          orderhistory.clear();
        });
      }
      await prefs.remove('orderHistory');
      await prefs.setString('lastClearedDate', today);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Cleared yesterday's order details successfully"),
          backgroundColor: Colors.amber,
        ));
      }
    }
  }

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
    super.build(context);
    final theme = Theme.of(context);
    TextEditingController controller = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton.extended(
          elevation: 10.00,
          backgroundColor: theme.colorScheme.secondary,
          onPressed: () {
            orderverfication();
          },
          icon: const Icon(Icons.room_service),
          label: Text(AppLocalizations.of(context)!.deliver,
              style: theme.textTheme.labelLarge),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchBar(
                    padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 15.00)),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    hintText: AppLocalizations.of(context)!.s_order,
                    leading: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.00, horizontal: 12.00),
                        child: Icon(Icons.search, color: Colors.grey)),
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.done),
                        onPressed: () {
                          search(controller.text);
                        },
                      ),
                      IconButton(
                          icon: const Icon(Icons.restart_alt),
                          onPressed: () {
                            setState(() {
                              searchResults.clear();
                              buildSearchList([]);
                            });
                          }),
                      const SizedBox(width: 10.00)
                    ],
                    onChanged: (value) {
                      String filteredValue =
                          value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (value != filteredValue) {
                        controller.value = TextEditingValue(
                          text: filteredValue,
                          selection: TextSelection.collapsed(
                              offset: filteredValue.length),
                        );
                      }
                    },
                    onSubmitted: search,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          buildSearchList(searchResults),
        ],
      ),
    );
  }

  SliverList buildSearchList(List<int> searchResults) {
    final keys = searchResults.isEmpty ? deliverlater.toList() : searchResults;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (keys.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No orders to be delivered later"),
              ),
            );
          }
          final orderId = keys[index];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: generateList(orderId),
            ),
          );
        },
        childCount: keys.isEmpty ? 1 : keys.length,
      ),
    );
  }

  Widget generateList(int orderId) {
    final theme = Theme.of(context);
    final isHoldOrder = orderhistory[orderId]?['submitted'] == null;
    final holdOrderStyle = TextStyle(color: theme.colorScheme.primary, fontSize: theme.textTheme.titleLarge?.fontSize, fontWeight: theme.textTheme.titleLarge?.fontWeight, fontFamily: theme.textTheme.titleLarge?.fontFamily);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.order_items,
                    style: theme.textTheme.titleLarge),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleLarge,
                    children: [
                      const TextSpan(text: '#'),
                      TextSpan(
                        text: orderId.toString(),
                        style: isHoldOrder ? holdOrderStyle : null,
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(orderhistory[orderId]!['name'].length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      orderhistory[orderId]!['status'][i] == true
                          ? Icons.check_circle
                          : orderhistory[orderId]!['status'][i] == null
                              ? Icons.help_outline
                              : Icons.cancel,
                      color: orderhistory[orderId]!['status'][i] == true
                          ? Colors.green
                          : orderhistory[orderId]!['status'][i] == null
                              ? Colors.yellow
                              : Colors.red,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        orderhistory[orderId]!['name'][i],
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      "x ${orderhistory[orderId]!['count'][i]}",
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.titleLarge,
                    children: [
                      TextSpan(
                          text:
                              "${AppLocalizations.of(context)!.total}: "),
                      TextSpan(
                        text: "₹${orderhistory[orderId]!['price']}",
                        style: isHoldOrder ? holdOrderStyle : null,
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void markdelivered(bool submit, int orderId) async{
    try{
        final response = await http.put((submit)?Uri.parse("https://proj-xs.fly.dev/orders/$orderId/delivered"):Uri.parse("https://proj-xs.fly.dev/orders/$orderId/cancelled"));
        if (response.statusCode == 200){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order $orderId ${(submit)?"Delivered":"Cancelled"} Successfully")));
            }
          }
          else{
            if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Submiting order : ${response.statusCode}")));
            }
          }
        } on Exception catch (e){
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
            }
        }
    
  }

  void orderverfication() {
    int orderId = 0;
    bool rfid = true;
    List<String> names = [];
    List<int> count = [];
    int price = 0;
    List<dynamic> status = [];
    final FocusNode searchBarFocus = FocusNode();
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(AppLocalizations.of(context)!.item_delivery,
                  style: theme.textTheme.titleLarge),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchBar(
                    backgroundColor:
                        const WidgetStatePropertyAll(Colors.black),
                    autoFocus: true,
                    focusNode: searchBarFocus,
                    padding: (widget.portrait)
                        ? const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 5))
                        : WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 10.0)),
                    controller: controller,
                    keyboardType: TextInputType.number,
                    leading: const Icon(Icons.verified),
                    hintText: AppLocalizations.of(context)!.s_tap,
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                        },
                      ),
                      IconButton(
                          icon: const Icon(Icons.restart_alt),
                          onPressed: () {
                            setState(() {
                              controller.clear();
                              orderId = 0;
                              FocusScope.of(context)
                                  .requestFocus(searchBarFocus);
                            });
                          }),
                    ],
                    onChanged: (value) async {
                      controller.text =
                          value.replaceAll(RegExp(r'[^0-9]'), '');
                      controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length));
                      if (value.isEmpty ||
                          controller.text.isEmpty ||
                          controller.text == "") {
                        return;
                      }
                      try {
                        await Future.delayed(
                            const Duration(milliseconds: 200));
                        final response = await http.get(Uri.parse(
                            "https://proj-xs.fly.dev/orders/by_user?${rfid ? "rfid=${controller.text}" : "user_id=${controller.text}"}"));
                        if (response.statusCode == 200) {
                          Map<String, dynamic> decodedJson =
                              jsonDecode(response.body);
                          setState(() {
                            for (var order in decodedJson["data"]) {
                              orderId = order["order_id"];
                              price = order["total_price"];
                              names = [];
                              count = [];
                              status = [];
                              for (var item in order["items"]) {
                                names.add(item["name"]);
                                count.add(item["quantity"]);
                                status.add(null);
                              }
                              orderhistory[orderId] = {
                                'name': names,
                                'count': count,
                                'price': price,
                                'status': status,
                                'submitted': null
                              };
                              _saveOrderHistory();                          
                            }
                          });
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        "Error Getting Order : ${response.statusCode}")));
                          }
                          setState(() {
                            orderId = 0;
                          });
                        }
                      } on Exception catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Not Connected, $e")));
                        }
                      }
                    },
                  ),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("User ID",
                              style: theme.textTheme.bodyLarge),
                          Switch(
                            value: rfid,
                            onChanged: (value) {
                              setState(() {
                                rfid = value;
                                controller.clear();
                                orderId = 0;
                                FocusScope.of(context)
                                    .requestFocus(searchBarFocus);
                              });
                            },
                          ),
                          Text("RFID", style: theme.textTheme.bodyLarge)
                        ],
                      ),
                    ),
                  ),
                  if (orderId != 0 && orderhistory.keys.any((e) => e == orderId))
                    Flexible(
                      child: SingleChildScrollView(
                        child: buildVerificationCard(orderId),
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)!.not_found,
                        style: theme.textTheme.titleLarge,
                      )),
                    )
                ],
              ),
            );
          });
        });
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isPrimary,
      {bool isYellow = false}) {
    final theme = Theme.of(context);
    Color color;
    if (isYellow) {
      color = Colors.yellowAccent;
    } else {
      color = isPrimary ? theme.colorScheme.primary : theme.colorScheme.error;
    }

    return ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
            horizontal: 15, vertical: 20),
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

  Widget buildVerificationCard(int orderId) {
    final theme = Theme.of(context);
    List<bool?> currentStatus =
        List<bool?>.from(orderhistory[orderId]!['status']);
    bool? isSubmitted = (orderhistory[orderId]!['submitted'] == null) ? null : false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: (widget.portrait) ? 10 : 30, vertical: 10.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleLarge,
                        children: [
                          TextSpan(
                              text: "${AppLocalizations.of(context)!.order_id} #"),
                          TextSpan(
                            text: orderId.toString(),
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.00),
                const Divider(thickness: 1, color: Colors.white24),
                ...List.generate(orderhistory[orderId]!['name'].length, (i) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: isSubmitted == true
                                ? null
                                : () {
                                    setState(() {
                                      if (currentStatus[i] == null ||
                                          currentStatus[i] == false) {
                                        currentStatus[i] = true;
                                      } else if (currentStatus[i] == true) {
                                        currentStatus[i] = false;
                                      }
                                    });
                                  },
                            icon: Icon(
                              currentStatus[i] == true
                                  ? Icons.check_circle
                                  : currentStatus[i] == false
                                      ? Icons.cancel
                                      : Icons.help_outline,
                              color: currentStatus[i] == true
                                  ? Colors.green
                                  : currentStatus[i] == false
                                      ? Colors.red
                                      : Colors.yellow,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                                "${orderhistory[orderId]!['name'][i]}",
                                style: theme.textTheme.bodyLarge),
                          ),
                          const SizedBox(width: 8),
                          Text("x ${orderhistory[orderId]!['count'][i]}",
                              style: theme.textTheme.bodyLarge),
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
                      const Divider(thickness: 1, color: Colors.white24),
                    ],
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.titleLarge,
                        children: [
                          TextSpan(
                              text: "${AppLocalizations.of(context)!.price}: "),
                          TextSpan(
                            text: "₹${orderhistory[orderId]!['price']}",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: _getButtonStyle(context, true),
                      onPressed: isSubmitted == true
                          ? null
                          : () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(AppLocalizations.of(context)!
                                          .confirm_order_changes),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (int i = 0; i <orderhistory[orderId]!['name'].length;i++)
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          "${orderhistory[orderId]!['name'][i]}",
                                                          style: theme.textTheme.bodyLarge?.copyWith(
                                                            color: currentStatus[i] == true
                                                                ? Colors.green
                                                                : currentStatus[i] == null
                                                                    ? Colors.yellow
                                                                    : Colors.red,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                            "x ${orderhistory[orderId]!['count'][i]}",
                                                            style: theme.textTheme.bodyLarge?.copyWith(
                                                              fontSize: 16,
                                                            ),
                                                            ),
                                                      ),
                                                          const SizedBox(width: 8),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              currentStatus[i] == true
                                                                  ? AppLocalizations.of(context)!.accept
                                                                  : currentStatus[i] == null
                                                                      ? AppLocalizations.of(context)!.deliver_later
                                                                      : AppLocalizations.of(context)!.reject,
                                                              style: theme.textTheme.bodyLarge?.copyWith(
                                                                color: currentStatus[i] == true
                                                                    ? Colors.green
                                                                    : currentStatus[i] == null
                                                                        ? Colors.yellow
                                                                        : Colors.red,
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                    ],
                                                  ),
                                                  const Divider(
                                                      thickness: 1,
                                                      color: Colors.white24),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: _getButtonStyle(
                                                    context, false),
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.close),
                                                    const SizedBox(width: 8),
                                                    Text(AppLocalizations.of(
                                                            context)!
                                                        .cancel),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: _getButtonStyle(context, true),
                                                onPressed: () {
                                                  setState(() {
                                                    bool isAllTrue = currentStatus
                                                        .every((e) => e == true);
                                                    bool isAllFalse = currentStatus
                                                        .every((e) => e == false);
                                                    if (isAllTrue == false &&
                                                        isAllFalse == false) {
                                                      orderhistory[orderId]![
                                                          'submitted'] = null;
                                                      orderhistory[orderId]![
                                                              'status'] =
                                                          List<bool?>.from(
                                                              currentStatus);
                                                      isSubmitted =
                                                          orderhistory[orderId]![
                                                              'submitted'];
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: (currentStatus.any(
                                                                  (e) => e == null))
                                                              ? Text(
                                                                  "Made order(s) to be delivered later")
                                                              : Text(
                                                                  "Accepted/Rejected Order"),
                                                          backgroundColor:
                                                              (currentStatus.any(
                                                                      (e) => e == null))
                                                                  ? Colors.yellowAccent
                                                                  : Colors.orangeAccent,
                                                        ),
                                                      );
                                                    } else if (isAllFalse) {
                                                      orderhistory[orderId]![
                                                              'status'] =
                                                          List<bool?>.from(
                                                              currentStatus);
                                                      orderhistory[orderId]![
                                                          'submitted'] = true;
                                                      isSubmitted =
                                                          orderhistory[orderId]![
                                                              'submitted'] ??
                                                              false;
                                                      markdelivered(false, orderId);
                                                    } else if (isAllTrue == true) {
                                                      orderhistory[orderId]![
                                                              'status'] =
                                                          List<bool?>.from(
                                                              currentStatus);
                                                      orderhistory[orderId]![
                                                          'submitted'] = true;
                                                      isSubmitted =
                                                          orderhistory[orderId]![
                                                              'submitted'] ??
                                                              false;
                                                      markdelivered(true, orderId);
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                  buildSearchList([]);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.check),
                                                    const SizedBox(width: 8),
                                                    Text(AppLocalizations.of(
                                                            context)!
                                                        .submit),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  });
                            },
                      child: Row(
                        children: [
                          const Icon(Icons.check),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.submit),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
