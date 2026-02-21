class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final bool isRead;
  final String? appointmentId;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.appointmentId,
    this.type = NotificationType.reminder,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time.millisecondsSinceEpoch,
      'isRead': isRead,
      'appointmentId': appointmentId,
      'type': type.toString().split('.').last,
    };
  }

  // Create from Map
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      time: DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      isRead: map['isRead'] ?? false,
      appointmentId: map['appointmentId'],
      type: _parseNotificationType(map['type']),
    );
  }

  // Parse notification type from string
  static NotificationType _parseNotificationType(String? typeString) {
    if (typeString == null) return NotificationType.reminder;

    switch (typeString) {
      case 'reminder':
        return NotificationType.reminder;
      case 'booking':
        return NotificationType.booking;
      case 'cancellation':
        return NotificationType.cancellation;
      case 'payment':
        return NotificationType.payment;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.reminder;
    }
  }

  // Create a copy with updated values
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    bool? isRead,
    String? appointmentId,
    NotificationType? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      appointmentId: appointmentId ?? this.appointmentId,
      type: type ?? this.type,
    );
  }

  // Mark notification as read
  AppNotification markAsRead() {
    return copyWith(isRead: true);
  }

  // Check if notification is for today
  bool get isToday {
    final now = DateTime.now();
    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  // Check if notification is past
  bool get isPast {
    return time.isBefore(DateTime.now());
  }

  // Get time ago string
  String get timeAgo {
    final difference = DateTime.now().difference(time);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'AppNotification(id: $id, title: $title, message: $message, time: $time, isRead: $isRead, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppNotification &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.time == time &&
        other.isRead == isRead &&
        other.appointmentId == appointmentId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        message.hashCode ^
        time.hashCode ^
        isRead.hashCode ^
        appointmentId.hashCode ^
        type.hashCode;
  }
}

// Notification types enum
enum NotificationType {
  reminder, // Appointment reminders
  booking, // Booking confirmations
  cancellation, // Cancellation notices
  payment, // Payment confirmations
  promotion, // Promotional messages
}
