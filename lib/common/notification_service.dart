import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchant/models/menu_item.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init({void Function(NotificationResponse)? onTap}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification clicked: ${details.payload}');
        onTap?.call(details);
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> showStockNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      debugPrint('Calling _notificationsPlugin.show for id: $id');
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
        'stock_alerts_v3',
        'Stock Alerts',
        channelDescription: 'Notifications for low stock items',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('low_stock'),
        icon: 'ic_launcher',
        showWhen: true,
      );

      const DarwinNotificationDetails darwinPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'low_stock.mp3',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinPlatformChannelSpecifics,
        macOS: darwinPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: id.toString(),
      );
    } catch (e) {
      debugPrint('Error showing system notification: $e');
    }
  }

  static Future<void> checkAndNotifyStock(
    List<MenuItem> items, {
    String Function(MenuItem)? titleBuilder,
    String Function(MenuItem)? bodyBuilder,
    void Function(MenuItem, String, String)? onNotify,
    void Function(MenuItem)? onStockHealthy,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    for (var item in items) {
      final String systemNotifiedKey = 'system_notified_${item.id}';
      final String lastStockKey = 'last_stock_${item.id}';

      final int? lastStock = prefs.getInt(lastStockKey);
      
      // Only notify for items that are currently On Menu and have stock < 30
      final bool isLowStock = item.available && item.stock != -1 && item.stock < 30;

      if (isLowStock) {
        // If stock increased (e.g. from 5 to 10), we don't trigger a NEW system notification
        // but we still want it to stay in the in-app list.
        bool stockIncreased = lastStock != null && item.stock > lastStock;
        
        final title = titleBuilder?.call(item) ?? 'Low Stock Alert';
        final body = bodyBuilder?.call(item) ??
            '${item.name} is running low on stock (${item.stock} remaining)';

        // ALWAYS call onNotify if low stock, so the in-app drawer stays updated
        onNotify?.call(item, title, body);

        // System notification (banner/sound) only happens ONCE
        final bool alreadyNotifiedSystem = prefs.getBool(systemNotifiedKey) ?? false;
        
        if (!alreadyNotifiedSystem && !stockIncreased) {
          await showStockNotification(
            id: item.id,
            title: title,
            body: body,
          );
          await prefs.setBool(systemNotifiedKey, true);
        }
        
        await prefs.setInt(lastStockKey, item.stock);
      } else {
        // Item is now healthy (>= 30, or -1, or Off Menu)
        if (item.stock >= 30 || item.stock == -1 || !item.available) {
          // Clear the "already notified" flag so if it drops again later, we notify again
          await prefs.remove(systemNotifiedKey);
          onStockHealthy?.call(item);
        }
        await prefs.setInt(lastStockKey, item.stock);
      }
    }
  }
}
