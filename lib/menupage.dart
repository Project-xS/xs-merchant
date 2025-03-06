import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/tristatetoggle.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}


class _MenupageState extends State<Menupage> with AutoFetchMixin{
  Image icon = Image(image: AssetImage("assets/images/logo.png"), width: 256.00, height: 256.00);
  Image itemicon = Image(image: AssetImage("assets/images/friedrice.png"));
  int sort = 1;
  // Map<int, Map<String, dynamic>> item1 = {
  //   1: {'name': 'Chicken Rice', 'price': 120, 'is_veg': false, 'available': true, 'stocks': -1},
  //   2: {'name': 'Veg Fried Rice', 'price': 100, 'is_veg': true, 'available': true, 'stocks': -1},
  //   3: {'name': 'Chilli Chicken', 'price': 150, 'is_veg': false, 'available': true, 'stocks': 100},
  //   4: {'name': 'Rice', 'price': 50, 'is_veg': true, 'available': true, 'stocks': 0},
  //   5: {'name': 'Rasam', 'price': 40, 'is_veg': true, 'available': true, 'stocks': 500},
  //   6: {'name': 'Sambar', 'price': 60, 'is_veg': true, 'available': false, 'stocks': 100},
  //   7: {'name': 'V Parotta', 'price': 30, 'is_veg': true, 'available': true, 'stocks': 100},
  //   8: {'name': 'N Parotta', 'price': 35, 'is_veg': false, 'available': false, 'stocks': 500},
  //   9: {'name': 'Noodles', 'price': 80, 'is_veg': false, 'available': false, 'stocks': 500},
  //   10: {'name': 'special', 'price': 9999, 'is_veg': true, 'available': true, 'stocks': 100},
  //   11: {'name': 'Chcken Rice', 'price': 120, 'is_veg': false, 'available': false, 'stocks': 100},
  //   12: {'name': 'Veg Frie Rice', 'price': 100, 'is_veg': true, 'available': false, 'stocks': 100},
  //   13: {'name': 'Chlli Chicken', 'price': 150, 'is_veg': false, 'available': true, 'stocks': 500},
  //   14: {'name': 'ice', 'price': 50, 'is_veg': true, 'available': false, 'stocks': 500},
  //   15: {'name': 'asam', 'price': 40, 'is_veg': true, 'available': false, 'stocks': 100},
  //   16: {'name': 'Sabar', 'price': 60, 'is_veg': true, 'available': false, 'stocks': 100},
  //   17: {'name': 'V arotta', 'price': 30, 'is_veg': false, 'available': false, 'stocks': 500},
  //   18: {'name': 'N arotta', 'price': 35, 'is_veg': false, 'available': false, 'stocks': 100},
  //   19: {'name': 'Nodles', 'price': 80, 'is_veg': true, 'available': true, 'stocks': 100},
  //   20: {'name': 'oodles', 'price': 90, 'is_veg': true, 'available': false, 'stocks': 100},
  //   21: {'name': 'Chicen Rice', 'price': 120, 'is_veg': false, 'available': false, 'stocks': 100},
  //   22: {'name': 'Veg Fied Rice', 'price': 100, 'is_veg': true, 'available': false, 'stocks': 100},
  //   23: {'name': 'Chili Chicken', 'price': 150, 'is_veg': false, 'available': false, 'stocks': 100},
  //   24: {'name': 'Rie', 'price': 50, 'is_veg': false, 'available': false, 'stocks': 100},
  //   25: {'name': 'Raam', 'price': 40, 'is_veg': true, 'available': false, 'stocks': 100},
  //   26: {'name': 'Sambr', 'price': 60, 'is_veg': false, 'available': false, 'stocks': 100},
  //   27: {'name': 'V Paotta', 'price': 30, 'is_veg': true, 'available': false, 'stocks': 100},
  //   28: {'name': 'N Paotta', 'price': 35, 'is_veg': false, 'available': false, 'stocks': 100},
  //   29: {'name': 'Noodes', 'price': 80, 'is_veg': false, 'available': false, 'stocks': 100},
  //   30: {'name': 'odles', 'price': 90, 'is_veg': false, 'available': false, 'stocks': 100},
  // };

