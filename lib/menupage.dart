import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auto_fetch_mixin.dart';
import 'package:merchant/image_upload.dart';
import 'package:merchant/l10n/app_localizations.dart';
import 'package:merchant/login.dart';
import 'package:merchant/main.dart';


class Menupage extends StatefulWidget {
  final bool portrait;
  final bool isTamil;
  final int canteenId;
  const Menupage(this.portrait, this.isTamil, this.canteenId, {super.key});

  @override
  State<Menupage> createState() => MenupageState();
}


class MenupageState extends State<Menupage> with AutoFetchMixin<Menupage>{
  int sortmenu = 1;
  Uint8List? png, pngn;
  int? pngid;
  bool isLoading = false;
  Map<String, String> piclink = {};
  Image icon = Image(image: AssetImage("assets/images/logo.png"), width: 256.00, height: 256.00);
  Image itemicon = Image(image: AssetImage("assets/images/friedrice.png"));

  @override
  int get canteenIdToFetch => widget.canteenId;

  @override
  void initState(){
    if((timer == null || !timer!.isActive) && GlobalMenuCache.items.isEmpty){
      fetchAndCacheAndNotify(widget.canteenId);
    }
    super.initState();
  }

  dynamic onImageUpdate(int id, Uint8List? image, bool loading){
    setState((){
      png = image;
      pngid = id;
      isLoading = loading;
    });
  }

  dynamic onImageUpdate1(int id, Uint8List? image, bool loading){
    setState((){
      pngn = image;
      isLoading = loading;
    });
  }

