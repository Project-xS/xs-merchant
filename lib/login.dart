import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/main.dart';

class Login extends StatefulWidget {
  final Function(bool, int, String) updateLoginState;
  const Login({super.key, required this.updateLoginState});

  @override
  State<Login> createState() => LoginState();
}

bool isLoggedin = false, isLoading = false;
int canteenId = 0;
int? error;
String uName = "", pass = "", canteen = "";
bool isAndroid = Platform.isAndroid;

class LoginState extends State<Login> with TickerProviderStateMixin {
  bool isPasswordVisible = false;
  final textFieldFocusNode = FocusNode();
  TextEditingController controller1 = TextEditingController(text: uName);
  TextEditingController controller2 = TextEditingController(text: pass);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _snowfallController;

  Future<List<String>> details() async {
    uName = (await storage.read(key: "Username") ?? "").toLowerCase();
    pass = await storage.read(key: "Password") ?? "";
    canteen = await storage.read(key: "CanteenId") ?? "$canteenId";
    return [uName, pass, canteen];
  }

  @override
  void initState() {
    details();
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _snowfallController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    _animationController.dispose();
    _snowfallController.dispose();
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
        final Map<String, dynamic> responseData = json.decode(response.body);
        final int canteenId =
            int.parse(responseData['data']['canteen_id'].toString());
        final String name = responseData['data']['canteen_name'];

        await storage.write(key: "Username", value: name);
        await storage.write(key: "Password", value: password);
        await storage.write(key: "CanteenId", value: canteenId.toString());
        setState(() {
          isLoggedin = true;
          isLoading = false;
          widget.updateLoginState(isLoggedin, canteenId, name);
        });
        debugPrint('Login successful. Canteen ID: $canteenId');
      } else if (response.statusCode == 401) {
        setState(() {
          isLoggedin = false;
          isLoading = false;
          error = 401;
        });
      } else {
        debugPrint('Login failed: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        setState(() {
          error = 0;
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
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1117), Color(0xFF161B22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(
            painter: MountainPainter(),
            size: Size.infinite,
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _snowfallController,
              builder: (context, child) {
                return CustomPaint(
                  painter: SnowfallPainter(_snowfallController.value),
                );
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: isAndroid ? null : 400,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/logo.png', height: 80),
                            const SizedBox(height: 16),
                            Text(
                              "Welcome Back",
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Login to manage your canteen",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildTextField(
                              controller: controller1,
                              label: "Username",
                              icon: Icons.person_outline,
                              errorText: error == 401
                                  ? "ID or Password Wrong"
                                  : error == 0
                                      ? "Check Internet Connection"
                                      : null,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: controller2,
                              label: "Password",
                              icon: Icons.lock_outline,
                              obscureText: !isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading
            ? null
            : () {
                if (controller1.text.trim().isNotEmpty &&
                    controller2.text.trim().isNotEmpty) {
                  loginUser(controller1.text, controller2.text);
                }
              },
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mountainPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final moonPaint = Paint()..color = const Color.fromARGB(255, 227, 224, 224).withOpacity(0.9);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 60, moonPaint);
    Path mountainPath = Path();
    mountainPath.moveTo(0, size.height * 0.75);
    mountainPath.cubicTo(size.width * 0.1, size.height * 0.65, size.width * 0.2, size.height * 0.7, size.width * 0.3, size.height * 0.6);
    mountainPath.cubicTo(size.width * 0.4, size.height * 0.5, size.width * 0.55, size.height * 0.55, size.width * 0.65, size.height * 0.7);
    mountainPath.cubicTo(size.width * 0.75, size.height * 0.85, size.width * 0.85, size.height * 0.8, size.width, size.height * 0.75);
    mountainPath.lineTo(size.width, size.height);
    mountainPath.lineTo(0, size.height);
    mountainPath.close();
    canvas.drawPath(mountainPath, mountainPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SnowfallPainter extends CustomPainter {
  final double animationValue;
  final _snowflakes = <Snowflake>[];

  SnowfallPainter(this.animationValue) {
    if (_snowflakes.isEmpty) {
      for (int i = 0; i < 100; i++) {
        _snowflakes.add(Snowflake());
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);

    for (var snowflake in _snowflakes) {
      snowflake.update(animationValue, size);
      canvas.drawCircle(
          Offset(snowflake.position.dx * size.width,
              snowflake.position.dy * size.height),
          snowflake.size,
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Snowflake {
  late Offset position;
  late double size;
  late double speed;
  late double phase;

  Snowflake() {
    _reset();
  }

  void _reset() {
    position = Offset(Random().nextDouble(), Random().nextDouble());
    size = Random().nextDouble() * 2 + 1;
    speed = 0.000000000001;
    phase = Random().nextDouble() * pi * 2;
  }

  void update(double animationValue, Size bounds) {
    double x = position.dx + sin(animationValue * 2 * pi + phase) * 0.002;
    double y = (position.dy + speed) % 1.0;

    if (y < position.dy) {
      position = Offset(Random().nextDouble(), 0);
    } else {
      position = Offset(x, y);
    }
  }
}