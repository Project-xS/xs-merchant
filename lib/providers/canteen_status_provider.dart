import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/api/api_constants.dart';
import 'package:merchant/auth/auth_service.dart';
import 'package:merchant/models/canteen_details.dart';

class CanteenStatusProvider extends ChangeNotifier {
  CanteenDetails? _canteen;
  bool _isLoading = false;
  String? _error;
  Timer? _pollTimer;

  CanteenDetails? get canteen => _canteen;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStatus => _canteen != null;
  bool get isOpen => _canteen?.isOpen ?? false;
  bool get isAlwaysOpen => _canteen?.isAlwaysOpen ?? false;

  Future<String?> refresh({bool silent = false}) async {
    if (!silent && _isLoading) return _error;

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    _error = null;
    try {
      final canteenId = AuthService.canteenId;
      if (canteenId == null || canteenId == 0) {
        _canteen = null;
        _error = 'Canteen ID unavailable. Please log in again.';
        return _error;
      }

      final response = await ApiClient.get(ApiConstants.canteenList);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _error = ApiClient.tryExtractErrorMessage(response) ??
            'Failed to fetch canteen status (${response.statusCode}).';
        return _error;
      }

      final decoded = jsonDecode(response.body);
      final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
      if (data is! List) {
        _error = 'Unexpected canteen list response.';
        _canteen = null;
        return _error;
      }

      CanteenDetails? matched;
      for (final entry in data) {
        if (entry is Map<String, dynamic>) {
          final details = CanteenDetails.fromJson(entry);
          if (details.canteenId == canteenId) {
            matched = details;
            break;
          }
        }
      }

      if (matched == null) {
        _error = 'Canteen not found in status response.';
        _canteen = null;
        return _error;
      }

      _canteen = matched;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to refresh canteen status: $e');
      }
      _error = 'Failed to fetch canteen status.';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }

    return _error;
  }

  Future<String?> openCanteen() async {
    return _toggleOpenState(true);
  }

  Future<String?> closeCanteen() async {
    return _toggleOpenState(false);
  }

  Future<String?> _toggleOpenState(bool open) async {
    if (_isLoading) return _error;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.post(
        open ? ApiConstants.canteenOpen : ApiConstants.canteenClose,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _error = ApiClient.tryExtractErrorMessage(response) ??
            'Failed to ${open ? 'open' : 'close'} canteen (${response.statusCode}).';
        return _error;
      }

      if (_canteen != null) {
        _canteen = _canteen!.copyWith(isOpen: open);
      }
      await refresh(silent: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to ${open ? 'open' : 'close'} canteen: $e');
      }
      _error = 'Failed to ${open ? 'open' : 'close'} canteen.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _error;
  }

  void startPolling({Duration interval = const Duration(seconds: 75)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) {
      refresh(silent: true);
    });
  }

  void stopPolling({bool clearState = true}) {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (clearState) {
      _canteen = null;
      _error = null;
      _isLoading = false;
    }
    notifyListeners();
  }
}