  int newitemid = 31;
  Map<int, Map<String, dynamic>> item = {};
  Map<int, Map<String, dynamic>> get items {
  var sortedEntries = item.entries.toList();

  if (sort == 1) {
    sortedEntries.sort((a, b) => a.value["name"].toLowerCase().replaceAll(' ', '').compareTo(b.value["name"].toLowerCase().replaceAll(' ', '')));
  } else if (sort == 2) {
    sortedEntries.sort((a, b) => b.value["price"].compareTo(a.value["price"]));
  } else if (sort == 3) {
    sortedEntries.sort((a, b) {
      int getPriority(Map<String, dynamic> item) {
        if (item["stocks"] == 0 && item["available"] == true) return 0;
        if (item["stocks"] == 0 && item["available"] == false) return 1;
        if (item["stocks"] == -1) return 3;
        return 2;
      }
      int priorityA = getPriority(a.value);
      int priorityB = getPriority(b.value);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      if (priorityA == 2) {
        return a.value["stocks"].compareTo(b.value["stocks"]);
      }
      return 0;
    });
  }

  return {for (var entry in sortedEntries) entry.key: entry.value};
}

Set<int> get availableid =>
    items.entries.where((entry) => entry.value['available'] == true && (entry.value['stocks'] == -1 || entry.value['stocks'] >= 1)).map((entry) => entry.key).toSet();

Set<int> get navailableid =>
    items.entries.where((entry) => entry.value['available'] == false || (entry.value['stocks'] != -1 && entry.value['stocks'] == 0)).map((entry) => entry.key).toSet();

