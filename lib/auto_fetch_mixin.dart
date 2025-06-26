import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/login.dart';
import 'package:merchant/main.dart';

mixin AutoFetchMixin<T extends StatefulWidget> on State<T> {
  Timer? timer;
  Map<int, Map<String, dynamic>> fetchedItems = {};
  LinkedHashSet<int> fetchedAid = LinkedHashSet();
  LinkedHashSet<int> fetchedNaid = LinkedHashSet();
  int sort = 1;
  int get canteenIdToFetch;
  void onDataUpdated(Map<int, Map<String, dynamic>> items, LinkedHashSet<int> available, LinkedHashSet<int> notAvailable);
  void onFetchError(dynamic error);


  @override
  void initState() {
    if (timer?.isActive == null){
      startAutoFetch();
    }
    super.initState();
  }

  // @override
  // void dispose() {
  //   timer?.cancel();
  //   GlobalMenuCache.items.clear();
  //   GlobalMenuCache.availableid.clear();
  //   GlobalMenuCache.navailableid.clear();
  //   super.dispose();
  // }

  void startAutoFetch() {
    timer = Timer.periodic(Duration(minutes: 1, seconds: 30), (timer) {
      debugPrint("Timer over, fetching");
      GlobalMenuCache.items.clear();
      GlobalMenuCache.availableid.clear();
      GlobalMenuCache.navailableid.clear();
      fetchAndCacheAndNotify((canteenIdToFetch==0)?canteenId:canteenIdToFetch);
    });
  }
  // uncomment below for caching
  Future<void> fetchAndCacheAndNotify(int id) async {    
    debugPrint(id.toString());
    if (!mounted) return;
    final url = "https://proj-xs.fly.dev/canteen/$id/items";
    // final cacheManager = JsonCacheManager.instance;
    // dynamic combinedJson;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        List<dynamic> dataList = decodedJson["data"];

        for (var item1 in dataList) {
          if (item1["is_available"] == true && (item1["stock"] == -1 || item1["stock"] >= 1)) {
            fetchedAid.add(item1["item_id"]);
          } else {
            fetchedNaid.add(item1["item_id"]);
          }
          fetchedItems[item1["item_id"]] = {
            "name": item1["name"],
            "price": item1["price"],
            "is_veg": item1["is_veg"],
            "available": item1["is_available"],
            "stocks": item1["stock"]
          };
        }
        GlobalMenuCache.items = fetchedItems;
        GlobalMenuCache.availableid = fetchedAid;
        GlobalMenuCache.navailableid = fetchedNaid;
        applySorting(GlobalMenuCache.items, sort, GlobalMenuCache.availableid, GlobalMenuCache.navailableid);
        onDataUpdated(GlobalMenuCache.items, GlobalMenuCache.availableid, GlobalMenuCache.navailableid);
        // onDataUpdated(fetchedItems, fetchedNaid);

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error Getting Items : ${response.statusCode}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        onFetchError("Failed to load data: ${response.statusCode}");
        return;
      }
    } catch (e) {
      if (mounted && Scaffold.maybeOf(context) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      onFetchError(e);
    }
  }

  dynamic applySorting(Map<int, Map<String, dynamic>> dataToSort, int s, LinkedHashSet<int> availableId, LinkedHashSet<int> navailableId) {
  List<int> avail = availableId.toList();
  List<int> navail = navailableId.toList();

  int Function(int, int) getComparator(int sortOption) {
    return (idA, idB) {
      Map<String, dynamic> itemA = dataToSort[idA]!;
      Map<String, dynamic> itemB = dataToSort[idB]!;

      if (sortOption == 1) {
        return itemA["name"].toLowerCase().replaceAll(' ', '').compareTo(itemB["name"].toLowerCase().replaceAll(' ', ''));
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
      onDataUpdated(fetchedItems, fetchedAid, fetchedNaid);
      sort = s;
    });
  }
  GlobalMenuCache.items = fetchedItems;
  GlobalMenuCache.availableid = fetchedAid;
  GlobalMenuCache.navailableid = fetchedNaid;
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
    _timer = Timer.periodic(Duration(minutes: 2), (timer) {
      triggerOrderFetch();
    });
  }

  Future<void> triggerOrderFetch() async {
    final int id = canteenIdForOrders;
    debugPrint("Fetching orders for canteen ID: $id");
    if (!mounted) return;

    try {
      final response = await http.get(Uri.parse("https://proj-xs.fly.dev/orders?canteen_id=$id"));
      
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
          fetchedOrders[time] = {
            'name': name,
            'count': count,
          };
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error Fetching Order Details: ${response.statusCode}"),
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
//   Map<int, Map<String, dynamic>> itemfetch = {};
//   Set<int> aid = {}, naid = {};
// mixin AutoFetchMixin<T extends StatefulWidget> on State<T> {
//   Timer? timer;

//   @override
//   void initState() {
//     super.initState();
//     startAutoFetch();
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   void startAutoFetch() {
//     timer = Timer.periodic(Duration(minutes: 1, seconds: 30), (timer) {
//       getallitems(canteenId??main.MyAppState().canteenId);
//     });
//   }

// Future<void> getallitems(int id) async {
//   debugPrint(id.toString());
//   if (!mounted) return;
//   final url = "https://proj-xs.fly.dev/canteen/$id/items";
//   final cacheManager = JsonCacheManager.instance;
//   dynamic combinedJson;

//   try {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       Map<String, dynamic> decodedJson = jsonDecode(response.body);
//       List<dynamic> dataList = decodedJson["data"];
//       setState(() {
//         itemfetch.clear();
//         aid.clear();
//         naid.clear();
//         for (var item1 in dataList) {
//           if (item1["is_available"] == true && (item1["stock"] == -1 || item1["stock"] >= 1)) {
//             aid.add(item1["item_id"]);
//           } else {
//             naid.add(item1["item_id"]);
//           }
//           itemfetch[item1["item_id"]] = {
//             "name": item1["name"],
//             "price": item1["price"],
//             "is_veg": item1["is_veg"],
//             "available": item1["is_available"],
//             "stocks": item1["stock"]
//           };
//         }
//       combinedJson = jsonEncode({
//         "items": itemfetch.map((key, value) => MapEntry(key.toString(), value)),
//         "availableid": aid.toList(),
//         "navailableid": naid.toList(),
//       });
//       debugPrint("$combinedJson");
//         if (mounted && Scaffold.maybeOf(context) != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Item Fetched Successfully"),
//               backgroundColor: Colors.cyanAccent,
//             ),
//           );
//         }
//       });
//       await cacheManager.putFile(
//         id.toString(),
//         Uint8List.fromList(utf8.encode(combinedJson)),
//         fileExtension: "json",
//       );
//       } else {
//         if (mounted && Scaffold.maybeOf(context) != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Error Getting Items : ${response.statusCode}"),
//               backgroundColor: Colors.redAccent,
//             ),
//           );
//         }
//         return;
//       }

//   } catch (e) {
//     if (mounted && Scaffold.maybeOf(context) != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Not Connected, $e"),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }
// }

// Future<void> loadItemsFromCache(int id) async {
//   final cacheManager = JsonCacheManager.instance;

//   try {
//     FileInfo? cachedFile = await cacheManager.getFileFromCache(id.toString());
//     if (cachedFile == null) return;

//     String jsonStr = await cachedFile.file.readAsString();
//     Map<String, dynamic> decodedJson = jsonDecode(jsonStr);
//     Map<int, Map<String, dynamic>> datalist = decodedJson["items"];

//     if (mounted) {
//       setState(() {
//         itemfetch.clear();
//         itemfetch = datalist;
//         naid = Set<int>.from(decodedJson["navailableid"]);
//         aid = Set<int>.from(decodedJson["availableid"]);
//       });
//     }
//   } catch (e) {
//     debugPrint("Error loading items from cache: $e");
//   }
// }
// }

// class JsonCacheManager {
//   static final CacheManager instance = CacheManager(
//     Config(
//       'itemCache',
//       stalePeriod: const Duration(minutes: 10),
//       maxNrOfCacheObjects: 1000,
//     ),
//   );

// }
  // Map<int, Map<String, dynamic>> applySorting(Map<int, Map<String, dynamic>> dataToSort, int s) {
  //     setState((){
  //       sort = s;
  //     });
  //   var sortedEntries = dataToSort.entries.toList();
  //   if (sort == 1) {
  //     sortedEntries.sort((a, b) => a.value["name"].toLowerCase().replaceAll(' ', '').compareTo(b.value["name"].toLowerCase().replaceAll(' ', '')));
  //   } else if (sort == 2) {
  //     sortedEntries.sort((a, b) => b.value["price"].compareTo(a.value["price"]));
  //   } else if (sort == 3) {
  //     sortedEntries.sort((a, b) {
  //       int getPriority(Map<String, dynamic> item) {
  //         if (item["stocks"] == 0 && item["available"] == true) return 0;
  //         if (item["stocks"] == 0 && item["available"] == false) return 1;
  //         if (item["stocks"] == -1) return 3;
  //         return 2;
  //       }
  //       int priorityA = getPriority(a.value);
  //       int priorityB = getPriority(b.value);

  //       if (priorityA != priorityB) {
  //         return priorityA.compareTo(priorityB);
  //       }
  //       if (priorityA == 2) {
  //         return a.value["stocks"].compareTo(b.value["stocks"]);
  //       }
  //       return 0;
  //     });
  //   }
  //   Map<int, Map<String, dynamic>> data = {for (var entry in sortedEntries) entry.key: entry.value};
  //   setState(() {
  //     fetchedItems = data;
  //     debugPrint("fetchedItems: ${fetchedItems.toString()}");
  //   });
  //   return fetchedItems;
  // }

  // Future<void> loadItemsFromCache(int id) async {
  //   final cacheManager = JsonCacheManager.instance;

  //   try {
  //     FileInfo? cachedFile = await cacheManager.getFileFromCache(id.toString());
  //     if (cachedFile == null) return;

  //     String jsonStr = await cachedFile.file.readAsString();
  //     Map<String, dynamic> decodedJson = jsonDecode(jsonStr);
  //     Map<int, Map<String, dynamic>> datalist = Map<int, Map<String, dynamic>>.from(
  //       decodedJson["items"].map((key, value) => MapEntry(int.parse(key), Map<String, dynamic>.from(value))),
  //     );

  //     Set<int> cachedNaid = Set<int>.from(decodedJson["navailableid"]);
  //     Set<int> cachedAid = Set<int>.from(decodedJson["availableid"]);

  //     if (mounted) {
  //       onDataUpdated(datalist, cachedAid, cachedNaid);
  //     }
  //   } catch (e) {
  //     debugPrint("Error loading items from cache: $e");
  //     onFetchError("Error loading from cache: $e");
  //   }
  // }

// class JsonCacheManager {
//   static final CacheManager instance = CacheManager(
//     Config(
//       'itemCache',
//       stalePeriod: const Duration(minutes: 10),
//       maxNrOfCacheObjects: 1000,
//     ),
//   );
// }
