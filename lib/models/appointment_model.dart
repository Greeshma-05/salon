class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String salonId;
  final String salonName;
  final String serviceId;
  final String serviceName;
  final String? stylistId;
  final String? stylistName;
  final DateTime appointmentDate;
  final String timeSlot; // e.g., "10:00 AM"
  final int duration; // in minutes
  final double totalPrice;
  final String
  status; // 'pending', 'confirmed', 'in-progress', 'completed', 'cancelled', 'no-show'
  final String paymentStatus; // 'pending', 'paid', 'refunded', 'failed'
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.salonId,
    required this.salonName,
    required this.serviceId,
    required this.serviceName,
    this.stylistId,
    this.stylistName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.duration,
    required this.totalPrice,
    this.paymentStatus = 'pending',
    this.status = 'pending',
    this.approvalStatus = 'pending',
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'salonId': salonId,
      'salonName': salonName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'duration': duration,
      'paymentStatus': paymentStatus,
      'totalPrice': totalPrice,
      'status': status,
      'approvalStatus': approvalStatus,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore Map
  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      salonId: map['salonId'] ?? '',
      salonName: map['salonName'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      stylistId: map['stylistId'],
      stylistName: map['stylistName'],
      appointmentDate: map['appointmentDate'] != null
          ? DateTime.parse(map['appointmentDate'])
          : DateTime.now(),
      timeSlot: map['timeSlot'] ?? '',
      duration: map['duration'] ?? 0,
      paymentStatus: map['paymentStatus'] ?? 'pending',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      approvalStatus: map['approvalStatus'] ?? 'pending',
      notes: map['notes'],
      cancellationReason: map['cancellationReason'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  // CopyWith method
  AppointmentModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? salonId,
    String? salonName,
    String? serviceId,
    String? serviceName,
    String? stylistId,
    String? stylistName,
    DateTime? appointmentDate,
    String? timeSlot,
    int? duration,
    String? paymentStatus,
    double? totalPrice,
    String? status,
    String? approvalStatus,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      timeSlot: timeSlot ?? this.timeSlot,
      duration: duration ?? this.duration,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to check if appointment can be cancelled
  bool get canBeCancelled {
    return status == 'pending' || status == 'confirmed';
  }

  // Helper method to check if appointment is upcoming
  bool get isUpcoming {
    return appointmentDate.isAfter(DateTime.now()) &&
        (status == 'pending' || status == 'confirmed');
  }

  // Helper method to check if appointment is past
  bool get isPast {
    return appointmentDate.isBefore(DateTime.now());
  }
}
