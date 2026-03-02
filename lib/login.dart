import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/auth/auth_service.dart';

class Login extends StatefulWidget {
  final Function(bool, int, String) updateLoginState;
  const Login({super.key, required this.updateLoginState});

  @override
  State<Login> createState() => LoginState();
}

final bool _isAndroid = Platform.isAndroid || Platform.isIOS;

class LoginState extends State<Login> with TickerProviderStateMixin {
  bool isLoggedin = false;
  bool isLoading = false;
  int canteenId = 0;
  int? error;
  bool isPasswordVisible = false;
  final textFieldFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _snowfallController;
  // final List<Snowflake> _snowflakes = List.generate(85, (index) => Snowflake());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _snowfallController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..repeat();

    _checkSavedCredentials();
  }

  Future<void> _checkSavedCredentials() async {
    final creds = await AuthService.getSavedCredentials();
    if (creds['username'] != null && creds['password'] != null) {
      controller1.text = creds['username']!;
      controller2.text = creds['password']!;
      loginUser(creds['username']!, creds['password']!);
    }
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
    setState(() {
      isLoading = true;
    });
    try {
      final response = await ApiClient.post(
        ApiConstants.login,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final token = responseData['token'];
        if (token is! String || token.isEmpty) {
          setState(() {
            error = 0;
            isLoggedin = false;
            isLoading = false;
          });
          return;
        }

        final data = responseData['data'];
        final int? responseCanteenId = (data is Map<String, dynamic>)
            ? int.tryParse('${data['canteen_id']}')
            : null;
        final String? responseCanteenName = (data is Map<String, dynamic>)
            ? data['canteen_name']?.toString()
            : null;

        await AuthService.setToken(
          token: token,
          canteenId: responseCanteenId,
          canteenName: responseCanteenName,
        );
        await AuthService.saveCredentials(username, password);

        final int effectiveCanteenId =
            AuthService.canteenId ?? responseCanteenId ?? 0;
        final String effectiveName =
            (AuthService.canteenName ?? responseCanteenName ?? username)
                .toString();

        setState(() {
          isLoggedin = true;
          isLoading = false;
          widget.updateLoginState(
            isLoggedin,
            effectiveCanteenId,
            effectiveName,
          );
        });
        if (kDebugMode) debugPrint('Login successful.');
      } else if (response.statusCode == 401) {
        setState(() {
          isLoggedin = false;
          isLoading = false;
          error = 401;
        });
      } else {
        if (kDebugMode) {
          debugPrint('Login failed: ${response.statusCode}');
          debugPrint('Response body: ${response.body}');
        }
        setState(() {
          error = 0;
          isLoggedin = false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error during login: $e');
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
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _snowfallController,
              builder: (context, child) {
                return CustomPaint(
                  painter: NorthernLightsPainter(_snowfallController.value),
                );
              },
            ),
          ),
          // CustomPaint(painter: MountainPainter(), size: Size.infinite),
          // Positioned.fill(
          //   child: AnimatedBuilder(
          //     animation: _snowfallController,
          //     builder: (context, child) {
          //       return CustomPaint(
          //         painter: SnowfallPainter(_snowfallController.value, _snowflakes),
          //       );
          //     },
          //   ),
          // ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: _isAndroid ? null : 400,
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 150,
                            width: 150,
                            fit: BoxFit.fill,
                          ),
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
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: controller1,
                                    label: "Username",
                                    icon: Icons.person_outline,
                                    maxLength: 256,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? "Username is required"
                                        : null,
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
                                    maxLength: 256,
                                    obscureText: !isPasswordVisible,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? "Password is required"
                                        : null,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isPasswordVisible =
                                              !isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildLoginButton(),
                                ],
                              ),
                            ),
                          ],
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
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
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
                if (_formKey.currentState!.validate()) {
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
        colors: [Color(0xFF334155), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5));

    final mountainHighlightPaint = Paint()
      ..color = const Color.fromARGB(50, 255, 255, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final moonCenter = Offset(size.width * 0.15, size.height * 0.15);
    const double moonRadius = 60;

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color.fromARGB(80, 255, 255, 255),
              const Color.fromARGB(0, 255, 255, 255),
            ],
          ).createShader(
            Rect.fromCircle(center: moonCenter, radius: moonRadius * 2),
          );
    canvas.drawCircle(moonCenter, moonRadius * 2, glowPaint);

    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color.fromARGB(255, 237, 237, 237),
          const Color.fromARGB(255, 176, 176, 176),
        ],
        stops: [0.65, 1.0],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    final craterPaint = Paint()
      ..color = const Color.fromARGB(200, 120, 120, 120);

    final List<Map<String, dynamic>> craters = [
      {"offset": Offset(-20, -10), "radius": 10.0},
      {"offset": Offset(50, -5), "radius": 6.0},
      {"offset": Offset(-1, -50), "radius": 5.0},
      {"offset": Offset(18, 18), "radius": 7.0},
      {"offset": Offset(-25, 20), "radius": 8.0},
      {"offset": Offset(5, 45), "radius": 4.0},
    ];

    for (final crater in craters) {
      canvas.drawCircle(
        moonCenter + crater["offset"],
        crater["radius"] as double,
        craterPaint,
      );
    }

    // Mountains
    Path mountainPath = Path();
    mountainPath.moveTo(0, size.height * 0.75);
    mountainPath.cubicTo(
      size.width * 0.1,
      size.height * 0.65,
      size.width * 0.2,
      size.height * 0.7,
      size.width * 0.3,
      size.height * 0.6,
    );
    mountainPath.cubicTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.55,
      size.height * 0.55,
      size.width * 0.65,
      size.height * 0.7,
    );
    mountainPath.cubicTo(
      size.width * 0.75,
      size.height * 0.85,
      size.width * 0.85,
      size.height * 0.8,
      size.width,
      size.height * 0.75,
    );
    mountainPath.lineTo(size.width, size.height);
    mountainPath.lineTo(0, size.height);
    mountainPath.close();
    canvas.drawPath(mountainPath, mountainPaint);
    canvas.drawPath(mountainPath, mountainHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SnowfallPainter extends CustomPainter {
  final double animationValue;
  final List<Snowflake> snowflakes;

  SnowfallPainter(this.animationValue, this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(150, 255, 255, 255);

    for (var snowflake in snowflakes) {
      final x = snowflake.getX(animationValue);
      final y = snowflake.getY(animationValue);
      
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        snowflake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SnowfallPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class Snowflake {
  late double initialX;
  late double initialY;
  late double size;
  late double speedMultiplier;
  late double phase;

  Snowflake() {
    initialX = Random().nextDouble();
    initialY = Random().nextDouble();
    size = Random().nextDouble() * 2 + 1;
    speedMultiplier = Random().nextDouble() * 0.5 + 0.5;
    phase = Random().nextDouble() * pi * 2;
  }

  double getY(double animationValue) {
    // The snowflake will fall across the screen 4 times during the 1-minute animation cycle
    return (initialY + animationValue * 3 * speedMultiplier) % 1.0;
  }

  double getX(double animationValue) {
    // Slow sway movement
    return (initialX + sin(phase + animationValue * 10 * pi) * 0.02) % 1.0;
  }
}

class NorthernLightsPainter extends CustomPainter {
  final double animationValue;
  NorthernLightsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect skyRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.7);
    
    for (int i = 0; i < 3; i++) {
      final double phase = (animationValue + (i * 0.33)) % 1.0;
      final double opacity = sin(phase * pi) * 0.15;
      
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(0.0),
            Colors.greenAccent.withOpacity(opacity),
            Colors.blueAccent.withOpacity(opacity * 0.5),
            Colors.blueAccent.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 0.7, 1.0],
        ).createShader(skyRect);

      final path = Path();
      final double yOffset = size.height * (0.2 + (i * 0.08));
      
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 15) {
        final double wave = sin((x / size.width * 2 * pi) + (animationValue * 7 * pi) + (i * pi / 2)) * 40;
        path.lineTo(x, yOffset + wave);
      }
      path.lineTo(size.width, size.height * 0.7);
      path.lineTo(0, size.height * 0.7);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant NorthernLightsPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
