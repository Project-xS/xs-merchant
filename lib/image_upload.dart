import 'dart:convert';
import 'package:croppy/croppy.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:merchant/login.dart';
import 'package:merchant/main.dart';
import 'package:merchant/settings_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:extended_image/extended_image.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUpload extends StatefulWidget {
  final bool isAndroid;
  final int canteenId;
  final Function(int id, Uint8List? image, bool loading) onImageUpdate;
  final bool newitem;
  final Function(int id, Uint8List? image, bool loading)? onImageUpdate1;
  const ImageUpload(this.canteenId, this.isAndroid, this.onImageUpdate,{this.newitem = false, this.onImageUpdate1, super.key});

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

  Future<void> pickImage() async {
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
          allowedAspectRatios: const [
            CropAspectRatio(width: 250, height: 250),
          ],
          showLoadingIndicatorOnSubmit: false,
        );

        if (croppedResult != null && mounted) {
          ui.Image finalImage = croppedResult.uiImage;
          if (finalImage.width != 250 || finalImage.height != 250) {
            final ByteData? byteData =
                await finalImage.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final List<int> bytes = byteData.buffer.asUint8List();
              img.Image? decodedImage = img.decodeImage(bytes);
              if (decodedImage != null) {
                img.Image resizedImage =
                    img.copyResize(decodedImage, width: 250, height: 250);
                final Uint8List resizedBytes =
                    Uint8List.fromList(img.encodePng(resizedImage));
                finalImage = await decodeImageFromList(resizedBytes);
              }
            }
          }

          setState(() {
            croppedUiImage = finalImage;
          });
          await converttopng(croppedUiImage);
        }
      }
    } catch (e) {
      debugPrint("Error during image pick/crop: $e");
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> converttopng(ui.Image? image) async {
    if (image == null) return;

    final byte = await image.toByteData(format: ui.ImageByteFormat.png);
    debugPrint("Image converted to PNG: ${byte?.lengthInBytes} bytes");
    if (byte == null) return;

    setState(() {
      png = byte.buffer.asUint8List();
      if(widget.newitem){
        widget.onImageUpdate1!(widget.canteenId, png, false);
      }
      else{        
        widget.onImageUpdate(widget.canteenId, png, false);
      }
      debugPrint("Image picked and converted to PNG: ${png?.lengthInBytes} bytes");
    });
  }

Future<String> imageupload(int id, Uint8List? image) async{
  dynamic data, data1;
  debugPrint("[imageupload] Called with id: $id, image: ${image != null ? image.length : 'null'} bytes");
  if(image == null) {
    debugPrint("[imageupload] image is null, returning early");
    return "";
  }
  try{
    debugPrint("[imageupload] Setting isLoading true");
    if(mounted && Scaffold.maybeOf(context) != null){
      setState((){      
        isLoading = true;
      });
    }
    debugPrint("[imageupload] Sending POST to /assets/upload/$id");
    final response1 = await http.post(
      Uri.parse("https://proj-xs.fly.dev/assets/upload/$id"), 
      headers: {'Content-Type': 'application/json'});
    debugPrint("[imageupload] POST /assets/upload/$id status: ${response1.statusCode}, body: ${response1.body}");

    if(response1.statusCode == 200){
      data = jsonDecode(response1.body);
      await Future.delayed(Duration(seconds: 1));
      debugPrint("[imageupload] POST response data: ${data.toString()}");
      debugPrint("[imageupload] Sending PUT to presigned url: ${data['url']}");
      final response = await http.put(
        Uri.parse("${data['url']}"),
        body: image, 
        headers: {'Content-Type': 'image/png'}
      );
      debugPrint("[imageupload] PUT presigned url status: ${response.statusCode}, body: ${response.body}");
      if(response.statusCode == 200){
        debugPrint("[imageupload] PUT to presigned url succeeded");
        debugPrint("[imageupload] Sending PUT to /menu/set_pic/$id");
        await Future.delayed(Duration(seconds: 1));
        final setimage = await http.put(
          Uri.parse("https://proj-xs.fly.dev/menu/set_pic/$id"),
          headers: {'Content-Type': 'application/json'},
        );
        debugPrint("[imageupload] PUT /menu/set_pic/$id status: ${setimage.statusCode}, body: ${setimage.body}");
        debugPrint("[imageupload] Sending GET to /assets/$id");
        await Future.delayed(Duration(seconds: 1));
        final response2 = await http.get(
          Uri.parse("https://proj-xs.fly.dev/assets/$id"),
          headers: {'Content-Type': 'application/json'});
        debugPrint("[imageupload] GET /assets/$id status: ${response2.statusCode}, body: ${response2.body}");
        if (response2.statusCode == 200){
          data1 = jsonDecode(response2.body);
          debugPrint("[imageupload] Image Uploaded Successfully");
          isLoading = false;
          debugPrint("[imageupload] GlobalMenuCache: ${GlobalMenuCache.items[id]?['pic']} ${data1['item_id']} ${data1['url']}");
          return data1['url'];      
        }else{
          debugPrint("[imageupload] GET /assets/$id failed");
          if(mounted && Scaffold.maybeOf(context) != null){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Image Upload Failed: Get Stage, , ${response2.body}"),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return "";
        }
      }else{
        debugPrint("[imageupload] PUT to presigned url failed");
        if(mounted && Scaffold.maybeOf(context) != null){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image Upload Failed: 2nd Stage, ${response1.body}"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return "";
      }
    }
    else{
      debugPrint("[imageupload] POST /assets/upload/$id failed");
      if(mounted && Scaffold.maybeOf(context) != null){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image Upload Failed: 1st Stage, ${response1.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return "";
    }
  } on Exception catch(e){
    debugPrint("[imageupload] Exception: $e");
    return "";
  } finally{
    debugPrint("[imageupload] finally block, isLoading set to false");
    if(mounted && Scaffold.maybeOf(context) != null){
      setState((){
        isLoading = false;
        if(data1 != null){
          GlobalMenuCache.items[id]?['pic'] = data1['url'];
          debugPrint("[imageupload] Image Uploaded Successfully (finally)");
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

dynamic getallimage(Function(Map<String, String>) imageexpired) async{
  Map<String, String> updated = {};
  Set<int> item = GlobalMenuCache.availableid;
  Set<int> item1 = GlobalMenuCache.availableid;
  for(int i in item){
    if(GlobalMenuCache.items[i]?['pic'] != true){
      continue;
    }
    final response = await http.get(
    Uri.parse("https://proj-xs.fly.dev/assets/$i"),
    headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200){
      final data1 = jsonDecode(response.body);
        updated['$i'] = data1['url'];
    }
  }
  for(int i in item1){
    if(GlobalMenuCache.items[i]?['pic'] != true){
      continue;
    }
    final response = await http.get(
    Uri.parse("https://proj-xs.fly.dev/assets/$i"),
    headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200){
      final data1 = jsonDecode(response.body);
        updated['$i'] = data1['url'];
    }
  }
  // debugPrint("Updated Expired Image");
  imagecalled = false;
  imageexpired(updated);
  return;
}

Future<Widget> buildImageDisplay(String itemId, double width, double height, SharedPreferences cache, Function(Map<String, String>) imageexpired) async{
  // return Image(image: AssetImage("assets/images/friedrice.png"));
  if (imagecalled) return const Center(child: CircularProgressIndicator());
  final cacheTimeString = cache.getString('time');
  final now = DateTime.now();
  if (cacheTimeString == null || cache.getString('piclink') == null ||
      now.difference(DateTime.parse(cacheTimeString)).inHours > 11) {
        if(!imagecalled){
          imagecalled = true;
          await getallimage(imageexpired);
        }
        else{
          debugPrint("!imagecalled, ${GlobalMenuCache.items[int.parse(itemId)]?['name']}");
          return const Center(
            child: Icon(Icons.fastfood, size: 50),
          );
        }
  }
  final picLinkString = cache.getString('piclink');
  if (picLinkString == null) {
    debugPrint("piclink not found");
    return const Center(
      child: Icon(Icons.fastfood, size: 50),
    );
  }
  final Map<String, dynamic> link = jsonDecode(picLinkString);
  final imageUrl = link[itemId];

  if (imageUrl != null && GlobalMenuCache.items[int.parse(itemId)]?['pic'] == true ) {
    return ExtendedImage.network(
      imageUrl,
      filterQuality: FilterQuality.high,
      cache: true,
      cacheKey: itemId,
      width: (isAndroid)?115:(2)*20.5,
      height: (isAndroid)?115:(5)*20.5,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const Center(child: CircularProgressIndicator());
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              fit: BoxFit.scaleDown,
            );
          case LoadState.failed:
            debugPrint("No image loadstate failed, ${GlobalMenuCache.items[int.parse(itemId)]?['name']}");
            return const Center(
              child: Icon(Icons.fastfood, size: 50),
            );
        }
      },
    );
  } else {
    return const Center(
      child: Icon(Icons.fastfood, size: 50),
    );
  }
}

Future<void> removeImageFromCache(String url,String itemId) async {
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
          ),
      ],
    );
  }
}