# Loyalty Points System - Implementation Guide

## Overview
Complete loyalty points system integrated into the customer front page with earning, redemption, and discount features.

## Components Created

### 1. **Loyalty Points Service** (`lib/services/loyalty_points_service.dart`)
Core service managing all loyalty point operations.

**Key Features:**
- Point earning from payments (1 point per ₹1)
- Referral bonuses (50 points)
- Review rewards (25 points)
- Point redemption with discount calculation
- Transaction history tracking
- Expiry management (365 days)
- LocalStorage persistence via SharedPreferences

**Constants:**
```dart
POINTS_PER_RUPEE = 1           // Earn rate
POINTS_PER_REFERRAL = 50       // Referral bonus
POINTS_PER_REVIEW = 25         // Review bonus
REDEMPTION_RATE = 100          // 100 points = ₹100 discount
MIN_POINTS_TO_REDEEM = 100     // Minimum for redemption
POINTS_EXPIRY_DAYS = 365       // Expiration period
```

**Main Methods:**
- `earnPointsFromPayment(amount, bookingId)` - Earn from bookings
- `earnReferralPoints(userId)` - Referral bonuses
- `earnReviewPoints(salonId)` - Review rewards
- `redeemPoints(pointsToRedeem)` - Convert to discount
- `getTransactionsByType(type)` - Filter transactions
- `getPointsBreakdown()` - Summary analytics

### 2. **Loyalty Home Widget** (`lib/screens/customer/loyalty_points_home_widget.dart`)
Beautiful gradient card displayed on customer home screen.

**Features:**
- Live points balance display
- Potential discount calculation
- Redemption status indicator
- Quick redeem button
- Earning rules showcase (Payment, Referral, Review)
- Tappable history navigation

**UI Elements:**
- Primary color gradient background
- Available points counter
- Potential discount value
- Status badge (Ready/Not Ready)
- Earning breakdown with icons
- Action button to redeem

### 3. **Redeem Loyalty Dialog** (`lib/screens/customer/redeem_loyalty_dialog.dart`)
Interactive dialog for redeeming points.

**Features:**
- Available points summary
- Custom points input
- Real-time discount calculation
- "Max" button for full balance
- Redemption terms display
- Confirmation action

**Validation:**
- Minimum 100 points required
- Cannot exceed available balance
- Live preview of discount amount

### 4. **Loyalty Points Details Screen** (`lib/screens/customer/loyalty_points_details_screen.dart`)
Comprehensive details page with three tabs.

**Tabs:**
1. **Overview**
   - Total available points display
   - Points breakdown (Earned/Redeemed/Expired)
   - Recent activity preview
   - Visual cards for each metric

2. **History**
   - Complete transaction log
   - Sorted by date (newest first)
   - Transaction type indicators
   - Points change visualization

3. **Rules**
   - How to Earn Points (Payments, Referrals, Reviews)
   - How to Redeem (Minimum, Rate, Application)
   - Important Terms (Expiry, Non-transferable, Cancellation)

## Integration

### Registration in Provider

Added to `lib/main.dart`:
```dart
ChangeNotifierProvider(create: (_) => LoyaltyPointsService()),
```

### Display on Home Screen

Integrated into `lib/screens/customer/salons_list_screen.dart`:
```dart
const LoyaltyPointsHomeWidget(),
```

Displays between Nearby Salons and All Salons sections.

## Usage Examples

### Earning Points from Payment
```dart
final loyaltyService = Provider.of<LoyaltyPointsService>(context, listen: false);

// After successful booking payment
await loyaltyService.earnPointsFromPayment(
  499.99,  // Amount paid
  'booking_123',  // Booking ID
);
// Result: 499 points earned
```

### Earning from Referral
```dart
await loyaltyService.earnReferralPoints('user_456');
// Result: 50 points earned
```

### Earning from Review
```dart
await loyaltyService.earnReviewPoints('salon_789');
// Result: 25 points earned
```

### Redeeming Points
```dart
try {
  final discountAmount = await loyaltyService.redeemPoints(200);
  // discountAmount = ₹200
  print('Redeemed for ₹$discountAmount discount');
} catch (e) {
  print('Error: $e');
}
```

## Point Calculation Examples

| Scenario | Calculation | Points |
|----------|-------------|--------|
| Pay ₹100 | 100 × 1 | 100 |
| Pay ₹2,500 | 2500 × 1 | 2,500 |
| Referral | Fixed | 50 |
| Review | Fixed | 25 |
| Redeem 200 pts | 200 ÷ 100 × ₹100 | ₹200 discount |
| Redeem 550 pts | 550 ÷ 100 × ₹100 | ₹550 discount |

## Data Persistence

Points data stored in SharedPreferences:
- `loyalty_total_points` - Total earned points
- `loyalty_redeemed_points` - Points redeemed for discounts
- `loyalty_transactions` - JSON array of all transactions

**Transaction Format:**
```json
{
  "id": "1234567890",
  "type": "earned",
  "points": 500,
  "description": "Payment of ₹500.00",
  "date": "2026-02-21T10:30:00.000Z",
  "relatedBookingId": "booking_123"
}
```

