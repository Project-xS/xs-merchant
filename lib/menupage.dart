import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant/tristatetoggle.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}


class _MenupageState extends State<Menupage> {
  Image icon = Image(image: AssetImage("assets/images/logo.png"), width: 256.00, height: 256.00);
  Image itemicon = Image(image: AssetImage("assets/images/friedrice.png"));
  int sort = 1;
  Map<int, Map<String, dynamic>> item = {
    1: {'name': 'Chicken Rice', 'price': 120, 'isVeg': false, 'onmenu': true},
    2: {'name': 'Veg Fried Rice', 'price': 100, 'isVeg': true, 'onmenu': true},
    3: {'name': 'Chilli Chicken', 'price': 150, 'isVeg': false, 'onmenu': true},
    4: {'name': 'Rice', 'price': 50, 'isVeg': true, 'onmenu': true},
    5: {'name': 'Rasam', 'price': 40, 'isVeg': true, 'onmenu': true},
    6: {'name': 'Sambar', 'price': 60, 'isVeg': true, 'onmenu': false},
    7: {'name': 'V Parotta', 'price': 30, 'isVeg': true, 'onmenu': true},
    8: {'name': 'N Parotta', 'price': 35, 'isVeg': false, 'onmenu': false},
    9: {'name': 'Noodles', 'price': 80, 'isVeg': false, 'onmenu': false},
    10: {'name': 'special', 'price': 9999, 'isVeg': true, 'onmenu': true},
    11: {'name': 'Chcken Rice', 'price': 120, 'isVeg': false, 'onmenu': false},
    12: {'name': 'Veg Frie Rice', 'price': 100, 'isVeg': true, 'onmenu': false},
    13: {'name': 'Chlli Chicken', 'price': 150, 'isVeg': false, 'onmenu': true},
    14: {'name': 'ice', 'price': 50, 'isVeg': true, 'onmenu': false},
    15: {'name': 'asam', 'price': 40, 'isVeg': true, 'onmenu': false},
    16: {'name': 'Sabar', 'price': 60, 'isVeg': true, 'onmenu': false},
    17: {'name': 'V arotta', 'price': 30, 'isVeg': false, 'onmenu': false},
    18: {'name': 'N arotta', 'price': 35, 'isVeg': false, 'onmenu': false},
    19: {'name': 'Nodles', 'price': 80, 'isVeg': true, 'onmenu': true},
    20: {'name': 'oodles', 'price': 90, 'isVeg': true, 'onmenu': false},
    21: {'name': 'Chicen Rice', 'price': 120, 'isVeg': false, 'onmenu': false},
    22: {'name': 'Veg Fied Rice', 'price': 100, 'isVeg': true, 'onmenu': false},
    23: {'name': 'Chili Chicken', 'price': 150, 'isVeg': false, 'onmenu': false},
    24: {'name': 'Rie', 'price': 50, 'isVeg': false, 'onmenu': false},
    25: {'name': 'Raam', 'price': 40, 'isVeg': true, 'onmenu': false},
    26: {'name': 'Sambr', 'price': 60, 'isVeg': false, 'onmenu': false},
    27: {'name': 'V Paotta', 'price': 30, 'isVeg': true, 'onmenu': false},
    28: {'name': 'N Paotta', 'price': 35, 'isVeg': false, 'onmenu': false},
    29: {'name': 'Noodes', 'price': 80, 'isVeg': false, 'onmenu': false},
    30: {'name': 'odles', 'price': 90, 'isVeg': false, 'onmenu': false},
  };

  int newitemid = 31;
  Map<int, Map<String, dynamic>> get items {
  var sortedEntries = item.entries.toList();

  if (sort == 1) {
    sortedEntries.sort((a, b) => a.value["name"].toLowerCase().replaceAll(' ', '').compareTo(b.value["name"].toLowerCase().replaceAll(' ', '')));
  } else if (sort == 2) {
    sortedEntries.sort((a, b) => b.value["price"].compareTo(a.value["price"]));
  } else if (sort == 3) {
    sortedEntries.sort((a, b) => (a.value["isVeg"] ? 0 : 1).compareTo(b.value["isVeg"] ? 0 : 1));
  }

  return {for (var entry in sortedEntries) entry.key: entry.value};
}

Set<int> get onmenuid =>
    items.entries.where((entry) => entry.value['onmenu'] == true).map((entry) => entry.key).toSet();

Set<int> get offmenuid =>
    items.entries.where((entry) => entry.value['onmenu'] == false).map((entry) => entry.key).toSet();

