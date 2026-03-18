import 'dart:async';

import 'package:launchdarkly_event_source_client/launchdarkly_event_source_client.dart';
import 'package:merchant/api/api_client.dart';
import 'package:merchant/auth/auth_service.dart';

enum SseConnectionState {
  idle,
  connecting,
  connected,
  reconnecting,
  failed,
  closed,
}

class SseNetworkHealth {
  const SseNetworkHealth({
    required this.isSlowNetwork,
    required this.metricMs,
    required this.eventIdMs,
    required this.deviceEpochMs,
    required this.breachStreak,
    required this.recoveryStreak,
  });

  final bool isSlowNetwork;
  final int metricMs;
  final int eventIdMs;
  final int deviceEpochMs;
  final int breachStreak;
  final int recoveryStreak;
}

class SseMessage {
  const SseMessage({
    required this.event,
    required this.data,
    required this.eventIdMs,
    required this.receivedAtEpochMs,
  });

  final String event;
  final String data;
  final int? eventIdMs;
  final int receivedAtEpochMs;
}

typedef SseMessageHandler = void Function(SseMessage message);
typedef SseConnectionStateHandler = void Function(SseConnectionState state);
typedef SseHealthHandler = void Function(SseNetworkHealth health);
typedef SseErrorHandler = void Function(Object error, StackTrace stackTrace);

class SseRealtimeClient {
  SseRealtimeClient({
    required this.path,
    required this.eventTypes,
    required this.onMessage,
    required this.onConnectionStateChanged,
    required this.onHealthUpdated,
    required this.onFatalError,
    this.slowThresholdMs = 5000,
    this.recoveryThresholdMs = 3000,
    this.slowStreakRequired = 3,
    this.recoveryStreakRequired = 3,
  }) : _healthTracker = _SseHealthTracker(
         slowThresholdMs: slowThresholdMs,
         recoveryThresholdMs: recoveryThresholdMs,
         slowStreakRequired: slowStreakRequired,
         recoveryStreakRequired: recoveryStreakRequired,
       );

  final String path;
  final Set<String> eventTypes;
  final SseMessageHandler onMessage;
  final SseConnectionStateHandler onConnectionStateChanged;
  final SseHealthHandler onHealthUpdated;
  final SseErrorHandler onFatalError;

  final int slowThresholdMs;
  final int recoveryThresholdMs;
  final int slowStreakRequired;
  final int recoveryStreakRequired;

  final _SseHealthTracker _healthTracker;

  SSEClient? _client;
  StreamSubscription<Event>? _subscription;
  bool _stopped = false;
  SseConnectionState _state = SseConnectionState.idle;

  SseConnectionState get state => _state;

  void start() {
    if (_subscription != null || _client != null) return;
    _stopped = false;
    _setState(SseConnectionState.connecting);

    final token = AuthService.token;
    if (token == null || token.isEmpty) {
      _setState(SseConnectionState.failed);
      onFatalError(
        StateError('Cannot connect SSE without an auth token.'),
        StackTrace.current,
      );
      return;
    }

    final uri = Uri.parse('${ApiClient.baseUrl}$path');
    final headers = {'Authorization': 'Bearer $token'};
    final logger = _StateTrackingLogger(onSignal: _handleLoggerSignal);

    _client = SSEClient(uri, eventTypes, headers: headers, logger: logger);

    _subscription = _client!.stream.listen(
      _handleEvent,
      onError: (error, stackTrace) {
        if (_stopped) return;
        _setState(SseConnectionState.failed);
        onFatalError(error, stackTrace ?? StackTrace.current);
      },
      onDone: () {
        if (_stopped) return;
        _setState(SseConnectionState.reconnecting);
      },
      cancelOnError: false,
    );
  }

  Future<void> stop() async {
    _stopped = true;
    await _subscription?.cancel();
    _subscription = null;
    if (_client != null) {
      await _client!.close();
      _client = null;
    }
    _setState(SseConnectionState.closed);
  }

