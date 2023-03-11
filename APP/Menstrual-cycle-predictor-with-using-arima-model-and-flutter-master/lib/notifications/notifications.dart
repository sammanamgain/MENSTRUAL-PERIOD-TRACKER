import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menstrual_period_tracker/data/database.dart';
import 'package:menstrual_period_tracker/timerui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationAPI {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject();

  static Future _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel description',
      icon: 'flutter_logo',
      importance: Importance.max,
    ));
  }

  static Future init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('flutter_logo');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.show(
        id,
        title,
        body,
        await _notificationDetails(),
        payload: payload,
      );

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async =>
      _notifications.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        await _notificationDetails(),
      );

  static void stopNotification() {
    _notifications.cancelAll();
  }

  static Future showScheduledDateNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async {
    _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      await _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future showScheduledDate2Notification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate,
  }) async {
    _notifications.zonedSchedule(
      id,
      title,
      body,
      _schedule(scheduledDate),
      await _notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _schedule(DateTime scheduledDateTime) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(Duration(days: 1))
        : scheduledDate;
  }
}
