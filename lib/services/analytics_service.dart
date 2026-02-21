import 'package:flutter/foundation.dart';
import '../services/booking_service.dart';
import '../services/customer_management_service.dart';

class AnalyticsService extends ChangeNotifier {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final BookingService _bookingService = BookingService();
  final CustomerManagementService _customerService =
      CustomerManagementService();

  /// Calculate monthly revenue for a specific month
  double calculateMonthlyRevenue(int year, int month) {
    final bookings = _bookingService.getAllBookings();
    double revenue = 0.0;

    for (var booking in bookings) {
      if (booking.appointmentDate.year == year &&
          booking.appointmentDate.month == month &&
          (booking.paymentStatus.toLowerCase() == 'paid' ||
              booking.status.toLowerCase() == 'completed')) {
        revenue += booking.totalPrice;
      }
    }

    return revenue;
  }

  /// Get monthly revenue for last N months
  List<MonthlyRevenue> getMonthlyRevenueData(int months) {
    final now = DateTime.now();
    final List<MonthlyRevenue> data = [];

    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final revenue = calculateMonthlyRevenue(date.year, date.month);
      data.add(
        MonthlyRevenue(
          year: date.year,
          month: date.month,
          revenue: revenue,
          date: date,
        ),
      );
    }

    return data;
  }

  /// Calculate growth rate (current month vs previous month)
  double calculateGrowthRate() {
    final now = DateTime.now();
    final currentRevenue = calculateMonthlyRevenue(now.year, now.month);

    final lastMonth = DateTime(now.year, now.month - 1);
    final previousRevenue = calculateMonthlyRevenue(
      lastMonth.year,
      lastMonth.month,
    );

    if (previousRevenue == 0) return 0.0;

    return ((currentRevenue - previousRevenue) / previousRevenue) * 100;
  }

  /// Calculate year-over-year growth rate
  double calculateYearOverYearGrowth() {
    final now = DateTime.now();
    final currentRevenue = calculateMonthlyRevenue(now.year, now.month);

    final lastYear = DateTime(now.year - 1, now.month);
    final lastYearRevenue = calculateMonthlyRevenue(
      lastYear.year,
      lastYear.month,
    );

    if (lastYearRevenue == 0) return 0.0;

    return ((currentRevenue - lastYearRevenue) / lastYearRevenue) * 100;
  }

  /// Calculate customer retention rate
  double calculateRetentionRate() {
    final bookings = _bookingService.getAllBookings();
    final customers = _customerService.getAllCustomers();

    if (customers.isEmpty) return 0.0;

    // Get unique customer IDs who have booked more than once
    final customerBookingCounts = <String, int>{};

    for (var booking in bookings) {
      customerBookingCounts[booking.customerId] =
          (customerBookingCounts[booking.customerId] ?? 0) + 1;
    }

    final repeatCustomers = customerBookingCounts.values
        .where((count) => count > 1)
        .length;

    return (repeatCustomers / customers.length) * 100;
  }

  /// Calculate repeat customer rate (bookings from repeat customers)
  double calculateRepeatCustomerRate() {
    final bookings = _bookingService.getAllBookings();

    if (bookings.isEmpty) return 0.0;

    // Count bookings per customer
    final customerBookingCounts = <String, int>{};

    for (var booking in bookings) {
      customerBookingCounts[booking.customerId] =
          (customerBookingCounts[booking.customerId] ?? 0) + 1;
    }

    // Count bookings from customers with more than 1 booking
    int repeatBookings = 0;
    for (var booking in bookings) {
      if (customerBookingCounts[booking.customerId]! > 1) {
        repeatBookings++;
      }
    }

    return (repeatBookings / bookings.length) * 100;
  }

  /// Calculate average booking value
  double calculateAverageBookingValue() {
    final bookings = _bookingService.getAllBookings();

    if (bookings.isEmpty) return 0.0;

    double total = 0.0;
    for (var booking in bookings) {
      total += booking.totalPrice;
    }

    return total / bookings.length;
  }

  /// Get service popularity data
  List<ServicePopularity> getServicePopularity() {
    final bookings = _bookingService.getAllBookings();
    final serviceStats = <String, ServicePopularity>{};

    for (var booking in bookings) {
      if (serviceStats.containsKey(booking.serviceName)) {
        serviceStats[booking.serviceName] = ServicePopularity(
          serviceName: booking.serviceName,
          bookingCount: serviceStats[booking.serviceName]!.bookingCount + 1,
          revenue:
              serviceStats[booking.serviceName]!.revenue + booking.totalPrice,
        );
      } else {
        serviceStats[booking.serviceName] = ServicePopularity(
          serviceName: booking.serviceName,
          bookingCount: 1,
          revenue: booking.totalPrice,
        );
      }
    }

    final popularityList = serviceStats.values.toList()
      ..sort((a, b) => b.bookingCount.compareTo(a.bookingCount));

    return popularityList.take(10).toList();
  }

  /// Get business performance summary
  BusinessPerformance getBusinessPerformance() {
    final now = DateTime.now();
    final currentRevenue = calculateMonthlyRevenue(now.year, now.month);
    final growthRate = calculateGrowthRate();
    final retentionRate = calculateRetentionRate();
    final repeatCustomerRate = calculateRepeatCustomerRate();
    final averageBookingValue = calculateAverageBookingValue();
    final monthlyData = getMonthlyRevenueData(6);
    final servicePopularity = getServicePopularity();

    return BusinessPerformance(
      currentMonthRevenue: currentRevenue,
      growthRate: growthRate,
      retentionRate: retentionRate,
      repeatCustomerRate: repeatCustomerRate,
      averageBookingValue: averageBookingValue,
      monthlyRevenueData: monthlyData,
      servicePopularity: servicePopularity,
    );
  }

  /// Get total customers
  int getTotalCustomers() {
    return _customerService.getAllCustomers().length;
  }

  /// Get total bookings
  int getTotalBookings() {
    return _bookingService.getAllBookings().length;
  }

  /// Get completed bookings
  int getCompletedBookings() {
    return _bookingService
        .getAllBookings()
        .where((b) => b.status.toLowerCase() == 'completed')
        .length;
  }

  /// Get total revenue (all time)
  double getTotalRevenue() {
    final bookings = _bookingService.getAllBookings();
    double total = 0.0;

    for (var booking in bookings) {
      if (booking.paymentStatus.toLowerCase() == 'paid' ||
          booking.status.toLowerCase() == 'completed') {
        total += booking.totalPrice;
      }
    }

    return total;
  }
}

/// Monthly Revenue Model
class MonthlyRevenue {
  final int year;
  final int month;
  final double revenue;
  final DateTime date;

  MonthlyRevenue({
    required this.year,
    required this.month,
    required this.revenue,
    required this.date,
  });

  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Service Popularity Model
class ServicePopularity {
  final String serviceName;
  final int bookingCount;
  final double revenue;

  ServicePopularity({
    required this.serviceName,
    required this.bookingCount,
    required this.revenue,
  });

  double get averageValue => bookingCount > 0 ? revenue / bookingCount : 0.0;
}

/// Business Performance Model
class BusinessPerformance {
  final double currentMonthRevenue;
  final double growthRate;
  final double retentionRate;
  final double repeatCustomerRate;
  final double averageBookingValue;
  final List<MonthlyRevenue> monthlyRevenueData;
  final List<ServicePopularity> servicePopularity;

  BusinessPerformance({
    required this.currentMonthRevenue,
    required this.growthRate,
    required this.retentionRate,
    required this.repeatCustomerRate,
    required this.averageBookingValue,
    required this.monthlyRevenueData,
    required this.servicePopularity,
  });
}
