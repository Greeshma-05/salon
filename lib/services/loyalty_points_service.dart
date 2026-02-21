import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Model for loyalty points transaction
class LoyaltyTransaction {
  final String id;
  final String type; // 'earned', 'redeemed', 'expired'
  final int points;
  final String description;
  final DateTime date;
  final String? relatedBookingId;

  LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.date,
    this.relatedBookingId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'points': points,
      'description': description,
      'date': date.toIso8601String(),
      'relatedBookingId': relatedBookingId,
    };
  }

  factory LoyaltyTransaction.fromMap(Map<String, dynamic> map) {
    return LoyaltyTransaction(
      id: map['id'] ?? '',
      type: map['type'] ?? 'earned',
      points: map['points'] ?? 0,
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      relatedBookingId: map['relatedBookingId'],
    );
  }
}

/// Service to manage loyalty points
class LoyaltyPointsService extends ChangeNotifier {
  static final LoyaltyPointsService _instance =
      LoyaltyPointsService._internal();

  factory LoyaltyPointsService() => _instance;

  LoyaltyPointsService._internal() {
    _loadLoyaltyData();
  }

  late SharedPreferences _prefs;
  int _totalPoints = 0;
  int _redeemedPoints = 0;
  List<LoyaltyTransaction> _transactions = [];

  // Loyalty Rules
  static const int POINTS_PER_RUPEE = 1; // 1 point per ₹1 spent
  static const int POINTS_PER_REFERRAL = 50; // 50 points for referral
  static const int POINTS_PER_REVIEW = 25; // 25 points for review
  static const int REDEMPTION_RATE = 100; // 100 points = ₹100 discount
  static const int MIN_POINTS_TO_REDEEM = 100;
  static const int POINTS_EXPIRY_DAYS = 365; // Points expire after 1 year

  // Getters
  int get totalPoints => _totalPoints;
  int get availablePoints => _totalPoints - _redeemedPoints;
  int get redeemedPoints => _redeemedPoints;
  List<LoyaltyTransaction> get transactions => _transactions;

  double get discountAmount => (availablePoints / REDEMPTION_RATE) * 100;

  String get pointsStatus {
    if (availablePoints < MIN_POINTS_TO_REDEEM) {
      return 'Earn ${MIN_POINTS_TO_REDEEM - availablePoints} more points to redeem';
    }
    return 'Ready to redeem!';
  }

  /// Load loyalty data from storage
  Future<void> _loadLoyaltyData() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _totalPoints = _prefs.getInt('loyalty_total_points') ?? 0;
      _redeemedPoints = _prefs.getInt('loyalty_redeemed_points') ?? 0;

      final transactionsJson =
          _prefs.getStringList('loyalty_transactions') ?? [];
      _transactions = transactionsJson
          .map((t) => LoyaltyTransaction.fromMap(jsonDecode(t)))
          .toList();

