import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_notification.dart';
import '../models/appointment_model.dart';
import 'notification_settings_service.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final Map<String, List<Timer>> _scheduledTimers =
      {}; // appointmentId -> timers

  final StreamController<List<AppNotification>> _notificationsController =
      StreamController<List<AppNotification>>.broadcast();

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  Stream<List<AppNotification>> get notificationsStream =>
      _notificationsController.stream;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Schedule appointment reminders based on settings
  void scheduleAppointmentReminders(
    AppointmentModel appointment,
    NotificationSettingsService settingsService,
  ) {
    // Parse appointment time
    final bookingDateTime = _parseAppointmentDateTime(
      appointment.appointmentDate,
      appointment.timeSlot,
    );

    if (bookingDateTime == null) {
      debugPrint(
        '⚠️ Could not parse appointment time: ${appointment.timeSlot}',
      );
      return;
    }

    final settings = settingsService.getSettings();
    final timers = <Timer>[];

    // Schedule day before reminder
    if (settings.dayBeforeReminder) {
      final reminderTime = bookingDateTime.subtract(const Duration(days: 1));

      if (reminderTime.isAfter(DateTime.now())) {
        final delay = reminderTime.difference(DateTime.now());

        debugPrint(
          '📅 Scheduling day-before reminder in ${delay.inMinutes} minutes',
        );

        final timer = Timer(delay, () {
          _addNotification(
            AppNotification(
              id: '${appointment.id}_day_before',
              title: 'Appointment Tomorrow',
              message:
                  '${appointment.serviceName} at ${appointment.salonName} - ${appointment.timeSlot}',
              time: DateTime.now(),
              appointmentId: appointment.id,
              type: NotificationType.reminder,
            ),
          );
        });

        timers.add(timer);
      }
    }

    // Schedule 2 hours before reminder
    if (settings.twoHoursBeforeReminder) {
      final reminderTime = bookingDateTime.subtract(const Duration(hours: 2));

      if (reminderTime.isAfter(DateTime.now())) {
        final delay = reminderTime.difference(DateTime.now());

        debugPrint(
          '⏰ Scheduling 2-hour reminder in ${delay.inMinutes} minutes',
        );

        final timer = Timer(delay, () {
          _addNotification(
            AppNotification(
              id: '${appointment.id}_2hours',
              title: 'Appointment in 2 Hours',
              message:
                  '${appointment.serviceName} at ${appointment.salonName} - ${appointment.timeSlot}',
              time: DateTime.now(),
              appointmentId: appointment.id,
              type: NotificationType.reminder,
            ),
          );
        });

        timers.add(timer);
      }
    }

    // Store timers for this appointment
    if (timers.isNotEmpty) {
      _scheduledTimers[appointment.id] = timers;
    }
  }

  /// Parse appointment date and time slot into DateTime
  DateTime? _parseAppointmentDateTime(DateTime date, String timeSlot) {
    try {
      // Expected format: "10:00 AM" or "2:30 PM"
      final timeFormat = DateFormat('h:mm a');
      final parsedTime = timeFormat.parse(timeSlot);

      // Combine date and time
      return DateTime(
        date.year,
        date.month,
        date.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      debugPrint('Error parsing time slot "$timeSlot": $e');
      return null;
    }
  }

  /// Add notification to the list
  void _addNotification(AppNotification notification) {
    _notifications.insert(0, notification); // Add to beginning (newest first)
    _notificationsController.add(_notifications);
    notifyListeners();

    debugPrint('🔔 Notification added: ${notification.title}');
  }

  /// Cancel scheduled reminders for an appointment
  void cancelAppointmentReminders(String appointmentId) {
    final timers = _scheduledTimers[appointmentId];

    if (timers != null) {
      for (var timer in timers) {
        timer.cancel();
      }
      _scheduledTimers.remove(appointmentId);
      debugPrint('❌ Cancelled reminders for appointment: $appointmentId');
    }
  }

  /// Add a manual notification
  void addNotification({
    required String title,
    required String message,
    String? appointmentId,
    NotificationType type = NotificationType.reminder,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      time: DateTime.now(),
      appointmentId: appointmentId,
      type: type,
    );

    _addNotification(notification);
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);

    if (index != -1) {
      _notifications[index] = _notifications[index].markAsRead();
      _notificationsController.add(_notifications);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].markAsRead();
      }
    }
    _notificationsController.add(_notifications);
    notifyListeners();
  }

  /// Remove a notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationsController.add(_notifications);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _notificationsController.add(_notifications);
    notifyListeners();
  }

  /// Clear all read notifications
  void clearReadNotifications() {
    _notifications.removeWhere((n) => n.isRead);
    _notificationsController.add(_notifications);
    notifyListeners();
  }

  /// Get notifications for a specific appointment
  List<AppNotification> getAppointmentNotifications(String appointmentId) {
    return _notifications
        .where((n) => n.appointmentId == appointmentId)
        .toList();
  }

  /// Send booking confirmation notification
  void sendBookingConfirmation(AppointmentModel appointment) {
    addNotification(
      title: 'Booking Confirmed!',
      message:
          '${appointment.serviceName} at ${appointment.salonName} on ${DateFormat('MMM dd').format(appointment.appointmentDate)}',
      appointmentId: appointment.id,
      type: NotificationType.booking,
    );
  }

  /// Send cancellation notification
  void sendCancellationNotification(AppointmentModel appointment) {
    addNotification(
      title: 'Appointment Cancelled',
      message:
          '${appointment.serviceName} on ${DateFormat('MMM dd').format(appointment.appointmentDate)} has been cancelled',
      appointmentId: appointment.id,
      type: NotificationType.cancellation,
    );
  }

  /// Send payment confirmation notification
  void sendPaymentConfirmation(AppointmentModel appointment, double amount) {
    addNotification(
      title: 'Payment Confirmed',
      message:
          'Payment of \$${amount.toStringAsFixed(2)} received for ${appointment.serviceName}',
      appointmentId: appointment.id,
      type: NotificationType.payment,
    );
  }

  /// Send booking approval/rejection notification
  void sendBookingApprovalNotification(
    AppointmentModel appointment, {
    required bool approved,
  }) {
    if (approved) {
      addNotification(
        title: '✅ Booking Approved!',
        message:
            'Your booking for ${appointment.serviceName} on ${DateFormat('MMM dd').format(appointment.appointmentDate)} has been approved',
        appointmentId: appointment.id,
        type: NotificationType.booking,
      );
    } else {
      addNotification(
        title: '❌ Booking Rejected',
        message:
            'Your booking for ${appointment.serviceName} on ${DateFormat('MMM dd').format(appointment.appointmentDate)} has been rejected. The slot is now available.',
        appointmentId: appointment.id,
        type: NotificationType.cancellation,
      );
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    // Cancel all timers
    for (var timers in _scheduledTimers.values) {
      for (var timer in timers) {
        timer.cancel();
      }
    }
    _scheduledTimers.clear();
    _notificationsController.close();
    super.dispose();
  }
}
