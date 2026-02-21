import 'package:hive/hive.dart';
import 'service.dart';

part 'salon.g.dart';

@HiveType(typeId: 0)
class Salon extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String location;

  @HiveField(3)
  double rating;

  @HiveField(4)
  List<Service> services;

  Salon({
    required this.id,
    required this.name,
    required this.location,
    this.rating = 0.0,
    this.services = const [],
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      services:
          (json['services'] as List<dynamic>?)
              ?.map((s) => Service.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Copy with method for updates
  Salon copyWith({
    String? id,
    String? name,
    String? location,
    double? rating,
    List<Service>? services,
  }) {
    return Salon(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      services: services ?? this.services,
    );
  }

  @override
  String toString() {
    return 'Salon(id: $id, name: $name, location: $location, rating: $rating, services: ${services.length})';
  }
}
