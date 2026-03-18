import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/auth/auth_service.dart';
import 'package:merchant/billing.dart';
import 'package:merchant/mobile_billing.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/login.dart';
import 'package:merchant/menupage.dart';
import 'package:merchant/models/menu_item.dart';
import 'package:merchant/orderhistory.dart';
import 'package:merchant/orders.dart';
import 'package:merchant/sales_prediction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';

import 'package:merchant/api/api_constants.dart';
import 'package:merchant/menu/edit_item_dialog.dart';
import 'package:merchant/providers/canteen_status_provider.dart';
import 'package:merchant/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:merchant/common/notification_service.dart';

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
  final item = GlobalMenuCache.items[id];
  if (item != null) {
    GlobalMenuCache.items[id] = item.copyWith(pic: url);
  }
}

String name = "";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init(
    onTap: (details) {
      _HomePageState.scaffoldKey.currentState?.openEndDrawer();
    },
  );
  await dotenv.load(fileName: ".env", isOptional: true);
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1025, 1025));
  }
  cache = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CanteenStatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
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
  bool isLoggedin = false;
  int canteenId = 0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    GlobalMenuCache.items.clear();
    GlobalMenuCache.availableid.clear();
    GlobalMenuCache.navailableid.clear();
    ApiClient.onUnauthorized = () {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (mounted) {
        updateLoginState(false, 0, '');
      }
    };
    ApiClient.onForbidden = () {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Insufficient privileges.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    };
    initApp();
    super.initState();
  }

  @override
  void dispose() {
    GlobalMenuCache.items.clear();
    GlobalMenuCache.availableid.clear();
    GlobalMenuCache.navailableid.clear();
    ApiClient.onUnauthorized = null;
    ApiClient.onForbidden = null;
    timer?.cancel();
    super.dispose();
  }

  @override
  int get canteenIdToFetch => canteenId;

  Future<void> initApp() async {
    await firstTimeloggedin();
  }

  Future<void> firstTimeloggedin() async {
    final session = await AuthService.loadFromStorage();
    if (session != null && !session.isExpired) {
      final displayName = (session.canteenName ?? " ").trim().toUpperCase();
      updateLoginState(true, session.canteenId ?? 0, displayName);
    }
  }

  void _changeLanguage(bool value) {
    setState(() {
      isTamil = value;
    });
  }

  void updateLoginState(bool loggedIn, int id, String canteenname) {
    if (!mounted) return;
    setState(() {
      isLoggedin = loggedIn;
      canteenId = id;
      name = canteenname;
    });
    final statusProvider = Provider.of<CanteenStatusProvider>(
      context,
      listen: false,
    );
    if (loggedIn) {
      statusProvider.refresh();
    } else {
      statusProvider.stopPolling();
    }
  }

  @override
  Future<void> fetchAndCacheAndNotify() async {
    if (!mounted || !AuthService.isLoggedIn) return;
    final statusProvider = Provider.of<CanteenStatusProvider>(
      context,
      listen: false,
    );
    statusProvider.refresh(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
            const OpenBillingPageIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenBillingPageIntent: OpenBillingPageAction(
            name: name,
            isTamil: isTamil,
            canteenId: canteenId,
            isPortrait: Platform.isAndroid || Platform.isIOS,
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
              surfaceContainerHighest: Color(0xFF1C2128),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              error: Colors.redAccent,
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headlineMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleLarge: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleMedium: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B949E),
                fontWeight: FontWeight.normal,
              ),
              bodySmall: TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
              labelLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Catamaran',
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: const CardThemeData(
              elevation: 4,
              color: Color(0xFF161B22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: const Color(0xFF161B22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titleTextStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Catamaran',
              ),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF161B22),
              labelStyle: const TextStyle(color: Color(0xFF8B949E)),
              hintStyle: const TextStyle(color: Color(0xFF8B949E)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromARGB(77, 255, 255, 255),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF238636)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
          supportedLocales: const [Locale('en', ''), Locale('ta', '')],
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
                  updateLoginState: updateLoginState,
                )
              : Login(updateLoginState: updateLoginState),
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

  const HomePage({
    super.key,
    required this.isLoggedin,
    required this.changeLanguage,
    required this.isTamil,
    required this.canteenId,
    required this.updateLoginState,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  bool portrait = Platform.isAndroid || Platform.isIOS;
  int currentIndex = 0;

  void _showEditDialogFromNotification(BuildContext context, MenuItem item) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EditItemDialog(
          itemId: item.id,
          initialName: item.name,
          initialPrice: item.price,
          initialStock: item.stock,
          initialIsVeg: item.isVeg,
          initialAvailable: item.available,
          canteenId: widget.canteenId,
          isPortrait: portrait,
          onUpdate: (name, price, stock, isVeg, isAvailable, imageBytes) async {
            if (imageBytes != null) {
              String? url = await ImageUploadState().imageupload(
                item.id,
                imageBytes,
              );
              if (url != null && url.isNotEmpty) {
                setState(() {
                  final currentItem = GlobalMenuCache.items[item.id];
                  if (currentItem != null) {
                    GlobalMenuCache.items[item.id] = currentItem.copyWith(
                      pic: url,
                    );
                    changeimage(item.id, url);
                  }
                });
              }
            }
            // Update item logic similar to Menupage
            try {
              final response = await ApiClient.put(
                ApiConstants.menuUpdate,
                headers: {
                  'accept': 'application/json',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  "item_id": item.id,
                  "update": {
                    "is_available": isAvailable,
                    "is_veg": isVeg,
                    "name": name,
                    "price": price,
                    "stock": stock,
                  },
                }),
              );

              if (response.statusCode >= 200 && response.statusCode < 300) {
                // Remove notification from provider immediately on success
                final navContext = navigatorKey.currentContext;
                if (navContext != null && navContext.mounted) {
                  Provider.of<NotificationProvider>(
                    navContext,
                    listen: false,
                  ).removeNotification(item.id);
                }

                setState(() {
                  GlobalMenuCache.items[item.id] = item.copyWith(
                    name: name,
                    price: price,
                    stock: stock,
                    isVeg: isVeg,
                    available: isAvailable,
                  );
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Item updated successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error updating item: ${response.statusCode}",
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            } catch (e) {
              debugPrint("Error updating item: $e");
            }
          },
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePortrait();
  }

  void _updatePortrait() {
    if (Platform.isAndroid || Platform.isIOS) {
      final newPortrait =
          MediaQuery.orientationOf(context) == Orientation.portrait;
      if (portrait != newPortrait) {
        setState(() {
          portrait = newPortrait;
        });
      }
    } else {
      if (portrait != false) {
        setState(() {
          portrait = false;
        });
      }
    }
  }

  Widget _buildStatusChip(
    ThemeData theme,
    AppLocalizations localizations,
    CanteenStatusProvider status,
  ) {
    final bool hasStatus = status.hasStatus;
    final bool isAlwaysOpen = status.isAlwaysOpen;
    final bool isOpen = status.isOpen;

    String label;
    Color baseColor;

    if (!hasStatus) {
      label = localizations.shop_status_unknown;
      baseColor = theme.colorScheme.onSurfaceVariant;
    } else if (!isOpen) {
      label = localizations.shop_closed;
      baseColor = theme.colorScheme.error;
    } else if (isAlwaysOpen) {
      label = localizations.always_open;
      baseColor = theme.colorScheme.primary;
    } else {
      label = localizations.shop_open;
      baseColor = Colors.green;
    }

    final chip = ActionChip(
      onPressed: !hasStatus || status.isLoading
          ? null
          : () async {
              final confirmed = await _confirmShopToggle(
                context,
                localizations,
                isOpen,
              );
              if (!confirmed || !context.mounted) return;

              final error = isOpen
                  ? await status.closeCanteen()
                  : await status.openCanteen();
              if (!context.mounted) return;
              if (error != null && error.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: baseColor,
                ),
              ),
            ),
          Text(
            label,
            style:
                theme.textTheme.labelLarge?.copyWith(color: baseColor) ??
                TextStyle(color: baseColor),
          ),
        ],
      ),
      backgroundColor: baseColor.withOpacity(0.15),
      side: BorderSide(color: baseColor.withOpacity(0.4)),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );

    final error = status.error;
    if (error != null && error.isNotEmpty) {
      return Tooltip(message: error, child: chip);
    }
    return chip;
  }

  Widget? _buildStatusActionButton(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
    CanteenStatusProvider status,
  ) {
    if (!status.hasStatus) return null;

    final bool isOpen = status.isOpen;
    final String label = isOpen
        ? localizations.close_shop
        : localizations.open_shop;
    final IconData icon = isOpen ? Icons.lock : Icons.lock_open;
    final Color btnColor = isOpen
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return FilledButton.icon(
      onPressed: status.isLoading
          ? null
          : () async {
              final confirmed = await _confirmShopToggle(
                context,
                localizations,
                isOpen,
              );
              if (!confirmed || !context.mounted) return;

              final error = isOpen
                  ? await status.closeCanteen()
                  : await status.openCanteen();
              if (!context.mounted) return;
              if (error != null && error.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        minimumSize: const Size(0, 44),
        textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
      ),
    );
  }

  Future<bool> _confirmShopToggle(
    BuildContext context,
    AppLocalizations localizations,
    bool isOpen,
  ) async {
    final title = isOpen ? localizations.close_shop : localizations.open_shop;
    final message = isOpen
        ? localizations.confirm_close_shop
        : localizations.confirm_open_shop;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final media = MediaQuery.of(context);
        final isCompact = media.size.width < 600;
        final dialogWidth = isCompact ? media.size.width : 520.0;
        final horizontalInsetRaw = (media.size.width - dialogWidth) / 2;
        final horizontalInset = isCompact
            ? 24.0
            : (horizontalInsetRaw < 24.0 ? 24.0 : horizontalInsetRaw);

        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: 24.0,
          ),
          title: Text(title),
          content: SizedBox(width: dialogWidth, child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(localizations.confirm_action),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Widget _buildClosedBanner(
    ThemeData theme,
    AppLocalizations localizations,
    CanteenStatusProvider status,
  ) {
    if (!status.hasStatus || status.isOpen) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: theme.colorScheme.error.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.error.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Icon(Icons.storefront, color: theme.colorScheme.error, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.shop_closed,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.shop_closed_banner,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      key: _HomePageState.scaffoldKey,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png'),
        ),
        title: Text(localizations.app_name, style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<CanteenStatusProvider>(
            builder: (context, status, _) {
              final chip = _buildStatusChip(theme, localizations, status);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: chip,
              );
            },
          ),
          IconButton(
            onPressed: () =>
                _HomePageState.scaffoldKey.currentState?.openEndDrawer(),
            tooltip: 'More',
            icon: const Icon(Icons.menu, size: 28),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          child: RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(178, 22, 27, 34),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: const Color.fromARGB(51, 255, 255, 255),
                  ),
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color.fromARGB(204, 255, 255, 255),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(90, 13, 17, 23),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color.fromARGB(40, 255, 255, 255),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.isTamil ? "English" : "தமிழ்",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: widget.isTamil,
                                onChanged: widget.changeLanguage,
                                activeColor: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Shop Controls",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color.fromARGB(204, 255, 255, 255),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Consumer<CanteenStatusProvider>(
                          builder: (context, status, _) {
                            if (!status.hasStatus) {
                              return Text(
                                localizations.shop_status_unknown,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              );
                            }

                            final bool hasStatus = status.hasStatus;
                            final bool isOpen = status.isOpen;
                            final bool isAlwaysOpen = status.isAlwaysOpen;

                            String statusText;
                            IconData statusIcon;
                            Color statusColor = Colors.white54;

                            if (!hasStatus) {
                              statusText = localizations.shop_status_unknown;
                              statusIcon = Icons.help_outline;
                            } else if (!isOpen) {
                              statusText = localizations.shop_closed;
                              statusIcon = Icons.lock_outline;
                              statusColor = theme.colorScheme.error.withOpacity(
                                0.8,
                              );
                            } else if (isAlwaysOpen) {
                              statusText = localizations.always_open;
                              statusIcon = Icons.all_inclusive;
                              statusColor = theme.colorScheme.primary
                                  .withOpacity(0.8);
                            } else {
                              statusText = localizations.shop_open;
                              statusIcon = Icons.check_circle_outline;
                              statusColor = Colors.green.withOpacity(0.8);
                            }

                            final actionButton = _buildStatusActionButton(
                              context,
                              theme,
                              localizations,
                              status,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        size: 16,
                                        color: statusColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        statusText,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: statusColor,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (actionButton != null)
                                  SizedBox(
                                    width: double.infinity,
                                    child: actionButton,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white24),
                      ListTile(
                        leading: const Icon(Icons.receipt_long, size: 28),
                        title: Text(
                          localizations.billing,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => portrait
                                  ? MobileBilling(
                                      name,
                                      widget.isTamil,
                                      widget.canteenId,
                                    )
                                  : Billing(
                                      name,
                                      portrait,
                                      widget.isTamil,
                                      widget.canteenId,
                                    ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.image_outlined, size: 28),
                        title: Text(
                          "Set new Canteen Image",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          await pickAndUploadCanteenImage(
                            context,
                            widget.canteenId,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.online_prediction, size: 28),
                        title: Text(
                          "Prediction",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SalesPredictionPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: Colors.white24),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Notifications",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: const Color.fromARGB(204, 255, 255, 255),
                              ),
                            ),
                            Consumer<NotificationProvider>(
                              builder: (context, provider, child) {
                                if (provider.notifications.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return IconButton(
                                  icon: const Icon(
                                    Icons.clear_all,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => provider.clearAll(),
                                  tooltip: 'Clear All',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Consumer<NotificationProvider>(
                          builder: (context, provider, child) {
                            if (provider.notifications.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No new notifications",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              );
                            }
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: provider.notifications.length,
                              itemBuilder: (context, index) {
                                final notification =
                                    provider.notifications[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  subtitle: Text(notification.message),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 20,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () => provider
                                        .removeNotification(notification.id),
                                  ),
                                  onTap: () {
                                    // Open Edit Item Dialog
                                    final item =
                                        GlobalMenuCache.items[notification.id];
                                    if (item != null) {
                                      _showEditDialogFromNotification(
                                        context,
                                        item,
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          size: 28,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          "Log Out",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        onTap: () {
                          AuthService.logout();
                          widget.updateLoginState(
                            false,
                            widget.canteenId,
                            name.toLowerCase(),
                          );
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Center(
              child: Text(
                (name.trim().isEmpty) ? "Welcome" : "Welcome, $name",
                style: theme.textTheme.displayLarge,
              ),
            ),
          ),
          Consumer<CanteenStatusProvider>(
            builder: (context, status, _) {
              return _buildClosedBanner(theme, localizations, status);
            },
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
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: BottomNavigationBar(
              onTap: (int ind) {
                setState(() {
                  currentIndex = ind;
                });
              },
              currentIndex: currentIndex,
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
            ),
          ),
        ),
      ),
    );
  }
}