## Conditions & Rules

### Earning Conditions
✓ Points earned immediately after successful payment  
✓ Referral points awarded when referred customer completes first booking  
✓ Review points awarded upon review submission  
✓ Points calculated based on actual amount spent (to 2 decimal places)

### Redemption Conditions
✓ Minimum 100 points required  
✓ Conversion: 100 points = ₹100 discount  
✓ Can redeem partial balance  
✓ Discount applied during checkout  
✓ One discount per booking (cannot combine)

### Expiry Conditions
✓ Points expire after 365 days of earning  
✓ Expired points removed automatically on app startup  
✓ Redeemed points not subject to expiry  
✓ Users notified of expiring points

## Frontend Features

### Home Screen Widget
- **Position:** After Nearby Salons section
- **Colors:** Gradient (Primary → Primary 70%)
- **Height:** ~300px
- **Actions:** History link, Redeem button

### Details Screen
- **Tabs:** 3 (Overview, History, Rules)
- **Data:** Real-time from service
- **Navigation:** Via History link in widget
- **Refresh:** Auto-updates with Provider changes

## Backend Integration Notes

For Firebase integration (optional):
```dart
// Future: Sync with Firestore
await firestore
  .collection('users')
  .doc(userId)
  .update({
    'loyaltyPoints': totalPoints,
    'transactions': transactions,
  });
```

## Testing Scenarios

### Scenario 1: New Customer
1. User opens app
2. No points initially (0 available)
3. Widget shows "Earn 100 more points to redeem"
4. Redeem button disabled

### Scenario 2: After Payment
1. Customer pays ₹500 for booking
2. ✅ 500 points credited instantly
3. Widget updates to show 500 available
4. Redeem button enabled (≥100 points)

### Scenario 3: Redemption
1. Customer has 500 points available
2. Clicks "Redeem Points Now"
3. Dialog opens with 500 prefilled
4. Shows "Potential Discount: ₹500"
5. User confirms
6. ✅ Points redeemed
7. Available balance: 0
8. Discount ready for next booking

### Scenario 4: Referral + Review
1. User refers friend (50 points)
2. User writes review (25 points)
3. Total: 75 points
4. Status: "Earn 25 more points to redeem"

## Customization

### Change Earning Rate
Update in `loyalty_points_service.dart`:
```dart
static const int POINTS_PER_RUPEE = 2; // Change from 1 to 2
```

### Change Redemption Rate
```dart
static const int REDEMPTION_RATE = 50; // 50 points = ₹100 discount
```

### Change Minimum Points
```dart
static const int MIN_POINTS_TO_REDEEM = 50; // Change from 100
```

### Change Expiry Period
```dart
static const int POINTS_EXPIRY_DAYS = 180; // Change from 365 days
```

## Future Enhancements

1. **Tiered Loyalty Program**
   - Silver (0-500 pts): 1x points
   - Gold (501-2000 pts): 1.5x points
   - Platinum (2001+ pts): 2x points

2. **Seasonal Bonuses**
   - Double points on special dates
   - Festival offers

3. **Leaderboard**
   - Top customers by points
   - Monthly achievements

4. **Point Gifting**
   - Send points to friends
   - Gift redemption codes

5. **Analytics Dashboard**
   - Points trend chart
   - Earning/redemption patterns
   - Expiry notifications

## Files Summary

| File | Purpose | Lines |
|------|---------|-------|
| `loyalty_points_service.dart` | Core logic & persistence | ~400 |
| `loyalty_points_home_widget.dart` | Home page display | ~250 |
| `redeem_loyalty_dialog.dart` | Redemption UI | ~200 |
| `loyalty_points_details_screen.dart` | History & rules | ~400 |

**Total: ~1,250 lines of code**

## API Documentation

### LoyaltyPointsService Methods

#### Earning
```dart
Future<void> earnPointsFromPayment(double amount, String bookingId)
Future<void> earnReferralPoints(String referredUserId)
Future<void> earnReviewPoints(String salonId)
```

#### Redemption
```dart
Future<double> redeemPoints(int pointsToRedeem)
Future<void> cancelRedemption(String transactionId)
```

#### Queries
```dart
List<LoyaltyTransaction> getTransactionsByType(String type)
List<LoyaltyTransaction> getRecentTransactions({int limit = 10})
Map<String, dynamic> getPointsBreakdown()
```

#### Admin
```dart
Future<void> resetPoints()
void _cleanupExpiredPoints()
```

## Support & Troubleshooting

**Q: Points not showing?**  
A: Check SharedPreferences data. Run `loyaltyService.loadLoyaltyData()` manually.

**Q: Redemption fails?**  
A: Ensure points ≥ 100. Check error message in catch block.

**Q: Points disappeared?**  
A: May have expired after 365 days. Check transaction history for 'expired' type entries.

**Q: How to give bonus points?**  
A: Use `earnPointsFromPayment(bonus, 'admin_gift')` or direct increment of `_totalPoints`.
