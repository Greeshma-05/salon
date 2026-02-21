class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String serviceId;
  final String serviceName;
  final DateTime bookingDate;
  final String timeSlot;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final DateTime createdAt;
  final String? notes;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceId,
    required this.serviceName,
    required this.bookingDate,
    required this.timeSlot,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      bookingDate: DateTime.parse(map['bookingDate']),
      timeSlot: map['timeSlot'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
      notes: map['notes'],
    );
  }
}
