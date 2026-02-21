import 'package:flutter/material.dart';
import '../services/pricing_service.dart';

class DynamicPriceDisplay extends StatelessWidget {
  final PricingResult pricing;
  final bool showDetails;
  final bool compact;

  const DynamicPriceDisplay({
    super.key,
    required this.pricing,
    this.showDetails = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView(context);
    }
    return _buildFullView(context);
  }

  Widget _buildCompactView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (pricing.hasDiscount || pricing.hasSurcharge) ...[
          Text(
            pricing.formattedBasePrice,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          pricing.formattedAdjustedPrice,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: pricing.hasDiscount
                ? Colors.green
                : pricing.hasSurcharge
                ? Colors.orange
                : null,
          ),
        ),
        if (pricing.priceChangeLabel.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: pricing.getLabelColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pricing.priceChangeLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: pricing.getLabelColor(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFullView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pricing.getLabelColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Label Badge
          Row(
            children: [
              Icon(
                pricing.getLabelIcon(),
                size: 18,
                color: pricing.getLabelColor(),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pricing.priceLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: pricing.getLabelColor(),
                  ),
                ),
              ),
              if (pricing.hasDiscount || pricing.hasSurcharge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pricing.getLabelColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pricing.priceChangeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: pricing.getLabelColor(),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Pricing Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pricing.hasDiscount || pricing.hasSurcharge) ...[
                      Text(
                        'Original Price',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        pricing.formattedBasePrice,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      pricing.hasDiscount || pricing.hasSurcharge
                          ? 'Adjusted Price'
                          : 'Price',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      pricing.formattedAdjustedPrice,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: pricing.hasDiscount
                            ? Colors.green
                            : pricing.hasSurcharge
                            ? Colors.orange.shade700
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (pricing.hasDiscount)
                      Text(
                        'You save ${pricing.formattedSavings}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Applied Discounts/Charges
          if (showDetails && pricing.appliedDiscounts.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Applied Adjustments:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            ...pricing.appliedDiscounts.map(
              (discount) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: pricing.getLabelColor(),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        discount,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Demand Info
          if (showDetails) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Demand: ${pricing.demandLevel}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${pricing.recentBookingCount} recent bookings)',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
