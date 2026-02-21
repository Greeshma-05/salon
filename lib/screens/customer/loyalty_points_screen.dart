import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/loyalty_service.dart';

class LoyaltyPointsScreen extends StatefulWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  State<LoyaltyPointsScreen> createState() => _LoyaltyPointsScreenState();
}

class _LoyaltyPointsScreenState extends State<LoyaltyPointsScreen> {
  final LoyaltyService _loyaltyService = LoyaltyService();
  final TextEditingController _pointsController = TextEditingController();
  bool _isRedeeming = false;

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view loyalty points')),
      );
    }

    final currentPoints = _loyaltyService.getCurrentPoints(user);
    final canRedeem = _loyaltyService.canRedeem(currentPoints);
    final tier = _loyaltyService.getLoyaltyTier(currentPoints);
    final nextTierInfo = _loyaltyService.getNextTierInfo(currentPoints);

    return Scaffold(
      appBar: AppBar(title: const Text('Loyalty Points'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Points Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Points Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currentPoints',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '≈ ₹${_loyaltyService.calculateDiscountFromPoints(currentPoints).toStringAsFixed(0)} discount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$tier Member',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // How it Works
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How It Works',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.shopping_bag,
                    title: 'Earn Points',
                    description: 'Get 10 points for every ₹500 spent',
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.card_giftcard,
                    title: 'First Booking Bonus',
                    description: 'Earn 50 bonus points on your first booking',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.discount,
                    title: 'Redeem Rewards',
                    description: '100 points = ₹50 discount on next booking',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 24),

                  // Tier Progress
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tier Progress',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(nextTierInfo),
                          const SizedBox(height: 12),
                          _buildTierBadge('Bronze', currentPoints >= 0),
                          _buildTierBadge('Silver', currentPoints >= 200),
                          _buildTierBadge('Gold', currentPoints >= 500),
                          _buildTierBadge('Platinum', currentPoints >= 1000),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Redeem Section
                  if (canRedeem) ...[
                    Text(
                      'Redeem Points',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter points to redeem (minimum 100):',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _pointsController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'e.g., 100, 200, 300...',
                                prefixIcon: const Icon(Icons.stars),
                                suffixText: 'points',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isRedeeming ? null : _redeemPoints,
                                icon: _isRedeeming
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.redeem),
                                label: Text(
                                  _isRedeeming
                                      ? 'Redeeming...'
                                      : 'Redeem Points',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You need at least 100 points to redeem. Keep shopping to earn more!',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildTierBadge(String tier, bool achieved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            color: achieved ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            tier,
            style: TextStyle(
              color: achieved ? Colors.black : Colors.grey,
              fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _redeemPoints() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) return;

    final pointsText = _pointsController.text.trim();
    if (pointsText.isEmpty) {
      _showError('Please enter points to redeem');
      return;
    }

    final points = int.tryParse(pointsText);
    if (points == null || points < 100) {
      _showError('Minimum 100 points required');
      return;
    }

    if (points % 100 != 0) {
      _showError('Points must be in multiples of 100');
      return;
    }

    if (points > user.loyaltyPoints) {
      _showError('Insufficient points. You have ${user.loyaltyPoints} points');
      return;
    }

    setState(() => _isRedeeming = true);

    final result = await _loyaltyService.redeemPoints(
      user: user,
      pointsToRedeem: points,
    );

    setState(() => _isRedeeming = false);

    if (result != null) {
      // Update auth provider with new user data
      await authProvider.refreshUser();

      if (mounted) {
        _pointsController.clear();
        _showSuccessDialog(result);
      }
    } else {
      _showError('Failed to redeem points. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessDialog(RedemptionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Points Redeemed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '₹${result.discountAmount.toStringAsFixed(0)} discount credited',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Points used: ${result.pointsRedeemed}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining: ${result.updatedUser.loyaltyPoints} points',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Great!'),
            ),
          ),
        ],
      ),
    );
  }
}
