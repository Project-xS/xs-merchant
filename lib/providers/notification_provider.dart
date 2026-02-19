import 'package:flutter/material.dart';

class InAppNotification {
  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  InAppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<InAppNotification> _notifications = [];

  List<InAppNotification> get notifications => List.unmodifiable(_notifications);

  void addNotification(InAppNotification notification) {
    // Check if a notification for this item already exists, if so update it
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _notifications[index] = notification;
    } else {
      _notifications.insert(0, notification);
    }
    notifyListeners();
  }

  void removeNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }
}
