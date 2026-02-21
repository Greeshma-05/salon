import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class LoyaltyService extends ChangeNotifier {
  // Singleton pattern
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  final AuthService _authService = AuthService();

  // Loyalty Rules
  static const int pointsPerRupees = 10; // 10 points per ₹500
  static const double rupeesPerPoint = 500.0;
  static const int firstBookingBonus = 50;
  static const int pointsForDiscount = 100; // 100 points = ₹50
  static const double discountAmount = 50.0;

  // Track if user has received first booking bonus
  final Set<String> _usersWithBonus = {};

  /// Get current loyalty points for a user
  int getCurrentPoints(UserModel user) {
    return user.loyaltyPoints;
  }

  /// Calculate points to be earned from an amount
  /// 10 points for every ₹500 spent
  int calculatePointsFromAmount(double amount) {
    return ((amount / rupeesPerPoint) * pointsPerRupees).floor();
  }

  /// Calculate discount amount from points
  /// 100 points = ₹50 discount
  double calculateDiscountFromPoints(int points) {
    final sets = (points / pointsForDiscount).floor();
    return sets * discountAmount;
  }

  /// Calculate maximum discount that can be applied
  /// based on available points and bill amount
  double getMaximumDiscount(int availablePoints, double billAmount) {
    final maxDiscount = calculateDiscountFromPoints(availablePoints);
    // Discount cannot exceed bill amount
    return maxDiscount > billAmount ? billAmount : maxDiscount;
  }

  /// Calculate points needed for a specific discount
  int getPointsNeededForDiscount(double discountAmount) {
    return ((discountAmount / LoyaltyService.discountAmount) *
            pointsForDiscount)
        .ceil();
  }

  /// Add points to user account
  /// Returns updated UserModel
  Future<UserModel?> addPoints({
    required UserModel user,
    required double amountSpent,
    bool isFirstBooking = false,
  }) async {
    try {
      int pointsToAdd = calculatePointsFromAmount(amountSpent);

      // Add first booking bonus if applicable
      if (isFirstBooking && !_usersWithBonus.contains(user.uid)) {
        pointsToAdd += firstBookingBonus;
        _usersWithBonus.add(user.uid);
        debugPrint('🎉 First booking bonus: $firstBookingBonus points added!');
      }

      final newPoints = user.loyaltyPoints + pointsToAdd;
      final updatedUser = user.copyWith(loyaltyPoints: newPoints);

      // Save to storage
      await _authService.updateUserData(user.uid, {'loyaltyPoints': newPoints});

      debugPrint('✨ Added $pointsToAdd points. New balance: $newPoints');
      notifyListeners();

      return updatedUser;
    } catch (e) {
      debugPrint('Error adding points: $e');
      return null;
    }
  }

  /// Redeem points for discount
  /// Returns tuple (updatedUser, discountAmount)
  Future<RedemptionResult?> redeemPoints({
    required UserModel user,
    required int pointsToRedeem,
  }) async {
    try {
      // Validate points
      if (pointsToRedeem < pointsForDiscount) {
        debugPrint(
          '❌ Minimum $pointsForDiscount points required for redemption',
        );
        return null;
      }

      if (pointsToRedeem > user.loyaltyPoints) {
        debugPrint('❌ Insufficient points. Available: ${user.loyaltyPoints}');
        return null;
      }

      // Calculate discount (must be in multiples of 100)
      final pointsToUse =
          (pointsToRedeem / pointsForDiscount).floor() * pointsForDiscount;
      final discount = calculateDiscountFromPoints(pointsToUse);

      // Update user points
      final newPoints = user.loyaltyPoints - pointsToUse;
      final updatedUser = user.copyWith(loyaltyPoints: newPoints);

      // Save to storage
      await _authService.updateUserData(user.uid, {'loyaltyPoints': newPoints});

      debugPrint('💰 Redeemed $pointsToUse points for ₹$discount discount');
      notifyListeners();

      return RedemptionResult(
        updatedUser: updatedUser,
        discountAmount: discount,
        pointsRedeemed: pointsToUse,
      );
    } catch (e) {
      debugPrint('Error redeeming points: $e');
      return null;
    }
  }

  /// Check if user has enough points for minimum redemption
  bool canRedeem(int availablePoints) {
    return availablePoints >= pointsForDiscount;
  }

  /// Get loyalty tier based on total points earned
  String getLoyaltyTier(int totalPoints) {
    if (totalPoints >= 1000) return 'Platinum';
    if (totalPoints >= 500) return 'Gold';
    if (totalPoints >= 200) return 'Silver';
    return 'Bronze';
  }

  /// Get next tier requirement
  String getNextTierInfo(int currentPoints) {
    if (currentPoints < 200) {
      return 'Earn ${200 - currentPoints} more points to reach Silver tier';
    } else if (currentPoints < 500) {
      return 'Earn ${500 - currentPoints} more points to reach Gold tier';
    } else if (currentPoints < 1000) {
      return 'Earn ${1000 - currentPoints} more points to reach Platinum tier';
    }
    return 'You\'re at the highest tier!';
  }

  /// Reset service (for testing)
  void reset() {
    _usersWithBonus.clear();
    notifyListeners();
  }
}

/// Result of points redemption
class RedemptionResult {
  final UserModel updatedUser;
  final double discountAmount;
  final int pointsRedeemed;

  RedemptionResult({
    required this.updatedUser,
    required this.discountAmount,
    required this.pointsRedeemed,
  });
}
