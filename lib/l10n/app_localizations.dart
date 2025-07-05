import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Namma Canteen'**
  String get app_name;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Order Verification'**
  String get verify;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get order;

  /// No description provided for @on_menu_head.
  ///
  /// In en, this message translates to:
  /// **'On Menu'**
  String get on_menu_head;

  /// No description provided for @off_menu_head.
  ///
  /// In en, this message translates to:
  /// **'Not on Menu'**
  String get off_menu_head;

  /// No description provided for @on_menu.
  ///
  /// In en, this message translates to:
  /// **'On Menu'**
  String get on_menu;

  /// No description provided for @off_menu.
  ///
  /// In en, this message translates to:
  /// **'Not on Menu'**
  String get off_menu;

  /// No description provided for @no_item_menu.
  ///
  /// In en, this message translates to:
  /// **'No Item on Menu'**
  String get no_item_menu;

  /// No description provided for @no_item.
  ///
  /// In en, this message translates to:
  /// **'No Items Available'**
  String get no_item;

  /// No description provided for @sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get sort_by;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stock;

  /// No description provided for @veg.
  ///
  /// In en, this message translates to:
  /// **'Veg'**
  String get veg;

  /// No description provided for @low_stock.
  ///
  /// In en, this message translates to:
  /// **'Low_Stocks'**
  String get low_stock;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @bulk_edit.
  ///
  /// In en, this message translates to:
  /// **'Bulk Edit'**
  String get bulk_edit;

  /// No description provided for @add_item.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get add_item;

  /// No description provided for @add_item_head.
  ///
  /// In en, this message translates to:
  /// **'Add New Item:'**
  String get add_item_head;

  /// No description provided for @multiple_item_edit.
  ///
  /// In en, this message translates to:
  /// **'Multiple Item Edit:'**
  String get multiple_item_edit;

  /// No description provided for @search_name.
  ///
  /// In en, this message translates to:
  /// **'Enter name to search'**
  String get search_name;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @order_items.
  ///
  /// In en, this message translates to:
  /// **'Order Items:'**
  String get order_items;

  /// No description provided for @s_order.
  ///
  /// In en, this message translates to:
  /// **'Enter Order No. to Search'**
  String get s_order;

  /// No description provided for @s_tap.
  ///
  /// In en, this message translates to:
  /// **'Click Here and Tap the ID'**
  String get s_tap;

  /// No description provided for @deliver.
  ///
  /// In en, this message translates to:
  /// **'Deliver'**
  String get deliver;

  /// No description provided for @delivery_time.
  ///
  /// In en, this message translates to:
  /// **'Delivery Timing:- '**
  String get delivery_time;

  /// No description provided for @item_delivery.
  ///
  /// In en, this message translates to:
  /// **'Item Delivery:'**
  String get item_delivery;

  /// No description provided for @not_found.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get not_found;

  /// No description provided for @order_id.
  ///
  /// In en, this message translates to:
  /// **'Order ID:'**
  String get order_id;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total: '**
  String get total;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @modify_item.
  ///
  /// In en, this message translates to:
  /// **'Modify Item - {name} :'**
  String modify_item(String name);

  /// No description provided for @new_price.
  ///
  /// In en, this message translates to:
  /// **'New Price - ₹'**
  String get new_price;

  /// No description provided for @new_name.
  ///
  /// In en, this message translates to:
  /// **'New Name'**
  String get new_name;

  /// No description provided for @confirm_remove.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Remove \"{name}\" from the Menu?'**
  String confirm_remove(String name);

  /// No description provided for @confirm_add.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Add \"{name}\" to the Menu?'**
  String confirm_add(String name);

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Do you want to Delete \"{name}\" permanently?'**
  String confirm_delete(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Change Language:-'**
  String get language;

  /// No description provided for @confirm_order_changes.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to make changes to the order?'**
  String get confirm_order_changes;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note: This can be done only once or make it hold to deliver later.'**
  String get note;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @deliver_later.
  ///
  /// In en, this message translates to:
  /// **'Deliver Later'**
  String get deliver_later;

  /// No description provided for @timing.
  ///
  /// In en, this message translates to:
  /// **'Timing: '**
  String get timing;

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Generate Bill'**
  String get billing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