  void modifyItem(int itemId, String oldName, double oldRate, bool isveg, bool available) {
    bool isError = false;
    String name = "";
    int stocks = items[itemId]?['stocks']??0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Modify Item - $oldName :", style: TextStyle(fontWeight: FontWeight.w700)),
              content: Padding(
                padding: EdgeInsets.all(10.00),
                child: SizedBox(
                  height: 260.00,
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                          return TextFormField(
                            maxLength: 40,
                            initialValue: oldName,
                            autofocus: true,
                            autocorrect: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                            decoration: InputDecoration(
                              labelText: "New Name",
                              labelStyle: TextStyle(fontSize: 15.00),
                              floatingLabelStyle: TextStyle(fontSize: 20.00),
                              counterText: "",
                              errorText: isError ? "Item Already Present" : null,
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isError ? Colors.red : Colors.blue, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isError ? Colors.red : Colors.grey, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (items.values.where((item) => item != items[itemId]).any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == value.trim().toLowerCase().replaceAll(' ', ''))) {
                                  isError = true;
                                } else {
                                  isError = false;
                                  name = value;
                                }
                              });
                            },
                          );}
                        ),
                        SizedBox(height: 20.00),
                        TextFormField(
                          maxLength: 4,
                          initialValue: oldRate.toInt().toString(),
                          autofocus: true,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: "New Price - ₹",
                            labelStyle: TextStyle(fontSize: 15.00),
                            floatingLabelStyle: TextStyle(fontSize: 20.00),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              oldRate = (int.tryParse(value) != null)? int.parse(value).toDouble() : oldRate;
                            });
                          },
                        ),
                  //Stock rests to 0 need to fix
                        TextFormField(
                          maxLength: 5,
                          initialValue: "${items[itemId]?['stocks']}",
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?([1-9][0-9]*|0)?$'))],
                          onChanged: (value) {
                            if (value.isEmpty || value == "-") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: Stocks can be either -1 or finite",
                                      style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              int parsedValue = int.tryParse(value)??stocks;
                                if (parsedValue < -1){
                                  stocks = 1;
                                }
                                else{
                                  stocks = parsedValue;
                                }
                              }
                          },
                          decoration: InputDecoration(
                            labelText: "Stocks",
                            hintText: "Enter -1 for Unlimited",
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text("Veg : ", style: TextStyle(fontSize: 15.00)),
                            StatefulBuilder(
                              builder:(context, setState) {
                              return Checkbox(
                                value: isveg,
                                onChanged: (value) {
                                  setState(() {
                                    isveg = value ?? false;
                                  });
                                },
                              );},
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                    fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                    overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                  ),
                  onPressed: isError ? null : () {
                    if(!isError){
                        setState(() {
                          item[itemId] = {
                            'name': name.isNotEmpty?name:oldName,
                            'price': oldRate,
                            'is_veg': isveg,
                            'available': available,
                            'stocks': stocks
                          };
                          updateitem(itemId,item);
                        });
                        Navigator.pop(context);
                        }
                      },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Icon(Icons.check, color: Colors.greenAccent),
                    SizedBox(width: 5.00),
                    Text("Submit", style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            );
          },
        );
  }

  void addNewItem(int newitemid) {
    bool isError = false;
    String name = "";
    String priceText = "";
    int stocks = 0;
    bool isveg = false;
    bool available = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add new Item: ", style: TextStyle(fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: double.minPositive,
              height: 300.00,
              child: Column(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) {
                    return Padding(
                      padding: EdgeInsets.all(5.0),
                      child: TextFormField(
                        maxLength: 40,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(fontSize: 15.00),
                          floatingLabelStyle: TextStyle(fontSize: 20.00),
                          errorText: isError ? "Item Already Exists, this Updates the existing item" : null,
                          errorMaxLines: 2,
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isError ? Colors.red : Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: isError ? Colors.red : Colors.grey, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            name = value;
                            isError = items.values.any(
                              (item) => item['name'].trim().toLowerCase().replaceAll(' ', '') ==
                                  value.trim().toLowerCase().replaceAll(' ', ''),
                            );
                          });
                        },
                      )
                    );},
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextFormField(
                      maxLength: 4,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: "Price",
                        labelStyle: TextStyle(fontSize: 15.00),
                        floatingLabelStyle: TextStyle(fontSize: 20.00),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          priceText = value;
                        });
                      },
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: TextFormField(
                    maxLength: 5,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?([1-9][0-9]*|0)?$'))],
                    onChanged: (value) {
                      if (value.isEmpty || value == "-") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: Stocks can be either -1 or finite",
                                style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } else {
                        int? parsedValue = int.tryParse(value);
                        if(parsedValue != null){
                          if (parsedValue < -1){
                            stocks = 1;
                          }
                          else{
                            stocks = parsedValue;
                          }
                        }
                        else{
                          stocks = 0;
                        }
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Stocks",
                      hintText: "Enter -1 for Unlimited",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.00),
                StatefulBuilder(builder: (context, setState) {
                  return Row(
                    children: [
                      Text("Veg : ", style: TextStyle(fontSize: 15.00)),
                      Checkbox(
                        value: isveg,
                        onChanged: (value) {
                          setState(() {
                            isveg = value ?? false;
                            if (value == null || isveg == false){
                              isveg = false;
                            }
                            else{
                              isveg = true;
                            }
                          });
                        },
                      ),
                    ],
                  );}),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(EdgeInsets.all(30.00)),
                  fixedSize: WidgetStatePropertyAll(Size.fromWidth(132)),
                  overlayColor: WidgetStatePropertyAll(const Color.fromARGB(255, 37, 113, 255)),
                ),
                onPressed: () {
                  if (name.isEmpty || priceText.isEmpty || int.tryParse(priceText) == null || int.parse(priceText) == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Error - Don't feed Empty or Invalid Values",
                          style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  setState(() {
                    int olditemid = newitemid;
                    int foundItemId = items.keys.firstWhere(
                      (key) => items[key]?['name'].trim().toLowerCase().replaceAll(' ', '') ==
                          name.trim().toLowerCase().replaceAll(' ', ''),
                          orElse: () => olditemid,
                    );
                    if(foundItemId!=olditemid){
                      item[foundItemId] = {
                        'name': name,
                        'price': int.parse(priceText).toDouble(),
                        'is_veg': isveg,
                        'available': available,
                        'stocks': stocks,
                      };
                      updateitem(foundItemId, item);
                      if (navailableid.contains(foundItemId)){
                        navailableid.remove(foundItemId);
                        availableid.add(foundItemId);
                      }
                      }
                      else{
                        apipostcall(name, int.parse(priceText).toDouble(), isveg, stocks, available);
                        getallitems();
                      }
                    if (isError){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Exception: $name Already Exists, Updated its details",
                            style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: Colors.yellowAccent,
                        ),
                      );
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Item : \"$name\" Added Successfully",
                            style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: Colors.cyanAccent,
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                  },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.check, color: Colors.greenAccent), 
                  Text("Submit", 
                  style: TextStyle(fontWeight: FontWeight.w600))]),
              ),
            ],
          );
        });
  }

  void delAddItem(int itemId, String name, bool isAdd , bool available){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Do you want to ${(isAdd && available)?"Remove \"$name\" from the Menu":((isAdd && !available)?"Add \"$name\" to the Menu":"Delete \"$name\"")}", style: TextStyle(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.minPositive,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)), 
                  fixedSize: WidgetStatePropertyAll(Size(120, 45)),
                  overlayColor: WidgetStatePropertyAll(Color.fromARGB(255, 37, 113, 255)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel")
              ),
              SizedBox(width:20.00),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(isAdd?(available?Colors.yellow:Colors.green):Colors.red),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)), 
                  fixedSize: WidgetStatePropertyAll(Size(120, 45)),
                  overlayColor: WidgetStatePropertyAll(isAdd?(available?Colors.yellowAccent:Colors.greenAccent):Colors.redAccent),
                ),
                onPressed: () {
                    setState(() {
                      if (isAdd == true){
                        if (item[itemId]?['available']) {
                          availableid.remove(itemId);
                          navailableid.add(itemId);
                          item[itemId]?['available'] = false;
                          updateitem(itemId, item);
                        }
                        else {
                            item[itemId]?['available'] = true;
                            availableid.add(itemId);
                            navailableid.remove(itemId);
                            updateitem(itemId, item);
                      }}
                      else{
                        if (item[itemId]?['available']){
                          availableid.remove(itemId);
                        }
                        else{
                          navailableid.remove(itemId);
                        }
                        item.remove(itemId);
                        deleteitem(itemId);
                      }
                      Navigator.pop(context);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Item : ${(isAdd && available)?"$name Removed from Menu":((isAdd && !available)?"$name Added to the Menu":"$name Deleted Successfully")}",
                        style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: (isAdd && available)?Colors.yellowAccent:((isAdd && !available)?Colors.cyanAccent:Colors.redAccent))
                  );
                },
                child: Text((isAdd && available)?"Remove":((isAdd && !available)?"Add":"Delete")),
          )],
          ),
        ),
      );
    },
  );
}
  
  void massEdit(){
    Set<int> searchitems = {};
    TextEditingController controller = TextEditingController();
    Map<int, bool> errorMap = {};
    Set<String> err = {};
    Map<int, Map<String, dynamic>> changes = {};
    showDialog(
      context: context,
      builder: (context) {
            return AlertDialog(
              title: Text("Multiple Item Edit:"),
              titleTextStyle: TextStyle(fontSize: 25.00, fontWeight: FontWeight.w700),
              content: SizedBox(
                height: 400.00,
                width: 550.00,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SearchBar(
                            controller: controller,
                            backgroundColor: WidgetStateProperty.all(Colors.black),
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
                            leading: Icon(Icons.search),
                            hintText: "Enter name to search",
                            onChanged: (value) async {
                              if(value.isEmpty){
                                setState(() {
                                  searchitems.clear();
                                });
                                return;
                              }
                              await Future.delayed(Duration(milliseconds: 200));
                              try {
                                final response = await http.get(Uri.parse("https://proj-xs.fly.dev/search/$value"));
                                Map<String, dynamic> decodedJson = jsonDecode(response.body);
                                debugPrint("$decodedJson");
                                List<dynamic> idList = decodedJson["data"];
                                setState(() {
                                  searchitems.clear();
                                  for (var i in idList) {
                                    int? itemId = i["item_id"] is int 
                                        ? i["item_id"] 
                                        : int.tryParse(i["item_id"].toString());
                                    
                                    if (itemId != null) {
                                      searchitems.add(itemId);
                                    }
                                  }
                                  debugPrint("Search results: $searchitems");
                                });
                              } on Exception catch (e) {
                                if (mounted){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error performing search : $e"))
                                );
                                }
                              }
                            },
                            trailing: [
                              IconButton(icon: Icon(Icons.clear),
                                onPressed: (){
                                  setState(() {
                                    controller.clear();
                                    searchitems.clear();
                                  });}), SizedBox(width: 10)]
                            ),
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: searchitems.isNotEmpty ? searchitems.length : items.length,
                            itemBuilder: (BuildContext context, int index) {
                            int itemId = searchitems.isNotEmpty ? searchitems.elementAt(index) : items.keys.elementAt(index);
                              return ListTile(
                                subtitle: Form(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          StatefulBuilder(
                                            builder: (context, setState) {
                                            return SizedBox( 
                                              width: 150.00,
                                              child: TextFormField(
                                                key: ValueKey(items[itemId]?['name']),
                                                maxLength: 40,
                                                initialValue: items[itemId]?['name'],
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value.isEmpty) {
                                                      errorMap[itemId] = true;
                                                      err.add('Empty');
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text("Error: Name Cannot be Empty",
                                                              style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                                                          backgroundColor: Colors.redAccent,
                                                        ),
                                                      );
                                                    } else {
                                                      if (items.values.where((item) => item != items[itemId]).any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == value.trim().toLowerCase().replaceAll(' ', ''))) {
                                                        errorMap[itemId] = true;
                                                        err.add(value.trim().toLowerCase().replaceAll(" ", ""));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text("Exception: $value Already Exists, Change the name",
                                                                style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                                                            backgroundColor: Colors.redAccent,
                                                          ),
                                                        );
                                                      } else {
                                                        errorMap.remove(itemId);
                                                        if (!errorMap.containsKey(itemId)){
                                                        changes[itemId] = {
                                                          'name': value,
                                                          'price': changes.containsKey(itemId) ? (changes[itemId]?['price']) : (items[itemId]?['price']),
                                                          'is_veg': changes.containsKey(itemId) ? (changes[itemId]?['is_veg']) : (items[itemId]?['is_veg']),
                                                          'available': changes.containsKey(itemId) ? (changes[itemId]?['available']) : (items[itemId]?['available']),
                                                          'stocks': changes.containsKey(itemId) ? (changes[itemId]?['stocks']) : (items[itemId]?['stocks'])
                                                        };
                                                      }}
                                                    }
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Item Name",
                                                  counterText: "",
                                                  errorText: errorMap[itemId] == true ? "Item Exists or Empty" : null,
                                                  border: OutlineInputBorder(),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: errorMap[itemId] == true ? Colors.red : Colors.blue, width: 2),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: errorMap[itemId] == true ? Colors.red : Colors.grey, width: 2),
                                                  ),
                                                ),
                                              ),
                                            );},
                                          ),
                                          SizedBox(width: 10.00),
                                            SizedBox(
                                              width: 60.00,
                                              child: TextFormField(
                                                key: ValueKey(items[itemId]?['price']),
                                                maxLength: 4,
                                                initialValue: items[itemId]?['price'].toInt().toString(),
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                onChanged: (value) {
                                                  if (value.isEmpty) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Error: Price Cannot be Empty",
                                                            style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                                                        backgroundColor: Colors.redAccent,
                                                      ),
                                                    );
                                                  } else {
                                                    changes[itemId] = {
                                                      'price': int.parse(value).toDouble(),
                                                      'name': changes.containsKey(itemId) ? (changes[itemId]?['name']) : (items[itemId]?['name']),
                                                      'is_veg': changes.containsKey(itemId) ? (changes[itemId]?['is_veg']) : (items[itemId]?['is_veg']),
                                                      'available': changes.containsKey(itemId) ? (changes[itemId]?['available']) : (items[itemId]?['available']),
                                                      'stocks': changes.containsKey(itemId) ? (changes[itemId]?['stocks']) : (items[itemId]?['stocks'])
                                                    };
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Price",
                                                  counterText: "",
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.blue, width: 2),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.00),
                                            SizedBox(
                                              width: 60.00,
                                              child: TextFormField(
                                                key: ValueKey(items[itemId]?['stocks']),
                                                maxLength: 5,
                                                initialValue: items[itemId]?['stocks'].toString(),
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?([1-9][0-9]*|0)?$'))],
                                                onChanged: (value) {
                                                  if (value.isEmpty || value == "-") {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Error: Stocks can be either -1 or finite",
                                                            style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                                                        backgroundColor: Colors.redAccent,
                                                      ),
                                                    );
                                                  } else {
                                                    int? parsedValue = int.tryParse(value);
                                                    if (parsedValue != null) {
                                                      if (parsedValue < -1) parsedValue = -1;
                                                      changes[itemId] = {
                                                        'price': changes.containsKey(itemId) ? (changes[itemId]?['price']) : (items[itemId]?['price']),
                                                        'name': changes.containsKey(itemId) ? (changes[itemId]?['name']) : (items[itemId]?['name']),
                                                        'is_veg': changes.containsKey(itemId) ? (changes[itemId]?['is_veg']) : (items[itemId]?['is_veg']),
                                                        'available': changes.containsKey(itemId) ? (changes[itemId]?['available']) : (items[itemId]?['available']),
                                                        'stocks': parsedValue,
                                                      };
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Stocks",
                                                  counterText: "",
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.blue, width: 2),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.00),
                                            SizedBox(
                                              width: 70.00,
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Checkbox(
                                                        value: item[itemId]?['is_veg'],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            item[itemId]?['is_veg'] = !(item[itemId]?['is_veg'] ?? false);
                                                          });
                                                        },
                                                      ),
                                                      Text("Veg", style: TextStyle(fontSize: 15.00)),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.00),
                                            Expanded(
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Row(
                                                    children: [
                                                      Checkbox(
                                                        value: item[itemId]?['available'],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            if (!item[itemId]?['available']) {
                                                              item[itemId]?['available'] = true;
                                                              if(navailableid.contains(itemId)){
                                                                navailableid.remove(itemId);
                                                              }
                                                              availableid.add(itemId);
                                                            } else {
                                                              item[itemId]?['available'] = false;
                                                              availableid.remove(itemId);
                                                              navailableid.add(itemId);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          item[itemId]?['available'] ? "On Menu" : "Not On Menu",
                                                          style: TextStyle(fontSize: 15),
                                                          textAlign: TextAlign.start,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                        ])
                                      ]),
                                  ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
              actions: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                    fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                    overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                  ),
                  onPressed: (errorMap.isNotEmpty)
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: Name(s) Already Exists, Change that to proceed",
                                  style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight: FontWeight.w700)),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      : () {
                        if(errorMap.isEmpty){
                          setState(() {
                            for (int i in changes.keys) {
                              if (changes[i]?['name'] != items[i]?['name'] || changes[i]?['price'] != items[i]?['price'] || changes[i]?['stocks'] != items[i]?['stocks']) {
                                item[i] = {
                                  'name': changes[i]?['name'],
                                  'price': changes[i]?['price'],
                                  'is_veg': item[i]?['is_veg'],
                                  'available': item[i]?['available'],
                                  'stocks': changes[i]?['stocks']
                                };
                                updateitem(i, item);
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "Item Changes are Successful",
                                style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: Colors.cyanAccent,
                            ));
                            errorMap.clear();
                            Navigator.pop(context);
                          });}
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Icon(Icons.check, color: Colors.greenAccent), 
                    Text("Submit", style: TextStyle(fontWeight: FontWeight.w600))]),
                ),
              ],
            );
          },
        );
  }

