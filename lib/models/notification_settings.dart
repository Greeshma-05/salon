class NotificationSettings {
  final bool dayBeforeReminder;
  final bool twoHoursBeforeReminder;

  NotificationSettings({
    required this.dayBeforeReminder,
    required this.twoHoursBeforeReminder,
  });

  // Default settings
  factory NotificationSettings.defaultSettings() {
    return NotificationSettings(
      dayBeforeReminder: true,
      twoHoursBeforeReminder: true,
    );
  }

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'dayBeforeReminder': dayBeforeReminder,
      'twoHoursBeforeReminder': twoHoursBeforeReminder,
    };
  }

  // Create from Map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      dayBeforeReminder: map['dayBeforeReminder'] ?? true,
      twoHoursBeforeReminder: map['twoHoursBeforeReminder'] ?? true,
    );
  }

  // Create a copy with updated values
  NotificationSettings copyWith({
    bool? dayBeforeReminder,
    bool? twoHoursBeforeReminder,
  }) {
    return NotificationSettings(
      dayBeforeReminder: dayBeforeReminder ?? this.dayBeforeReminder,
      twoHoursBeforeReminder:
          twoHoursBeforeReminder ?? this.twoHoursBeforeReminder,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(dayBeforeReminder: $dayBeforeReminder, twoHoursBeforeReminder: $twoHoursBeforeReminder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationSettings &&
        other.dayBeforeReminder == dayBeforeReminder &&
        other.twoHoursBeforeReminder == twoHoursBeforeReminder;
  }

  @override
  int get hashCode =>
      dayBeforeReminder.hashCode ^ twoHoursBeforeReminder.hashCode;
}
