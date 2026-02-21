class Offer {
  final String id;
  final String title;
  final double discountPercent;
  final DateTime validUntil;
  final List<String> applicableServices;
  final bool isActive;
  final DateTime createdAt;

  Offer({
    required this.id,
    required this.title,
    required this.discountPercent,
    required this.validUntil,
    required this.applicableServices,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool isValidForService(String serviceName) {
    if (!isActive) return false;
    if (DateTime.now().isAfter(validUntil)) return false;
    if (applicableServices.isEmpty) return true; // Applies to all services
    return applicableServices.contains(serviceName);
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'discountPercent': discountPercent,
      'validUntil': validUntil.toIso8601String(),
      'applicableServices': applicableServices,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] as String,
      title: map['title'] as String,
      discountPercent: (map['discountPercent'] as num).toDouble(),
      validUntil: DateTime.parse(map['validUntil'] as String),
      applicableServices: List<String>.from(map['applicableServices'] as List),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Offer copyWith({
    String? id,
    String? title,
    double? discountPercent,
    DateTime? validUntil,
    List<String>? applicableServices,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Offer(
      id: id ?? this.id,
      title: title ?? this.title,
      discountPercent: discountPercent ?? this.discountPercent,
      validUntil: validUntil ?? this.validUntil,
      applicableServices: applicableServices ?? this.applicableServices,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