void apipostcall(String name, double price, bool isveg, int stocks, bool available) async {
  try {
  final response = await http.post(
    Uri.parse('https://proj-xs.fly.dev/menu/create'),
    headers: {
      "accept": "application/json",
      "Content-Type": "application/json"
    },
    body: jsonEncode({
      "canteen_id": 1,
      // "description": "hi",
      "list": true,
      // "pic_link": "hi",
      "name": name,
      "price": price,
      "is_veg": isveg,       
      "is_available": available,
      "stock": stocks        
    }), 
  );
  
  if (response.statusCode == 200) { 
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Created Succesfully")));
    }
  } else {
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response.body}")));
    }
  }
} on Exception catch (e) {
  if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
  }
}
}

 @override
  void fetchData() { //Auto Fetch mixin function
    getallitems();
  }

void getallitems() async{
  if (!mounted) return;
  try{
  final response = await http.get(Uri.parse("https://proj-xs.fly.dev/menu/items"));
      if (response.statusCode == 200){
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        List<dynamic> dataList = decodedJson["data"];
        setState(() {
          item.clear();
          for (var item1 in dataList) {
            item[item1["item_id"]] = {
              "name": item1["name"],
              "price": item1["price"].toDouble(),
              "is_veg": item1["is_veg"],
              "available": item1["is_available"],
              "stocks": item1["stock"]
            };
          }
          // debugPrint("${item.keys}");
          if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Fetched Successfully")));
          }
    });
}
else{
  if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error from DB")));
  }}
  } on Exception catch (e){
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
  }
  }
  }

