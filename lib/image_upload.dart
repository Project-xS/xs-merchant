import 'dart:convert';
import 'package:croppy/croppy.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:merchant/login.dart';
import 'package:merchant/main.dart';
import 'package:merchant/menupage.dart';
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path!;
      imageFile = File(path);
      imagepicked = FileImage(imageFile!);

      png = null;
      croppedUiImage = null;

      setState(() {});
    }
  }

  Future<void> initialize() async {
    if (imageFile == null || png != null) return;
    final bytes = await imageFile!.readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage != null) {
      img.Image resizedImage = img.copyResize(decodedImage, width: 250, height: 250);
      final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));
      setState(() {
        png = resizedBytes;
        if(widget.newitem){
        widget.onImageUpdate1!(widget.canteenId, png, false);
      }
      else{
        widget.onImageUpdate(widget.canteenId, png, false);
      }
      });
    } else {
      debugPrint("Failed to decode image for initialization.");
      setState(() {
        png = null;
      });
      if(widget.newitem){
        widget.onImageUpdate1!(widget.canteenId, null, false);
      }
      else{
        widget.onImageUpdate(widget.canteenId, null, false);
      }
    }
  }

  Future<void> initializeimage() async{
    await initialize();
  }

  Widget previewImages(){
    if (imageFile == null) {
      return const Text("No image picked yet.");
    }
    initializeimage();
    return FutureBuilder(
      future: initializeimage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return SizedBox(
          height: 400,
          width: 300,
          child: Column(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: (croppedUiImage != null)
                      ? RawImage(image: croppedUiImage!)
                      : (png != null)
                          ? Image.memory(png!)
                          : (imagepicked != null)
                              ? Image(image: imagepicked!)
                              : const Text("No image"),
                ),
              ),
              const SizedBox(height: 10),
              isProcessingImage
                  ? const CircularProgressIndicator.adaptive()
                  : ElevatedButton(
                      onPressed: () async {
                        if (imageFile == null) return;
                        setState(() {
                          isProcessingImage = true;
                        });

                        try {
                          final croppedResult = await showCupertinoImageCropper(
                            context,
                            imageProvider: FileImage(imageFile!),
                            allowedAspectRatios: const [
                              CropAspectRatio(width: 250, height: 250),
                            ],
                            showLoadingIndicatorOnSubmit: false);
                            
                          if (croppedResult != null && mounted) {
                            ui.Image finalImage = croppedResult.uiImage;
                            if (finalImage.width != 250 || finalImage.height != 250) {
                              final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
                              if (byteData != null) {
                                final List<int> bytes = byteData.buffer.asUint8List();
                                img.Image? decodedImage = img.decodeImage(bytes);
                                if (decodedImage != null) {
                                  img.Image resizedImage = img.copyResize(decodedImage, width: 250, height: 250);
                                  final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));
                                  finalImage = await decodeImageFromList(resizedBytes);
                                }
                              }
                            }

                            setState(() {
                              croppedUiImage = finalImage;
                            });
                            await converttopng(croppedUiImage);
                          } else {
                            debugPrint("Cropping canceled or no result received.");
                          }
                        } catch (e) {
                          setState(() {
                            pickImageError = e;
                          });
                          debugPrint("Error during cropping: $e");
                        } finally {
                          setState(() {
                            isProcessingImage = false;
                          });
                        }
                      },
                      child: const Text("Crop Image"),
                    ),
            ],
          ),
        );
      },
    );
  }

  Future<void> converttopng(ui.Image? image) async {
    if (image == null) return;

    final byte = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byte == null) return;

    setState(() {
      png = byte.buffer.asUint8List();
      if(widget.newitem){
        widget.onImageUpdate1!(widget.canteenId, png, false);
      }
      else{        
        widget.onImageUpdate(widget.canteenId, png, false);
      }
    });
  }

Future<String> imageupload(int id, Uint8List? image) async{
  dynamic data, data1;
  if(image == null) return "";
  try{
    if(mounted && Scaffold.maybeOf(context) != null){
    setState((){      
      isLoading = true;
    });}
    final response1 = await http.post(
      Uri.parse("https://proj-xs.fly.dev/assets/upload/$id"), 
      headers: {'Content-Type': 'application/json'});

    if(response1.statusCode == 200){
      data = jsonDecode(response1.body);
      debugPrint("1st: ${data.toString()}");
      final response = await http.put(
        Uri.parse("${data['url']}"), 
        body: image, 
        headers: {'Content-Type': 'image/png'}
        );
      if(response.statusCode == 200){
        final setimage = await http.put(
          Uri.parse("https://proj-xs.fly.dev/menu/set_pic/$id"),
          headers: {'Content-Type': 'application/json'},
        );
        debugPrint(setimage.body);
        final response2 = await http.get(
          Uri.parse("https://proj-xs.fly.dev/assets/$id"),
          headers: {'Content-Type': 'application/json'});
        if (response2.statusCode == 200){
          data1 = jsonDecode(response2.body);
          // debugPrint("2nd: ${data1.toString()}");
          debugPrint("Image Uploaded Successfully");
          isLoading = false;
          debugPrint("${GlobalMenuCache.items[id]?['pic']} ${data1['item_id']} ${data1['url']}");
          return data1['url'];
            
      }else{
        if(mounted && Scaffold.maybeOf(context) != null){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image Upload Failed: Get Stage"),
              backgroundColor: Colors.redAccent,
                ),
          );
        }
        return "";
      }
      }else{
        if(mounted && Scaffold.maybeOf(context) != null){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image Upload Failed: 2nd Stage"),
            backgroundColor: Colors.redAccent,
              ),
        );
      }
      return "";
    }
    }
    else{
      if(mounted && Scaffold.maybeOf(context) != null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image Upload Failed: 1st Stage"),
          backgroundColor: Colors.redAccent,
            ),
      );
    }
    return "";
    }
  } on Exception catch(e){
    debugPrint("Error: $e");
    return "";
  } finally{
    if(mounted && Scaffold.maybeOf(context) != null){
    setState((){
      isLoading = false;
      if(data1 != null){
        GlobalMenuCache.items[id]?['pic'] = data1['url'];
        debugPrint("Image Uploaded Successfully");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image Uploaded Successfully"),
            backgroundColor: Colors.cyanAccent,
          ),
        );
      }
    });}
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
      width: (isAndroid)?115:(MenupageState().axisCount+1)*20.5,
      height: (isAndroid)?115:(MenupageState().axisCount+1)*20.5,
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
        Flexible(child: Text("Picture: ", style: TextStyle(fontSize: 20.00))),
        SizedBox(height: 10),
        ElevatedButton(
          child: (isAndroid)?Text("Open Gallery"):Text("Open File Explorer"),
          onPressed: () => pickImage()
        ),
        SizedBox(height: 10),
        Flexible(child: previewImages()),
      ],
    );
  }
}