  void modifyItem(int itemId, String oldName, int oldRate, bool isveg, bool available){
    bool loading = false;
    bool isError = false;
    String name = "";
    int stocks = GlobalMenuCache.items[itemId]?['stocks']??0;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.modify_item(oldName) , style: TextStyle(fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w500)),
              content: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10.00),
                  child: Form(
                    child: Column(
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                          return TextFormField(
                            maxLength: 40,
                            initialValue: oldName,
                            autofocus: true,
                            autocorrect: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.new_name,
                              labelStyle: TextStyle(fontSize: 15.00),
                              floatingLabelStyle: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                              counterText: "",
                              errorText: isError ? "Item Already Present" : null,
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isError ? Colors.red : Colors.blue, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: isError ? Colors.red : Colors.grey, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                if (GlobalMenuCache.items.values.where((item) => item != GlobalMenuCache.items[itemId]).any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == value.trim().toLowerCase().replaceAll(' ', ''))) {
                                  isError = true;
                                } else {
                                  isError = false;
                                  name = value;
                                }
                              });
                            },
                          );}
                        ),
                        SizedBox(height: 20.00),
                        TextFormField(
                          maxLength: 4,
                          initialValue: oldRate.toInt().toString(),
                          autofocus: true,
                          autocorrect: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.new_price,
                            labelStyle: TextStyle(fontSize: 15.00),
                            floatingLabelStyle: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              oldRate = (int.tryParse(value) != null)? int.parse(value) : oldRate;
                            });
                          },
                        ),
                        SizedBox(height: 5.00),
                        TextFormField(
                          maxLength: 5,
                          initialValue: "${GlobalMenuCache.items[itemId]?['stocks']}",
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?([1-9][0-9]*|0)?$'))],
                          onChanged: (value) {
                            if (value.isEmpty || value == "-") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: Stocks can be either -1 or finite",
                                      style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            } else {
                              int parsedValue = int.tryParse(value)??stocks;
                                if (parsedValue < -1){
                                  stocks = 1;
                                }
                                else{
                                  stocks = parsedValue;
                                }
                              }
                          },
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.stock,
                            labelStyle: TextStyle(fontSize: 15.00),
                            floatingLabelStyle: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                            hintText: "Enter -1 for Unlimited",
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text("${AppLocalizations.of(context)!.veg} : ", style: TextStyle(fontSize: 15.00)),
                            StatefulBuilder(
                              builder:(context, setState) {
                              return Checkbox(
                                value: isveg,
                                onChanged: (value) {
                                  setState(() {
                                    isveg = value ?? false;
                                  });
                                },
                              );},
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Column(children: [
                          Text("Picture: ", style: TextStyle(fontSize: 20.00)),
                          SizedBox(height: 10),
                          ImageUpload(widget.canteenId, widget.portrait, onImageUpdate),
                        ])
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                StatefulBuilder(
                  builder: (context, setState) {
                   return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                          foregroundColor: WidgetStateProperty.all(Colors.black),
                          padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                          fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                          overlayColor: WidgetStateProperty.all(const Color.fromARGB(227, 237, 74, 14)),
                        ),
                        onPressed: () {
                          setState((){
                            loading = false;
                          });
                          Navigator.pop(context);
                        },
                        child:Text(AppLocalizations.of(context)!.cancel, style: TextStyle(fontWeight: FontWeight.w600)),                  
                      ),
                    TextButton(
                      style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      padding: WidgetStateProperty.all(EdgeInsets.all(30.00)),
                      fixedSize: WidgetStateProperty.all(Size.fromWidth(132)),
                      overlayColor: WidgetStateProperty.all((isLoading)?Colors.grey:Color.fromARGB(255, 37, 113, 255)),
                    ),
                    onPressed: (loading) ? null : () async{
                      setState((){
                        loading = true;
                      });
                      if(!isError){
                          setState(() {
                            GlobalMenuCache.items[itemId] = {
                              'name': name.isNotEmpty?name:oldName,
                              'price': oldRate,
                              'is_veg': isveg,
                              'available': available,
                              'stocks': stocks,
                              'pic': GlobalMenuCache.items[itemId]?['pic']
                            };
                          });
                            String url = await ImageUploadState().imageupload(itemId, png);
                            if(url.isNotEmpty){
                              setState(() {                              
                                GlobalMenuCache.items[itemId]?['pic'] = url;
                                final Map<String, dynamic> list = jsonDecode(cache.getString("piclink")!);
                                list.map((itemId, url)=> MapEntry(itemId.toString(), url));
                                list[itemId.toString()] = url;
                                changeimage(itemId, url);
                              });
                            }
                            await updateitem(itemId, GlobalMenuCache.items[itemId]);
                            setState((){
                              loading = false;
                            });
                            if(mounted){
                              Navigator.pop(context);
                            }
                          }
                          else{
                            setState(() {
                              loading = false;
                            });
                          }
                        },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      (loading)?Flexible(child: SizedBox(height: 20.00, width: 20.00, child: CircularProgressIndicator())):Icon(Icons.check, color: Colors.greenAccent),
                      SizedBox(width: 5.00),
                      Text(AppLocalizations.of(context)!.submit, style: TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                    ),
                    ],
                  );},
                )]);
          },
        );
  }

  void addNewItem() {
    bool isError = false;
    String name = "";
    String priceText = "";
    int stocks = 0;
    bool isveg = false;
    bool available = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.add_item_head, style: TextStyle(fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
            content: Padding(
              padding: EdgeInsets.all(10.00),
              child: Form(
                child: Column(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                      return Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          maxLength: 40,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.name,
                            labelStyle: TextStyle(fontSize: 15.00),
                            floatingLabelStyle: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                            errorText: isError ? "Item Already Exists, this Updates the existing item" : null,
                            errorMaxLines: 2,
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isError ? Colors.red : Colors.blue, width: 2),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: isError ? Colors.red : Colors.grey, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              name = value;
                              isError = GlobalMenuCache.items.values.any(
                                (item) => item['name'].trim().toLowerCase().replaceAll(' ', '') ==
                                    value.trim().toLowerCase().replaceAll(' ', ''),
                              );
                            });
                          },
                        )
                      );},
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: TextFormField(
                        maxLength: 4,
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.price,
                          labelStyle: TextStyle(fontSize: 15.00),
                          floatingLabelStyle: TextStyle(fontSize: 20.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            priceText = value;
                          });
                        },
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: TextFormField(
                      maxLength: 5,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?([1-9][0-9]*|0)?$'))],
                      onChanged: (value) {
                        if (value.isEmpty || value == "-") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: Stocks can be either -1 or finite",
                                  style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } else {
                          int? parsedValue = int.tryParse(value);
                          if(parsedValue != null){
                            if (parsedValue < -1){
                              stocks = 1;
                            }
                            else{
                              stocks = parsedValue;
                            }
                          }
                          else{
                            stocks = 0;
                          }
                        }
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.stock,
                        hintText: "Enter -1 for Unlimited",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.00),
                  StatefulBuilder(builder: (context, setState) {
                    return Row(
                      children: [
                        Text("${AppLocalizations.of(context)!.veg} : ", style: TextStyle(fontSize: 15.00)),
                        Checkbox(
                          value: isveg,
                          onChanged: (value) {
                            setState(() {
                              isveg = value ?? false;
                              if (value == null || isveg == false){
                                isveg = false;
                              }
                              else{
                                isveg = true;
                              }
                            });
                          },
                        ),
                      ],
                    );}),
                    SizedBox(height: 15),
                    Column(children: [
                      Text("Picture: ", style: TextStyle(fontSize: 20.00)),
                      SizedBox(height: 10),
                      ImageUpload(widget.canteenId, widget.portrait, onImageUpdate1, newitem: true, onImageUpdate1: onImageUpdate1,),])
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(EdgeInsets.all(30.00)),
                  fixedSize: WidgetStatePropertyAll(Size.fromWidth(132)),
                  overlayColor: WidgetStatePropertyAll(const Color.fromARGB(255, 37, 113, 255)),
                ),
                onPressed: () {
                  if (name.isEmpty || priceText.isEmpty || int.tryParse(priceText) == null || int.parse(priceText) == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Error - Don't feed Empty or Invalid Values",
                          style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  setState(() {
                    int olditemid = 0;
                    int foundItemId = GlobalMenuCache.items.keys.firstWhere(
                      (key) => GlobalMenuCache.items[key]?['name'].trim().toLowerCase().replaceAll(' ', '') ==
                          name.trim().toLowerCase().replaceAll(' ', ''),
                          orElse: () => olditemid,
                    );
                    if(foundItemId!=olditemid){
                      GlobalMenuCache.items[foundItemId] = {
                        'name': name,
                        'price': int.parse(priceText),
                        'is_veg': isveg,
                        'available': available,
                        'stocks': stocks,
                      };
                      updateitem(foundItemId, GlobalMenuCache.items[foundItemId]);
                      if (GlobalMenuCache.navailableid.contains(foundItemId)){
                        GlobalMenuCache.navailableid.remove(foundItemId);
                        GlobalMenuCache.availableid.add(foundItemId);
                      }
                      }
                      else{
                        apipostcall(name, int.parse(priceText), isveg, stocks, available);
                      }
                    if (isError){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Item: $name Already Exists, Updated its details",
                            style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                          ),
                          backgroundColor: Colors.yellowAccent,
                        ),
                      );
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Item : \"$name\" Added Successfully",
                            style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                          ),
                          backgroundColor: Colors.cyanAccent,
                        ),
                      );
                    }
                  });
                  Navigator.pop(context);
                  },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.check, color: Colors.greenAccent), 
                  Text(AppLocalizations.of(context)!.submit, 
                  style: TextStyle(fontWeight: FontWeight.w600))]),
              ),
            ],
          );
        });
  }

  void delAddItem(int itemId, String name, bool isAdd , bool available){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text((isAdd && available)?AppLocalizations.of(context)!.confirm_remove(name):((isAdd && !available)?AppLocalizations.of(context)!.confirm_add(name):AppLocalizations.of(context)!.confirm_delete(name)), style: TextStyle(fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w500)),
        content: SizedBox(
          width: double.minPositive,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)), 
                  fixedSize: WidgetStatePropertyAll(Size(120, 45)),
                  overlayColor: WidgetStatePropertyAll(Color.fromARGB(255, 37, 113, 255)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel)
              ),
              SizedBox(width:20.00),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(isAdd?(available?Colors.yellow:Colors.green):Colors.red),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)), 
                  fixedSize: WidgetStatePropertyAll(Size(120, 45)),
                  overlayColor: WidgetStatePropertyAll(isAdd?(available?Colors.yellowAccent:Colors.greenAccent):Colors.redAccent),
                ),
                onPressed: () {
                    setState(() {
                      if (isAdd == true){
                        if (GlobalMenuCache.items[itemId]?['available']) {
                          GlobalMenuCache.availableid.remove(itemId);
                          GlobalMenuCache.navailableid.add(itemId);
                          GlobalMenuCache.items[itemId]?['available'] = false;
                          updateitem(itemId, GlobalMenuCache.items[itemId]);
                        }
                        else {
                            GlobalMenuCache.items[itemId]?['available'] = true;
                            GlobalMenuCache.availableid.add(itemId);
                            GlobalMenuCache.navailableid.remove(itemId);
                            updateitem(itemId, GlobalMenuCache.items[itemId]);
                      }}
                      else{
                        deleteitem(itemId);
                      }
                      Navigator.pop(context);
                    });
                },
                child: Text((isAdd && available)?AppLocalizations.of(context)!.remove:((isAdd && !available)?AppLocalizations.of(context)!.add:AppLocalizations.of(context)!.delete), style: TextStyle(fontWeight:(widget.isTamil)?FontWeight.w600:FontWeight.w500)),
          )],
          ),
        ),
      );
    },
  );
}

  void massEdit(){
    if (widget.portrait){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
    ]);
    }
    Set<int> searchitems = {};
    TextEditingController controller = TextEditingController();
    Map<int, bool> errorMap = {};
    Set<String> err = {};
    Map<int, Map<String, dynamic>> changes = {};
    showDialog(
      barrierDismissible: (widget.portrait)?false:true,
      context: context,
      builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.multiple_item_edit),
              titleTextStyle: TextStyle(fontSize: 25.00, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w500),
              content: SizedBox(
                height: 400.00,
                width: (widget.isTamil && widget.portrait)?670:(widget.portrait)?660:(widget.isTamil)?665:550,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SearchBar(
                            controller: controller,
                            backgroundColor: WidgetStateProperty.all(Colors.black),
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
                            leading: Icon(Icons.search),
                            hintText: AppLocalizations.of(context)!.search_name,
                            onChanged: (value) async {
                              if(value.isEmpty){
                                setState(() {
                                  searchitems.clear();
                                });
                                return;
                              }
                              await Future.delayed(Duration(milliseconds: 200));
                              try {
                                final response = await http.get(Uri.parse("https://proj-xs.fly.dev/search/$canteenId/$value"));
                                Map<String, dynamic> decodedJson = jsonDecode(response.body);
                                // debugPrint("$decodedJson");
                                List<dynamic> idList = decodedJson["data"];
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
                              } on Exception catch (e) {
                                if (mounted){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error performing search : $e"),
                                  backgroundColor: Colors.redAccent)
                                );
                                }
                              }
                            },
                            trailing: [
                              IconButton(icon: Icon(Icons.clear),
                                onPressed: (){
                                  setState(() {
                                    controller.clear();
                                    searchitems.clear();
                                  });}), SizedBox(width: 10)]
                            ),
                          ),
                          SizedBox(height: 10),
                          ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: searchitems.isNotEmpty ? searchitems.length : GlobalMenuCache.items.length,
                            itemBuilder: (BuildContext context, int index) {
                            int itemId = searchitems.isNotEmpty ? searchitems.elementAt(index) : GlobalMenuCache.items.keys.elementAt(index);
                              return ListTile(
                                subtitle: Form(
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          StatefulBuilder(
                                            builder: (context, setState) {
                                            return SizedBox( 
                                              width: (widget.isTamil)?140.00:150.00,
                                              child: TextFormField(
                                                key: ValueKey(GlobalMenuCache.items[itemId]?['name']),
                                                maxLength: 40,
                                                initialValue: GlobalMenuCache.items[itemId]?['name'],
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value.isEmpty) {
                                                      errorMap[itemId] = true;
                                                      err.add('Empty');
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text("Error: Name Cannot be Empty",
                                                              style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                                                          backgroundColor: Colors.redAccent,
                                                        ),
                                                      );
                                                    } else {
                                                      if (GlobalMenuCache.items.values.where((item) => item != GlobalMenuCache.items[itemId]).any((item) => item['name'].trim().toLowerCase().replaceAll(' ', '') == value.trim().toLowerCase().replaceAll(' ', ''))) {
                                                        errorMap[itemId] = true;
                                                        err.add(value.trim().toLowerCase().replaceAll(" ", ""));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text("Item: $value Already Exists, Change the name",
                                                                style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                                                            backgroundColor: Colors.redAccent,
                                                          ),
                                                        );
                                                      } else {
                                                        errorMap.remove(itemId);
                                                        if (!errorMap.containsKey(itemId)){
                                                        changes[itemId] = {
                                                          'name': value,
                                                          'price': changes.containsKey(itemId) ? (changes[itemId]?['price']) : (GlobalMenuCache.items[itemId]?['price']),
                                                          'is_veg': changes.containsKey(itemId) ? (changes[itemId]?['is_veg']) : (GlobalMenuCache.items[itemId]?['is_veg']),
                                                          'available': changes.containsKey(itemId) ? (changes[itemId]?['available']) : (GlobalMenuCache.items[itemId]?['available']),
                                                          'stocks': changes.containsKey(itemId) ? (changes[itemId]?['stocks']) : (GlobalMenuCache.items[itemId]?['stocks'])
                                                        };
                                                      }}
                                                    }
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  labelText: AppLocalizations.of(context)!.name,
                                                  counterText: "",
                                                  errorText: errorMap[itemId] == true ? "Item Exists or Empty" : null,
                                                  border: OutlineInputBorder(),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: errorMap[itemId] == true ? Colors.red : Colors.blue, width: 2),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: errorMap[itemId] == true ? Colors.red : Colors.grey, width: 2),
                                                  ),
                                                ),
                                              ),
                                            );},
                                          ),
                                          SizedBox(width: 10.00),
                                            SizedBox(
                                              width: (widget.isTamil)?75.00:60.00,
                                              child: TextFormField(
                                                key: ValueKey(GlobalMenuCache.items[itemId]?['price']),
                                                maxLength: 4,
                                                initialValue: GlobalMenuCache.items[itemId]?['price'].toString(),
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                onChanged: (value) {
                                                  if (value.isEmpty) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Error: Price Cannot be Empty",
                                                            style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                                                        backgroundColor: Colors.redAccent,
                                                      ),
                                                    );
                                                  } else {
                                                    changes[itemId] = {
                                                      'price': int.parse(value),
                                                      'name': changes.containsKey(itemId) ? (changes[itemId]?['name']) : (GlobalMenuCache.items[itemId]?['name']),
                                                      'is_veg': changes.containsKey(itemId) ? (changes[itemId]?['is_veg']) : (GlobalMenuCache.items[itemId]?['is_veg']),
                                                      'available': changes.containsKey(itemId) ? (changes[itemId]?['available']) : (GlobalMenuCache.items[itemId]?['available']),
                                                      'stocks': changes.containsKey(itemId) ? (changes[itemId]?['stocks']) : (GlobalMenuCache.items[itemId]?['stocks'])
                                                    };
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: AppLocalizations.of(context)!.price,
                                                  counterText: "",
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.blue, width: 2),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.00),
                                            SizedBox(
                                              width: (widget.isTamil)?75.00:60.00,
                                              child: TextFormField(
                                                key: ValueKey(GlobalMenuCache.items[itemId]?['stocks']),
                                                maxLength: 5,
                                                initialValue: GlobalMenuCache.items[itemId]?['stocks'].toString(),
                                                keyboardType: TextInputType.number,
                                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?([1-9][0-9]*|0)?$'))],
                                                onChanged: (value) {
                                                  if (value.isEmpty || value == "-") {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Error: Stocks can be either -1 or finite",
                                                            style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                                                        backgroundColor: Colors.redAccent,
                                                      ),
                                                    );
                                                  } else {
                                                    int? parsedValue = int.tryParse(value);
                                                    if (parsedValue != null) {
                                                      if (parsedValue < -1) parsedValue = -1;
                                                      changes[itemId] = {
                                                        'price': changes.containsKey(itemId) ? (changes[itemId]?['price']) : (GlobalMenuCache.items[itemId]?['price']),
                                                        'name': changes.containsKey(itemId) ? (changes[itemId]?['name']) : (GlobalMenuCache.items[itemId]?['name']),
                                                        'is_veg': changes.containsKey(itemId) ? (changes[itemId]?['is_veg']) : (GlobalMenuCache.items[itemId]?['is_veg']),
                                                        'available': changes.containsKey(itemId) ? (changes[itemId]?['available']) : (GlobalMenuCache.items[itemId]?['available']),
                                                        'stocks': parsedValue,
                                                      };
                                                    }
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: AppLocalizations.of(context)!.stock,
                                                  counterText: "",
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.blue, width: 2),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.grey, width: 2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.00),
                                            SizedBox(
                                              width: (widget.isTamil)?95.00:70.00,
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Checkbox(
                                                        value: GlobalMenuCache.items[itemId]?['is_veg'],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            GlobalMenuCache.items[itemId]?['is_veg'] = !(GlobalMenuCache.items[itemId]?['is_veg'] ?? false);
                                                          });
                                                        },
                                                      ),
                                                      Text(AppLocalizations.of(context)!.veg, style: TextStyle(fontSize: 15.00)),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.00),
                                            Expanded(
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Row(
                                                    children: [
                                                      Checkbox(
                                                        value: GlobalMenuCache.items[itemId]?['available'],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            if (!GlobalMenuCache.items[itemId]?['available']) {
                                                              GlobalMenuCache.items[itemId]?['available'] = true;
                                                              if(GlobalMenuCache.navailableid.contains(itemId)){
                                                                GlobalMenuCache.navailableid.remove(itemId);
                                                              }
                                                              GlobalMenuCache.availableid.add(itemId);
                                                            } else {
                                                              GlobalMenuCache.items[itemId]?['available'] = false;
                                                              GlobalMenuCache.availableid.remove(itemId);
                                                              GlobalMenuCache.navailableid.add(itemId);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          GlobalMenuCache.items[itemId]?['available'] ? AppLocalizations.of(context)!.on_menu : AppLocalizations.of(context)!.off_menu,
                                                          style: TextStyle(fontSize: 15),
                                                          textAlign: TextAlign.start,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                        ])
                                      ]),
                                  ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ),
              contentPadding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 2),
              actionsPadding: EdgeInsets.only(left: 10, bottom: 10, right: 10), 
              actionsOverflowButtonSpacing: 0,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.red),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)), 
                  fixedSize: WidgetStatePropertyAll(Size(105, 60)),
                  overlayColor: WidgetStatePropertyAll(Color.fromARGB(255, 37, 113, 255)),
                ),
                onPressed: () {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                  ]);
                  Navigator.pop(context);
                  },
                child: Text(AppLocalizations.of(context)!.cancel)
              ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0)),
                    fixedSize: WidgetStateProperty.all(Size(105, 60)),
                    overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                  ),
                  onPressed: (errorMap.isNotEmpty)
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: Name(s) Already Exists, Change that to proceed",
                                  style: TextStyle(fontSize: 15.00, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400)),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      : () {
                        if(errorMap.isEmpty){
                          setState(() {
                            for (int i in changes.keys) {
                              if (changes[i]?['name'] != GlobalMenuCache.items[i]?['name'] || changes[i]?['price'] != GlobalMenuCache.items[i]?['price'] || changes[i]?['stocks'] != GlobalMenuCache.items[i]?['stocks']) {
                                GlobalMenuCache.items[i] = {
                                  'name': changes[i]?['name'],
                                  'price': changes[i]?['price'],
                                  'is_veg': GlobalMenuCache.items[i]?['is_veg'],
                                  'available': GlobalMenuCache.items[i]?['available'],
                                  'stocks': changes[i]?['stocks']
                                };
                                updateitem(i, GlobalMenuCache.items[i]);
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "Item Changes are Successful",
                                style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w700:FontWeight.w400),
                              ),
                              backgroundColor: Colors.cyanAccent,
                            ));
                            errorMap.clear();
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                            ]);
                            Navigator.pop(context);
                          });}
                        },
                  child: Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Icon(Icons.check, color: Colors.greenAccent), 
                        Text(AppLocalizations.of(context)!.submit, style: TextStyle(fontWeight: FontWeight.w600))]),
                    ],
                  ),
                ),
                ],)
              ],
            );
          },
        );
  }

