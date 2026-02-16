import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/auth/auth_service.dart';
import 'package:merchant/common/button_styles.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/menu/menu_item_card.dart';
import 'package:merchant/menu/edit_item_dialog.dart';
import 'package:merchant/common/shimmer_loading.dart';
import 'package:merchant/menu/add_item_dialog.dart';
import 'package:merchant/main.dart';

class Menupage extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const Menupage(this.portrait, this.isTamil, this.canteenId, {super.key});

  @override
  State<Menupage> createState() => MenupageState();
}

class MenupageState extends State<Menupage> with AutoFetchMixin<Menupage> {
  int sortmenu = 1;

  @override
  int get canteenIdToFetch => widget.canteenId;

  @override
  void initState() {
    if ((timer == null || !timer!.isActive) && GlobalMenuCache.items.isEmpty) {
      fetchAndCacheAndNotify();
    }
    super.initState();
  }

  void modifyItem(
    int itemId,
    String oldName,
    int oldRate,
    bool isveg,
    bool available,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EditItemDialog(
          itemId: itemId,
          initialName: oldName,
          initialPrice: oldRate,
          initialStock: GlobalMenuCache.items[itemId]?['stocks'] ?? 0,
          initialIsVeg: isveg,
          initialAvailable: available,
          canteenId: widget.canteenId,
          isPortrait: widget.portrait,
          onUpdate: (name, price, stock, isVeg, isAvailable, imageBytes) async {
            if (imageBytes != null) {
              String? url = await ImageUploadState().imageupload(
                itemId,
                imageBytes,
              );
              if (url != null && url.isNotEmpty) {
                if (mounted) {
                  // Check mounted before setState
                  setState(() {
                    GlobalMenuCache.items[itemId]?['pic'] = url;
                    changeimage(itemId, url);
                  });
                }
              }
            }
            await updateitem(itemId, {
              'name': name,
              'price': price,
              'is_veg': isVeg,
              'available': isAvailable,
              'stocks': stock,
              'pic': GlobalMenuCache.items[itemId]?['pic'],
            });
          },
        );
      },
    );
  }

  void addNewItem() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AddItemDialog(
          canteenId: widget.canteenId,
          isPortrait: widget.portrait,
          onAdd: (name, price, stock, isVeg, isAvailable, imageBytes) async {
            int? id;
            // Check for duplicate
            int foundItemId = GlobalMenuCache.items.keys.firstWhere(
              (key) =>
                  GlobalMenuCache.items[key]?['name']
                      .trim()
                      .toLowerCase()
                      .replaceAll(' ', '') ==
                  name.trim().toLowerCase().replaceAll(' ', ''),
              orElse: () => -1,
            );

            if (foundItemId != -1) {
              // Update existing
              if (mounted) {
                setState(() {
                  GlobalMenuCache.items[foundItemId] = {
                    'name': name,
                    'price': price,
                    'is_veg': isVeg,
                    'available': isAvailable,
                    'stocks': stock,
                  };
                  updateitem(foundItemId, GlobalMenuCache.items[foundItemId]);
                  if (GlobalMenuCache.navailableid.contains(foundItemId)) {
                    GlobalMenuCache.navailableid.remove(foundItemId);
                    GlobalMenuCache.availableid.add(foundItemId);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Item Already Exists, Updated its details"),
                    backgroundColor: Colors.yellowAccent,
                  ),
                );
              }
              id = foundItemId;
            } else {
              // Add new
              id = await addnewitem(
                name,
                price,
                isVeg,
                stock,
                isAvailable,
                hasPic: imageBytes != null,
              );
              if (id != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Item : \"$name\" Added Successfully"),
                    backgroundColor: Colors.cyanAccent,
                  ),
                );
              }
            }

            if (id != null) {
              if (imageBytes != null) {
                // Use ImageUploadState().imageupload without instance if method allows it,
                // OR duplicate logic?
                // Based on investigation, imageupload method is safe to call on detached instance
                // if it doesn't access widget properties.
                // But wait, in AddItemDialog/menupage callback, I don't have an ImageUpload widget instance to call state method on!
                // The original code instantiated `ImageUploadState()`.
                // I will do the same.
                String? url = await ImageUploadState().imageupload(
                  id,
                  imageBytes,
                );
                if (url != null && url.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      GlobalMenuCache.items[id!]?['pic'] = url;
                      changeimage(id, url);
                    });
                  }
                }
              }
              // Refresh logic
              fetchAndCacheAndNotify();
            }
          },
        );
      },
    );
  }

  // Future<String?> imageupload(int id, Uint8List? image) async {
  //   dynamic data, data1;
  //   if (image == null) return null;
  //   try {
  //     final response1 = await http.post(
  //         Uri.parse("https://proj-xs.fly.dev/assets/upload/$id"),
  //         headers: {'Content-Type': 'application/json'});

  //     if (response1.statusCode == 200) {
  //       data = jsonDecode(response1.body);
  //       debugPrint("1st: ${data.toString()}");
  //       final response = await http.put(Uri.parse("${data['url']}"),
  //           body: image, headers: {'Content-Type': 'image/png'});
  //       if (response.statusCode == 200) {
  //         final setimage = await http.put(
  //           Uri.parse("https://proj-xs.fly.dev/menu/set_pic/$id"),
  //           headers: {'Content-Type': 'application/json'},
  //         );
  //         debugPrint(setimage.body);
  //         final response2 = await http.get(
  //             Uri.parse("https://proj-xs.fly.dev/assets/$id"),
  //             headers: {'Content-Type': 'application/json'});
  //         if (response2.statusCode == 200) {
  //           data1 = jsonDecode(response2.body);
  //           // debugPrint("2nd: ${data1.toString()}");
  //           debugPrint("Image Uploaded Successfully");
  //           debugPrint(
  //               "${GlobalMenuCache.items[id]?['pic']} ${data1['item_id']} ${data1['url']}");
  //           return data1['url'];
  //         } else {
  //           if (mounted) {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text("Image Upload Failed: Get Stage"),
  //                 backgroundColor: Colors.redAccent,
  //               ),
  //             );
  //           }
  //           return null;
  //         }
  //       } else {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text("Image Upload Failed: 2nd Stage"),
  //               backgroundColor: Colors.redAccent,
  //             ),
  //           );
  //         }
  //         return null;
  //       }
  //     } else {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Image Upload Failed: 1st Stage"),
  //             backgroundColor: Colors.redAccent,
  //           ),
  //         );
  //       }
  //       return null;
  //     }
  //   } on Exception catch (e) {
  //     debugPrint("Error: $e");
  //     return null;
  //   }
  // }

  void delAddItem(int itemId, String name, bool isAdd, bool available) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            (isAdd && available)
                ? AppLocalizations.of(context)!.confirm_remove(name)
                : ((isAdd && !available)
                      ? AppLocalizations.of(context)!.confirm_add(name)
                      : AppLocalizations.of(context)!.confirm_delete(name)),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: const Text("Are you sure?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: getActionButtonStyle(context, false),
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const Icon(Icons.close),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.cancel),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: getActionButtonStyle(
                    context,
                    true,
                    isYellow: isAdd && available,
                  ),
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      if (isAdd == true) {
                        if (GlobalMenuCache.items[itemId]?['available']) {
                          GlobalMenuCache.availableid.remove(itemId);
                          GlobalMenuCache.navailableid.add(itemId);
                          GlobalMenuCache.items[itemId]?['available'] = false;
                          updateitem(itemId, GlobalMenuCache.items[itemId]);
                        } else {
                          GlobalMenuCache.items[itemId]?['available'] = true;
                          GlobalMenuCache.availableid.add(itemId);
                          GlobalMenuCache.navailableid.remove(itemId);
                          updateitem(itemId, GlobalMenuCache.items[itemId]);
                        }
                      } else {
                        deleteitem(itemId);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.check),
                      const SizedBox(width: 8),
                      Text(
                        (isAdd && available)
                            ? AppLocalizations.of(context)!.remove
                            : ((isAdd && !available)
                                  ? AppLocalizations.of(context)!.add
                                  : AppLocalizations.of(context)!.delete),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void massEdit() {
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;
    if (widget.portrait && !isWindows) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    Set<int> searchitems = {};
    TextEditingController controller = TextEditingController();
    Map<int, Map<String, dynamic>> changes = {};
    showDialog(
      barrierDismissible: (widget.portrait && !isWindows) ? false : true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context)!.multiple_item_edit,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              final content = SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SearchBar(
                        controller: controller,
                        hintText: AppLocalizations.of(context)!.search_name,
                        onChanged: (value) async {
                          if (value.isEmpty) {
                            if (mounted) {
                              setState(() {
                                searchitems.clear();
                              });
                            }
                            return;
                          }
                          await Future.delayed(
                            const Duration(milliseconds: 200),
                          );
                          try {
                            final response = await ApiClient.get(
                              "/search/${Uri.encodeComponent(value)}",
                            );
                            Map<String, dynamic> decodedJson = jsonDecode(
                              response.body,
                            );
                            List<dynamic> idList = decodedJson["data"];
                            if (mounted) {
                              setState(() {
                                searchitems.clear();
                                for (var i in idList) {
                                  int? itemId = i["item_id"] is int
                                      ? i["item_id"]
                                      : int.tryParse(i["item_id"].toString());

                                  if (itemId != null) {
                                    searchitems.add(itemId);
                                  }
                                }
                              });
                            }
                          } on Exception catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error performing search : $e"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        trailing: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  controller.clear();
                                  searchitems.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: (widget.portrait) ? 5 : 4.8,
                        ),
                        itemCount: searchitems.isNotEmpty
                            ? searchitems.length
                            : GlobalMenuCache.items.length,
                        itemBuilder: (BuildContext context, int index) {
                          int itemId = searchitems.isNotEmpty
                              ? searchitems.elementAt(index)
                              : GlobalMenuCache.items.keys.elementAt(index);
                          return Container(
                            decoration: BoxDecoration(
                              border: (!widget.portrait && index % 2 != 0)
                                  ? const Border(
                                      left: BorderSide(
                                        color: Colors.white54,
                                        width: 1.0,
                                      ),
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Text("${index + 1}."),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    key: ValueKey("name_$itemId"),
                                    initialValue:
                                        GlobalMenuCache.items[itemId]?['name'],
                                    decoration: const InputDecoration(
                                      labelText: "Name",
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                    onChanged: (value) {
                                      changes[itemId] = {
                                        ...changes[itemId] ?? {},
                                        'name': value,
                                      };
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    key: ValueKey("price_$itemId"),
                                    initialValue: GlobalMenuCache
                                        .items[itemId]?['price']
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Price",
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                    onChanged: (value) {
                                      changes[itemId] = {
                                        ...changes[itemId] ?? {},
                                        'price': int.tryParse(value) ?? 0,
                                      };
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    key: ValueKey("stock_$itemId"),
                                    initialValue: GlobalMenuCache
                                        .items[itemId]?['stocks']
                                        .toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Stock",
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                    onChanged: (value) {
                                      changes[itemId] = {
                                        ...changes[itemId] ?? {},
                                        'stocks': int.tryParse(value) ?? 0,
                                      };
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Veg",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Checkbox(
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value:
                                            changes[itemId]?['is_veg'] ??
                                            GlobalMenuCache
                                                .items[itemId]?['is_veg'],
                                        onChanged: (value) {
                                          if (mounted) {
                                            setState(() {
                                              changes[itemId] = {
                                                ...changes[itemId] ?? {},
                                                'is_veg': value,
                                              };
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "Menu",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Checkbox(
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value:
                                            changes[itemId]?['available'] ??
                                            GlobalMenuCache
                                                .items[itemId]?['available'],
                                        onChanged: (value) {
                                          if (mounted) {
                                            setState(() {
                                              changes[itemId] = {
                                                ...changes[itemId] ?? {},
                                                'available': value,
                                              };
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
              if (isWindows) {
                return SizedBox(width: 800, child: content);
              }
              return content;
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: getActionButtonStyle(context, false),
                  onPressed: () {
                    if (!isWindows) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                      ]);
                    }
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.close),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.cancel),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: getActionButtonStyle(context, true),
                  onPressed: () async {
                    for (int i in changes.keys) {
                      final itemChanges = changes[i];
                      if (itemChanges == null) continue;

                      final originalItem = GlobalMenuCache.items[i];
                      if (originalItem == null) continue;

                      final updatedItem = {
                        'name': itemChanges['name'] ?? originalItem['name'],
                        'price': itemChanges['price'] ?? originalItem['price'],
                        'is_veg':
                            itemChanges['is_veg'] ?? originalItem['is_veg'],
                        'available':
                            itemChanges['available'] ??
                            originalItem['available'],
                        'stocks':
                            itemChanges['stocks'] ?? originalItem['stocks'],
                        'pic': originalItem['pic'],
                      };
                      if (mounted) {
                        setState(() {
                          GlobalMenuCache.items[i] = updatedItem;
                        });
                      }
                      await updateitem(i, updatedItem);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Item Changes are Successful"),
                          backgroundColor: Colors.cyanAccent,
                        ),
                      );
                      if (!isWindows) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                        ]);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.check),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.submit),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<int?> addnewitem(
    String name,
    int price,
    bool isveg,
    int stocks,
    bool available, {
    bool hasPic = false,
  }) async {
    try {
      final internalCanteenId = AuthService.canteenId ?? widget.canteenId;
      final response = await ApiClient.post(
        '/menu/create',
        headers: {
          "accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "canteen_id": internalCanteenId,
          "name": name,
          "price": price,
          "is_veg": isveg,
          "is_available": available,
          "stock": stocks,
          "has_pic": hasPic,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedJson = jsonDecode(response.body);
        final int? createdItemId = decodedJson["item_id"] is int
            ? decodedJson["item_id"]
            : int.tryParse(decodedJson["item_id"]?.toString() ?? "");
        if (mounted) {
          setState(() {
            if (createdItemId != null) {
              GlobalMenuCache.items[createdItemId] = {
                "name": name,
                "price": price,
                "is_veg": isveg,
                "available": available,
                "stocks": stocks,
                "pic": decodedJson["pic_link"],
              };
            }
          });
        }
        // Removed internal image upload logic dependent on pngn
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item Created Succesfully"),
              backgroundColor: Colors.cyanAccent,
            ),
          );
        }
        return createdItemId;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ApiClient.tryExtractErrorMessage(response) ??
                    "Error: ${response.body}",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return null;
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return null;
    }
  }

  dynamic updateitem(int itemId, Map<String, dynamic>? item) async {
    try {
      final response = await ApiClient.put(
        "/menu/update",
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "item_id": itemId,
          "update": {
            "is_available": item?["available"],
            "is_veg": item?['is_veg'],
            "name": item?["name"],
            "price": item?["price"],
            "stock": item?["stocks"],
          },
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item Update Successful"),
              backgroundColor: Colors.cyanAccent,
            ),
          );
          setState(() {
            GlobalMenuCache.items[itemId] = {
              "available": item?["available"],
              "is_veg": item?['is_veg'],
              "name": item?["name"],
              "pic": GlobalMenuCache.items[itemId]?['pic'],
              "etag": GlobalMenuCache.items[itemId]?['etag'],
              "price": item?["price"],
              "stocks": item?["stocks"],
            };
          });
          return true;
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error Updating Items : ${response.statusCode}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void deleteitem(int itemId) async {
    try {
      final response = await ApiClient.delete(
        "/menu/delete/$itemId",
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            if (GlobalMenuCache.items[itemId]?['available']) {
              GlobalMenuCache.availableid.remove(itemId);
            } else {
              GlobalMenuCache.navailableid.remove(itemId);
            }
            GlobalMenuCache.items.remove(itemId);
            fetchAndCacheAndNotify();
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item Deleted Successfully"),
              backgroundColor: Colors.cyanAccent,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error Deleting Item : ${response.statusCode}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Not Connected, $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String value = "Name";
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          overlayColor: Colors.black,
          overlayOpacity: 0.4,
          spacing: 12,
          spaceBetweenChildren: 12,
          childrenButtonSize: const Size(60.0, 60.0),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.refresh),
              label: AppLocalizations.of(context)!.refresh,
              backgroundColor: theme.colorScheme.secondary,
              labelStyle: theme.textTheme.labelLarge,
              onTap: () => fetchAndCacheAndNotify(),
            ),
            SpeedDialChild(
              child: const Icon(Icons.edit),
              label: AppLocalizations.of(context)!.bulk_edit,
              backgroundColor: theme.colorScheme.secondary,
              labelStyle: theme.textTheme.labelLarge,
              onTap: () => massEdit(),
            ),
            SpeedDialChild(
              child: const Icon(Icons.add_box),
              label: AppLocalizations.of(context)!.add_item,
              backgroundColor: theme.colorScheme.secondary,
              labelStyle: theme.textTheme.labelLarge,
              onTap: () => addNewItem(),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.on_menu_head,
                    style: theme.textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text("Sort:", style: theme.textTheme.titleMedium),
                      const SizedBox(width: 8),
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButton<String>(
                          value: value,
                          items: ["Name", "Price", "Low Stock"]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (chvalue) {
                            if (mounted) {
                              setState(() {
                                if (chvalue == "Name") {
                                  sortmenu = 1;
                                  value = "Name";
                                } else if (chvalue == "Price") {
                                  sortmenu = 2;
                                  value = "Price";
                                } else {
                                  sortmenu = 3;
                                  value = "Low Stock";
                                }
                              });
                            }
                            applySorting(
                              GlobalMenuCache.items,
                              sortmenu,
                              GlobalMenuCache.availableid,
                              GlobalMenuCache.navailableid,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildGridSection(GlobalMenuCache.availableid, true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.off_menu_head,
                    style: theme.textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text("Sort:", style: theme.textTheme.titleMedium),
                      const SizedBox(width: 8),
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButton<String>(
                          value: value,
                          items: ["Name", "Price", "Low Stock"]
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (chvalue) {
                            if (mounted) {
                              setState(() {
                                if (chvalue == "Name") {
                                  sortmenu = 1;
                                  value = "Name";
                                } else if (chvalue == "Price") {
                                  sortmenu = 2;
                                  value = "Price";
                                } else {
                                  sortmenu = 3;
                                  value = "Low Stock";
                                }
                              });
                            }
                            applySorting(
                              GlobalMenuCache.items,
                              sortmenu,
                              GlobalMenuCache.availableid,
                              GlobalMenuCache.navailableid,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          buildGridSection(GlobalMenuCache.navailableid, false),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }

  Widget showImage(int itemId, bool available) {
    return FutureBuilder<Widget>(
      future: ImageUploadState().buildImageDisplay(itemId.toString(), 160, 160),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MenuGridShimmer();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Text("${snapshot.error}");
        } else {
          return snapshot.data!;
        }
      },
    );
  }

  Widget buildGridSection(Set<int> menuSet, bool available) {
    if (menuSet.isEmpty) {
      if (isLoading) {
        return const SliverToBoxAdapter(child: MenuGridShimmer());
      }
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              available
                  ? AppLocalizations.of(context)!.no_item_menu
                  : AppLocalizations.of(context)!.no_item,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.portrait
            ? 2
            : (MediaQuery.of(context).size.width / 250).floor().clamp(2, 8),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        int itemId = menuSet.elementAt(index);
        final item = GlobalMenuCache.items[itemId];
        if (item == null) return const SizedBox.shrink();

        return MenuItemCard(
          itemId: itemId,
          item: item,
          isTamil: widget.isTamil,
          available: available,
          onTap: () => delAddItem(itemId, item['name'], true, available),
          onEdit: () => modifyItem(
            itemId,
            item['name'],
            item['price'],
            item['is_veg'],
            available,
          ),
          onDelete: () => delAddItem(itemId, item['name'], false, false),
        );
      }, childCount: menuSet.length),
    );
  }
}
