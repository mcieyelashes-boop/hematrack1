import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId   = 'hematrack_weekly';
  static const _channelName = 'Follow-up Mingguan';

  /// Notification ID stabil dari childId — unik per anak, tidak collision.
  int _notifId(String childId) => childId.hashCode.abs() % 100000;

  Future<bool> init() async {
    if (_initialized) return true;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final result = await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
    return result ?? false;
  }

  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true, badge: true, sound: true) ??
          false;
    }
    return true;
  }

  Future<void> scheduleWeeklyReminder(
      String childName, String childId) async {
    await init();
    await _plugin.periodicallyShow(
      _notifId(childId),
      'Waktunya foto follow-up!',
      'Saatnya mengambil foto monitoring mingguan untuk $childName.',
      RepeatInterval.weekly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Pengingat foto follow-up mingguan',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelReminder(String childId) async {
    await init();
    await _plugin.cancel(_notifId(childId));
  }

  Future<bool> isScheduled(String childId) async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((n) => n.id == _notifId(childId));
  }
}