void apipostcall(String name, int price, bool isveg, int stocks, bool available) async {
  try {
  final response = await http.post(
    Uri.parse('https://proj-xs.fly.dev/menu/create'),
    headers: {
      "accept": "application/json",
      "Content-Type": "application/json"
    },
    body: jsonEncode({
      "canteen_id": widget.canteenId,
      "pic_link": (pngn!=null)?true:false,
      "name": name,
      "price": price,
      "is_veg": isveg,       
      "is_available": available,
      "stock": stocks,
      "pic_bytes": pngn
    }), 
  );
  
  if (response.statusCode == 200) { 
    final Map<String, dynamic> decodedJson = jsonDecode(response.body);
    setState(() {
      GlobalMenuCache.items[decodedJson["item_id"]] = {
      "name": name,
      "price": price,
      "is_veg": isveg,
      "available": available,
      "stocks": stocks,
      "pic": decodedJson["pic_link"]
      };
      ImageUploadState().imageupload(canteenId, pngn);
    });
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Created Succesfully"),backgroundColor: Colors.cyanAccent));
    }
  } else {
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response.body}"), backgroundColor: Colors.redAccent));
    }
  }
} on Exception catch (e) {
  if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e"), backgroundColor: Colors.redAccent));
  }
}
}

dynamic updateitem(int itemId, Map<String, dynamic>? item) async{
  try{
  final response = await http.put(Uri.parse("https://proj-xs.fly.dev/menu/update"),
  headers: {'accept' : 'application/json','Content-Type' : 'application/json'},
  body: jsonEncode({
    "item_id": itemId,
    "update": {
    "description": "string",
    "is_available": item?["available"],
    "is_veg": item?['is_veg'],
    "name": item?["name"],
    "pic_link": true,
    "price": item?["price"],
    "stock": item?["stocks"]
  }}
  ));
  if (response.statusCode == 200){
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Update Successful"), backgroundColor: Colors.cyanAccent));
    }
  }
  else{
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Updating Items : ${response.statusCode}"), backgroundColor: Colors.redAccent));
  }
  }
} on Exception catch (e){
  if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e"), backgroundColor: Colors.redAccent));
  }
}
}

