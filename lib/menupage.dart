import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  Image icon = Image(image: AssetImage("assets/logo.png"), width: 250.00, height: 150.00);

  Map<int, Map<String, dynamic>> items = {
    1: {'name': 'Chicken Rice', 'price': 120, 'isVeg': false},
    2: {'name': 'Veg Fried Rice', 'price': 100, 'isVeg': true},
    3: {'name': 'Chilli Chicken', 'price': 150, 'isVeg': false},
    4: {'name': 'Rice', 'price': 50, 'isVeg': true},
    5: {'name': 'Rasam', 'price': 40, 'isVeg': true},
    6: {'name': 'Sambar', 'price': 60, 'isVeg': true},
    7: {'name': 'V Parotta', 'price': 30, 'isVeg': true},
    8: {'name': 'N Parotta', 'price': 35, 'isVeg': false},
    9: {'name': 'Noodles', 'price': 80, 'isVeg': false},
    10: {'name': 'special', 'price': 9999, 'isVeg': true},
    11: {'name': 'Chcken Rice', 'price': 120, 'isVeg': false},
    12: {'name': 'Veg Frie Rice', 'price': 100, 'isVeg': true},
    13: {'name': 'Chlli Chicken', 'price': 150, 'isVeg': false},
    14: {'name': 'ice', 'price': 50, 'isVeg': true},
    15: {'name': 'asam', 'price': 40, 'isVeg': true},
    16: {'name': 'Sabar', 'price': 60, 'isVeg': true},
    17: {'name': 'V arotta', 'price': 30, 'isVeg': false},
    18: {'name': 'N arotta', 'price': 35, 'isVeg': false},
    19: {'name': 'Nodles', 'price': 80, 'isVeg': true},
    20: {'name': 'oodles', 'price': 90, 'isVeg': true},
    21: {'name': 'Chicen Rice', 'price': 120, 'isVeg': false},
    22: {'name': 'Veg Fied Rice', 'price': 100, 'isVeg': true},
    23: {'name': 'Chili Chicken', 'price': 150, 'isVeg': false},
    24: {'name': 'Rie', 'price': 50, 'isVeg': false},
    25: {'name': 'Raam', 'price': 40, 'isVeg': true},
    26: {'name': 'Sambr', 'price': 60, 'isVeg': false},
    27: {'name': 'V Paotta', 'price': 30, 'isVeg': true},
    28: {'name': 'N Paotta', 'price': 35, 'isVeg': false},
    29: {'name': 'Noodes', 'price': 80, 'isVeg': false},
    30: {'name': 'odles', 'price': 90, 'isVeg': false},

  };

  int newitemid = 1;
  Set<int> onmenuid = {1, 2, 6, 8, 15, 16, 18, 24, 25, 26, 27, 30};
  Set<int> offmenuid = {3, 4, 5, 7, 9, 10, 11, 12, 13, 14, 17, 19, 20, 21, 22, 23, 28, 29};

  void modifyItem(int itemId, String oldName, int oldRate, bool isVeg) {
    int newRate = 0;
    String name = "";
    TextEditingController controllerCR = TextEditingController(text: "$oldRate");
    TextEditingController controllerN = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modify Item - $oldName :", style: TextStyle(fontWeight: FontWeight.w700)),
          content: Padding(
            padding: EdgeInsets.all(10.00),
            child: SizedBox(
              height: 170.00,
              child: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextFormField(
                      controller: controllerN,
                      maxLength: 40,
                      autofocus: true,
                      autocorrect: false,
                      decoration: InputDecoration(
                      labelText: "New Name", 
                      labelStyle: TextStyle(fontSize:15.00), 
                      floatingLabelStyle: TextStyle(fontSize:20.00)),
                ),
                    TextFormField(
                      controller: controllerCR,
                      maxLength: 4,
                      autofocus: true,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: "New Price - ₹", labelStyle: TextStyle(fontSize:15.00), floatingLabelStyle: TextStyle(fontSize:20.00)),
                    ),
                    Row(
                      children: [Text("Veg : ", style: TextStyle(fontSize:15.00)),
                        StatefulBuilder(
                          builder:(context, setState) {
                              return Checkbox(
                                value: items[itemId]?['isVeg'], 
                                onChanged: (value){
                                    setState((){
                                      if (items[itemId]?['isVeg'] == true){
                                        items[itemId]?['isVeg'] = false;
                                        isVeg = false;
                                      }
                                      else{
                                        items[itemId]?['isVeg'] = true;
                                        isVeg = true;
                                      }
                                    });
                                }
                                );}
                        ),
                      ],
                    )])
                ),
              ),
            ),
        actions: [TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black), 
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      padding:WidgetStatePropertyAll(EdgeInsets.all(30.00)),
                      fixedSize: WidgetStatePropertyAll(Size.fromWidth(132)),
                      overlayColor: WidgetStatePropertyAll(const Color.fromARGB(255, 37, 113, 255))),
                    onPressed: () {
                      if (controllerCR.text.isEmpty || controllerCR.text.isEmpty || int.tryParse(controllerCR.text) == null || int.parse(controllerCR.text) == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: Price Cannot be Empty",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      else{
                        if (controllerN.text.isEmpty || controllerN.text.isEmpty){
                          name = oldName;
                        }
                        else{
                          name = controllerN.text;
                        }
                        newRate = int.parse(controllerCR.text);
                        setState(() {
                          if (items.values.any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == name.trim().toLowerCase().replaceAll(' ', ''))){
                            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $name Already Exist - Give a new Name",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                        else{
                          items[itemId] = {
                            'name' : name,
                            'price' : newRate,
                            'isVeg' : isVeg,
                          };}
                      Navigator.pop(context);
                    });}},
                    child: Row(spacing: 5.00,children:[Icon(Icons.check,color:Colors.greenAccent),Text("Submit", style:TextStyle(fontWeight: FontWeight.w600))],),
                  ),],);
      },
    );
  }

  void addNewItem(){
    showDialog(context: context, builder: (BuildContext context){
      TextEditingController controller1 = TextEditingController();
      TextEditingController controller2 = TextEditingController();
      bool isVeg = false;
      return AlertDialog(
        title: Text("Add new Item: ",style: TextStyle(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: double.minPositive,
          height: 200.00,
          child: Form(
            child: Column(
              children: [Padding(
                padding: EdgeInsets.all(5.0),
                child: TextFormField(
                  maxLength: 40,
                  controller: controller1,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: "Name", labelStyle: TextStyle(fontSize:15.00), floatingLabelStyle: TextStyle(fontSize:20.00)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: TextFormField(
                  maxLength: 4,
                  controller: controller2,
                  autocorrect: false,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: "Price", labelStyle: TextStyle(fontSize:15.00), floatingLabelStyle: TextStyle(fontSize:20.00)),
                ),
              ),
              SizedBox(height:10.00),
              Row(
                      children: [Text("Veg : ", style: TextStyle(fontSize:15.00)),
                        StatefulBuilder(
                          builder:(context, setState) {
                              return Checkbox(
                                value: isVeg, 
                                onChanged: (value){
                                    setState((){
                                      if (isVeg){
                                        isVeg = false;
                                      }
                                      else{
                                        isVeg = true;
                                      }
                                    });
                                }
                                );}
                        ),
                      ],
                    )
              ]),
              ),
        ),
      actions:[TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black), 
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      padding:WidgetStatePropertyAll(EdgeInsets.all(30.00)),
                      fixedSize: WidgetStatePropertyAll(Size.fromWidth(132)),
                      overlayColor: WidgetStatePropertyAll(const Color.fromARGB(255, 37, 113, 255))),
                    onPressed: () {
                      String name = controller1.text.trim();
                      String priceText = controller2.text.trim();
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
                        if (offmenuid.contains(newitemid)){
                          offmenuid.remove(newitemid);
                        }
                        if (items.values.any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == name.trim().toLowerCase().replaceAll(' ', ''))){
                            newitemid = items.keys.firstWhere(
                              (key) => items[key]?['name'].toLowerCase() == name, 
                              orElse: () => newitemid = newitemid);
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                            content: Text("Exception: $name Already Exists, Changed that item details",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        items[newitemid] = { 
                          'name': name,
                          'price': int.parse(priceText),
                          'isVeg' : isVeg
                          };
                          Navigator.pop(context);
                      }
                      else{
                        items[newitemid] = { 
                          'name': name,
                          'price': int.parse(priceText),
                          'isVeg' : isVeg
                          };
                        onmenuid.add(newitemid);
                        newitemid++;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                        "Item : \"$name\" Added Successful",
                        style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: Colors.cyanAccent,
                        ));
                      Navigator.pop(context);
                      }});
                    },
                    child: Row(spacing: 5.00,children:[Icon(Icons.check,color:Colors.greenAccent),Text("Submit", style:TextStyle(fontWeight: FontWeight.w600))],),
                  )]
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
                      if (onmenuid.contains(itemId)) {
                        onmenuid.remove(itemId);
                        if (isAdd == true){
                          offmenuid.add(itemId);
                        }
                      } else {
                          offmenuid.remove(itemId);
                          if (isAdd == true){
                            onmenuid.add(itemId);
                        }
                      }
                      if (isAdd == false){
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
    bool isError = false;
    Set<String> err = {};
    Map<int, Map<String, dynamic>> changes = {};
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:Text("Multiple Item Edit:"),
          titleTextStyle: TextStyle(
              fontSize: 25.00,
              fontWeight: FontWeight.w700,
          ),
          content: SizedBox(
            height: 400.00,
            width: 500.00,
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
                          children: [
                            SizedBox(
                              width: 150.00,
                              child: TextFormField(
                                maxLength: 40,
                                initialValue: items[itemId]?['name'],
                                decoration: InputDecoration(labelText: "Item Name", counterText: ""),
                                onChanged: (value){ 
                                  if (value.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Error: Price Cannot be Empty",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                                    backgroundColor: Colors.redAccent,));
                                  }
                                  else{
                                    if (items.values.any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == value.trim().toLowerCase().replaceAll(' ', ''))){
                                      isError = true;
                                      err.add(value.trim().replaceAll(" ",""));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Exception: $value Already Exits, Change the name",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                    }
                                    else{
                                      changes[itemId]={
                                        'name' : value,
                                        'price' : changes.containsKey(itemId) == true ? (changes[itemId]?['price']) : (items[itemId]?['price']),
                                        'isVeg' : changes.containsKey(itemId) == true ? (changes[itemId]?['isVeg']) : (items[itemId]?['isVeg'])
                                      };
                                }}
                                }),
                            ),
                            SizedBox(width:10.00),
                            SizedBox(
                              width: 50.00,
                              child: TextFormField(
                                maxLength: 4,
                                initialValue: items[itemId]?['price'].toString(),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(labelText: "Price", counterText: ""),
                                onChanged: (value){ 
                                  if (value.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Error: Price Cannot be Empty",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                                    backgroundColor: Colors.redAccent,));
                                  }
                                  else{
                                    changes[itemId]={
                                      'price' : int.parse(value),
                                      'name' : changes.containsKey(itemId) == true ? (changes[itemId]?['name']) : (items[itemId]?['name']),
                                      'isVeg' : changes.containsKey(itemId) == true ? (changes[itemId]?['isVeg']) : (items[itemId]?['isVeg'])
                                    };
                                }}
                              ),
                            ),SizedBox(width:10.00),
                            StatefulBuilder(
                              builder: (context, setState) {
                              return SizedBox(
                                width: 220.00,
                                child:Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                                value: items[itemId]?['isVeg'],
                                                onChanged: (value){
                                                    setState((){
                                                      if (items[itemId]?['isVeg'] == true){
                                                        items[itemId]?['isVeg'] = false;
                                                      }
                                                      else{
                                                        items[itemId]?['isVeg'] = true;
                                                      }
                                                    });
                                                }
                                        ),
                                      Text("Veg", style: TextStyle(fontSize:15.00)), 
                                  SizedBox(width:10.00),                                  
                                  Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: onmenuid.contains(itemId),
                                      onChanged: (value) {
                                        setState(() {
                                          if (!onmenuid.contains(itemId)) {
                                            onmenuid.add(itemId);
                                            offmenuid.remove(itemId);
                                          } else {
                                            onmenuid.remove(itemId);
                                            offmenuid.add(itemId);
                                          }
                                      });
                                      },
                                    ),
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      onmenuid.contains(itemId) ? "On Menu" : "Not On Menu",
                                      style: TextStyle(fontSize: 15))
                                  ],
                                ),
                              ]));
                            }),
                          ],
                        ),
                      ],
                    ),
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
              onPressed: !isError ? () { 
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $err name Already Exists, Change that to proceed",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                      backgroundColor: Colors.redAccent,
                    ),);} 
                : () {
                  setState(() {
                    for (int i in changes.keys){
                      if(changes[i]?['name'] != items[i]?['name'] || changes[i]?['price'] != items[i]?['price']){
                        items[i] = {
                          'name' : changes[i]?['name'],
                          'price' : changes[i]?['price'],
                          'isVeg' : items[i]?['isVeg']
                        };
                      }}
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                        "Item Changes are Successful",
                        style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: Colors.cyanAccent,
                        ));
                      Navigator.pop(context);
                    });
              },
              child: Row(spacing: 5.00,children:[Icon(Icons.check,color:Colors.greenAccent),Text("Submit", style:TextStyle(fontWeight: FontWeight.w600))],),
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
              addNewItem();
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
          SizedBox(height: 10.00),
          Text("On Menu:", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
          SizedBox(height: 15.00),
          Text("Not On Menu:", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => delAddItem(itemId, items[itemId]?['name'], true, onmenuid.contains(itemId)),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.5,
                                child: icon),
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    if (items[itemId]?['isVeg'] ?? false) 
                                      Icon(Symbols.nutrition_sharp, size: 18, color: Colors.pink)
                                    else 
                                      Icon(Icons.kebab_dining, size: 18, color: Colors.brown),
                                  ],
                                ),
                                ),
                              AspectRatio(
                                aspectRatio: 10,
                                child: Text(
                                  "₹${items[itemId]?['price'] ?? 'N/A'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
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
                          modifyItem(itemId, items[itemId]?['name'], items[itemId]?['price'], items[itemId]?['isVeg']);
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