  void _handleLoggerSignal(_SseLoggerSignal signal) {
    if (_stopped) return;
    switch (signal) {
      case _SseLoggerSignal.connecting:
        if (_state != SseConnectionState.connected) {
          _setState(SseConnectionState.connecting);
        }
        break;
      case _SseLoggerSignal.connected:
        _setState(SseConnectionState.connected);
        break;
      case _SseLoggerSignal.reconnecting:
        if (_state != SseConnectionState.failed &&
            _state != SseConnectionState.closed) {
          _setState(SseConnectionState.reconnecting);
        }
        break;
      case _SseLoggerSignal.idle:
        if (_state != SseConnectionState.closed &&
            _state != SseConnectionState.failed) {
          _setState(SseConnectionState.idle);
        }
        break;
    }
  }

  void _handleEvent(Event event) {
    if (_stopped) return;

    if (event is OpenEvent) {
      _setState(SseConnectionState.connected);
      return;
    }

    if (event is! MessageEvent) return;

    final eventType = event.type.trim();
    final data = event.data.trim();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final idMs = int.tryParse((event.id ?? '').trim());

    if (idMs != null) {
      final health = _healthTracker.trackEvent(idMs, nowMs);
      onHealthUpdated(health);
    }

    onMessage(
      SseMessage(
        event: eventType,
        data: data,
        eventIdMs: idMs,
        receivedAtEpochMs: nowMs,
      ),
    );
  }

  void _setState(SseConnectionState newState) {
    if (_state == newState) return;
    _state = newState;
    onConnectionStateChanged(newState);
  }
}

enum _SseLoggerSignal { connecting, connected, reconnecting, idle }

class _StateTrackingLogger implements EventSourceLogger {
  _StateTrackingLogger({required this.onSignal});

  final void Function(_SseLoggerSignal signal) onSignal;

  @override
  void debug(String message) {
    _parse(message);
  }

  @override
  void error(String message) {
    _parse(message);
  }

  @override
  void info(String message) {
    _parse(message);
  }

  @override
  void warn(String message) {
    _parse(message);
  }

  void _parse(String message) {
    if (message.contains('StateConnected')) {
      onSignal(_SseLoggerSignal.connected);
      return;
    }
    if (message.contains('StateConnecting')) {
      onSignal(_SseLoggerSignal.connecting);
      return;
    }
    if (message.contains('StateBackoff') ||
        message.contains('will retry with backoff') ||
        message.contains('Waiting ')) {
      onSignal(_SseLoggerSignal.reconnecting);
      return;
    }
    if (message.contains('StateIdle')) {
      onSignal(_SseLoggerSignal.idle);
    }
  }
}

class _SseHealthTracker {
  _SseHealthTracker({
    required this.slowThresholdMs,
    required this.recoveryThresholdMs,
    required this.slowStreakRequired,
    required this.recoveryStreakRequired,
  });

  final int slowThresholdMs;
  final int recoveryThresholdMs;
  final int slowStreakRequired;
  final int recoveryStreakRequired;

  int _breachStreak = 0;
  int _recoveryStreak = 0;
  bool _isSlow = false;

  SseNetworkHealth trackEvent(int eventIdMs, int nowEpochMs) {
    final metricMs = (nowEpochMs - eventIdMs).abs();
    final breached = metricMs > slowThresholdMs;
    final recovered = metricMs <= recoveryThresholdMs;

    if (breached) {
      _breachStreak += 1;
      _recoveryStreak = 0;
    } else if (recovered) {
      _recoveryStreak += 1;
      _breachStreak = 0;
    } else {
      _breachStreak = 0;
      _recoveryStreak = 0;
    }

    if (!_isSlow && _breachStreak >= slowStreakRequired) {
      _isSlow = true;
    } else if (_isSlow && _recoveryStreak >= recoveryStreakRequired) {
      _isSlow = false;
    }

    return SseNetworkHealth(
      isSlowNetwork: _isSlow,
      metricMs: metricMs,
      eventIdMs: eventIdMs,
      deviceEpochMs: nowEpochMs,
      breachStreak: _breachStreak,
      recoveryStreak: _recoveryStreak,
    );
  }
}
