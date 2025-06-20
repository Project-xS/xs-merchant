import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/menu_grid.dart';

class Billing extends StatefulWidget {
  final String name;
  final bool isPortrait;
  final bool isTamil;
  final int canteenId;
  const Billing(this.name, this.isPortrait, this.isTamil, this.canteenId, {super.key});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focus = FocusNode();
  Map<int, Map<String, dynamic>> bill = {};
  Map<int, Map<String, dynamic>> item = {};
  List<int> searchitems = [];
  int billIndex = 1;

  @override
  Widget build(BuildContext context) {
    void updateSearchItems(searchitem) {
      setState(() {
        searchitems = searchitem;
      });
    }
    void updateBillItems(updatedBill) {
      setState(() {
        bill = updatedBill;
      });
    }
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyan,
        label: Text("Close", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18)),
        icon: Icon(Icons.close, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        forceMaterialTransparency: true,
        toolbarHeight: 50.00,
        title: Text("Billing:", style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 110,
          width: MediaQuery.of(context).size.width - 2,
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SearchBar(
                              controller: controller,
                              backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 130, 126, 126)),
                              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
                              leading: Icon(Icons.search, color: Colors.black),
                              hintText: AppLocalizations.of(context)!.search_name,
                              hintStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black)),
                              onChanged: (value) async {
                                if(value.isEmpty){
                                  setState(() {
                                    searchitems.clear();
                                    updateSearchItems(searchitems);
                                  });
                                  return;
                                }
                                await Future.delayed(Duration(milliseconds: 300));
                                try {
                                  final response = await http.get(Uri.parse("https://proj-xs.fly.dev/search/$value"));
                                  Map<String, dynamic> decodedJson = jsonDecode(response.body);
                                  List<dynamic> idList = decodedJson["data"];
                                  setState(() {
                                    searchitems.clear();
                                    for (var i in idList) {
                                      int? itemId = i["item_id"] is int 
                                          ? i["item_id"] 
                                          : int.tryParse(i["item_id"].toString());
                                      
                                      if (itemId != null && i["is_available"]==true) {
                                        searchitems.add(itemId);
                                      }
                                    }
                                    debugPrint(searchitems.toString());
                                  });
                                } on Exception catch (e) {
                                  if (mounted){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error performing search : $e"),
                                    backgroundColor: Colors.redAccent)
                                  );
                                  }
                                }
                              },
                              trailing: [
                                IconButton(icon: Icon(Icons.clear, color: Colors.black),
                                  onPressed: (){
                                    setState(() {
                                      controller.clear();
                                      searchitems.clear();
                                      updateSearchItems(searchitems);
                                      focus.requestFocus(focus);
                                    });
                                    setState(() {                                    
                                    });
                                    }), SizedBox(width: 10)]
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: SingleChildScrollView(
                                child: BillMenu(
                                  widget.canteenId,
                                  widget.isTamil,
                                  searchitems,
                                  updateSearchItems,                              
                                  bill,
                                  updateBillItems
                                )
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(" Bill: ", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Expanded(flex: 3, child: Text("Item", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),                        
                        Expanded(flex: 2, child: Text("Count", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text("Price", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                        Flexible(flex: 1, child: Text("")) //to match formatting
                      ]
                    ),
                    Expanded(
                      child: (bill.isEmpty)?Center(child: Text("No Items", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))):ListView.builder(
                        itemCount: bill.length,
                        itemBuilder: (context, index) {
                          int i = bill.keys.elementAt(index);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                            child: Row(
                              children: [
                                Text("${index+1}. "),
                                Expanded(flex: 3, child: Text(bill[i]?['name'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18))),          
                                Expanded(flex: 2, child: Text(bill[i]?['count'].toString()??"", textAlign: TextAlign.center, style: TextStyle(fontSize: 18))),
                                Expanded(flex: 2, child: Text("₹${bill[i]?['price']}", style: TextStyle(fontSize: 18))),
                                IconButton(
                                  onPressed: (){
                                    showDialog(
                                      context: context, 
                                      builder: (context){
                                        return AlertDialog(
                                          title: Text("Edit Bill Item: ", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,)),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Center(child: Text("Item: ${bill[i]?['name']}")),
                                              Center(child: Text("Quantity:", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
                                              SizedBox(height: 10),
                                              TextFormField(
                                                initialValue: bill[i]?['count'].toString()??"1",
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                decoration: InputDecoration(labelText: "Enter Quantity", hintText: "Greater than or equal to 1"),
                                                onChanged: (value) {
                                                  if (int.parse(value)>=1){
                                                  setState(() {
                                                    bill[i] = {                                                      
                                                    'price' : (bill[i]?['price']/bill[i]?['count']).toInt()*int.parse(value),
                                                    'count' : int.parse(value),
                                                    'id' : i,
                                                    'name' : bill[i]?['name']                                                            
                                                    };
                                                    updateBillItems(bill);
                                                  });
                                                }else{
                                                  setState(() {
                                                    bill[i]?['count'] = 1;
                                                    updateBillItems(bill);
                                                  });
                                                }
                                                // Navigator.pop(context);
                                                }
                                              ),
                                              SizedBox(height: 20),
                                              TextButton(onPressed: (){
                                                setState(() {
                                                  Navigator.pop(context);
                                                });                              
                                              }, 
                                              style: ButtonStyle(
                                                padding: WidgetStatePropertyAll(EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20)),
                                                backgroundColor: WidgetStateProperty.all(Colors.greenAccent)),
                                              child: Text("Change", style: TextStyle(fontSize: 20.00 ,color: Colors.black, fontWeight: FontWeight.bold)),
                                              ),
                                              SizedBox(height: 20),
                                              Text("Or", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              SizedBox(height: 20),
                                              Text("Delete Bill Item: ", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                                              SizedBox(height: 20),
                                              TextButton(onPressed: (){
                                                setState(() {
                                                  if (bill.keys.contains(i)){
                                                    bill.removeWhere((key, value) => key == i);
                                                    updateBillItems(bill);
                                                    Navigator.pop(context);
                                                  }
                                                });                                  
                                              }, 
                                              style: ButtonStyle(
                                                padding: WidgetStatePropertyAll(EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20)),
                                                backgroundColor: WidgetStateProperty.all(Colors.redAccent)),
                                              child: Text("Delete", style: TextStyle(fontSize: 20.00 ,color: Colors.black, fontWeight: FontWeight.bold)),
                                              )
                                            ])
                                        );
                                      }
                                      );},                                   
                                  icon: Icon(Icons.edit)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Row(children: [],)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}