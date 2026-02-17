import 'dart:convert';

class Jwt {
  static Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final jsonMap = json.decode(decoded);
    if (jsonMap is! Map<String, dynamic>) {
      throw const FormatException('Invalid JWT payload');
    }
    return jsonMap;
  }
}
