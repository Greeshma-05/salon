class FeedbackModel {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerImage;
  final String salonId;
  final String salonName;
  final String? appointmentId;
  final String? stylistId;
  final String? stylistName;
  final String? serviceId;
  final String? serviceName;
  final double rating; // 1.0 to 5.0
  final String comment;
  final List<String>? images; // Optional feedback images
  final String? response; // Admin/salon response
  final DateTime? responseDate;
  final bool isVerified; // Verified purchase/appointment
  final bool isVisible; // Show on public reviews
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedbackModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerImage,
    required this.salonId,
    required this.salonName,
    this.appointmentId,
    this.stylistId,
    this.stylistName,
    this.serviceId,
    this.serviceName,
    required this.rating,
    required this.comment,
    this.images,
    this.response,
    this.responseDate,
    this.isVerified = false,
    this.isVisible = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,
      'salonId': salonId,
      'salonName': salonName,
      'appointmentId': appointmentId,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'rating': rating,
      'comment': comment,
      'images': images,
      'response': response,
      'responseDate': responseDate?.toIso8601String(),
      'isVerified': isVerified,
      'isVisible': isVisible,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerImage: map['customerImage'],
      salonId: map['salonId'] ?? '',
      salonName: map['salonName'] ?? '',
      appointmentId: map['appointmentId'],
      stylistId: map['stylistId'],
      stylistName: map['stylistName'],
      serviceId: map['serviceId'],
      serviceName: map['serviceName'],
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      images: map['images'] != null ? List<String>.from(map['images']) : null,
      response: map['response'],
      responseDate: map['responseDate'] != null
          ? DateTime.parse(map['responseDate'])
          : null,
      isVerified: map['isVerified'] ?? false,
      isVisible: map['isVisible'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // CopyWith method
  FeedbackModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerImage,
    String? salonId,
    String? salonName,
    String? appointmentId,
    String? stylistId,
    String? stylistName,
    String? serviceId,
    String? serviceName,
    double? rating,
    String? comment,
    List<String>? images,
    String? response,
    DateTime? responseDate,
    bool? isVerified,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerImage: customerImage ?? this.customerImage,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      appointmentId: appointmentId ?? this.appointmentId,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      response: response ?? this.response,
      responseDate: responseDate ?? this.responseDate,
      isVerified: isVerified ?? this.isVerified,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get star rating as int
  int get starRating => rating.round();

  // Helper method to check if feedback has response
  bool get hasResponse => response != null && response!.isNotEmpty;
}
