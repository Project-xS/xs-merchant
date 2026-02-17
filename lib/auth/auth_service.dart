import 'package:flutter/foundation.dart';
import 'package:merchant/auth/jwt.dart';
import 'package:merchant/common/secure_storage.dart';

class AuthSession {
  AuthSession({
    required this.token,
    required this.expiresAtMs,
    this.canteenId,
    this.canteenName,
  });

  final String token;
  final int expiresAtMs;
  final int? canteenId;
  final String? canteenName;

  bool get isExpired => DateTime.now().millisecondsSinceEpoch >= expiresAtMs;
}

class AuthService {
  static const _tokenKey = 'AdminJwt';
  static const _expiresAtMsKey = 'AdminJwtExpiresAtMs';
  static const _canteenIdKey = 'AdminCanteenId';
  static const _canteenNameKey = 'AdminCanteenName';

  static AuthSession? _session;

  static AuthSession? get session => _session;
  static String? get token => _session?.token;
  static int? get canteenId => _session?.canteenId;
  static String? get canteenName => _session?.canteenName;
  static bool get isLoggedIn => _session != null && !_session!.isExpired;

  static Future<AuthSession?> loadFromStorage() async {
    final token = await secureStorage.read(key: _tokenKey);
    final expiresAtMsRaw = await secureStorage.read(key: _expiresAtMsKey);
    final expiresAtMs = int.tryParse(expiresAtMsRaw ?? '');
    final canteenIdRaw = await secureStorage.read(key: _canteenIdKey);
    final canteenNameRaw = await secureStorage.read(key: _canteenNameKey);
    int? canteenIdHint = int.tryParse(canteenIdRaw ?? '');
    String? canteenNameHint =
        (canteenNameRaw != null && canteenNameRaw.isNotEmpty)
        ? canteenNameRaw
        : null;

    // Backwards-compat: older builds stored these as "Username" / "CanteenId".
    if (canteenIdHint == null) {
      canteenIdHint = int.tryParse(
        await secureStorage.read(key: 'CanteenId') ?? '',
      );
    }
    if (canteenNameHint == null) {
      final legacyName = await secureStorage.read(key: 'Username');
      if (legacyName != null && legacyName.trim().isNotEmpty) {
        canteenNameHint = legacyName.trim();
      }
    }
    if (token == null || token.isEmpty || expiresAtMs == null) {
      _session = null;
      return null;
    }

    final loaded = _buildSession(
      token: token,
      expiresAtMs: expiresAtMs,
      canteenIdHint: canteenIdHint,
      canteenNameHint: canteenNameHint,
    );
    if (loaded.isExpired) {
      await logout();
      return null;
    }

    _session = loaded;
    // Best-effort migrate display fields to new keys for future runs.
    if (_session?.canteenId != null) {
      await secureStorage.write(
        key: _canteenIdKey,
        value: '${_session!.canteenId}',
      );
    }
    if ((_session?.canteenName ?? '').isNotEmpty) {
      await secureStorage.write(
        key: _canteenNameKey,
        value: _session!.canteenName,
      );
    }
    if (kDebugMode) {
      debugPrint(
        'Loaded admin session: canteenId=${_session?.canteenId}, canteenName=${_session?.canteenName}, expiresAtMs=${_session?.expiresAtMs}',
      );
    }
    return _session;
  }

  static Future<void> setToken({
    required String token,
    int? canteenId,
    String? canteenName,
  }) async {
    final expiresAtMs = DateTime.now()
        .add(const Duration(hours: 12))
        .millisecondsSinceEpoch;

    // Keep UI claims local; never rely on these for authorization.
    final session = _buildSession(
      token: token,
      expiresAtMs: expiresAtMs,
      canteenIdHint: canteenId,
      canteenNameHint: canteenName,
    );

    _session = session;
    await secureStorage.write(key: _tokenKey, value: token);
    await secureStorage.write(key: _expiresAtMsKey, value: '$expiresAtMs');
    if (_session?.canteenId != null) {
      await secureStorage.write(
        key: _canteenIdKey,
        value: '${_session!.canteenId}',
      );
    }
    if ((_session?.canteenName ?? '').isNotEmpty) {
      await secureStorage.write(
        key: _canteenNameKey,
        value: _session!.canteenName,
      );
    }

    // Clear legacy credentials if present.
    await secureStorage.delete(key: 'Password');
    await secureStorage.delete(key: 'Username');
    await secureStorage.delete(key: 'CanteenId');
  }

  static Future<void> logout() async {
    _session = null;
    await secureStorage.delete(key: _tokenKey);
    await secureStorage.delete(key: _expiresAtMsKey);
    await secureStorage.delete(key: _canteenIdKey);
    await secureStorage.delete(key: _canteenNameKey);
  }

  static AuthSession _buildSession({
    required String token,
    required int expiresAtMs,
    int? canteenIdHint,
    String? canteenNameHint,
  }) {
    int? canteenId = canteenIdHint;
    String? canteenName = canteenNameHint;

    try {
      final payload = Jwt.decodePayload(token);
      final payloadCanteenId = payload['canteen_id'];
      final payloadCanteenName = payload['canteen_name'];

      if (canteenId == null && payloadCanteenId is num) {
        canteenId = payloadCanteenId.toInt();
      }
      if (canteenName == null && payloadCanteenName is String) {
        canteenName = payloadCanteenName;
      }
    } catch (_) {
      // Ignore decoding failures; token is still usable for Authorization header.
    }

    return AuthSession(
      token: token,
      expiresAtMs: expiresAtMs,
      canteenId: canteenId,
      canteenName: canteenName,
    );
  }
}
