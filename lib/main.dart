import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/billing.dart';
import 'package:merchant/mobile_billing.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/login.dart' as login;
import 'package:merchant/login.dart';
import 'package:merchant/menupage.dart';
import 'package:merchant/orderhistory.dart';
import 'package:merchant/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

late SharedPreferences cache;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void imageexpired(Map<String, String> updatedimage) async {
  cache.setString('time', DateTime.now().toString());
  cache.setString('piclink', jsonEncode(updatedimage));
}

void changeimage(int id, String url) async {
  final list = jsonDecode(cache.getString("piclink")!) as Map<String, dynamic>;
  list.map((itemId, url) => MapEntry(itemId.toString(), url));
  list[id.toString()] = url;
  cache.setString("piclink", jsonEncode(list));
  GlobalMenuCache.items[id]?['pic'] = url;
}

String name = "";

final storage = FlutterSecureStorage(
    aOptions: (isAndroid)
        ? const AndroidOptions(encryptedSharedPreferences: true)
        : AndroidOptions.defaultOptions);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1025, 1025));
  }
  cache = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class GlobalMenuCache {
  static Map<int, Map<String, dynamic>> items = {};
  static LinkedHashSet<int> availableid = LinkedHashSet();
  static LinkedHashSet<int> navailableid = LinkedHashSet();
}

class OpenBillingPageIntent extends Intent {
  const OpenBillingPageIntent();
}

class OpenBillingPageAction extends Action<OpenBillingPageIntent> {
  OpenBillingPageAction({
    required this.name,
    required this.isTamil,
    required this.canteenId,
    required this.isPortrait,
  });

  final String name;
  final bool isTamil;
  final int canteenId;
  final bool isPortrait;

  @override
  void invoke(OpenBillingPageIntent intent) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => isPortrait
              ? MobileBilling(name, isTamil, canteenId)
              : Billing(name, isPortrait, isTamil, canteenId),
        ),
      );
    }
  }
}

class MyAppState extends State<MyApp> with AutoFetchMixin<MyApp> {
  bool isTamil = false;
  bool isLoggedin = login.isLoggedin;
  // bool isLoggedin = false;

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

  Future<void> firstTimeloggedin() async {
    int id = int.parse(await storage.read(key: "CanteenId") ?? "0");
    String uname = (await storage.read(key: "Username") ?? "").toUpperCase();
    String c;
    [_, _, c] = await LoginState().details();
    if (id != 0) {
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
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB): const OpenBillingPageIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenBillingPageIntent: OpenBillingPageAction(
            name: name,
            isTamil: isTamil,
            canteenId: canteenId,
            isPortrait: login.isAndroid,
          ),
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: (isTamil) ? "Tamil" : 'Catamaran',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
            primaryColor: const Color(0xFF0D1117),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF238636),
              secondary: Color(0xFF30A14E),
              surface: Colors.black,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              error: Colors.redAccent,
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              titleLarge: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              bodyLarge: TextStyle(
                  fontSize: 16, color: Colors.white, fontWeight: FontWeight.normal),
              bodyMedium: TextStyle(
                  fontSize: 14, color: Color(0xFF8B949E), fontWeight: FontWeight.normal),
              labelLarge: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            cardTheme: const CardThemeData(
              elevation: 4,
              color: Color(0xFF161B22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromARGB(0, 22, 27, 34),
              selectedItemColor: Color(0xFF238636),
              unselectedItemColor: Color(0xFF8B949E),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
            ),
          ),
          locale: isTamil ? const Locale('ta', '') : const Locale('en', ''),
          supportedLocales: const [
            Locale('en', ''),
            Locale('ta', ''),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: (isLoggedin == true)
              ? HomePage(
                  changeLanguage: _changeLanguage,
                  isTamil: isTamil,
                  canteenId: canteenId,
                  isLoggedin: isLoggedin,
                  updateLoginState: updateLoginState)
              : login.Login(updateLoginState: updateLoginState),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) changeLanguage;
  final bool isTamil;
  final bool isLoggedin;
  final int canteenId;
  final Function(bool, int, String) updateLoginState;

  const HomePage(
      {super.key,
      required this.isLoggedin,
      required this.changeLanguage,
      required this.isTamil,
      required this.canteenId,
      required this.updateLoginState});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool portrait = login.isAndroid;
  int currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePortrait();
  }

  void _updatePortrait() {
    if (Platform.isAndroid) {
      portrait = MediaQuery.of(context).orientation == Orientation.portrait;
    } else {
      portrait = false;
    }
  }

  List<Widget> getPages(bool portrait) {
    return [
      Menupage(portrait, widget.isTamil, widget.canteenId),
      OrderHistory(portrait, widget.isTamil, widget.canteenId),
      Orders(portrait, widget.isTamil, widget.canteenId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      appBar: AppBar(
        title: Text(
          localizations.app_name,
          style: theme.textTheme.titleLarge,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'More',
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(178, 22, 27, 34),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                border: Border.all(color: const Color.fromARGB(51, 255, 255, 255)),
              ),
              child: SafeArea(
                minimum: const EdgeInsets.only(top: 40, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        localizations.language,
                        style: theme.textTheme.titleLarge?.copyWith(color: const Color.fromARGB(204, 255, 255, 255)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: Text(
                        widget.isTamil ? "English" : "தமிழ்",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      value: widget.isTamil,
                      onChanged: widget.changeLanguage,
                      activeColor: theme.colorScheme.primary,
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.receipt_long, size: 28),
                      title: Text(
                        localizations.billing,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => portrait
                                ? MobileBilling(
                                    name, widget.isTamil, widget.canteenId)
                                : Billing(
                                    name, portrait, widget.isTamil, widget.canteenId),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.image_outlined, size: 28),
                      title: Text(
                        "Set new Canteen Image",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        await pickAndUploadCanteenImage(context, widget.canteenId);
                        if(context.mounted){
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Spacer(),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: Icon(Icons.logout, size: 28, color: theme.colorScheme.error),
                      title: Text(
                        "Log Out",
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error),
                      ),
                      onTap: () {
                        widget.updateLoginState(false, widget.canteenId, name.toLowerCase());
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Center(
              child: Text(
                "Welcome, $name",
                style: theme.textTheme.displayLarge,
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: getPages(portrait)[currentIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.restaurant_menu_outlined),
                activeIcon: const Icon(Icons.restaurant_menu),
                label: localizations.menu,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history_outlined),
                activeIcon: const Icon(Icons.history),
                label: localizations.verify,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.pending_actions_outlined),
                activeIcon: const Icon(Icons.pending_actions),
                label: localizations.order,
              ),
            ],
            onTap: (int ind) {
              setState(() {
                currentIndex = ind;
              });
            },
            currentIndex: currentIndex,
          ),
        ),
      ),
    );
  }
}