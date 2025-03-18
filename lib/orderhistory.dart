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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistory extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  const OrderHistory(this.portrait, this.isTamil, {super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> with AutomaticKeepAliveClientMixin{
  // Map<int, Map<String, dynamic>> orderhistory = {
  //   1: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [1, 2, 2], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
  //   2: {'name': ['Chicken Rice', 'Veg Fried Rice'], 'count': [2, 1], 'price': [100, 100], 'status': [null, null], 'submitted': false},
  //   3: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 2], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
  //   4: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 1], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
  //   5: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 1], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
  //   6: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [1, 2, 2], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
  //   7: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [2, 1, 1], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
  //   8: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rice'], 'count': [1, 4, 3], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
  //   9: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Chilli Chicken'], 'count': [3, 1, 4], 'price': [100, 100, 150], 'status': [null, null, null], 'submitted': false},
  //   10: {'name': ['Chicken Rice', 'Veg Fried Rice', 'Rasam'], 'count': [7, 3, 4], 'price': [100, 100, 50], 'status': [null, null, null], 'submitted': false},
  // };
  Map<int, Map<String, dynamic>> orderhistory = {};

  List<int> searchResults = [];

  // List<int> get filteredKeys => orderhistory.keys
  //   .where((key) => orderhistory[key]?['submitted'] != false)
  //   .toList();

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
    // orderhistory.clear();
    // _saveOrderHistory();
    super.build(context);
    TextEditingController controller = TextEditingController();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        elevation: 10.00,
        backgroundColor: Colors.cyan,
        onPressed: (){
          orderverfication();
        },
        icon: Icon(Icons.room_service, color: Colors.black),
        label: Text(AppLocalizations.of(context)!.deliver,  style: TextStyle(color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w500)),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: ((widget.portrait)?5:(MediaQuery.of(context).size.width)/3.5)),
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
                  hintText: AppLocalizations.of(context)!.s_order,
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
    //Uncomment filteredKeys getter at line 43 for showing all the orders and not the Deliver later ones
    return Flexible(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                // itemCount: (searchResults.isEmpty)?orderhistory.length:searchResults.length,
                itemCount: (searchResults.isEmpty)?deliverlater.length:searchResults.length,
                // itemCount: (searchResults.isEmpty)?(filteredKeys.isNotEmpty)?filteredKeys.length:1:(searchResults.isNotEmpty)?searchResults.length:1,
                itemBuilder: (BuildContext context, int index) {
                  int orderId = (searchResults.isEmpty)?deliverlater.elementAt(index):searchResults.elementAt(index);
                  // int orderId = (searchResults.isEmpty)?orderhistory.keys.elementAt(index):searchResults.elementAt(index);
                  // int orderId = (searchResults.isEmpty && filteredKeys.isNotEmpty)?filteredKeys[index]:(filteredKeys.isEmpty)?0:(searchResults.isNotEmpty)?searchResults.elementAt(index):0;
                  return Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: (widget.portrait)?(MediaQuery.of(context).size.width):(MediaQuery.of(context).size.width)/2.2,
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.all(25.0),
                          //Just column thing is enough if we need all items orderhistory to be shown
                          child: (orderId == 0 || deliverlater.isEmpty) ? Text("No order to be delivered later", style: TextStyle(fontSize: 22.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)) : 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context)!.order_items, style: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w600)),
                                  Row(
                                    children: [
                                      Text("${AppLocalizations.of(context)!.order_id} ", style: TextStyle(fontSize: 20.00, fontWeight: FontWeight.w600)),
                                      Text("#$orderId", style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.w700, color: Colors.cyan)),
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
                    ),
                  );
                  }
                )
              );
  }

  Widget generateList(int orderId) {
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
                          SizedBox(width: 30, child: Text("x ${orderhistory[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00), overflow: TextOverflow.ellipsis,)),
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
              Text(AppLocalizations.of(context)!.total, style: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w600:FontWeight.w500)),
              Text("${orderhistory[orderId]?['price']}", style: TextStyle(fontSize: 22.00, fontWeight:(widget.isTamil)?FontWeight.w800:FontWeight.w600, color: Colors.cyan)),
            ],
          )
      ],
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

  void orderverfication(){
    int orderId = 0;
    // int currentorder = 1;
    List<String> names = [];
    List<int> count = [];
    int price = 0;
    List<dynamic> status = [];
    final FocusNode searchBarFocus = FocusNode();
    TextEditingController controller = TextEditingController(); 
    showDialog(context: context, builder: (BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.item_delivery, style: TextStyle(fontSize: 22.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w500)),
          content: SizedBox(
            width: 550,
            height: 500,
            child: Column(
              children: [
          SearchBar(
            backgroundColor: WidgetStateProperty.all(Colors.black),
            autoFocus: true,
            focusNode: searchBarFocus,
            padding: (widget.portrait)?WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 5)):WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10.0)),
            controller: controller,
            keyboardType: TextInputType.number,
            leading : Icon(Icons.verified),
            hintText: AppLocalizations.of(context)!.s_tap,
            trailing: [
              IconButton(icon: Icon(Icons.clear),
                onPressed: (){
                    controller.clear();
                    },
                    ),
                    // IconButton(icon: Icon(Icons.done), 
                    //   onPressed:() {
                    //     setState(() {
                    //     to = int.tryParse(controller.text) ?? 0;    
                    //     });
                    // },
                    // ),
                    IconButton(icon: Icon(Icons.restart_alt),
                      onPressed: (){
                        setState(() {
                          controller.clear();
                          orderId = 0;
                          FocusScope.of(context).requestFocus(searchBarFocus);
                        });
                      }),
                    ],
                      onChanged: (value) async{
                        controller.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                        controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length));
                        if(value.isEmpty || controller.text.isEmpty || controller.text == ""){
                          return;
                        }
                        try {
                          await Future.delayed(Duration(milliseconds: 200));
                          final response = await http.get(Uri.parse("https://proj-xs.fly.dev/orders/by_user?user_id=${controller.text}"));
                          if (response.statusCode == 200){
                          Map<String, dynamic> decodedJson = jsonDecode(response.body);
                          setState((){
                              for (var order in decodedJson["data"]) {
                                orderId = order["order_id"];
                                price = order["total_price"];
                                names = [];
                                count = [];
                                status = [];
                                // currentorder += 1;
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
                          }});}
                          else{
                            if(mounted){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Getting Order : ${response.statusCode}")));
                            }
                            setState(() {
                              orderId = 0;
                              // currentorder = 0;
                            });
                          }
                          }on Exception catch (e){
                            if(mounted){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
                            }
                          }
                      }
                      ),
                    SizedBox(
                      width: (widget.portrait)?550:500,
                      height: 430,
                      child: Padding(
                      padding: (widget.portrait)?EdgeInsets.symmetric(horizontal: 5):EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    SizedBox(height: 20.0),
                    Expanded(
                      child: (orderId == 0 || !orderhistory.keys.any((e) => e == orderId)) 
                      ? Center(child: Text(AppLocalizations.of(context)!.not_found, style: TextStyle(fontSize: 22.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w600))) 
                      : ListView.builder(
                        padding: (widget.portrait)?EdgeInsets.all(2.00):EdgeInsets.all(10.0),
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          List<bool?> currentStatus = List<bool?>.from(orderhistory[orderId]?['status']);
                          bool? isSubmitted = (orderhistory[orderId]?['submitted'] == null) ? null : false;
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: (widget.portrait)?10:30, vertical: 10.0),
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${AppLocalizations.of(context)!.order_id} ", style: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w600)),
                                          Text("#$orderId", style: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w600, color: Colors.cyan)),
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
                                                        SizedBox(width: 8),
                                                        Expanded(child: Text("x ${orderhistory[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00))),
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("${AppLocalizations.of(context)!.price}: ", style: TextStyle(fontSize: 18.00)),
                                              Text("${orderhistory[orderId]?['price']}", style: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w600, color: Colors.cyan))
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  Text("${AppLocalizations.of(context)!.all}:", style: TextStyle(fontSize: 18.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w500)),
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
                                                                title: Text(AppLocalizations.of(context)!.confirm_order_changes, style: TextStyle(fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w600)),
                                                                content: SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Center(child: Text(AppLocalizations.of(context)!.note, style: TextStyle(color: Colors.red, fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w800, backgroundColor: Colors.white), maxLines: 2,)),
                                                                      SizedBox(height: 10.00),
                                                                      SizedBox(width:1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
                                                                      for (int i = 0; i < orderhistory[orderId]?['name'].length; i++)
                                                                        Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Expanded(child: Text("${orderhistory[orderId]?['name'][i]}", style: TextStyle(fontSize: 18.00, fontWeight:(widget.isTamil)?FontWeight.w600:FontWeight.w500, color: (currentStatus[i] == true) ? Colors.green : (currentStatus[i] == null) ? Colors.yellow : Colors.red))),
                                                                                SizedBox(width: 8),
                                                                                Expanded(child: Text("x ${orderhistory[orderId]?['count'][i]}", style: TextStyle(fontSize: 18.00, fontWeight:(widget.isTamil)?FontWeight.w600:FontWeight.w500, color: (currentStatus[i] == true) ? Colors.green : (currentStatus[i] == null) ? Colors.yellow : Colors.red))),
                                                                                Text((currentStatus[i] == true) ? AppLocalizations.of(context)!.accept : (currentStatus[i] == null) ? AppLocalizations.of(context)!.deliver_later : AppLocalizations.of(context)!.reject, style: TextStyle(fontSize: 18.00, fontWeight: FontWeight.bold, color: (currentStatus[i] == true) ? Colors.green : (currentStatus[i] == null) ? Colors.yellow : Colors.red)),
                                                                              ],
                                                                            ),
                                                                            SizedBox(width: 1200.00, height: 20.00, child: Divider(height: 10.00, thickness: 2.00, color:Color.fromRGBO(75, 75, 75, 1))),
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
                                                                          Text(AppLocalizations.of(context)!.cancel, style: TextStyle(fontWeight: FontWeight.w600))])
                                                                      ),
                                                                      TextButton(
                                                                        style: ButtonStyle(
                                                                          backgroundColor: WidgetStateProperty.all(Colors.black),
                                                                          foregroundColor: WidgetStateProperty.all(Colors.white),
                                                                          padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                                                                          fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                                                                          overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                                                                        ),
                                                                        onPressed: (){
                                                                          setState((){
                                                                            bool isAllTrue = currentStatus.every((e) => e == true);
                                                                            bool isAllFalse = currentStatus.every((e) => e == false);
                                                                            if (isAllTrue == false && isAllFalse == false){
                                                                              orderhistory[orderId]?['submitted'] = null;
                                                                              orderhistory[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                              isSubmitted = orderhistory[orderId]?['submitted'];
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: (currentStatus.any((e) => e == null))?Text("Made order(s) to be delivered later", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),):Text("Accepted/Rejected Order", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),),
                                                                                backgroundColor: (currentStatus.any((e) => e == null))?Colors.yellowAccent:Colors.orangeAccent,
                                                                                )
                                                                              );
                                                                            }
                                                                            else if (isAllFalse){
                                                                            orderhistory[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                            orderhistory[orderId]?['submitted'] = true;
                                                                            isSubmitted = orderhistory[orderId]?['submitted'] ?? false;
                                                                            markdelivered(false, orderId);
                                                                        }else if(isAllTrue == true){
                                                                          orderhistory[orderId]?['status'] = List<bool?>.from(currentStatus);
                                                                            orderhistory[orderId]?['submitted'] = true;
                                                                            isSubmitted = orderhistory[orderId]?['submitted'] ?? false;
                                                                            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                            //     content: Text("Accepted the whole order", style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),),
                                                                            //     backgroundColor: Colors.green,
                                                                            //     ));
                                                                            markdelivered(true, orderId);                              
                                                                        }});
                                                                          Navigator.pop(context);                     
                                                                          //can remove buildSearchlist when we need to show everything
                                                                          buildSearchList([]);
                                                                        },
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [Icon(Icons.check, color: Colors.greenAccent), 
                                                                          Text(AppLocalizations.of(context)!.submit, style: TextStyle(fontWeight: FontWeight.w600))]),
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
                                                    Text(AppLocalizations.of(context)!.submit, style: TextStyle(fontWeight: FontWeight.w600)),
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

