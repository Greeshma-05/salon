import 'package:flutter/material.dart';
import '../models/service_model.dart';
import 'booking_service.dart';

class PricingService extends ChangeNotifier {
  static final PricingService _instance = PricingService._internal();
  factory PricingService() => _instance;
  PricingService._internal();

  final BookingService _bookingService = BookingService();

  // Thresholds
  static const int highDemandThreshold = 5;
  static const int lowDemandThreshold = 2;
  static const int recentDaysWindow = 7; // Check bookings in last 7 days

  // Pricing adjustments
  static const double highDemandIncrease = 0.10; // 10%
  static const double lowDemandDiscount = 0.15; // 15%
  static const double weekdayDiscount = 0.05; // 5%

  /// Calculate dynamic price for a service
  PricingResult getDynamicPrice({
    required String serviceId,
    required String serviceName,
    required double basePrice,
    DateTime? bookingDate,
  }) {
    // Get booking count for this service in recent days
    final recentBookingCount = _getRecentBookingCount(serviceId);

    // Determine if booking date is a weekday
    final isWeekday = _isWeekday(bookingDate ?? DateTime.now());

    double adjustedPrice = basePrice;
    String priceLabel = 'Regular Price';
    List<String> appliedDiscounts = [];

    // Apply high demand pricing
    if (recentBookingCount > highDemandThreshold) {
      adjustedPrice = basePrice * (1 + highDemandIncrease);
      priceLabel = 'High Demand';
      appliedDiscounts.add('High demand (+10%)');
    }
    // Apply low demand discount
    else if (recentBookingCount < lowDemandThreshold) {
      adjustedPrice = basePrice * (1 - lowDemandDiscount);
      priceLabel = 'Special Discount';
      appliedDiscounts.add('Low demand special (-15%)');
    }

    // Apply weekday discount (can stack with low demand)
    if (isWeekday && recentBookingCount < lowDemandThreshold) {
      adjustedPrice = adjustedPrice * (1 - weekdayDiscount);
      appliedDiscounts.add('Weekday bonus (-5%)');
      priceLabel = 'Special Discount';
    } else if (isWeekday && recentBookingCount <= highDemandThreshold) {
      // If not high demand, apply weekday discount
      adjustedPrice = adjustedPrice * (1 - weekdayDiscount);
      appliedDiscounts.add('Weekday special (-5%)');
      if (priceLabel == 'Regular Price') {
        priceLabel = 'Weekday Special';
      }
    }

    // Calculate discount percentage
    final discountPercentage = ((basePrice - adjustedPrice) / basePrice * 100)
        .abs();

    return PricingResult(
      serviceName: serviceName,
      basePrice: basePrice,
      adjustedPrice: adjustedPrice,
      priceLabel: priceLabel,
      appliedDiscounts: appliedDiscounts,
      discountPercentage: discountPercentage,
      isDiscounted: adjustedPrice < basePrice,
      demandLevel: _getDemandLevel(recentBookingCount),
      recentBookingCount: recentBookingCount,
    );
  }

  /// Get count of bookings for a service in recent days
  int _getRecentBookingCount(String serviceId) {
    final cutoffDate = DateTime.now().subtract(
      Duration(days: recentDaysWindow),
    );
    final allAppointments = _bookingService.appointments;

    return allAppointments.where((appointment) {
      return appointment.serviceId == serviceId &&
          appointment.appointmentDate.isAfter(cutoffDate) &&
          appointment.status != 'cancelled';
    }).length;
  }

  /// Check if date is a weekday (Monday-Friday)
  bool _isWeekday(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  /// Get demand level label
  String _getDemandLevel(int bookingCount) {
    if (bookingCount > highDemandThreshold) {
      return 'High';
    } else if (bookingCount < lowDemandThreshold) {
      return 'Low';
    } else {
      return 'Medium';
    }
  }

  /// Get pricing for multiple services
  List<PricingResult> getBulkPricing({
    required List<ServiceModel> services,
    DateTime? bookingDate,
  }) {
    return services.map((service) {
      return getDynamicPrice(
        serviceId: service.id,
        serviceName: service.name,
        basePrice: service.price,
        bookingDate: bookingDate,
      );
    }).toList();
  }
}

/// Result class containing pricing information
class PricingResult {
  final String serviceName;
  final double basePrice;
  final double adjustedPrice;
  final String priceLabel;
  final List<String> appliedDiscounts;
  final double discountPercentage;
  final bool isDiscounted;
  final String demandLevel;
  final int recentBookingCount;

  PricingResult({
    required this.serviceName,
    required this.basePrice,
    required this.adjustedPrice,
    required this.priceLabel,
    required this.appliedDiscounts,
    required this.discountPercentage,
    required this.isDiscounted,
    required this.demandLevel,
    required this.recentBookingCount,
  });

  double get savingsAmount => basePrice - adjustedPrice;

  bool get hasDiscount => isDiscounted;

  bool get hasSurcharge => adjustedPrice > basePrice;

  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(2)}';

  String get formattedAdjustedPrice => '\$${adjustedPrice.toStringAsFixed(2)}';

  String get formattedSavings => '\$${savingsAmount.abs().toStringAsFixed(2)}';

  String get priceChangeLabel {
    if (hasDiscount) {
      return 'Save ${discountPercentage.toStringAsFixed(0)}%';
    } else if (hasSurcharge) {
      return '+${discountPercentage.toStringAsFixed(0)}%';
    }
    return '';
  }

  Color getLabelColor() {
    if (priceLabel.contains('High Demand')) {
      return Colors.orange;
    } else if (priceLabel.contains('Special') ||
        priceLabel.contains('Weekday')) {
      return Colors.green;
    }
    return Colors.grey;
  }

  IconData getLabelIcon() {
    if (priceLabel.contains('High Demand')) {
      return Icons.trending_up;
    } else if (priceLabel.contains('Special') ||
        priceLabel.contains('Weekday')) {
      return Icons.local_offer;
    }
    return Icons.attach_money;
  }
}
