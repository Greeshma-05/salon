import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/loyalty_points_service.dart';

class RedeemLoyaltyDialog extends StatefulWidget {
  const RedeemLoyaltyDialog({Key? key}) : super(key: key);

  @override
  State<RedeemLoyaltyDialog> createState() => _RedeemLoyaltyDialogState();
}

class _RedeemLoyaltyDialogState extends State<RedeemLoyaltyDialog> {
  late int _pointsToRedeem;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    final loyaltyService = Provider.of<LoyaltyPointsService>(
      context,
      listen: false,
    );
    _pointsToRedeem = loyaltyService.availablePoints;
    _pointsController = TextEditingController(text: _pointsToRedeem.toString());
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  void _updatePointsToRedeem(String value) {
    final loyaltyService = Provider.of<LoyaltyPointsService>(
      context,
      listen: false,
    );

    if (value.isEmpty) {
      setState(() {
        _pointsToRedeem = 0;
      });
      return;
    }

    final points = int.tryParse(value) ?? 0;
    final maxPoints = loyaltyService.availablePoints;

    setState(() {
      _pointsToRedeem = points.clamp(0, maxPoints);
      _pointsController.text = _pointsToRedeem.toString();
    });
  }

  void _redeemPoints() async {
    final loyaltyService = Provider.of<LoyaltyPointsService>(
      context,
      listen: false,
    );

    if (_pointsToRedeem < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 100 points required')),
      );
      return;
    }

    try {
      final discountAmount = await loyaltyService.redeemPoints(_pointsToRedeem);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Redeemed $_pointsToRedeem points for ₹${discountAmount.toStringAsFixed(2)} discount!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoyaltyPointsService>(
      builder: (context, loyaltyService, _) {
        final availablePoints = loyaltyService.availablePoints;
        final discountAmount = (_pointsToRedeem / 100) * 100;

        return AlertDialog(
          title: const Text('Redeem Loyalty Points'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Points:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$availablePoints',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Redeeming:',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$_pointsToRedeem points',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Points Input
                TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  onChanged: _updatePointsToRedeem,
                  decoration: InputDecoration(
                    labelText: 'Points to Redeem',
                    hintText: 'Min. 100 points',
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        _pointsController.text = availablePoints.toString();
                        _updatePointsToRedeem(availablePoints.toString());
                      },
                      child: const Text('Max'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Discount Calculation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Discount',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${discountAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.discount, color: Colors.green[700], size: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Redemption Rules
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Redemption Terms',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildTermsItem('✓ Minimum 100 points required'),
                      _buildTermsItem('✓ 100 points = ₹100 discount'),
                      _buildTermsItem(
                        '✓ Discount applies to your next booking',
                      ),
                      _buildTermsItem('✓ Cannot combine multiple discounts'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _pointsToRedeem >= 100 ? _redeemPoints : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Redeem Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTermsItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
      ),
    );
  }
}
