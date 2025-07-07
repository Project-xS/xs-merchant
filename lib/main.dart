import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/billing.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/login.dart' as login;
import 'package:merchant/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:merchant/orderhistory.dart';
import 'package:merchant/orders.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter/material.dart';
import 'package:merchant/menupage.dart';

late SharedPreferences cache;

 void imageexpired(Map<String,String> updatedimage) async{
    cache.setString('time', DateTime.now().toString());
    cache.setString('piclink', jsonEncode(updatedimage));
}

  void changeimage(int id, String url) async{
    final list = jsonDecode(cache.getString("piclink")!) as Map<String, dynamic>;
    list.map((itemId, url)=> MapEntry(itemId.toString(), url));
    list[id.toString()] = url;
    cache.setString("piclink", jsonEncode(list));
    GlobalMenuCache.items[id]?['pic'] = url;
  }

  String name = "";

  final storage = FlutterSecureStorage(aOptions: (isAndroid)
      ? AndroidOptions(encryptedSharedPreferences: true)
      : AndroidOptions.defaultOptions);

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1025,1025));
  }
  cache = await SharedPreferences.getInstance();
  //Delete the cache of Username and Password along with Canteenid
    // storage.deleteAll(aOptions: (isAndroid)
    // ? AndroidOptions(encryptedSharedPreferences: true)
    // : AndroidOptions.defaultOptions);
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class GlobalMenuCache {
  static Map<int, Map<String, dynamic>> items = {};
  static LinkedHashSet<int> availableid = LinkedHashSet();
  static LinkedHashSet<int> navailableid = LinkedHashSet();
}

class MyAppState extends State<MyApp>  with AutoFetchMixin<MyApp>{
  bool isTamil = false;
  bool isLoggedin = login.isLoggedin;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    GlobalMenuCache.items.clear();
    GlobalMenuCache.availableid.clear();
    GlobalMenuCache.navailableid.clear();
    initApp();
    super.initState();
  }

  @override
  void dispose() {
    GlobalMenuCache.items.clear();
    GlobalMenuCache.availableid.clear();
    GlobalMenuCache.navailableid.clear();
    timer?.cancel();
    super.dispose();
  }


  @override
  int get canteenIdToFetch => canteenId;

  Future<void> initApp() async {
    await firstTimeloggedin();
  }

  Future<void> firstTimeloggedin() async{
      int id = int.parse(await storage.read(key: "CanteenId") ?? "0");
      String uname = (await storage.read(key: "Username") ?? "").toUpperCase();
      String c;
      [_, _, c] = await LoginState().details();
      if(id != 0){
        setState(() {
          isLoggedin = true;
          canteenId = int.parse(c);
          name = uname;
          });
      }
  }

  void _changeLanguage(bool value) {
    setState(() {
      isTamil = value;
    });
  }

  void updateLoginState(bool loggedIn, int id, String canteenname) {
    setState(() {
      isLoggedin = loggedIn;
      canteenId = id;
      name = canteenname;
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
      home: (isLoggedin == true)? HomePage(changeLanguage: _changeLanguage, isTamil: isTamil, canteenId: canteenId, isLoggedin: isLoggedin, updateLoginState: updateLoginState)
          : login.Login(updateLoginState: updateLoginState),
    );
  } 
}

class HomePage extends StatefulWidget {
  final Function(bool) changeLanguage;
  final bool isTamil;
  final bool isLoggedin;
  final int canteenId;
  final Function(bool, int, String) updateLoginState;

  const HomePage({super.key, required this.isLoggedin, required this.changeLanguage, required this.isTamil, required this.canteenId, required this.updateLoginState});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool portrait = login.isAndroid;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  int currentIndex = 1;
  List<Widget> getPages(bool portrait) {
    return [
      Center(child: Menupage(portrait, widget.isTamil, widget.canteenId)),
      Center(child: OrderHistory(portrait, widget.isTamil, widget.canteenId)),
      Center(child: Orders(portrait, widget.isTamil, widget.canteenId)),
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
          minimum: EdgeInsets.only(top: 50, bottom: 5),
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
              SizedBox(height: 20),
              (portrait)?SizedBox.shrink():ListTile(
                leading: Icon(Icons.receipt_long),
                horizontalTitleGap: 30,
                title: Text(AppLocalizations.of(context)!.billing, style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  Billing(name, portrait, widget.isTamil, widget.canteenId)));
                },
              ),
              SizedBox(height: 20),
              (currentIndex != 0)?Text(""):ListTile(
                leading: Icon(Icons.refresh),
                horizontalTitleGap: 30,
                title: Text("Force Refresh Images", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  setState((){                    
                    ImageUploadState().getallimage(imageexpired);
                  });
                },
              ),
              Expanded(child: Container()),
              ListTile(
                leading: Icon(Icons.logout),
                horizontalTitleGap: 30,
                title: Text("Log Out", style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  setState((){
                    widget.updateLoginState(false, widget.canteenId, name.toLowerCase());
                  });
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