  void modifyItem(int itemId, String oldName, int oldRate, bool isVeg, bool onmenu) {
    bool isError = false;
    String name = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Modify Item - $oldName :", style: TextStyle(fontWeight: FontWeight.w700)),
              content: Padding(
                padding: EdgeInsets.all(10.00),
                child: SizedBox(
                  height: 190.00,
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
                          initialValue: oldRate.toString(),
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
                              oldRate = int.tryParse(value) ?? oldRate;
                            });
                          },
                        ),
                        Row(
                          children: [
                            Text("Veg : ", style: TextStyle(fontSize: 15.00)),
                            StatefulBuilder(
                              builder:(context, setState) {
                              return Checkbox(
                                value: isVeg,
                                onChanged: (value) {
                                  setState(() {
                                    isVeg = value ?? false;
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
                            'isVeg': isVeg,
                            'onmenu': onmenu
                          };
                        });
                        Navigator.pop(context);
                        }
                      },
                  child: Row(children: [
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
    bool isVeg = false;
    bool onmenu = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add new Item: ", style: TextStyle(fontWeight: FontWeight.w700)),
            content: SizedBox(
              width: double.minPositive,
              height: 205.00,
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
                StatefulBuilder(builder: (context, setState) {
                  return Row(
                    children: [
                      Text("Veg : ", style: TextStyle(fontSize: 15.00)),
                      Checkbox(
                        value: isVeg,
                        onChanged: (value) {
                          setState(() {
                            isVeg = value ?? false;
                            if (value == null || isVeg == false){
                              isVeg = false;
                            }
                            else{
                              isVeg = true;
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
                        'price': int.parse(priceText),
                        'isVeg': isVeg,
                        'onmenu': onmenu
                      };
                      if (offmenuid.contains(foundItemId)){
                        offmenuid.remove(foundItemId);
                      }
                      }
                      else{
                        item[olditemid+1] = {
                        'name': name,
                        'price': int.parse(priceText),
                        'isVeg': isVeg,
                        'onmenu': onmenu
                      };
                      onmenuid.add(newitemid);
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
                child: Row(children: [Icon(Icons.check, color: Colors.greenAccent), Text("Submit", style: TextStyle(fontWeight: FontWeight.w600))]),
              ),
            ],
          );
        });
  }

  void delAddItem(int itemId, String name, bool isAdd , bool onmenu){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Do you want to ${(isAdd && onmenu)?"Remove \"$name\" from the Menu":((isAdd && !onmenu)?"Add \"$name\" to the Menu":"Delete \"$name\"")}", style: TextStyle(fontWeight: FontWeight.w700)),
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
                  backgroundColor: WidgetStatePropertyAll(isAdd?(onmenu?Colors.yellow:Colors.green):Colors.red),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)), 
                  fixedSize: WidgetStatePropertyAll(Size(120, 45)),
                  overlayColor: WidgetStatePropertyAll(isAdd?(onmenu?Colors.yellowAccent:Colors.greenAccent):Colors.redAccent),
                ),
                onPressed: () {
                    setState(() {
                      if (item[itemId]?['onmenu']) {
                        if (isAdd == true){
                          onmenuid.remove(itemId);
                          offmenuid.add(itemId);
                          item[itemId]?['onmenu'] = false;
                        }
                      } else {
                          if (isAdd == true){
                            item[itemId]?['onmenu'] = true;
                            onmenuid.add(itemId);
                            offmenuid.remove(itemId);
                        }
                      }
                      if (isAdd == false){
                        if (onmenuid.contains(itemId)){
                          onmenuid.remove(itemId);
                        }
                        else{
                          offmenuid.remove(itemId);
                        }
                        items.remove(itemId);
                      }
                      Navigator.pop(context);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Item : ${(isAdd && onmenu)?"$name Removed from Menu":((isAdd && !onmenu)?"$name Added to the Menu":"$name Deleted Successfully")}",
                        style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: (isAdd && onmenu)?Colors.yellowAccent:((isAdd && !onmenu)?Colors.cyanAccent:Colors.redAccent))
                  );
                },
                child: Text((isAdd && onmenu)?"Remove":((isAdd && !onmenu)?"Add":"Delete")),
          )],
          ),
        ),
      );
    },
  );
}
  
  void massEdit() {
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
                width: 477.00,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    int itemId = items.keys.elementAt(index);
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
                                                'isVeg': changes.containsKey(itemId) ? (changes[itemId]?['isVeg']) : (items[itemId]?['isVeg']),
                                                'onmenu': changes.containsKey(itemId) ? (changes[itemId]?['onmenu']) : (items[itemId]?['onmenu'])
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
                                      maxLength: 4,
                                      initialValue: items[itemId]?['price'].toString(),
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
                                            'price': int.parse(value),
                                            'name': changes.containsKey(itemId) ? (changes[itemId]?['name']) : (items[itemId]?['name']),
                                            'isVeg': changes.containsKey(itemId) ? (changes[itemId]?['isVeg']) : (items[itemId]?['isVeg']),
                                            'onmenu': changes.containsKey(itemId) ? (changes[itemId]?['onmenu']) : (items[itemId]?['onmenu'])

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
                                    width: 70.00,
                                    child: StatefulBuilder(
                                      builder: (context, setState) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: item[itemId]?['isVeg'],
                                              onChanged: (value) {
                                                setState(() {
                                                  item[itemId]?['isVeg'] = !(item[itemId]?['isVeg'] ?? false);
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
                                              value: item[itemId]?['onmenu'],
                                              onChanged: (value) {
                                                setState(() {
                                                  if (!item[itemId]?['onmenu']) {
                                                    item[itemId]?['onmenu'] = true;
                                                    if(offmenuid.contains(itemId)){
                                                      offmenuid.remove(itemId);
                                                    }
                                                    onmenuid.add(itemId);
                                                  } else {
                                                    item[itemId]?['onmenu'] = false;
                                                    onmenuid.remove(itemId);
                                                    offmenuid.add(itemId);
                                                  }
                                                });
                                              },
                                            ),
                                            Expanded(
                                              child: Text(
                                                item[itemId]?['onmenu'] ? "On Menu" : "Not On Menu",
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
                              if (changes[i]?['name'] != items[i]?['name'] || changes[i]?['price'] != items[i]?['price']) {
                                item[i] = {
                                  'name': changes[i]?['name'],
                                  'price': changes[i]?['price'],
                                  'isVeg': item[i]?['isVeg'],
                                  'onmenu': item[i]?['onmenu']
                                };
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
                  child: Row(children: [Icon(Icons.check, color: Colors.greenAccent), Text("Submit", style: TextStyle(fontWeight: FontWeight.w600))]),
                ),
              ],
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [FloatingActionButton(
        elevation: 10.00,
        backgroundColor: Colors.cyan,
          onPressed: (){
              addNewItem(newitemid++);
          },
          child: Icon(Icons.add,color: Colors.black)
          ),
          SizedBox(width: 10.00),
          FloatingActionButton(
            elevation: 10.00,
            backgroundColor: Colors.cyan,
            onPressed: () {
              massEdit();
            },
            child: Icon(Icons.edit,color: Colors.black),
          )]),
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
                      Text("Veg", style: TextStyle(fontSize: 20.0)),
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
                      // Text("Sort:", style: TextStyle(fontSize: 20.0)),
                      // SizedBox(width: 5.0),
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
          if (onmenuid.isEmpty)
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
            buildGridSection(onmenuid, Colors.green),
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
                      Text("Veg", style: TextStyle(fontSize: 20.0)),
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
          if (offmenuid.isEmpty) 
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
            buildGridSection(offmenuid, Colors.grey),
          ],
        ),
      ),
    );
  }

Widget buildGridSection(Set<int> menuSet, Color bgColor) {
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
                        onTap: () => delAddItem(itemId, items[itemId]?['name'], true, items[itemId]?['onmenu']),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height:20),
                              AspectRatio(
                                aspectRatio: 1.5,
                                child: itemicon),
                              AspectRatio(
                                aspectRatio: 10,
                                  child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        items[itemId]?['name'] ?? "Unknown Item",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              AspectRatio(
                                aspectRatio: 10,
                                child: Text(
                                  "₹${items[itemId]?['price'] ?? 'N/A'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
                                ),
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
                          modifyItem(itemId, items[itemId]?['name'], items[itemId]?['price'], items[itemId]?['isVeg'], items[itemId]?['onmenu']);
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
                      bottom: 60,
                      child: Image.asset((items[itemId]?['isVeg'])?"assets/images/veg.png":"assets/images/nonveg.png", width: 25, height: 25),
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