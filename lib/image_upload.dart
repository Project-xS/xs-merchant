import 'dart:convert';
import 'package:croppy/croppy.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/auth/auth_service.dart';
import 'package:merchant/common/global_menu_cache.dart';
import 'package:merchant/settings_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart';

class ImageUpload extends StatefulWidget {
  final bool isAndroid;
  final int canteenId;
  final Function(int id, Uint8List? image, bool loading) onImageUpdate;
  final bool newitem;
  final Function(int id, Uint8List? image, bool loading)? onImageUpdate1;
  const ImageUpload(
    this.canteenId,
    this.isAndroid,
    this.onImageUpdate, {
    this.newitem = false,
    this.onImageUpdate1,
    super.key,
  });

  @override
  State<ImageUpload> createState() => ImageUploadState();
}

bool imagecalled = false;
bool isLoading = false;

class ImageUploadState extends State<ImageUpload> {
  final ImagePicker picker = ImagePicker();
  var cropSettings = CropSettings.initial();
  dynamic pickImageError;
  FileImage? imagepicked;
  File? imageFile;
  ui.Image? croppedUiImage;
  Uint8List? png;

  String base64image = "";
  bool isProcessingImage = false;

  Future<void> pickImage({
    int height = 300,
    int width = 300,
    bool item = true,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (mounted) Navigator.of(context).pop();

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path!;
        final pickedFile = File(path);
        if (!mounted) return;
        final croppedResult = await showCupertinoImageCropper(
          context,
          imageProvider: FileImage(pickedFile),
          allowedAspectRatios: [CropAspectRatio(width: width, height: height)],
          showLoadingIndicatorOnSubmit: false,
        );

        if (croppedResult != null && mounted) {
          ui.Image finalImage = croppedResult.uiImage;

          // Set immediately to show in UI while resizing/converting
          setState(() {
            croppedUiImage = finalImage;
            png = null;
          });

          if (finalImage.width != width || finalImage.height != height) {
            final ByteData? byteData = await finalImage.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (byteData != null) {
              final List<int> bytes = byteData.buffer.asUint8List();
              img.Image? decodedImage = img.decodeImage(bytes);
              if (decodedImage != null) {
                img.Image resizedImage = img.copyResize(
                  decodedImage,
                  width: width,
                  height: height,
                );
                final Uint8List resizedBytes = Uint8List.fromList(
                  img.encodePng(resizedImage),
                );
                finalImage = await decodeImageFromList(resizedBytes);
                if (mounted) {
                  setState(() {
                    croppedUiImage = finalImage;
                  });
                }
              }
            }
          }
          await converttopng(finalImage);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Error during image pick/crop: $e");
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> converttopng(ui.Image? image) async {
    if (image == null) return;

    final byte = await image.toByteData(format: ui.ImageByteFormat.png);
    if (kDebugMode)
      debugPrint("Image converted to PNG: ${byte?.lengthInBytes} bytes");
    if (byte == null) return;

    setState(() {
      png = byte.buffer.asUint8List();
      if (widget.newitem) {
        widget.onImageUpdate1!(widget.canteenId, png, false);
      } else {
        widget.onImageUpdate(widget.canteenId, png, false);
      }
      if (kDebugMode)
        debugPrint(
          "Image picked and converted to PNG: ${png?.lengthInBytes} bytes",
        );
    });
  }

  Future<String?> imageupload(
    int id,
    Uint8List? image, {
    int height = 300,
    int width = 300,
  }) async {
    dynamic data, data1;
    if (kDebugMode) {
      debugPrint(
        "[imageupload] Called with id: $id, image: ${image != null ? image.length : 'null'} bytes",
      );
    }
    if (image == null) {
      if (kDebugMode) {
        debugPrint("[imageupload] image is null, returning early");
      }
      return null;
    }
    try {
      if (kDebugMode) debugPrint("[imageupload] Setting isLoading true");
      if (mounted) {
        setState(() {
          isLoading = true;
        });
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text("Uploading..."),
                  ],
                ),
              ),
            );
          },
        );
      }
      if (kDebugMode) {
        debugPrint("[imageupload] Sending PUT to /menu/upload_pic/$id");
      }
      final response1 = await ApiClient.put(
        ApiConstants.menuUploadPic(id),
        headers: {'accept': 'application/json'},
      );
      if (kDebugMode) {
        debugPrint(
          "[imageupload] POST /menu/upload_pic/$id status: ${response1.statusCode}, body: ${response1.body}",
        );
      }
      if (response1.statusCode == 200) {
        data = jsonDecode(response1.body);
        await Future.delayed(Duration(seconds: 1));
        if (kDebugMode) {
          debugPrint("[imageupload] POST response data: ${data.toString()}");
          debugPrint(
            "[imageupload] Sending PUT to presigned url: ${data['presigned_url']}",
          );
        }
        final response = await http.put(
          Uri.parse("${data['presigned_url']}"),
          body: image,
          headers: {'accept': 'image/png'},
        );
        if (kDebugMode) {
          debugPrint(
            "[imageupload] PUT presigned url status: ${response.statusCode}, body: ${response.body}",
          );
        }
        if (response.statusCode == 200) {
          if (kDebugMode) {
            debugPrint("[imageupload] PUT to presigned url succeeded");
            debugPrint("[imageupload] Sending PUT to /menu/set_pic/$id");
          }
          await Future.delayed(Duration(seconds: 1));
          final setimage = await ApiClient.put(
            ApiConstants.menuSetPic(id),
            headers: {'accept': 'application/json'},
          );
          if (kDebugMode) {
            debugPrint(
              "[imageupload] PUT /menu/set_pic/$id status: ${setimage.statusCode}, body: ${setimage.body}",
            );
          }
          if (kDebugMode) {
            debugPrint("[imageupload] Sending GET to /assets/$id");
          }
          await Future.delayed(Duration(seconds: 1));
          final response2 = await ApiClient.get(
            ApiConstants.assets(id),
            headers: {'Content-Type': 'application/json'},
          );
          if (kDebugMode) {
            debugPrint(
              "[imageupload] GET /assets/$id status: ${response2.statusCode}, body: ${response2.body}",
            );
          }
          debugPrint("[imageupload] GET /assets/$id status: ${response2.body}");
          if (response2.statusCode == 200) {
            data1 = jsonDecode(response2.body);
            if (kDebugMode) {
              debugPrint("[imageupload] Image Uploaded Successfully");
              debugPrint(
                "[imageupload] GlobalMenuCache: ${GlobalMenuCache.items[id]?.pic} ${data1['item_id']} ${data1['url']}",
              );
            }
            final item = GlobalMenuCache.items[id];
            if (item != null) {
              GlobalMenuCache.items[id] = item.copyWith(pic: data1['url']);
            }
            return data1['url'];
          } else {
            if (kDebugMode) {
              debugPrint("[imageupload] GET /assets/$id failed");
            }
            if (mounted && Scaffold.maybeOf(context) != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Image Upload Failed: Get Stage, , ${response2.body}",
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
            return "";
          }
        } else {
          if (kDebugMode) {
            debugPrint("[imageupload] PUT to presigned url failed");
          }
          if (mounted && Scaffold.maybeOf(context) != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Image Upload Failed: 2nd Stage, ${response1.body}",
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return "";
        }
      } else {
        if (kDebugMode) {
          debugPrint("[imageupload] POST /assets/upload/$id failed");
        }
        if (mounted && Scaffold.maybeOf(context) != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Image Upload Failed: 1st Stage, ${response1.body}",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return "";
      }
    } on Exception catch (e) {
      if (kDebugMode) debugPrint("[imageupload] Exception: $e");
      return "";
    } finally {
      if (kDebugMode) {
        debugPrint("[imageupload] finally block, isLoading set to false");
      }
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        setState(() {
          isLoading = false;
          if (data1 != null) {
            final item = GlobalMenuCache.items[id];
            if (item != null) {
              GlobalMenuCache.items[id] = item.copyWith(pic: data1['url']);
            }
            if (kDebugMode) {
              debugPrint("[imageupload] Image Uploaded Successfully (finally)");
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Image Uploaded Successfully"),
                backgroundColor: Colors.cyanAccent,
              ),
            );
          }
        });
      }
    }
  }

  Future<Widget> buildImageDisplay(
    String itemId,
    double width,
    double height,
  ) async {
    final imageUrl = GlobalMenuCache.items[int.parse(itemId)]?.pic;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      bool found = await cachedImageExists(
        imageUrl,
        cacheKey: GlobalMenuCache.items[int.parse(itemId)]?.etag,
      );
      File? file = await getCachedImageFile(
        imageUrl,
        cacheKey: GlobalMenuCache.items[int.parse(itemId)]?.etag,
      );
      if (found && file != null) {
        return Image.file(file);
      }
      return ExtendedImage.network(
        imageUrl,
        filterQuality: FilterQuality.high,
        cacheKey: GlobalMenuCache.items[int.parse(itemId)]?.etag,
        cache: true,
        // width: (isAndroid) ? 115 : width,
        // height: (isAndroid) ? 115 : height,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return const Center(child: CircularProgressIndicator());
            case LoadState.completed:
              return ExtendedRawImage(
                image: state.extendedImageInfo?.image,
                fit: BoxFit.cover,
              );
            case LoadState.failed:
              return const Center(child: Icon(Icons.fastfood, size: 50));
          }
        },
      );
    } else {
      return const Center(child: Icon(Icons.fastfood, size: 50));
    }
  }

  Future<void> removeImageFromCache(String url, String itemId) async {
    await clearDiskCachedImage(url, cacheKey: itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Picture: ", style: TextStyle(fontSize: 20.00)),
        ElevatedButton(
          child: const Text("Select Image"),
          onPressed: () => pickImage(),
        ),
        if (png != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.memory(png!, height: 150),
          )
        else if (croppedUiImage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawImage(image: croppedUiImage, height: 150),
          ),
      ],
    );
  }
}

