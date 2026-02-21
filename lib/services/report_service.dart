import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import 'booking_service.dart';

class ReportService extends ChangeNotifier {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final BookingService _bookingService = BookingService();

  /// Get daily report for a specific date
  DailyReport getDailyReport(DateTime date) {
    final allBookings = _bookingService.getAllBookings();

    // Filter bookings for the specified date
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dailyBookings = allBookings.where((booking) {
      final bookingDate = DateTime(
        booking.appointmentDate.year,
        booking.appointmentDate.month,
        booking.appointmentDate.day,
      );
      return bookingDate.isAtSameMomentAs(dateOnly);
    }).toList();

    // Calculate total bookings
    final totalBookings = dailyBookings.length;

    // Calculate total revenue
    final totalRevenue = dailyBookings.fold<double>(
      0.0,
      (sum, booking) => sum + booking.totalPrice,
    );

    // Calculate total cancellations
    final totalCancellations = dailyBookings
        .where(
          (booking) =>
              booking.status == 'cancelled' ||
              booking.approvalStatus == 'rejected',
        )
        .length;

    // Find most booked service
    final serviceCounts = <String, int>{};
    for (var booking in dailyBookings) {
      serviceCounts[booking.serviceName] =
          (serviceCounts[booking.serviceName] ?? 0) + 1;
    }

    String mostBookedService = 'N/A';
    int mostBookedCount = 0;
    if (serviceCounts.isNotEmpty) {
      serviceCounts.forEach((service, count) {
        if (count > mostBookedCount) {
          mostBookedCount = count;
          mostBookedService = service;
        }
      });
    }

    // Calculate confirmed bookings
    final confirmedBookings = dailyBookings
        .where(
          (booking) =>
              booking.status == 'confirmed' ||
              booking.status == 'completed' ||
              booking.approvalStatus == 'approved',
        )
        .length;

    // Calculate pending bookings
    final pendingBookings = dailyBookings
        .where((booking) => booking.approvalStatus == 'pending')
        .length;

    // Calculate paid bookings
    final paidBookings = dailyBookings
        .where((booking) => booking.paymentStatus == 'paid')
        .length;

    // Calculate average booking value
    final averageBookingValue = totalBookings > 0
        ? totalRevenue / totalBookings
        : 0.0;

    return DailyReport(
      date: dateOnly,
      totalBookings: totalBookings,
      totalRevenue: totalRevenue,
      totalCancellations: totalCancellations,
      mostBookedService: mostBookedService,
      mostBookedServiceCount: mostBookedCount,
      confirmedBookings: confirmedBookings,
      pendingBookings: pendingBookings,
      paidBookings: paidBookings,
      averageBookingValue: averageBookingValue,
      bookings: dailyBookings,
    );
  }

  /// Get report for today
  DailyReport getTodayReport() {
    return getDailyReport(DateTime.now());
  }

  /// Get revenue for date range
  double getRevenueForRange(DateTime startDate, DateTime endDate) {
    final allBookings = _bookingService.getAllBookings();

    return allBookings
        .where((booking) {
          final bookingDate = DateTime(
            booking.appointmentDate.year,
            booking.appointmentDate.month,
            booking.appointmentDate.day,
          );
          return (bookingDate.isAtSameMomentAs(startDate) ||
                  bookingDate.isAfter(startDate)) &&
              (bookingDate.isAtSameMomentAs(endDate) ||
                  bookingDate.isBefore(endDate));
        })
        .fold<double>(0.0, (sum, booking) => sum + booking.totalPrice);
  }

  /// Get weekly report (last 7 days)
  WeeklyReport getWeeklyReport() {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 6));

    final dailyReports = <DailyReport>[];
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      dailyReports.add(getDailyReport(date));
    }

    final totalRevenue = dailyReports.fold<double>(
      0.0,
      (sum, report) => sum + report.totalRevenue,
    );

    final totalBookings = dailyReports.fold<int>(
      0,
      (sum, report) => sum + report.totalBookings,
    );

    return WeeklyReport(
      startDate: startDate,
      endDate: today,
      dailyReports: dailyReports,
      totalRevenue: totalRevenue,
      totalBookings: totalBookings,
    );
  }

  /// Get top services for a date range
  List<ServiceStats> getTopServices(
    DateTime startDate,
    DateTime endDate, {
    int limit = 5,
  }) {
    final allBookings = _bookingService.getAllBookings();

    final rangeBookings = allBookings.where((booking) {
      final bookingDate = DateTime(
        booking.appointmentDate.year,
        booking.appointmentDate.month,
        booking.appointmentDate.day,
      );
      return (bookingDate.isAtSameMomentAs(startDate) ||
              bookingDate.isAfter(startDate)) &&
          (bookingDate.isAtSameMomentAs(endDate) ||
              bookingDate.isBefore(endDate));
    }).toList();

    final serviceStats = <String, ServiceStats>{};

    for (var booking in rangeBookings) {
      if (!serviceStats.containsKey(booking.serviceName)) {
        serviceStats[booking.serviceName] = ServiceStats(
          serviceName: booking.serviceName,
          bookingCount: 0,
          totalRevenue: 0.0,
        );
      }

      serviceStats[booking.serviceName]!.bookingCount++;
      serviceStats[booking.serviceName]!.totalRevenue += booking.totalPrice;
    }

    final sortedStats = serviceStats.values.toList()
      ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));

    return sortedStats.take(limit).toList();
  }
}

/// Daily Report Model
class DailyReport {
  final DateTime date;
  final int totalBookings;
  final double totalRevenue;
  final int totalCancellations;
  final String mostBookedService;
  final int mostBookedServiceCount;
  final int confirmedBookings;
  final int pendingBookings;
  final int paidBookings;
  final double averageBookingValue;
  final List<AppointmentModel> bookings;

  DailyReport({
    required this.date,
    required this.totalBookings,
    required this.totalRevenue,
    required this.totalCancellations,
    required this.mostBookedService,
    required this.mostBookedServiceCount,
    required this.confirmedBookings,
    required this.pendingBookings,
    required this.paidBookings,
    required this.averageBookingValue,
    required this.bookings,
  });

  bool get hasBookings => totalBookings > 0;
}

/// Weekly Report Model
class WeeklyReport {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyReport> dailyReports;
  final double totalRevenue;
  final int totalBookings;

  WeeklyReport({
    required this.startDate,
    required this.endDate,
    required this.dailyReports,
    required this.totalRevenue,
    required this.totalBookings,
  });

  double get averageDailyRevenue =>
      dailyReports.isNotEmpty ? totalRevenue / dailyReports.length : 0.0;

  double get averageDailyBookings =>
      dailyReports.isNotEmpty ? totalBookings / dailyReports.length : 0.0;
}

/// Service Statistics Model
class ServiceStats {
  final String serviceName;
  int bookingCount;
  double totalRevenue;

  ServiceStats({
    required this.serviceName,
    required this.bookingCount,
    required this.totalRevenue,
  });

  double get averageRevenue =>
      bookingCount > 0 ? totalRevenue / bookingCount : 0.0;
}
