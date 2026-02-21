class Stylist {
  final String id;
  final String name;
  final String salonId;
  bool isAvailable;
  final List<String> skills;

  Stylist({
    required this.id,
    required this.name,
    required this.salonId,
    required this.isAvailable,
    required this.skills,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'salonId': salonId,
      'isAvailable': isAvailable,
      'skills': skills,
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
    );
  }

  // Create a copy with updated fields
  Stylist copyWith({
    String? id,
    String? name,
    String? salonId,
    bool? isAvailable,
    List<String>? skills,
  }) {
    return Stylist(
      id: id ?? this.id,
      name: name ?? this.name,
      salonId: salonId ?? this.salonId,
      isAvailable: isAvailable ?? this.isAvailable,
      skills: skills ?? this.skills,
    );
  }
}
