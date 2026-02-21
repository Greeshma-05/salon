import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import 'booking_service.dart';

class PaymentReportService extends ChangeNotifier {
  static final PaymentReportService _instance =
      PaymentReportService._internal();
  factory PaymentReportService() => _instance;
  PaymentReportService._internal();

  final BookingService _bookingService = BookingService();

  /// Get payment summary for all bookings
  PaymentSummary getPaymentSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? serviceFilter,
    String? stylistFilter,
  }) {
    final allBookings = _bookingService.getAllBookings();
    final filteredBookings = _applyFilters(
      allBookings,
      startDate: startDate,
      endDate: endDate,
      serviceFilter: serviceFilter,
      stylistFilter: stylistFilter,
    );

    double totalPaid = 0.0;
    double totalPending = 0.0;
    double totalRefunded = 0.0;
    int paidCount = 0;
    int pendingCount = 0;
    int refundedCount = 0;

    for (var booking in filteredBookings) {
      switch (booking.paymentStatus.toLowerCase()) {
        case 'paid':
          totalPaid += booking.totalPrice;
          paidCount++;
          break;
        case 'pending':
        case 'unpaid':
          totalPending += booking.totalPrice;
          pendingCount++;
          break;
        case 'refunded':
          totalRefunded += booking.totalPrice;
          refundedCount++;
          break;
      }
    }

    final totalRevenue = totalPaid + totalPending + totalRefunded;

    return PaymentSummary(
      totalPaid: totalPaid,
      totalPending: totalPending,
      totalRefunded: totalRefunded,
      paidCount: paidCount,
      pendingCount: pendingCount,
      refundedCount: refundedCount,
      totalRevenue: totalRevenue,
      bookings: filteredBookings,
    );
  }

  /// Get payments by status
  List<AppointmentModel> getPaymentsByStatus(String status) {
    final allBookings = _bookingService.getAllBookings();
    return allBookings
        .where(
          (booking) =>
              booking.paymentStatus.toLowerCase() == status.toLowerCase(),
        )
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  /// Get payments for a specific date range
  List<AppointmentModel> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final allBookings = _bookingService.getAllBookings();
    return allBookings.where((booking) {
      final bookingDate = DateTime(
        booking.appointmentDate.year,
        booking.appointmentDate.month,
        booking.appointmentDate.day,
      );
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      return (bookingDate.isAtSameMomentAs(start) ||
              bookingDate.isAfter(start)) &&
          (bookingDate.isAtSameMomentAs(end) || bookingDate.isBefore(end));
    }).toList()..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  /// Get payments for a specific service
  List<AppointmentModel> getPaymentsByService(String serviceName) {
    final allBookings = _bookingService.getAllBookings();
    return allBookings
        .where((booking) => booking.serviceName == serviceName)
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  /// Get payments for a specific stylist
  List<AppointmentModel> getPaymentsByStylist(String stylistId) {
    final allBookings = _bookingService.getAllBookings();
    return allBookings
        .where((booking) => booking.stylistId == stylistId)
        .toList()
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
  }

  /// Apply multiple filters to bookings
  List<AppointmentModel> _applyFilters(
    List<AppointmentModel> bookings, {
    DateTime? startDate,
    DateTime? endDate,
    String? serviceFilter,
    String? stylistFilter,
  }) {
    var filtered = bookings;

    // Filter by date range
    if (startDate != null && endDate != null) {
      filtered = filtered.where((booking) {
        final bookingDate = DateTime(
          booking.appointmentDate.year,
          booking.appointmentDate.month,
          booking.appointmentDate.day,
        );
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day);

        return (bookingDate.isAtSameMomentAs(start) ||
                bookingDate.isAfter(start)) &&
            (bookingDate.isAtSameMomentAs(end) || bookingDate.isBefore(end));
      }).toList();
    }

    // Filter by service
    if (serviceFilter != null && serviceFilter.isNotEmpty) {
      filtered = filtered
          .where((booking) => booking.serviceName == serviceFilter)
          .toList();
    }

    // Filter by stylist
    if (stylistFilter != null && stylistFilter.isNotEmpty) {
      filtered = filtered
          .where((booking) => booking.stylistId == stylistFilter)
          .toList();
    }

    return filtered;
  }

  /// Get unique service names from bookings
  List<String> getUniqueServices() {
    final allBookings = _bookingService.getAllBookings();
    final services = allBookings.map((b) => b.serviceName).toSet().toList();
    services.sort();
    return services;
  }

  /// Get unique stylists from bookings
  List<Map<String, String>> getUniqueStylists() {
    final allBookings = _bookingService.getAllBookings();
    final stylistMap = <String, String>{};

    for (var booking in allBookings) {
      if (booking.stylistId != null && booking.stylistName != null) {
        stylistMap[booking.stylistId!] = booking.stylistName!;
      }
    }

    return stylistMap.entries
        .map((e) => {'id': e.key, 'name': e.value})
        .toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));
  }

  /// Get payment trends (last 7 days)
  List<DailyPaymentTrend> getPaymentTrends() {
    final today = DateTime.now();
    final trends = <DailyPaymentTrend>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final summary = getPaymentSummary(startDate: date, endDate: date);

      trends.add(
        DailyPaymentTrend(
          date: date,
          totalPaid: summary.totalPaid,
          totalPending: summary.totalPending,
          totalRefunded: summary.totalRefunded,
        ),
      );
    }

    return trends;
  }

  /// Export payment report to CSV
  String exportPaymentReportToCSV({
    DateTime? startDate,
    DateTime? endDate,
    String? serviceFilter,
    String? stylistFilter,
  }) {
    final summary = getPaymentSummary(
      startDate: startDate,
      endDate: endDate,
      serviceFilter: serviceFilter,
      stylistFilter: stylistFilter,
    );

    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'Customer,Service,Stylist,Date,Time,Amount,Payment Status,Booking Status',
    );

    // Data rows
    for (var booking in summary.bookings) {
      buffer.writeln(
        '"${booking.customerName}","${booking.serviceName}","${booking.stylistName ?? 'N/A'}","${booking.appointmentDate.toIso8601String().split('T')[0]}","${booking.timeSlot}",\$${booking.totalPrice.toStringAsFixed(2)},"${booking.paymentStatus}","${booking.status}"',
      );
    }

    return buffer.toString();
  }
}

/// Payment Summary Model
class PaymentSummary {
  final double totalPaid;
  final double totalPending;
  final double totalRefunded;
  final int paidCount;
  final int pendingCount;
  final int refundedCount;
  final double totalRevenue;
  final List<AppointmentModel> bookings;

  PaymentSummary({
    required this.totalPaid,
    required this.totalPending,
    required this.totalRefunded,
    required this.paidCount,
    required this.pendingCount,
    required this.refundedCount,
    required this.totalRevenue,
    required this.bookings,
  });

  double get paidPercentage =>
      totalRevenue > 0 ? (totalPaid / totalRevenue) * 100 : 0;
  double get pendingPercentage =>
      totalRevenue > 0 ? (totalPending / totalRevenue) * 100 : 0;
  double get refundedPercentage =>
      totalRevenue > 0 ? (totalRefunded / totalRevenue) * 100 : 0;
}

/// Daily Payment Trend Model
class DailyPaymentTrend {
  final DateTime date;
  final double totalPaid;
  final double totalPending;
  final double totalRefunded;

  DailyPaymentTrend({
    required this.date,
    required this.totalPaid,
    required this.totalPending,
    required this.totalRefunded,
  });

  double get totalRevenue => totalPaid + totalPending + totalRefunded;
}
