import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/loyalty_points_service.dart';

class LoyaltyPointsDetailsScreen extends StatefulWidget {
  const LoyaltyPointsDetailsScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyPointsDetailsScreen> createState() =>
      _LoyaltyPointsDetailsScreenState();
}

class _LoyaltyPointsDetailsScreenState extends State<LoyaltyPointsDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Points Details'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Rules'),
          ],
        ),
      ),
      body: Consumer<LoyaltyPointsService>(
        builder: (context, loyaltyService, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, loyaltyService),
              _buildHistoryTab(context, loyaltyService),
              _buildRulesTab(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    LoyaltyPointsService loyaltyService,
  ) {
    final breakdown = loyaltyService.getPointsBreakdown();
    final totalEarned = breakdown['earned'] as int;
    final totalRedeemed = breakdown['redeemed'] as int;
    final totalExpired = breakdown['expired'] as int;
    final available = breakdown['available'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Points Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total Available Points',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '$available',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Worth ₹${(available / 100 * 100).toStringAsFixed(2)} in discounts',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Breakdown Grid
          Text(
            'Points Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildBreakdownCard(
                context,
                'Earned',
                totalEarned.toString(),
                Colors.green,
                Icons.add_circle_outline,
              ),
              _buildBreakdownCard(
                context,
                'Redeemed',
                totalRedeemed.toString(),
                Colors.blue,
                Icons.shopping_bag_outlined,
              ),
              _buildBreakdownCard(
                context,
                'Expired',
                totalExpired.toString(),
                Colors.red,
                Icons.timer_off_outlined,
              ),
              _buildBreakdownCard(
                context,
                'Available',
                available.toString(),
                Colors.purple,
                Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Activity
          if (loyaltyService.getRecentTransactions(limit: 3).isNotEmpty) ...[
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...loyaltyService
                .getRecentTransactions(limit: 3)
                .map(
                  (transaction) => _buildTransactionTile(context, transaction),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    LoyaltyPointsService loyaltyService,
  ) {
    final transactions = loyaltyService.getRecentTransactions(limit: 100);

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transaction history',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) =>
          _buildTransactionTile(context, transactions[index]),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    LoyaltyTransaction transaction,
  ) {
    late Color color;
    late IconData icon;
    late String typeLabel;

    switch (transaction.type) {
      case 'earned':
        color = Colors.green;
        icon = Icons.add_circle_outline;
        typeLabel = 'Earned';
        break;
      case 'redeemed':
        color = Colors.blue;
        icon = Icons.shopping_bag_outlined;
        typeLabel = 'Redeemed';
        break;
      case 'expired':
        color = Colors.red;
        icon = Icons.timer_off_outlined;
        typeLabel = 'Expired';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        typeLabel = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.description),
        subtitle: Text(
          'on ${transaction.date.toString().split('.')[0]}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.type == 'earned' ? '+' : '-'}${transaction.points}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              typeLabel,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleSection(context, '💳 How to Earn Points', [
            const RuleItem(
              title: 'From Payments',
              description: 'Earn 1 point for every ₹1 you spend on services',
            ),
            const RuleItem(
              title: 'Referrals',
              description:
                  'Get 50 points when someone you refer books a service',
            ),
            const RuleItem(
              title: 'Reviews',
              description: 'Earn 25 points for writing a review on any salon',
            ),
          ]),
          const SizedBox(height: 20),
          _buildRuleSection(context, '🎁 How to Redeem', [
            const RuleItem(
              title: 'Minimum Points',
              description: 'You need at least 100 points to redeem',
            ),
            const RuleItem(
              title: 'Conversion Rate',
              description: '100 points = ₹100 discount on your next booking',
            ),
            const RuleItem(
              title: 'Discount Application',
              description:
                  'Discounts are automatically applied during checkout',
            ),
          ]),
          const SizedBox(height: 20),
          _buildRuleSection(context, '⏰ Important Terms', [
            const RuleItem(
              title: 'Points Expiry',
              description: 'Unused points expire after 365 days',
            ),
            const RuleItem(
              title: 'Non-Transferable',
              description: 'Points cannot be transferred to other users',
            ),
            const RuleItem(
              title: 'Cancellation',
              description: 'Cancellations may result in loss of earned points',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildRuleSection(
    BuildContext context,
    String title,
    List<RuleItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  item.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
              if (items.last != item)
                Divider(color: Colors.grey[300], height: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class RuleItem {
  final String title;
  final String description;

  const RuleItem({required this.title, required this.description});
}
