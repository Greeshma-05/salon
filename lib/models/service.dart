import 'package:hive/hive.dart';

part 'service.g.dart';

@HiveType(typeId: 1)
class Service extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int duration; // in minutes

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'duration': duration};
  }

  // Create from JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? 0,
    );
  }

  // Copy with method for updates
  Service copyWith({String? id, String? name, double? price, int? duration}) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
    );
  }

  // Format duration as human-readable string
  String get formattedDuration {
    if (duration < 60) {
      return '$duration min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'hour' : 'hours'}';
      }
      return '$hours ${hours == 1 ? 'hour' : 'hours'} $minutes min';
    }
  }

  // Format price as currency (Indian Rupees)
  String get formattedPrice {
    return '₹${price.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'Service(id: $id, name: $name, price: $price, duration: $duration)';
  }
}
