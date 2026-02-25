class ApiConstants {
  // Auth
  static const String login = '/canteen/login';
  static const String canteenList = '/canteen';
  static const String canteenOpen = '/canteen/open';
  static const String canteenClose = '/canteen/close';

  // Menu
  static const String menuCreate = '/menu/create';
  static const String menuUpdate = '/menu/update';
  static String menuDelete(int id) => '/menu/delete/$id';
  static String menuUploadPic(dynamic id) => '/menu/upload_pic/$id';
  static String menuSetPic(dynamic id) => '/menu/set_pic/$id';
  static const String canteenUploadPic = '/canteen/upload_pic';
  static const String canteenSetPic = '/canteen/set_pic';

  // Orders
  static const String orders = '/orders';
  static String ordersByUser(String query) => '/orders/by_user?$query';
  static String orderAction(int id, String action) => '/orders/$id/$action';
  static const String ordersScan = '/orders/scan';

  // Assets
  static String assets(dynamic id) => '/assets/$id';

  // Search
  static String search(String query) => '/search/${Uri.encodeComponent(query)}';

  // User
  static const String pastOrders = '/users/get_past_orders';
}