void deleteitem(int itemId) async{
  try{
  final response = await http.delete(Uri.parse("https://proj-xs.fly.dev/menu/delete/$itemId"),
  headers: {'accept' : 'application/json'});
  if(response.statusCode == 200){
    setState(() {
       if (GlobalMenuCache.items[itemId]?['available']){
          GlobalMenuCache.availableid.remove(itemId);
        }
        else{
          GlobalMenuCache.navailableid.remove(itemId);
        }
        GlobalMenuCache.items.remove(itemId);
    });
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item Deleted Successfully"), backgroundColor: Colors.cyanAccent));
    }
  }
  else{
    if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Deleting Item : ${response.statusCode}"), backgroundColor: Colors.redAccent));
    }
  } }on Exception catch (e){
    if(mounted){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Not Connected, $e"), backgroundColor: Colors.redAccent,));
  }
  }
}

// Future<void> addNewItems() async {
//   for (var entry in item.entries) {
//     await apipostcall(
//       entry.key,
//       entry.value['name'],
//       entry.value['price'],
//       entry.value['is_veg'],
//       entry.value['stocks'],
//       entry.value['available'],
//     );
//   }
// }

    String value = "Name";
  @override
  Widget build(BuildContext context) {
    // setState(() => {});
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
          heroTag: "refresh",
          elevation: 10.00,
          backgroundColor: Colors.cyan,
            onPressed: (){
              fetchAndCacheAndNotify(widget.canteenId);
            },
            icon: Icon(Icons.refresh,color: Colors.black),
            label: Text(AppLocalizations.of(context)!.refresh, style: TextStyle(color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w800:FontWeight.w600)),
            ),
          SizedBox(height: 10.00),
          FloatingActionButton.extended(
            heroTag: "mass_edit",
            elevation: 10.00,
            backgroundColor: Colors.cyan,
            onPressed: () {
              massEdit();
            },
            icon: Icon(Icons.edit,color: Colors.black),
            label: Text(AppLocalizations.of(context)!.bulk_edit, style: TextStyle(color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w800:FontWeight.w600))
          ),
          SizedBox(height: 10.00),
          FloatingActionButton.extended(
          heroTag: "add",
          elevation: 10.00,
          backgroundColor: Colors.cyan,
          onPressed: (){
              addNewItem();
          },
          icon: Icon(Icons.add,color: Colors.black),
          label: Text(AppLocalizations.of(context)!.add_item, style: TextStyle(color: Colors.black, fontWeight:(widget.isTamil)?FontWeight.w800:FontWeight.w600))
          ),
          ]),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            SizedBox(height: 20.00),
            Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.on_menu_head,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(AppLocalizations.of(context)!.sort_by, style: TextStyle(fontSize: 22.00, fontWeight:(widget.isTamil)?FontWeight.w900:FontWeight.w600)),
                SizedBox(width: 5),
                DropdownButton(
                  focusColor: Colors.transparent,
                  value: value,
                  items: [DropdownMenuItem(value: "Name", child: Text("Name")), DropdownMenuItem(value: "Price", child: Text("Price")), DropdownMenuItem(value : "Low Stock", child: Text("Low Stock"))],
                  onChanged: (chvalue) {
                    setState(() {
                      if(chvalue == "Name"){
                        sortmenu = 1;
                        value = "Name";
                      }
                      else if (chvalue == "Price"){
                        sortmenu = 2;
                        value = "Price";
                      }
                      else{
                        sortmenu = 3;
                        value = "Low Stock";
                      }
                    });
                      applySorting(GlobalMenuCache.items, sortmenu, GlobalMenuCache.availableid, GlobalMenuCache.navailableid);
                  },
                ),
                SizedBox(width: 10)
              ],
            ),
          SizedBox(height: 10),
        if (GlobalMenuCache.availableid.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.no_item_menu,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else 
          buildGridSection(GlobalMenuCache.availableid, const Color.fromARGB(58, 0, 255, 64), Colors.white),
        SizedBox(height: 45.00),
        Align(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.off_menu_head,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(AppLocalizations.of(context)!.sort_by, style: TextStyle(fontSize: 22.00, fontWeight:(widget.isTamil)?FontWeight.w900:FontWeight.w600)),
                SizedBox(width: 5),
                DropdownButton(
                  focusColor: Colors.transparent,
                  value: value,
                  items: [DropdownMenuItem(value: "Name", child: Text("Name")), DropdownMenuItem(value: "Price", child: Text("Price")), DropdownMenuItem(value : "Low Stock", child: Text("Low Stock"))],
                  onChanged: (chvalue) {
                    setState(() {
                      if(chvalue == "Name"){
                        sortmenu = 1;
                        value = "Name";
                      }
                      else if (chvalue == "Price"){
                        sortmenu = 2;
                        value = "Price";
                      }
                      else{
                        sortmenu = 3;
                        value = "Low Stock";
                      }
                    });
                      applySorting(GlobalMenuCache.items, sortmenu, GlobalMenuCache.availableid, GlobalMenuCache.navailableid);
                  },
                ),
                SizedBox(width: 10)
              ],
            ),
          SizedBox(height: 10.00),
        if (GlobalMenuCache.navailableid.isEmpty) 
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.no_item,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else 
          buildGridSection(GlobalMenuCache.navailableid, const Color.fromARGB(55, 253, 76, 0), Colors.black),
          SizedBox(height: 70),
      ])
    ));
  }

