import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../../features/subscriptions/domain/subscription_model.dart';

/// NotificationService: Manages local payment reminder notifications for VELUNE.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
    );
  }

  /// Calculates the reminder date and schedules a local notification before a charge.
  Future<void> schedulePaymentReminder(Subscription sub, [int daysBefore = 3]) async {
    if (!sub.isActive) return;

    final notificationId = sub.id.hashCode.abs();
    final reminderDate = sub.nextPaymentDate.subtract(Duration(days: daysBefore));
    final formattedDate = DateFormat('MMM dd').format(sub.nextPaymentDate);
    final formattedAmount = '${sub.currency}${sub.amount.toStringAsFixed(2)}';

    final title = 'Upcoming Charge: ${sub.name}';
    final body =
        '${sub.name} payment in $daysBefore days. $formattedAmount will be charged on $formattedDate.';

    const androidDetails = AndroidNotificationDetails(
      'velune_payment_reminders',
      'Payment Reminders',
      channelDescription: 'Calm notifications for upcoming subscription payments',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // If the reminder date is in the future, register the notification alert
    if (reminderDate.isAfter(DateTime.now())) {
      try {
        await _notificationsPlugin.show(
          notificationId,
          title,
          body,
          notificationDetails,
        );
      } catch (_) {
        // Fallback gracefully if system notification permissions or alarms are restricted
      }
    }
  }

  /// Cancels any scheduled notification for a given subscription
  Future<void> cancelPaymentReminder(String subscriptionId) async {
    final notificationId = subscriptionId.hashCode.abs();
    await _notificationsPlugin.cancel(notificationId);
  }
}
