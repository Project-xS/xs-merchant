import 'dart:io';
import 'package:merchant/orders.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:merchant/menupage.dart';

void main(){
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  WidgetsFlutterBinding.ensureInitialized();
    setWindowMinSize(const Size(1025,1025));
  }
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
  int currentIndex = 1;
  final List<Widget> pages = [
    Center(child: Menupage()),
    Center(child: Orders()),
    Center(child: Text('Order History Page', style: TextStyle(fontSize: 30))),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FoodBoard", style:TextStyle(fontWeight:FontWeight.w500, fontSize: 35.00)),leading: Image(image: AssetImage('assets/images/logo.png')), toolbarHeight: 80.00,),
      body: Column(
        children: [Text(name, style:TextStyle(fontWeight:FontWeight.bold, fontSize:50.00),), 
        SizedBox(
          width:650,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                labelTextStyle: WidgetStatePropertyAll(TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                )),
              indicatorColor:Colors.amber,
              surfaceTintColor: Colors.grey,
              labelPadding: EdgeInsets.all(0),
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.00))),
            ),
              child: NavigationBar(
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu),
                  label: "Menu",
                  ),
                NavigationDestination(
                  icon: Icon(Icons.pending_actions),
                  label: "Orders"),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: "Order History"),],
              onDestinationSelected: (int ind){
                setState(() {
                  currentIndex=ind;
                });
              },
              selectedIndex: currentIndex,
              ),
            )),
        ),
          Expanded(
            child: pages[currentIndex],
          ),
        ],
      ),
    );
  }
}