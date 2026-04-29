import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'watering_channel',
          channelName: 'Watering Alerts',
          channelDescription: 'Pengingat menyiram tanaman',
          playSound: true,
          importance: NotificationImportance.High,
          defaultColor: Colors.teal,
          ledColor: Colors.white,
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> scheduleWateringReminder(int id, String plantName, int days) async {
    await AwesomeNotifications().cancel(id);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'watering_channel',
        title: 'Waktunya Menyiram! 💧',
        body: 'Tanaman $plantName kamu butuh air hari ini.',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationInterval(
        interval: Duration(days: days),
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: true,
      ),
    );
  }

  static Future<void> triggerInstantWateringNotification(String plantName) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'watering_channel',
        title: 'Tercatat! 💦',
        body: '$plantName telah disiram. Timer diatur ulang!',
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}