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

  @HiveField(5)
  double? latitude;

  @HiveField(6)
  double? longitude;

  // Distance in km (not persisted in Hive, calculated at runtime)
  double? distanceKm;

  Salon({
    required this.id,
    required this.name,
    required this.location,
    this.rating = 0.0,
    this.services = const [],
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
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
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      services:
          (json['services'] as List<dynamic>?)
              ?.map((s) => Service.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Create from Firestore map
  factory Salon.fromMap(Map<String, dynamic> map) {
    return Salon(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      services:
          (map['services'] as List<dynamic>?)
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
    double? latitude,
    double? longitude,
    double? distanceKm,
  }) {
    return Salon(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      services: services ?? this.services,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  String toString() {
    return 'Salon(id: $id, name: $name, location: $location, rating: $rating, services: ${services.length})';
  }
}
