// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Namma Canteen';

  @override
  String get menu => 'Menu';

  @override
  String get verify => 'Order Verification';

  @override
  String get order => 'Orders';

  @override
  String get on_menu_head => 'On Menu';

  @override
  String get off_menu_head => 'Not on Menu';

  @override
  String get on_menu => 'On Menu';

  @override
  String get off_menu => 'Not on Menu';

  @override
  String get no_item_menu => 'No Item on Menu';

  @override
  String get no_item => 'No Items Available';

  @override
  String get sort_by => 'Sort by: ';

  @override
  String get name => 'Name';

  @override
  String get price => 'Price';

  @override
  String get stock => 'Stocks';

  @override
  String get veg => 'Veg';

  @override
  String get low_stock => 'Low_Stocks';

  @override
  String get refresh => 'Refresh';

  @override
  String get bulk_edit => 'Bulk Edit';

  @override
  String get add_item => 'Add Item';

  @override
  String get add_item_head => 'Add New Item:';

  @override
  String get multiple_item_edit => 'Multiple Item Edit:';

  @override
  String get search_name => 'Enter name to search';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get order_items => 'Order Items:';

  @override
  String get s_order => 'Enter Order No. to Search';

  @override
  String get s_tap => 'Click Here and Tap the ID';

  @override
  String get deliver => 'Deliver';

  @override
  String get delivery_time => 'Delivery Timing:- ';

  @override
  String get item_delivery => 'Item Delivery:';

  @override
  String get not_found => 'Not Found';

  @override
  String get order_id => 'Order ID:';

  @override
  String get total => 'Total: ';

  @override
  String get all => 'All';

  @override
  String modify_item(String name) {
    return 'Modify Item - $name :';
  }

  @override
  String get new_price => 'New Price - ₹';

  @override
  String get new_name => 'New Name';

  @override
  String confirm_remove(String name) {
    return 'Do you want to Remove \"$name\" from the Menu?';
  }

  @override
  String confirm_add(String name) {
    return 'Do you want to Add \"$name\" to the Menu?';
  }

  @override
  String confirm_delete(String name) {
    return 'Do you want to Delete \"$name\" permanently?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get language => 'Change Language:-';

  @override
  String get confirm_order_changes =>
      'Are you sure to make changes to the order?';

  @override
  String get note =>
      'Note: This can be done only once or make it hold to deliver later.';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get deliver_later => 'Deliver Later';

  @override
  String get timing => 'Timing: ';

  @override
  String get instant => 'Instant';

  @override
  String get billing => 'Generate Bill';

  @override
  String get stock_alert_title => 'Low Stock Alert';

  @override
  String stock_alert_body(String name, int stock) {
    return '$name is running low on stock ($stock remaining)';
  }

  @override
  String get shop_open => 'Open';

  @override
  String get shop_closed => 'Closed';

  @override
  String get open_shop => 'Open Shop';

  @override
  String get close_shop => 'Close Shop';

  @override
  String get always_open => 'Always Open';

  @override
  String get shop_status_unknown => 'Status Unknown';

  @override
  String get shop_closed_banner =>
      'Shop is closed. New holds will not be created.';

  @override
  String get confirm_open_shop => 'Are you sure you want to open the shop?';

  @override
  String get confirm_close_shop => 'Are you sure you want to close the shop?';

  @override
  String get confirm_action => 'Confirm';
}
