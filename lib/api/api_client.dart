import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:merchant/auth/auth_service.dart';

typedef ApiVoidCallback = void Function();

class ApiClient {
  static const String baseUrl = 'https://proj-xs.fly.dev';

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
      if (headers != null) ...headers,
    };

    final token = AuthService.token;
    if (_shouldAttachAuthHeader(path) && token != null && token.isNotEmpty) {
      mergedHeaders['Authorization'] = 'Bearer $token';
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