      // Clean up expired points
      _cleanupExpiredPoints();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading loyalty data: $e');
    }
  }

  /// Save loyalty data to storage
  Future<void> _saveLoyaltyData() async {
    try {
      await _prefs.setInt('loyalty_total_points', _totalPoints);
      await _prefs.setInt('loyalty_redeemed_points', _redeemedPoints);

      final transactionsJson = _transactions
          .map((t) => jsonEncode(t.toMap()))
          .toList();
      await _prefs.setStringList('loyalty_transactions', transactionsJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving loyalty data: $e');
    }
  }

  /// Earn points from payment
  /// Formula: ₹amount × POINTS_PER_RUPEE (1 point per rupee)
  Future<void> earnPointsFromPayment(double amount, String bookingId) async {
    try {
      final pointsEarned = (amount * POINTS_PER_RUPEE).toInt();
      _totalPoints += pointsEarned;

      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'earned',
        points: pointsEarned,
        description: 'Payment of ₹${amount.toStringAsFixed(2)}',
        date: DateTime.now(),
        relatedBookingId: bookingId,
      );

      _transactions.add(transaction);
      await _saveLoyaltyData();
      debugPrint('✅ Earned $pointsEarned points from booking $bookingId');
    } catch (e) {
      debugPrint('Error earning points: $e');
    }
  }

  /// Earn points from referral
  Future<void> earnReferralPoints(String referredUserId) async {
    try {
      _totalPoints += POINTS_PER_REFERRAL;

      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'earned',
        points: POINTS_PER_REFERRAL,
        description: 'Referral bonus for user: $referredUserId',
        date: DateTime.now(),
      );

      _transactions.add(transaction);
      await _saveLoyaltyData();
      debugPrint('✅ Earned $POINTS_PER_REFERRAL referral points');
    } catch (e) {
      debugPrint('Error earning referral points: $e');
    }
  }

  /// Earn points from review
  Future<void> earnReviewPoints(String salonId) async {
    try {
      _totalPoints += POINTS_PER_REVIEW;

      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'earned',
        points: POINTS_PER_REVIEW,
        description: 'Review bonus for salon: $salonId',
        date: DateTime.now(),
      );

      _transactions.add(transaction);
      await _saveLoyaltyData();
      debugPrint('✅ Earned $POINTS_PER_REVIEW review points');
    } catch (e) {
      debugPrint('Error earning review points: $e');
    }
  }

  /// Redeem points for discount
  /// Returns discount amount in rupees
  Future<double> redeemPoints(int pointsToRedeem) async {
    try {
      if (pointsToRedeem < MIN_POINTS_TO_REDEEM) {
        throw Exception(
          'Minimum $MIN_POINTS_TO_REDEEM points required to redeem',
        );
      }

      if (pointsToRedeem > availablePoints) {
        throw Exception('Insufficient points. Available: $availablePoints');
      }

      final discountAmount = (pointsToRedeem / REDEMPTION_RATE) * 100;
      _redeemedPoints += pointsToRedeem;

      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'redeemed',
        points: pointsToRedeem,
        description:
            'Redeemed for ₹${discountAmount.toStringAsFixed(2)} discount',
        date: DateTime.now(),
      );

      _transactions.add(transaction);
      await _saveLoyaltyData();
      debugPrint(
        '✅ Redeemed $pointsToRedeem points for ₹${discountAmount.toStringAsFixed(2)} discount',
      );
      return discountAmount;
    } catch (e) {
      debugPrint('Error redeeming points: $e');
      rethrow;
    }
  }

  /// Cancel redemption (restore points)
  Future<void> cancelRedemption(String transactionId) async {
    try {
      final transaction = _transactions.firstWhere(
        (t) => t.id == transactionId && t.type == 'redeemed',
      );

      _redeemedPoints -= transaction.points;
      _transactions.removeWhere((t) => t.id == transactionId);

      await _saveLoyaltyData();
      debugPrint(
        '✅ Cancelled redemption, restored ${transaction.points} points',
      );
    } catch (e) {
      debugPrint('Error cancelling redemption: $e');
      rethrow;
    }
  }

  /// Clean up expired points
  void _cleanupExpiredPoints() {
    final now = DateTime.now();
    final expiredTransactions = _transactions
        .where(
          (t) =>
              t.type == 'earned' &&
              now.difference(t.date).inDays > POINTS_EXPIRY_DAYS,
        )
        .toList();

    for (final transaction in expiredTransactions) {
      _totalPoints -= transaction.points;
      _transactions.removeWhere((t) => t.id == transaction.id);

      final expiredTransaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'expired',
        points: transaction.points,
        description: 'Points expired from: ${transaction.description}',
        date: DateTime.now(),
      );

      _transactions.add(expiredTransaction);
    }

    if (expiredTransactions.isNotEmpty) {
      _saveLoyaltyData();
      debugPrint(
        '✅ Cleaned up ${expiredTransactions.length} expired transactions',
      );
    }
  }

  /// Get transaction history
  List<LoyaltyTransaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Get recent transactions
  List<LoyaltyTransaction> getRecentTransactions({int limit = 10}) {
    final sorted = _transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  /// Calculate points breakdown
  Map<String, dynamic> getPointsBreakdown() {
    int earnedTotal = 0;
    int redeemedTotal = 0;
    int expiredTotal = 0;

    for (final transaction in _transactions) {
      if (transaction.type == 'earned') {
        earnedTotal += transaction.points;
      } else if (transaction.type == 'redeemed') {
        redeemedTotal += transaction.points;
      } else if (transaction.type == 'expired') {
        expiredTotal += transaction.points;
      }
    }

    return {
      'earned': earnedTotal,
      'redeemed': redeemedTotal,
      'expired': expiredTotal,
      'available': availablePoints,
      'total': totalPoints,
    };
  }

  /// Reset all points (for testing/admin only)
  Future<void> resetPoints() async {
    try {
      _totalPoints = 0;
      _redeemedPoints = 0;
      _transactions.clear();
      await _saveLoyaltyData();
      debugPrint('✅ Points reset');
    } catch (e) {
      debugPrint('Error resetting points: $e');
    }
  }
}
