import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/main.dart';

mixin AutoFetchMixin<T extends StatefulWidget> on State<T> {
  Timer? timer;
  Map<int, Map<String, dynamic>> fetchedItems = {};
  LinkedHashSet<int> fetchedAid = LinkedHashSet();
  LinkedHashSet<int> fetchedNaid = LinkedHashSet();
  Map<String, Map<String, dynamic>> orders = {};
  int sort = 1;
  int get canteenIdToFetch;

  @override
  void initState() {
    if (timer?.isActive == null) {
      startAutoFetch();
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startAutoFetch() {
    timer?.cancel();
    timer = Timer.periodic(Duration(minutes: 1, seconds: 30), (timer) {
      debugPrint("Timer over, fetching");
      fetchAndCacheAndNotify();
    });
  }

  // uncomment below for caching
  Future<void> fetchAndCacheAndNotify() async {
    if (!mounted) return;
    final url = "/menu/items";
    // final cacheManager = JsonCacheManager.instance;
    // dynamic combinedJson;

    try {
      if (kDebugMode) {
        debugPrint('[menu] GET $url');
      }
      final response = await ApiClient.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        debugPrint("Fetched: ${decodedJson.toString()}");
        List<dynamic> dataList = decodedJson["data"];
        if (!mounted) return;
        setState(() {
          GlobalMenuCache.availableid.clear();
          GlobalMenuCache.navailableid.clear();
          GlobalMenuCache.items.clear();
        });
        for (var item1 in dataList) {
          if (item1["is_available"] == true &&
              (item1["stock"] == -1 || item1["stock"] >= 1)) {
            fetchedAid.add(item1["item_id"]);
          } else {
            fetchedNaid.add(item1["item_id"]);
          }
          fetchedItems[item1["item_id"]] = {
            "name": item1["name"],
            "price": item1["price"],
            "is_veg": item1["is_veg"],
            "available": item1["is_available"],
            "stocks": item1["stock"],
            "pic": item1["pic_link"],
            "etag": item1["pic_etag"]?.toString().replaceAll('"', ''),
          };
        }
        if (!mounted) return;
        setState(() {
          GlobalMenuCache.items = fetchedItems;
          GlobalMenuCache.availableid = fetchedAid;
          GlobalMenuCache.navailableid = fetchedNaid;
          applySorting(
            GlobalMenuCache.items,
            sort,
            GlobalMenuCache.availableid,
            GlobalMenuCache.navailableid,
          );
          // onDataUpdated(GlobalMenuCache.items, GlobalMenuCache.availableid, GlobalMenuCache.navailableid);
        });

        // combinedJson = jsonEncode({
        //   "items": fetchedItems.map((key, value) => MapEntry(key.toString(), value)),
        //   "availableid": fetchedAid.toList(),
        //   "navailableid": fetchedNaid.toList(),
        // });
        // debugPrint("$combinedJson");

        if (mounted && Scaffold.maybeOf(context) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Item Fetched Successfully"),
              backgroundColor: Colors.cyanAccent,
            ),
          );
        }
        // await cacheManager.putFile(
        //   id.toString(),
        //   Uint8List.fromList(utf8.encode(combinedJson)),
        //   fileExtension: "json",
        // );
      } else {
        if (mounted && Scaffold.maybeOf(context) != null) {
          final msg = ApiClient.tryExtractErrorMessage(response);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg ?? "Error Getting Items : ${response.statusCode}",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        if (kDebugMode) {
          debugPrint(
            '[menu] non-200: ${response.statusCode} body=${response.body}',
          );
        }
        if (kDebugMode)
          debugPrint("Failed to load data: ${response.statusCode}");
        return;
      }
    } catch (e) {
      if (mounted && Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Check Internet Connection"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      if (kDebugMode) debugPrint('[menu] exception: $e');
    }
  }

  dynamic applySorting(
    Map<int, Map<String, dynamic>> dataToSort,
    int s,
    LinkedHashSet<int> availableId,
    LinkedHashSet<int> navailableId,
  ) {
    List<int> avail = availableId.toList();
    List<int> navail = navailableId.toList();

    int Function(int, int) getComparator(int sortOption) {
      return (idA, idB) {
        Map<String, dynamic> itemA = dataToSort[idA]!;
        Map<String, dynamic> itemB = dataToSort[idB]!;

        if (sortOption == 1) {
          return itemA["name"]
              .toLowerCase()
              .replaceAll(' ', '')
              .compareTo(itemB["name"].toLowerCase().replaceAll(' ', ''));
        } else if (sortOption == 2) {
          return itemB["price"].compareTo(itemA["price"]);
        } else if (sortOption == 3) {
          int getPriority(Map<String, dynamic> item) {
            if (item["stocks"] == 0 && item["available"] == true) return 0;
            if (item["stocks"] == 0 && item["available"] == false) return 1;
            if (item["stocks"] == -1) return 3;
            return 2;
          }

          int priorityA = getPriority(itemA);
          int priorityB = getPriority(itemB);

          if (priorityA != priorityB) {
            return priorityA.compareTo(priorityB);
          }
          if (priorityA == 2) {
            return itemA["stocks"].compareTo(itemB["stocks"]);
          }
          return 0;
        }
        return 0;
      };
    }

    avail.sort(getComparator(s));
    navail.sort(getComparator(s));

    if (mounted) {
      setState(() {
        fetchedAid = LinkedHashSet<int>.from(avail);
        fetchedNaid = LinkedHashSet<int>.from(navail);
        GlobalMenuCache.items = fetchedItems;
        GlobalMenuCache.availableid = fetchedAid;
        GlobalMenuCache.navailableid = fetchedNaid;
        sort = s;
      });
    }
  }
}

mixin OrderFetchMixin<T extends StatefulWidget> on State<T> {
  Timer? _timer;

  int get canteenIdForOrders;
  void onOrdersUpdated(Map<String, Map<String, dynamic>> orders);
  void onOrderFetchError(dynamic error);

  @override
  void initState() {
    super.initState();
    triggerOrderFetch();
    _startOrderAutoFetchTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startOrderAutoFetchTimer() {
    _timer = Timer.periodic(Duration(minutes: 1, seconds: 30), (timer) {
      triggerOrderFetch();
    });
  }

  Future<void> triggerOrderFetch() async {
    final int id = canteenIdForOrders;
    if (kDebugMode) debugPrint("Fetching orders for canteen ID: $id");
    try {
      final response = await ApiClient.get('/orders');

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        Map<String, dynamic> dataList = decodedJson["data"];

        Map<String, Map<String, dynamic>> fetchedOrders = {};
        for (String time in dataList.keys) {
          List<String> name = [];
          List<int> count = [];
          for (var order in dataList[time]) {
            name.add(order["item_name"]);
            count.add(order["num_ordered"]);
          }
          fetchedOrders[time] = {'name': name, 'count': count};
        }
        onOrdersUpdated(fetchedOrders);
        if (mounted && Scaffold.maybeOf(context) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Order Details Fetched Successfully"),
              backgroundColor: Colors.cyanAccent,
            ),
          );
        }
      } else {
        if (mounted && Scaffold.maybeOf(context) != null) {
          final msg = ApiClient.tryExtractErrorMessage(response);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                msg ?? "Error Fetching Order Details: ${response.statusCode}",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        onOrderFetchError("Failed to fetch orders: ${response.statusCode}");
      }
    } on Exception catch (e) {
      if (mounted && Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      onOrderFetchError(e);
    }
  }
}
