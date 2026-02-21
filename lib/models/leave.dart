class Leave {
  final String id;
  final String stylistId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final bool isApproved;

  Leave({
    required this.id,
    required this.stylistId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.isApproved = true,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stylistId': stylistId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'isApproved': isApproved,
    };
  }

  // Create from JSON
  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] as String,
      stylistId: json['stylistId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String,
      isApproved: json['isApproved'] as bool? ?? true,
    );
  }

  // Check if a date falls within this leave period
  bool isDateOnLeave(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

    return (dateOnly.isAtSameMomentAs(startOnly) ||
            dateOnly.isAfter(startOnly)) &&
        (dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly));
  }

  Leave copyWith({
    String? id,
    String? stylistId,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    bool? isApproved,
  }) {
    return Leave(
      id: id ?? this.id,
      stylistId: stylistId ?? this.stylistId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  @override
  String toString() =>
      'Leave for stylist $stylistId from $startDate to $endDate';
}
