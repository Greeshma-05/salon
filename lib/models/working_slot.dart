class WorkingSlot {
  final String day; // Monday, Tuesday, etc.
  final String startTime; // "09:00"
  final String endTime; // "18:00"

  WorkingSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'day': day, 'startTime': startTime, 'endTime': endTime};
  }

  // Create from JSON
  factory WorkingSlot.fromJson(Map<String, dynamic> json) {
    return WorkingSlot(
      day: json['day'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  // Check if a time falls within this working slot
  bool isTimeInSlot(String time) {
    final timeValue = _timeToMinutes(time);
    final startValue = _timeToMinutes(startTime);
    final endValue = _timeToMinutes(endTime);

    return timeValue >= startValue && timeValue <= endValue;
  }

  // Convert time string (HH:mm) to minutes since midnight
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  WorkingSlot copyWith({String? day, String? startTime, String? endTime}) {
    return WorkingSlot(
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() => '$day: $startTime - $endTime';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkingSlot &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => day.hashCode ^ startTime.hashCode ^ endTime.hashCode;
}
