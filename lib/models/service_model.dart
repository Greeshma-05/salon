class ServiceModel {
  final String id;
  final String salonId;
  final String name;
  final String description;
  final double price;
  final int duration; // in minutes
  final String category;
  final String? imageUrl;
  final List<String> productsUsed; // Products used in treatment
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.category,
    this.productsUsed = const [],
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'salonId': salonId,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
      'productsUsed': productsUsed,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory ServiceModel.fromMap(Map<String, dynamic> map, String id) {
    return ServiceModel(
      id: id,
      salonId: map['salonId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      duration: map['duration'] ?? 0,
      productsUsed: List<String>.from(map['productsUsed'] ?? []),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
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
  ServiceModel copyWith({
    String? id,
    String? salonId,
    String? name,
    String? description,
    double? price,
    int? duration,
    List<String>? productsUsed,
    String? category,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      productsUsed: productsUsed ?? this.productsUsed,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
