class SalonModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String phone;
  final String email;
  final String ownerId; // Reference to admin user
  final String? imageUrl;
  final List<String> images; // Multiple salon images
  final Map<String, dynamic> openingHours; // e.g., {"monday": "9:00-18:00"}
  final double rating;
  final int totalReviews;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalonModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.phone,
    required this.email,
    required this.ownerId,
    this.imageUrl,
    this.images = const [],
    this.openingHours = const {},
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'phone': phone,
      'email': email,
      'ownerId': ownerId,
      'imageUrl': imageUrl,
      'images': images,
      'openingHours': openingHours,
      'rating': rating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory SalonModel.fromMap(Map<String, dynamic> map, String id) {
    return SalonModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      ownerId: map['ownerId'] ?? '',
      imageUrl: map['imageUrl'],
      images: List<String>.from(map['images'] ?? []),
      openingHours: Map<String, dynamic>.from(map['openingHours'] ?? {}),
      rating: (map['rating'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
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
  SalonModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? phone,
    String? email,
    String? ownerId,
    String? imageUrl,
    List<String>? images,
    Map<String, dynamic>? openingHours,
    double? rating,
    int? totalReviews,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      ownerId: ownerId ?? this.ownerId,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
