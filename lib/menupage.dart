import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  Image icon = Image(image: AssetImage("assets/logo.png"), width: 250.00, height: 150.00);

  Map<int, Map<String, dynamic>> items = {
    1: {'name': 'Chicken Rice', 'price': 120},
    2: {'name': 'Veg Fried Rice', 'price': 100},
    3: {'name': 'Chilli Chicken', 'price': 150},
    4: {'name': 'Rice', 'price': 50},
    5: {'name': 'Rasam', 'price': 40},
    6: {'name': 'Sambar', 'price': 60},
    7: {'name': 'V Parotta', 'price': 30},
    8: {'name': 'N Parotta', 'price': 35},
    9: {'name': 'Noodles', 'price': 80},
  };

  int newitemid = 10;
  Set<int> onmenuid = {1, 2, 6, 8};
  Set<int> offmenuid = {3, 4, 5, 7, 9};

  void toggleItem(int itemId) {
    setState(() {
      if (onmenuid.contains(itemId)) {
        onmenuid.remove(itemId);
        offmenuid.add(itemId);
      } else {
        offmenuid.remove(itemId);
        onmenuid.add(itemId);
      }
    });
  }

  void changeRate(int itemId, String name) {
    int newRate = 0;
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Rate of $name:", style: TextStyle(fontWeight: FontWeight.w700)),
          content: Padding(
            padding: EdgeInsets.all(10.00),
            child: Form(
              child: TextFormField(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: "New Price - ₹", labelStyle: TextStyle(fontSize:15.00), floatingLabelStyle: TextStyle(fontSize:20.00)),
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
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: Price Cannot be Empty",style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      newRate = int.parse(controller.text);
                      if (newRate == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: Price Cannot be Changed to 0", style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      } else {
                        setState(() {
                          items[itemId] = {
                            'name' : items[itemId]?['name'],
                            'price' : newRate,
                      };});
                      }
                      Navigator.pop(context);
                    },
                    child: Row(spacing: 5.00,children:[Icon(Icons.check,color:Colors.greenAccent),Text("Submit", style:TextStyle(fontWeight: FontWeight.w600))],),
                  ),],);
      },
    );
  }

  void addNewItem(){
    showDialog(context: context, builder: (BuildContext context){
      TextEditingController controller1 = TextEditingController();
      TextEditingController controller2 = TextEditingController();
      return AlertDialog(
        title: Text("Add new Item: ",style: TextStyle(fontWeight: FontWeight.w700)),
        content: Form(
          child: Column(
            children: [TextFormField(
              controller: controller1,
              autocorrect: false,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: "Name", labelStyle: TextStyle(fontSize:15.00), floatingLabelStyle: TextStyle(fontSize:20.00)),
            ),
            TextFormField(
              controller: controller2,
              autocorrect: false,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: "Price", labelStyle: TextStyle(fontSize:15.00), floatingLabelStyle: TextStyle(fontSize:20.00)),
            ),
            ]),
            ),
      actions:[TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black), 
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      padding:WidgetStatePropertyAll(EdgeInsets.all(30.00)),
                      fixedSize: WidgetStatePropertyAll(Size.fromWidth(132)),
                      overlayColor: WidgetStatePropertyAll(const Color.fromARGB(255, 37, 113, 255))),
                    onPressed: () {
                      if (controller1.text == "" || int.parse(controller2.text) == 0){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error - Don't feed Empty Values", style: TextStyle(fontSize: 15.00, color:Colors.black, fontWeight: FontWeight.w700),),
                            backgroundColor: Colors.redAccent));
                      }
                      setState(() {
                        items[newitemid] = { 
                          'name': controller1.text,
                          'price': int.parse(controller2.text)
                          };
                        onmenuid.add(newitemid);
                        newitemid++;
                        Navigator.pop(context);
                      });
                    },
                    child: Row(spacing: 5.00,children:[Icon(Icons.check,color:Colors.greenAccent),Text("Submit", style:TextStyle(fontWeight: FontWeight.w600))],),
                  )
      ]
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:FloatingActionButton(
        backgroundColor: Colors.green,
          child:Icon(Icons.add,color: Colors.black,),
          onPressed: (){
              addNewItem();
          }),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height:10.00),
            buildGridSection("On Menu", onmenuid, Colors.green),
            SizedBox(height:15.00),
            buildGridSection("Not On Menu", offmenuid, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget buildGridSection(String title, Set<int> menuSet, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
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
                    child: GestureDetector(
                      onTap: () => toggleItem(itemId),
                      child: Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(aspectRatio: 1.5, child:icon),
                            Text(
                              items[itemId]?['name'] ?? "Unknown Item",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              "₹${items[itemId]?['price'] ?? 'N/A'}",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: IconButton(
                      hoverColor: Colors.blue,
                      icon: Icon(Icons.edit, color: Colors.black),
                      onPressed: () {
                        changeRate(itemId, items[itemId]?['name']);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
