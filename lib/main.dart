import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool isTamil = false;

  void _changeLanguage(bool value) {
    setState(() {
      isTamil = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: (isTamil)?"Tamil":null,
        brightness: Brightness.dark,
      ),
      locale: isTamil ? Locale('ta', '') : Locale('en', ''),
      supportedLocales: [
        Locale('en', ''), 
        Locale('ta', ''), 
      ],
      localizationsDelegates: [
        AppLocalizations.delegate, 
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: HomePage(changeLanguage: _changeLanguage, isTamil: isTamil),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) changeLanguage;
  final bool isTamil;

  const HomePage({super.key, required this.changeLanguage, required this.isTamil});
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
      Center(child: Menupage(portrait, widget.isTamil)),
      Center(child: OrderHistory(portrait, widget.isTamil)),
      Center(child: Orders(portrait, widget.isTamil)),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.app_name, 
        style:TextStyle(fontWeight:(widget.isTamil)?FontWeight.w800:FontWeight.w500, 
        fontSize: (portrait)?20.00:35.00)),leading: Image(image: AssetImage('assets/images/logo.png')), 
        toolbarHeight: 80.00,
        forceMaterialTransparency: true
      ),
      endDrawer: Drawer(
        child: SafeArea(
          minimum: EdgeInsets.symmetric(vertical: 50),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.language),
              SizedBox(height: 10),
              SwitchListTile(
                title: Text(((widget.isTamil) ? "English" : "தமிழ்"), style: TextStyle(fontWeight: FontWeight.w600)),
                value: widget.isTamil,
                onChanged: (value) {
                  widget.changeLanguage(value);
                },
              ),
            ],
          ),
        ),
      ),
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
                  label: AppLocalizations.of(context)!.menu,
                  ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  label: AppLocalizations.of(context)!.verify),
                NavigationDestination(
                  icon: Icon(Icons.pending_actions),
                  label: AppLocalizations.of(context)!.order),],
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
