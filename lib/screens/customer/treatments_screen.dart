import 'package:flutter/material.dart';
import '../../models/treatment.dart';
import '../../services/treatment_service.dart';

class TreatmentsScreen extends StatefulWidget {
  const TreatmentsScreen({super.key});

  @override
  State<TreatmentsScreen> createState() => _TreatmentsScreenState();
}

class _TreatmentsScreenState extends State<TreatmentsScreen> {
  final TreatmentService _treatmentService = TreatmentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Treatments'), elevation: 0),
      body: StreamBuilder<List<Treatment>>(
        stream: _treatmentService.treatmentsStream,
        builder: (context, snapshot) {
          // Get all treatments
          final treatments = _treatmentService.getAllTreatments();

          if (treatments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No treatments available'),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: treatments.length,
            itemBuilder: (context, index) {
              final treatment = treatments[index];
              return _buildTreatmentCard(treatment);
            },
          );
        },
      ),
    );
  }

  Widget _buildTreatmentCard(Treatment treatment) {
    final isAvailable = treatment.isAvailable;

    return Card(
      elevation: isAvailable ? 2 : 0,
      color: isAvailable ? null : Colors.grey[200],
      child: InkWell(
        onTap: isAvailable
            ? () {
                _showTreatmentDetails(treatment);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTreatmentIcon(treatment.name),
                  color: isAvailable
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[500],
                  size: 28,
                ),
              ),

              const SizedBox(height: 12),

              // Treatment Name
              Text(
                treatment.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? null : Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Availability Status
              if (!isAvailable) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.block, size: 12, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Currently Unavailable',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Price
              Text(
                '\$${treatment.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isAvailable
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
              ),

              // Availability Indicator
              if (isAvailable)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Available Now',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTreatmentDetails(Treatment treatment) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTreatmentIcon(treatment.name),
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treatment.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${treatment.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Available Now',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking ${treatment.name}...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Book Treatment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTreatmentIcon(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('hair')) {
      return Icons.content_cut;
    } else if (nameLower.contains('makeup') || nameLower.contains('bridal')) {
      return Icons.face;
    } else if (nameLower.contains('facial') || nameLower.contains('aging')) {
      return Icons.face_retouching_natural;
    } else if (nameLower.contains('massage')) {
      return Icons.spa;
    } else if (nameLower.contains('nail')) {
      return Icons.back_hand;
    } else if (nameLower.contains('tan')) {
      return Icons.wb_sunny;
    } else if (nameLower.contains('color')) {
      return Icons.color_lens;
    } else if (nameLower.contains('keratin')) {
      return Icons.auto_awesome;
    } else {
      return Icons.healing;
    }
  }
}
