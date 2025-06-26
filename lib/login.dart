import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/main.dart';

class Login extends StatefulWidget {
  final Function(bool, int) updateLoginState;
  const Login({super.key, required this.updateLoginState});

  @override
  State<Login> createState() => LoginState();
}

bool isLoggedin = false, isLoading = false;
int canteenId = 0;
bool isAndroid = Platform.isAndroid;

class LoginState extends State<Login> {
  bool isPasswordVisible = false;
  final textFieldFocusNode = FocusNode();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  final storage = FlutterSecureStorage(aOptions: (isAndroid)
      ? AndroidOptions(encryptedSharedPreferences: true)
      : AndroidOptions.defaultOptions);

  Future<List<String>> details() async {
  String uName = await storage.read(key: "Username") ?? "";
  String pass = await storage.read(key: "Password") ?? "";
  String canteen = await storage.read(key: "CanteenId") ?? "0";
  canteenId = int.parse(canteen);
  MyAppState().canteenId = canteenId;
  return [uName, pass, canteen];
}
  @override
  void initState(){
    details();
    super.initState();
  }

  @override
  void dispose(){
    controller1.dispose();
    controller2.dispose();
    super.dispose();
  }

  Future<void> loginUser(String username, String password) async {
    final String apiUrl = 'https://proj-xs.fly.dev/canteen/login';
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        // final Map<String, dynamic> responseData = json.decode(response.body);
        // final String canteenId = responseData['canteenId'].toString();
        // final String name = responseData['name'];

        await storage.write(key: "Username", value: username); //Just place username for now, replace with "name" we get from response
        await storage.write(key: "Password", value: password);
        await storage.write(key: "CanteenId", value: "1"); //canteenId
        setState(() {
          canteenId = int.parse("1");//canteenID
          isLoggedin = true;
          isLoading = false;
          widget.updateLoginState(isLoggedin, canteenId);
        });
        debugPrint('Login successful. Canteen ID: $canteenId');
      } else {
        debugPrint('Login failed: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        setState(() {
          isLoggedin = false;
           isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      setState(() {
        isLoggedin = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0x0000122D),
      ),
      home: Scaffold(
        body: Container(
          width: (isAndroid)?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width - 80,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/login.png"),
            fit: BoxFit.fill
          )),
          child: Center(
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(width: (isAndroid)?200:350, child: Text("Namma Canteen", 
                  style: TextStyle(color: const Color.fromARGB(255, 0, 255, 255), 
                  fontWeight: FontWeight.bold, 
                  fontSize: (isAndroid)?50:90, 
                  letterSpacing: -1, 
                  height: 1, 
                  shadows:[Shadow(color: Colors.black, blurRadius: 15
                  )],),
                 maxLines: 2, 
                 textAlign: 
                 TextAlign.left,)),
                  Flexible(
                    flex: 10,
                    child: Card(
                      elevation: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 5),
                            Text("Login: ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: controller1,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: "UserName",
                                  hintText: "Enter Your UserName",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: controller2,
                                obscureText: !isPasswordVisible,
                                focusNode: textFieldFocusNode,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off_sharp),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                  labelText: "Password",
                                  hintText: "Enter Your Password",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: 120,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all((isLoading)?Colors.grey:Colors.black),
                                  foregroundColor: WidgetStateProperty.all(Colors.white),
                                  padding: WidgetStateProperty.all(EdgeInsets.all(25.0)),
                                  overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                                ),
                                onPressed: (isLoading)? null: () async {
                                  if (controller1.text.trim().isNotEmpty && controller2.text.trim().isNotEmpty) {
                                      loginUser(controller1.text, controller2.text);
                                      setState(() {
                                        isLoading = true;
                                      },);
                                    } else {
                                      
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    (isLoading)?SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                ),
                              ):Icon(Icons.check, color: Colors.greenAccent),
                                    SizedBox(width: 7.0),
                                    Text("Login",
                                        style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}