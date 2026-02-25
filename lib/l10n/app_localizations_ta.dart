// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get app_name => 'நம்ம கேன்டீன்';

  @override
  String get menu => 'மெனு';

  @override
  String get verify => 'ஆர்டர் சரிபார்ப்பு';

  @override
  String get order => 'ஆர்டர்';

  @override
  String get on_menu_head => 'மெனுவில் உள்ளவை';

  @override
  String get off_menu_head => 'மெனுவில் இல்லை';

  @override
  String get on_menu => 'மெனுவில் உள்ளது';

  @override
  String get off_menu => 'மெனுவில் இல்லை';

  @override
  String get no_item_menu => 'மெனுவில் ஏதும் இல்லை';

  @override
  String get no_item => 'எந்த பொருளும் இல்லை';

  @override
  String get sort_by => 'வரிசை: ';

  @override
  String get name => 'பெயர்';

  @override
  String get price => 'விலை';

  @override
  String get stock => 'இருப்பு';

  @override
  String get veg => 'சைவம்';

  @override
  String get low_stock => 'குறைந்த_இருப்பு';

  @override
  String get refresh => 'புதுப்பி';

  @override
  String get bulk_edit => 'மொத்த திருத்தம்';

  @override
  String get add_item => 'புதிய பொருள்';

  @override
  String get add_item_head => 'புதிய பொருளை சேர்க்க:';

  @override
  String get multiple_item_edit => 'பல பொருட்கள் திருத்தம்:';

  @override
  String get search_name => 'பெயரை உள்ளிடவும்';

  @override
  String get cancel => 'ரத்து';

  @override
  String get submit => 'ஒப்புதல்';

  @override
  String get order_items => 'பொருட்கள்:';

  @override
  String get s_order => 'ஆர்டர் எண்ணை உள்ளிடவும்';

  @override
  String get s_tap => 'கிளிக் செய்து அடையாள அட்டையைத் தட்டவும்';

  @override
  String get deliver => 'விநியோகம்';

  @override
  String get delivery_time => 'விநியோக நேரம்:-';

  @override
  String get item_delivery => 'உணவு விநியோகம்:';

  @override
  String get not_found => 'காணப்படவில்லை';

  @override
  String get order_id => 'ஆர்டர் ஐடி:';

  @override
  String get total => 'மொத்தம்: ';

  @override
  String get all => 'அனைத்தும்';

  @override
  String modify_item(String name) {
    return '$name - விவரங்களை மாற்ற :';
  }

  @override
  String get new_price => 'புதிய விலை - ₹';

  @override
  String get new_name => 'புதிய பெயர்';

  @override
  String confirm_remove(String name) {
    return 'நீங்கள் மெனுவிலிருந்து \"$name\" ஐ நீக்க விரும்புகிறீர்களா?';
  }

  @override
  String confirm_add(String name) {
    return 'நீங்கள் மெனுவிற்கு \"$name\" ஐ சேர்க்க விரும்புகிறீர்களா?';
  }

  @override
  String confirm_delete(String name) {
    return 'நீங்கள் \"$name\" ஐ அழிக்க விரும்புகிறீர்களா?';
  }

  @override
  String get remove => 'நீக்கு';

  @override
  String get add => 'சேர்';

  @override
  String get delete => 'அழி';

  @override
  String get language => 'மொழியை மாற்ற :-';

  @override
  String get confirm_order_changes =>
      'நீங்கள் ஆர்டரில் மாற்றங்களை செய்ய உறுதியாக இருக்கிறீர்களா?';

  @override
  String get note =>
      'குறிப்பு: கொடுக்க விரும்புகிறீர்களா அல்லது பிறகு வழங்க நிலுவையிலிருத்தலாம். இது ஒரே முறையே செய்யலாம்.';

  @override
  String get accept => 'ஏற்றுக்கொள்';

  @override
  String get reject => 'நிராகரி';

  @override
  String get deliver_later => 'பின்னர் வழங்கவும்';

  @override
  String get timing => 'நேரம்: ';

  @override
  String get instant => 'உடனடி';

  @override
  String get billing => 'பில் உருவாக்கம்';

  @override
  String get stock_alert_title => 'குறைந்த இருப்பு எச்சரிக்கை';

  @override
  String stock_alert_body(String name, int stock) {
    return '$name கையிருப்பு குறைவாக உள்ளது ($stock மீதமுள்ளது)';
  }

  @override
  String get shop_open => 'திறந்தது';

  @override
  String get shop_closed => 'மூடியது';

  @override
  String get open_shop => 'கடையை திறக்கவும்';

  @override
  String get close_shop => 'கடையை மூடவும்';

  @override
  String get always_open => 'எப்போதும் திறந்தது';

  @override
  String get shop_status_unknown => 'நிலை தெரியவில்லை';

  @override
  String get shop_closed_banner =>
      'கடை மூடப்பட்டுள்ளது. புதிய ஹோல்ட்கள் உருவாக்கப்படாது.';

  @override
  String get confirm_open_shop => 'கடையை திறக்க விரும்புகிறீர்களா?';

  @override
  String get confirm_close_shop => 'கடையை மூட விரும்புகிறீர்களா?';

  @override
  String get confirm_action => 'உறுதி';
}
