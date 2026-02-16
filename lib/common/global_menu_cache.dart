import 'dart:collection';
import 'package:merchant/models/menu_item.dart';

class GlobalMenuCache {
  static Map<int, MenuItem> items = {};
  static LinkedHashSet<int> availableid = LinkedHashSet();
  static LinkedHashSet<int> navailableid = LinkedHashSet();
}
