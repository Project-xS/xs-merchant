class ApiConstants {
  // Auth
  static const String login = '/canteen/login';

  // Menu
  static const String menuCreate = '/menu/create';
  static const String menuUpdate = '/menu/update';
  static String menuDelete(int id) => '/menu/delete/$id';
  static String menuUploadPic(dynamic id) => '/menu/upload_pic/$id';
  static String menuSetPic(dynamic id) => '/menu/set_pic/$id';
  static String canteenUploadPic(dynamic id) => '/canteen/upload_pic/$id';
  static String canteenSetPic(dynamic id) => '/canteen/set_pic/$id';

  // Orders
  static const String orders = '/orders';
  static String ordersByUser(String query) => '/orders/by_user?$query';
  static String orderAction(int id, String action) => '/orders/$id/$action';

  // Assets
  static String assets(dynamic id) => '/assets/$id';

  // Search
  static String search(String query) => '/search/${Uri.encodeComponent(query)}';
}
