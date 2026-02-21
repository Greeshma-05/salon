class StylistModel {
  final String id;
  final String salonId;
  final String name;
  final String bio;
  final String? profileImage;
  final String phone;
  final String email;
  final List<String> specializations; // e.g., ["Haircut", "Coloring"]
  final double rating;
  final int totalReviews;
  final int yearsOfExperience;
  final bool isAvailable;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StylistModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.bio,
    this.profileImage,
    required this.phone,
    required this.email,
    this.specializations = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.yearsOfExperience = 0,
    this.isAvailable = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'name': name,
      'bio': bio,
      'profileImage': profileImage,
      'phone': phone,
      'email': email,
      'specializations': specializations,
      'rating': rating,
      'totalReviews': totalReviews,
      'yearsOfExperience': yearsOfExperience,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory StylistModel.fromMap(Map<String, dynamic> map, String id) {
    return StylistModel(
      id: id,
      salonId: map['salonId'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['profileImage'],
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      specializations: List<String>.from(map['specializations'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // CopyWith method
  StylistModel copyWith({
    String? id,
    String? salonId,
    String? name,
    String? bio,
    String? profileImage,
    String? phone,
    String? email,
    List<String>? specializations,
    double? rating,
    int? totalReviews,
    int? yearsOfExperience,
    bool? isAvailable,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StylistModel(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      specializations: specializations ?? this.specializations,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