Future<void> pickAndUploadCanteenImage(
  BuildContext context,
  int canteenId,
) async {
  final effectiveCanteenId = AuthService.canteenId ?? canteenId;
  if (effectiveCanteenId == 0) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to determine canteen id. Please log in again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    return;
  }
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Loading..."),
            ],
          ),
        ),
      );
    },
  );

  Uint8List? imageBytes;
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path!;
      final pickedFile = File(path);
      final croppedResult = await showCupertinoImageCropper(
        context.mounted ? context : context,
        imageProvider: FileImage(pickedFile),
        allowedAspectRatios: [CropAspectRatio(width: 1280, height: 500)],
        showLoadingIndicatorOnSubmit: false,
      );

      if (croppedResult != null) {
        ui.Image finalImage = croppedResult.uiImage;
        if (finalImage.width != 1280 || finalImage.height != 500) {
          final ByteData? byteData = await finalImage.toByteData(
            format: ui.ImageByteFormat.png,
          );
          if (byteData != null) {
            final List<int> bytes = byteData.buffer.asUint8List();
            img.Image? decodedImage = img.decodeImage(bytes);
            if (decodedImage != null) {
              img.Image resizedImage = img.copyResize(
                decodedImage,
                width: 1280,
                height: 500,
              );
              imageBytes = Uint8List.fromList(img.encodePng(resizedImage));
            }
          }
        } else {
          final byteData = await finalImage.toByteData(
            format: ui.ImageByteFormat.png,
          );
          imageBytes = byteData?.buffer.asUint8List();
        }
      }
    }
  } catch (e) {
    if (kDebugMode) debugPrint("Error during image pick/crop: $e");
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    return;
  }

  if (imageBytes == null) {
    return;
  }

  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Uploading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  try {
    final response1 = await ApiClient.put(
      ApiConstants.canteenUploadPic,
      headers: {'accept': 'application/json'},
    );

    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final response = await http.put(
        Uri.parse("${data['presigned_url']}"),
        body: imageBytes,
        headers: {'accept': 'image/png'},
      );

      if (response.statusCode == 200) {
        await ApiClient.put(
          ApiConstants.canteenSetPic,
          headers: {'accept': 'application/json'},
        );

        if (context.mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Canteen Image Updated Successfully"),
              backgroundColor: Colors.cyanAccent,
            ),
          );
        }
      } else {
        if (context.mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image Upload Failed: 2nd Stage, ${response.body}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image Upload Failed: 1st Stage, ${response1.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  } on Exception catch (e) {
    if (kDebugMode) debugPrint("[imageupload] Exception: $e");
    if (context.mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred during upload."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
