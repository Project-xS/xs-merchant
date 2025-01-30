import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme:ThemeData.dark(),
    home:HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name="PKS";
  int currentindex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FoodBoard", style:TextStyle(fontWeight:FontWeight.w500, fontSize: 35.00)),leading: Image(image: AssetImage('assets/logo.png')), toolbarHeight: 80.00,),
      body: Column(
        children: [Text(name, style:TextStyle(fontWeight:FontWeight.bold, fontSize:50.00),), 
        NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              label: "Menu",
              // selectedIcon:pages(selectedIndex);
              ),
            NavigationDestination(
              icon: Icon(Icons.pending_actions),
              label: "Orders"),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: "Order History"),],
          onDestinationSelected: (int ind){
            setState(() {
              currentindex=ind;
            });
            // Navigator.of(context).push(
            //   MaterialPageRoute(builder: (context) )
            // )
          },
          selectedIndex: currentindex,
          indicatorColor:Colors.amber,
          surfaceTintColor: Colors.grey,
          indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.00)),) ,
          ) ,]
      ,
        ),);
  }
}