void updateitem(int itemId, Map<int, Map<String, dynamic>> item) async{
  try{
  final response = await http.put(Uri.parse("https://proj-xs.fly.dev/menu/update"),
  headers: {'accept' : 'application/json','Content-Type' : 'application/json'},
  body: jsonEncode({
    "item_id": itemId as num,
    "update": {
    "description": "string",
    "is_available": item[itemId]?["available"] as bool,
    "is_veg": item[itemId]?['is_veg'] as bool,
    "list": item[itemId]?["available"] as bool,
    "name": item[itemId]?["name"],
    "pic_link": "string",
    "price": item[itemId]?["price"] as num,
    "stock": item[itemId]?["stocks"] as num
  }}
  ));
  if (response.statusCode == 200){
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Update Successful")));
    }
  }
  else{
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error from DB")));
  }
  }
} on Exception catch (e){
  if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
  }
}
}

void deleteitem(int itemId) async{
  try{
  final response = await http.delete(Uri.parse("https://proj-xs.fly.dev/menu/delete/$itemId"),
  headers: {'accept' : 'application/json'});
  if(response.statusCode == 200){
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Deleted Successfully")));
    }
  }
  else{
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error from DB")));
    }
  } }on Exception catch (e){
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e")));
  }
  }
}

// Future<void> addNewItems() async {
//   for (var entry in item.entries) {
//     await apipostcall(
//       entry.key,
//       entry.value['name'],
//       entry.value['price'],
//       entry.value['is_veg'],
//       entry.value['stocks'],
//       entry.value['available'],
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
          elevation: 10.00,
          backgroundColor: Colors.cyan,
            onPressed: (){
                getallitems();
            },
            icon: Icon(Icons.refresh,color: Colors.black),
            label: Text("Refresh", style: TextStyle(color: Colors.black)),
            ),
          SizedBox(height: 10.00),
          FloatingActionButton.extended(
            elevation: 10.00,
            backgroundColor: Colors.cyan,
            onPressed: () {
              massEdit();
            },
            icon: Icon(Icons.edit,color: Colors.black),
            label: Text("Bulk Edit", style: TextStyle(color: Colors.black))
          ),
          SizedBox(height: 10.00),
          FloatingActionButton.extended(
          elevation: 10.00,
          backgroundColor: Colors.cyan,
          onPressed: (){
              addNewItem(newitemid++);
          },
          icon: Icon(Icons.add,color: Colors.black),
          label: Text("Add New Item", style: TextStyle(color: Colors.black))
          ),
          ]),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(height: 20.00),
            Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  "On Menu:",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Sort by: ", style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.w700)),
                      Text("Name", style: TextStyle(fontSize: 20.0)),
                      SizedBox(width: 10.0),
                      Text("Price", style: TextStyle(fontSize: 20.0)),
                      SizedBox(width: 10.0),
                      Text("Low_Stocks", style: TextStyle(fontSize: 20.0)),
                      SizedBox(width: 10.00)
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
                Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TriStateToggleSwitch(
                        initialState: SwitchState.inactive,
                        onChanged: (switchState) {
                          setState(() {
                            if (switchState == SwitchState.inactive) {  
                              sort = 1;
                            } else if (switchState == SwitchState.dual) {  
                              sort = 2;
                            } else {  
                              sort = 3;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
           SizedBox(height: 10),
            ],
          ),
          if (availableid.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No Items on Menu",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else 
            buildGridSection(availableid, Colors.green, Colors.white),
          SizedBox(height: 25.00),
          Align(
                alignment: Alignment.center,
                child: Text(
                  "Not on Menu:",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Sort by: ", style: TextStyle(fontSize: 22.00, fontWeight: FontWeight.w700)),
                      Text("Name", style: TextStyle(fontSize: 20.0)),
                      SizedBox(width: 10.0),
                      Text("Price", style: TextStyle(fontSize: 20.0)),
                      SizedBox(width: 10.0),
                      Text("Low_Stocks", style: TextStyle(fontSize: 20.0)),
                      SizedBox(width: 10.00)
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
                Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TriStateToggleSwitch(
                        initialState: SwitchState.inactive,
                        onChanged: (switchState) {
                          setState(() {
                            if (switchState == SwitchState.inactive) {  
                              sort = 1;
                            } else if (switchState == SwitchState.dual) {  
                              sort = 2;
                            } else {  
                              sort = 3;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.00),
          if (navailableid.isEmpty) 
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No Items Available",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else 
            buildGridSection(navailableid, Colors.grey, Colors.black),
          ],
        ),
      ),
    );
  }

Widget buildGridSection(Set<int> menuSet, Color bgColor, Color textColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 6;
          if (constraints.maxWidth < 960) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth < 1300) {
            crossAxisCount = 4;
          }
            else if (constraints.maxWidth < 1500) {
              crossAxisCount = 5;
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuSet.length,
            itemBuilder: (BuildContext context, int index) {
              int itemId = menuSet.elementAt(index);
              return GridTile(
                child: Stack(
                  children: [
                    InkWell(
                        onTap: () => delAddItem(itemId, items[itemId]?['name'], true, items[itemId]?['available']),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 285,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height:5),
                              AspectRatio(
                                aspectRatio: 1.6,
                                child: itemicon),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        items[itemId]?['name'] ?? "Unknown Item",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: (items[itemId]?['stocks'] == -1 || items[itemId]?['stocks'] >= 300)?textColor:(items[itemId]?['stocks'] > 0)?Colors.limeAccent:Colors.red,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "₹${items[itemId]?['price'].toInt() ?? 'N/A'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: (items[itemId]?['stocks'] == -1 || items[itemId]?['stocks'] >= 300)?textColor:(items[itemId]?['stocks'] > 0)?Colors.limeAccent:Colors.red, fontSize: 17),
                                ),
                              Text(
                                  "Stock: ${items[itemId]?['stocks'] == -1 ? 'Unlimited' : '${items[itemId]?['stocks']}'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: (items[itemId]?['stocks'] == -1 || items[itemId]?['stocks'] >= 300)?textColor:(items[itemId]?['stocks'] > 0)?Colors.limeAccent:Colors.red, fontSize: 17),
                                ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: IconButton(
                        hoverColor: Colors.blue,
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          modifyItem(itemId, items[itemId]?['name'], items[itemId]?['price'], items[itemId]?['is_veg'], items[itemId]?['available']);
                        },
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: IconButton(
                        hoverColor: Colors.red,
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          delAddItem(itemId, items[itemId]?['name'], false, false);
                        },
                      ),
                    ),
                    Positioned(
                      right: 45,
                      bottom: 80,
                      child: Image.asset((items[itemId]?['is_veg'])?"assets/images/veg.png":"assets/images/nonveg.png", width: 25, height: 25),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    ],
  );
}}