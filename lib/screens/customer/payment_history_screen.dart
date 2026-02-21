import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/booking_service.dart';
import '../../providers/auth_provider.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userModel?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History'), elevation: 0),
      body: Consumer<BookingService>(
        builder: (context, bookingService, child) {
          final allBookings = bookingService.getUserBookings(userId);

          // Separate paid and unpaid
          final paidBookings = allBookings
              .where((b) => b.paymentStatus == 'paid')
              .toList();
          final unpaidBookings = allBookings
              .where(
                (b) =>
                    b.paymentStatus == 'unpaid' || b.paymentStatus == 'pending',
              )
              .toList();

          // Calculate totals
          final totalPaid = paidBookings.fold<double>(
            0,
            (sum, booking) => sum + booking.totalPrice,
          );
          final totalUnpaid = unpaidBookings.fold<double>(
            0,
            (sum, booking) => sum + booking.totalPrice,
          );

          if (allBookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payment history',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your payment records will appear here',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Total Paid',
                          '\$${totalPaid.toStringAsFixed(2)}',
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          context,
                          'Total Unpaid',
                          '\$${totalUnpaid.toStringAsFixed(2)}',
                          Colors.orange,
                          Icons.pending,
                        ),
                      ),
                    ],
                  ),
                ),

                // Paid Payments Section
                if (paidBookings.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Paid Payments',
                    paidBookings.length,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: paidBookings.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(
                        context,
                        paidBookings[index],
                        isPaid: true,
                      );
                    },
                  ),
                ],

                // Unpaid Payments Section
                if (unpaidBookings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader(
                    context,
                    'Pending Payments',
                    unpaidBookings.length,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: unpaidBookings.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(
                        context,
                        unpaidBookings[index],
                        isPaid: false,
                      );
                    },
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    AppointmentModel booking, {
    required bool isPaid,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPaid
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle : Icons.schedule,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.salonName,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Details
            _buildDetailRow(
              Icons.calendar_today,
              DateFormat('MMM dd, yyyy').format(booking.appointmentDate),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, booking.timeSlot),
            if (booking.stylistName != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.person, booking.stylistName!),
            ],
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.receipt,
              'Ref: #${booking.id.substring(0, 8)}',
            ),

            const SizedBox(height: 12),

            // Status Badges
            Row(
              children: [
                _buildStatusChip(
                  booking.status,
                  _getStatusColor(booking.status),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  isPaid ? 'Paid' : 'Unpaid',
                  isPaid ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in-progress':
        return Colors.purple;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
