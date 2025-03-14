import 'dart:io';
// import 'package:flutter/services.dart';
import 'package:merchant/orderhistory.dart';
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
    debugShowCheckedModeBanner: false,
    theme:ThemeData.dark(),
    home:HomePage()));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool portrait = false;

  @override
  void initState() {
    super.initState();
    _updatePortrait();
  }

  void _updatePortrait() {
    if (Platform.isAndroid) {
      portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    }
    else {
      portrait = false;
  }
  }

  String name="Maaran Parotta Kadai";
  int currentIndex = 1;
  List<Widget> getPages(bool portrait) {
    return [
      Center(child: Menupage(portrait)),
      Center(child: OrderHistory(portrait)),
      Center(child: Orders(portrait)),
    ];
  }
  @override
  Widget build(BuildContext context) {
    _updatePortrait();
    return Scaffold(
      appBar: AppBar(title: Text("Namma Canteen", style:TextStyle(fontWeight:FontWeight.w500, fontSize: (portrait)?20.00:35.00)),leading: Image(image: AssetImage('assets/images/logo.png')), toolbarHeight: 80.00,),
      body: Column(
        children: [Text(name, style:TextStyle(fontWeight:FontWeight.bold, fontSize:(portrait)?25.00:50.00),), 
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
                  icon: Icon(Icons.local_shipping_outlined),
                  label: "Order Verification"),
                NavigationDestination(
                  icon: Icon(Icons.pending_actions),
                  label: "Orders"),],
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
            child: getPages(portrait)[currentIndex],
          ),
        ],
      ),
    );
  }
}
