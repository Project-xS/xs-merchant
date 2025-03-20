import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  final Function(bool, int) updateLoginState;
  const Login({super.key, required this.updateLoginState});

  @override
  State<Login> createState() => _LoginState();
}

bool isLoggedin = false;
int canteenId = 0;
bool isAndroid = Platform.isAndroid;
// bool isAndroid = true;

class _LoginState extends State<Login> {
  bool isPasswordVisible = false;
  final textFieldFocusNode = FocusNode();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  final storage = FlutterSecureStorage(aOptions: (isAndroid)
      ? AndroidOptions(encryptedSharedPreferences: true)
      : AndroidOptions.defaultOptions);
  late Future<List<String>> savedCredentials;

  Future<List<String>> details() async {
  String uName = await storage.read(key: "Username") ?? "";
  String pass = await storage.read(key: "Password") ?? "";
  String canteen = await storage.read(key: "CanteenId") ?? "0";
  return [uName, pass, canteen];
}

  @override
  void initState() {
    super.initState();
    savedCredentials = details().then((data) {
      if (data.isNotEmpty) {
        controller1.text = data[0];
        controller2.text = data[1];
      }
      return data;
    });
  }

  void login(String username, String password) async {
    List<String> data = await details();
    if (data[0] == username && data[1] == password) {
      setState(() {
        canteenId = int.parse(data[2]);
        isLoggedin = true;
      });
    } else {
      await storage.write(key: "Username", value: username);
      await storage.write(key: "Password", value: password);
      await storage.write(key: "CanteenId", value: "1");
      setState(() {
        canteenId = 1;
        isLoggedin = true;
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
                        child: FutureBuilder<List<String>>(
                          future: savedCredentials,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            return Column(
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
                                      backgroundColor: WidgetStateProperty.all(Colors.black),
                                      foregroundColor: WidgetStateProperty.all(Colors.white),
                                      padding: WidgetStateProperty.all(EdgeInsets.all(30.0)),
                                      overlayColor: WidgetStateProperty.all(const Color.fromARGB(255, 37, 113, 255)),
                                    ),
                                    onPressed: () async {
                                      if (controller1.text.trim().isNotEmpty && controller2.text.trim().isNotEmpty) {
                                        final uName = snapshot.data![0];
                                        final pass = snapshot.data![1];
                                        if (uName == controller1.text && pass == controller2.text) {
                                          setState(() {
                                            canteenId = int.parse(snapshot.data![2]);
                                            isLoggedin = true;
                                            widget.updateLoginState(true, canteenId);
                                          });
                                        } else {
                                          await storage.write(key: "Username", value: controller1.text);
                                          await storage.write(key: "Password", value: controller2.text);
                                          await storage.write(key: "CanteenId", value: "1");
                                          setState(() {
                                            canteenId = 1;
                                            isLoggedin = true;
                                          });
                                        }
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.check, color: Colors.greenAccent),
                                        SizedBox(width: 5.0),
                                        Text("Login",
                                            style: TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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