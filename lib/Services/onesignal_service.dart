import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';

class OneSignalService {
  final BuildContext? context;

  OneSignalService({this.context});

  Future<void> initOneSignal(String? userId) async {
    try {
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      OneSignal.shared.setAppId('ca77eaad-eb18-4da5-8442-747cc7092b00');

      OneSignal.shared.setLocationShared(false);

      bool accepted = await OneSignal.shared
          .promptUserForPushNotificationPermission(fallbackToSettings: true);
      debugPrint('🔔 Push permission accepted: $accepted');

      if (!accepted && context != null) {
        showDialog(
          context: context!,
          builder: (context) => AlertDialog(
            title: const Text('Enable Push Notifications'),
            content: const Text(
                'Push notifications are required for task updates. Please enable them in settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  OneSignal.shared.promptUserForPushNotificationPermission(
                      fallbackToSettings: true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }

      if (userId != null) {
        await OneSignal.shared.setExternalUserId(userId);
        debugPrint('Set external user ID: $userId');
      }

      // Foreground notification handler
      OneSignal.shared.setNotificationWillShowInForegroundHandler(
          (OSNotificationReceivedEvent event) {
        event.complete(event.notification);
        debugPrint(
            '📩 Notification in foreground: ${event.notification.jsonRepresentation()}');
      });

      OneSignal.shared
          .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
        debugPrint(
            '📬 Notification opened: ${result.notification.jsonRepresentation()}');
        final data = result.notification.additionalData;
        if (data != null && data.containsKey('task_id') && context != null) {
          debugPrint('📌 Task ID from notification: ${data['task_id']}');
        }
      });
    } catch (e) {
      debugPrint('🚫 Error initializing OneSignal: $e');
    }
  }
}
