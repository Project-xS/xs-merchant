import 'package:flutter/foundation.dart';
import 'package:merchant/realtime/sse_realtime_client.dart';

class GlobalInventoryRealtimeState {
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);
  static final ValueNotifier<SseNetworkHealth?> health =
      ValueNotifier<SseNetworkHealth?>(null);

  static void bumpRevision() {
    revision.value = revision.value + 1;
  }

  static void setHealth(SseNetworkHealth value) {
    health.value = value;
  }

  static void reset() {
    health.value = null;
    revision.value = revision.value + 1;
  }
}
