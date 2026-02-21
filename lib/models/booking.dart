import 'package:hive/hive.dart';

part 'booking.g.dart';

@HiveType(typeId: 2)
class Booking extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String salonName;

  @HiveField(2)
  String serviceName;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String time;

  Booking({
    required this.id,
    required this.salonName,
    required this.serviceName,
    required this.date,
    required this.time,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonName': salonName,
      'serviceName': serviceName,
      'date': date.toIso8601String(),
      'time': time,
    };
  }

  // Create from JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      salonName: json['salonName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      time: json['time'] ?? '',
    );
  }

  // Copy with method for updates
  Booking copyWith({
    String? id,
    String? salonName,
    String? serviceName,
    DateTime? date,
    String? time,
  }) {
    return Booking(
      id: id ?? this.id,
      salonName: salonName ?? this.salonName,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  // Format date as human-readable string
  String get formattedDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $time';
  }

  // Check if booking is in the past
  bool get isPast {
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(time.split(':')[0]),
      int.parse(time.split(':')[1].split(' ')[0]),
    );
    return bookingDateTime.isBefore(now);
  }

  // Check if booking is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if booking is upcoming
  bool get isUpcoming {
    return !isPast;
  }

  @override
  String toString() {
    return 'Booking(id: $id, salonName: $salonName, serviceName: $serviceName, date: $formattedDate, time: $time)';
  }
}
