import 'dart:collection';

class GlobalMenuCache {
  static Map<int, Map<String, dynamic>> items = {};
  static LinkedHashSet<int> availableid = LinkedHashSet();
  static LinkedHashSet<int> navailableid = LinkedHashSet();
}
