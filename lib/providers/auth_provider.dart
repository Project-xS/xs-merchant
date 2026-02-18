
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merchant/api_service.dart';
import 'package:merchant/models/login_response.dart';
import 'package:merchant/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  int? _canteenId;
  String? _canteenName;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  int? get canteenId => _canteenId;
  String? get canteenName => _canteenName;
  String? get errorMessage => _errorMessage;

  AuthProvider(this._apiService) {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    
    // Check for existing session in AuthService first
    await AuthService.loadFromStorage();
    
    final storedCanteenId = await _storage.read(key: "CanteenId");
    final storedCanteenName = await _storage.read(key: "Username");

    if (storedCanteenId != null && storedCanteenName != null) {
      _isLoggedIn = true;
      _canteenId = int.parse(storedCanteenId);
      _canteenName = storedCanteenName;
    } else if (AuthService.isLoggedIn) {
      _isLoggedIn = true;
      _canteenId = AuthService.canteenId;
      _canteenName = AuthService.canteenName;
    } else {
      _isLoggedIn = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseData = await _apiService.post(
        'canteen/login',
        body: {'username': username, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(responseData['data']);

      await _storage.write(key: "Username", value: loginResponse.canteenName);
      await _storage.write(key: "Password", value: password);
      await _storage.write(key: "CanteenId", value: loginResponse.canteenId.toString());
      
      // Also save for automatic login
      await AuthService.saveCredentials(username, password);

      _isLoggedIn = true;
      _canteenId = loginResponse.canteenId;
      _canteenName = loginResponse.canteenName;
      _errorMessage = null;
    } catch (e) {
      _isLoggedIn = false;
      _errorMessage = e.toString().contains('401') ? "ID or Password Wrong" : "Check Internet Connection";
      debugPrint('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "Username");
    await _storage.delete(key: "Password");
    await _storage.delete(key: "CanteenId");
    await AuthService.logout();
    _isLoggedIn = false;
    _canteenId = null;
    _canteenName = null;
    notifyListeners();
  }
}