Widget showImage(int itemId) {
  return FutureBuilder<Widget>(
    future: ImageUploadState().buildImageDisplay(itemId.toString(), 160, 160, cache, imageexpired),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError || !snapshot.hasData) {
        return Text("${snapshot.error}");
      } else {
        return snapshot.data!;
      }
    },
  );
}

int axisCount = 6;
Widget buildGridSection(Set<int> menuSet, Color bgColor, Color textColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 6;
          if (widget.portrait){
            crossAxisCount = 2;
            axisCount = 2;
          }
          else if (constraints.maxWidth < 900) {
            crossAxisCount = 3;
            axisCount = 3;
          } else if (constraints.maxWidth < 1200) {
            crossAxisCount = 4;
            axisCount = 4;
          }
            else if (constraints.maxWidth < 1460) {
              crossAxisCount = 5;
              axisCount = 5;            
          }
          return GridView.builder(
            shrinkWrap: true,
            clipBehavior: Clip.none,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: (isAndroid)?0.95:1,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuSet.length,
            itemBuilder: (BuildContext context, int index) {
              int itemId = menuSet.elementAt(index);
              return GridTile(
                footer: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset((GlobalMenuCache.items[itemId]?['is_veg'])?"assets/images/veg.png":"assets/images/nonveg.png", width: 25, height: 25),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    InkWell(
                        onTap: () => delAddItem(itemId, GlobalMenuCache.items[itemId]?['name'], true, GlobalMenuCache.items[itemId]?['available']),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 285,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(height:5),
                              showImage(itemId),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        GlobalMenuCache.items[itemId]?['name'] ?? "Unknown Item",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: (widget.isTamil)?FontWeight.w600:FontWeight.bold,
                                          color: (GlobalMenuCache.items[itemId]?['stocks'] == -1 || GlobalMenuCache.items[itemId]?['stocks'] >= 300)?Colors.white:(GlobalMenuCache.items[itemId]?['stocks'] > 0)?Colors.limeAccent:Colors.red,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "₹${GlobalMenuCache.items[itemId]?['price'] ?? 'N/A'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: (widget.isTamil)?FontWeight.w600:FontWeight.bold, color: (GlobalMenuCache.items[itemId]?['stocks'] == -1 || GlobalMenuCache.items[itemId]?['stocks'] >= 300)?Colors.white:(GlobalMenuCache.items[itemId]?['stocks'] > 0)?Colors.limeAccent:Colors.red, fontSize: 17),
                                ),
                              Text(
                                  "${AppLocalizations.of(context)!.stock}: ${GlobalMenuCache.items[itemId]?['stocks'] == -1 ? 'Unlimited' : '${GlobalMenuCache.items[itemId]?['stocks']}'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: (widget.isTamil)?FontWeight.w600:FontWeight.bold, color: (GlobalMenuCache.items[itemId]?['stocks'] == -1 || GlobalMenuCache.items[itemId]?['stocks'] >= 300)?Colors.white:(GlobalMenuCache.items[itemId]?['stocks'] > 0)?Colors.limeAccent:Colors.red, fontSize: 17),
                                ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      left: 5,
                      top: 5,
                      child: IconButton(
                        hoverColor: Colors.blue,
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          modifyItem(itemId, GlobalMenuCache.items[itemId]?['name'], GlobalMenuCache.items[itemId]?['price'], GlobalMenuCache.items[itemId]?['is_veg'], GlobalMenuCache.items[itemId]?['available']);
                        },
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 5,
                      child: IconButton(
                        hoverColor: Colors.red,
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          delAddItem(itemId, GlobalMenuCache.items[itemId]?['name'], false, false);
                        },
                      ),
                    ),                  
                  ],
                ),
              );
            },
          );
        },
      ),
    ],
  );
}}