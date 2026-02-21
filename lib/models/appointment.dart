class Appointment {
  final String id;
  final String serviceName;
  final List<String> productsUsed;
  final DateTime date;
  final String stylist;
  final String paymentStatus; // Paid / Unpaid

  Appointment({
    required this.id,
    required this.serviceName,
    required this.productsUsed,
    required this.date,
    required this.stylist,
    required this.paymentStatus,
  });

  // Format date as human-readable string
  String get formattedDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Check if payment is complete
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  // Get products as comma-separated string
  String get productsUsedText => productsUsed.join(', ');

  // Create a copy with updated fields
  Appointment copyWith({
    String? id,
    String? serviceName,
    List<String>? productsUsed,
    DateTime? date,
    String? stylist,
    String? paymentStatus,
  }) {
    return Appointment(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      productsUsed: productsUsed ?? this.productsUsed,
      date: date ?? this.date,
      stylist: stylist ?? this.stylist,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'productsUsed': productsUsed,
      'date': date.toIso8601String(),
      'stylist': stylist,
      'paymentStatus': paymentStatus,
    };
  }

  // Create from JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      productsUsed: (json['productsUsed'] as List).cast<String>(),
      date: DateTime.parse(json['date'] as String),
      stylist: json['stylist'] as String,
      paymentStatus: json['paymentStatus'] as String,
    );
  }
}
