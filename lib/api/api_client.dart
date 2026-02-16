import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:merchant/auth/auth_service.dart';

typedef ApiVoidCallback = void Function();

class ApiClient {
  static const String _defaultBaseUrl = 'https://proj-xs.fly.dev';

  static String get baseUrl {
    const envUrl = String.fromEnvironment('BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    final fileUrl = dotenv.env['BASE_URL'];
    if (fileUrl != null && fileUrl.isNotEmpty) return fileUrl;

    if (kDebugMode) {
      debugPrint(
        '[ApiClient] BASE_URL not set; falling back to $_defaultBaseUrl',
      );
    }
    return _defaultBaseUrl;
  }

  static ApiVoidCallback? onUnauthorized;
  static ApiVoidCallback? onForbidden;

  static bool _shouldAttachAuthHeader(String path) {
    if (path == '/' || path == '/health' || path == '/canteen/login') {
      return false;
    }
    return true;
  }

  static Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) {
    return _send('GET', path, headers: headers);
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('POST', path, headers: headers, body: body);
  }

  static Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('PUT', path, headers: headers, body: body);
  }

  static Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send('DELETE', path, headers: headers, body: body);
  }

  static Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final mergedHeaders = <String, String>{
      // Default JSON content-type for mutating requests
      if (method != 'GET' && body != null) 'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    final token = AuthService.token;
    if (_shouldAttachAuthHeader(path) && token != null && token.isNotEmpty) {
      mergedHeaders['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      debugPrint('[ApiClient] $method $path');
    }

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: mergedHeaders);
        break;
      case 'POST':
        response = await http.post(uri, headers: mergedHeaders, body: body);
        break;
      case 'PUT':
        response = await http.put(uri, headers: mergedHeaders, body: body);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: mergedHeaders, body: body);
        break;
      default:
        throw ArgumentError('Unsupported method: $method');
    }

    if (kDebugMode) {
      debugPrint('[ApiClient] $method $path → ${response.statusCode}');
    }

    if (response.statusCode == 401) {
      await AuthService.logout();
      onUnauthorized?.call();
    } else if (response.statusCode == 403) {
      onForbidden?.call();
    }

    return response;
  }

  static String? tryExtractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is String && err.isNotEmpty) return err;
      }
    } catch (_) {}
    return null;
  }
}
