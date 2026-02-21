import 'working_slot.dart';

class Stylist {
  final String id;
  final String name;
  final String salonId;
  bool isAvailable;
  final List<String> skills;
  final List<WorkingSlot> workingHours;

  Stylist({
    required this.id,
    required this.name,
    required this.salonId,
    required this.isAvailable,
    required this.skills,
    this.workingHours = const [],
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'salonId': salonId,
      'isAvailable': isAvailable,
      'skills': skills,
      'workingHours': workingHours.map((slot) => slot.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      id: json['id'] as String,
      name: json['name'] as String,
      salonId: json['salonId'] as String,
      isAvailable: json['isAvailable'] as bool,
      skills: (json['skills'] as List).cast<String>(),
      workingHours: json['workingHours'] != null
          ? (json['workingHours'] as List)
                .map((slot) => WorkingSlot.fromJson(slot))
                .toList()
          : [],
    );
  }

  // Create a copy with updated fields
  Stylist copyWith({
    String? id,
    String? name,
    String? salonId,
    bool? isAvailable,
    List<String>? skills,
    List<WorkingSlot>? workingHours,
  }) {
    return Stylist(
      id: id ?? this.id,
      name: name ?? this.name,
      salonId: salonId ?? this.salonId,
      isAvailable: isAvailable ?? this.isAvailable,
      skills: skills ?? this.skills,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}
