import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/booking_service.dart';
import '../../providers/auth_provider.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userModel?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings'), elevation: 0),
      body: Consumer<BookingService>(
        builder: (context, bookingService, child) {
          final bookings = bookingService.getUserBookings(userId);

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your booking history will appear here',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(context, booking, bookingService);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    AppointmentModel booking,
    BookingService bookingService,
  ) {
    final isPast = booking.appointmentDate.isBefore(DateTime.now());
    final isPaid = booking.paymentStatus == 'paid';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with service name and status badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.salonName,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                _buildPaymentBadge(isPaid),
              ],
            ),
            const Divider(height: 24),

            // Booking details
            _buildDetailRow(
              Icons.calendar_today,
              DateFormat('EEE, MMM dd, yyyy').format(booking.appointmentDate),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time, booking.timeSlot),
            if (booking.stylistName != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.person, booking.stylistName!),
            ],
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.attach_money,
              '\$${booking.totalPrice.toStringAsFixed(2)}',
            ),

            // Cancel button for upcoming bookings
            if (!isPast && booking.status != 'cancelled') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _confirmCancellation(context, booking, bookingService),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Booking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            size: 12,
            color: isPaid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancellation(
    BuildContext context,
    AppointmentModel booking,
    BookingService bookingService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: Text(
          'Are you sure you want to cancel your appointment for ${booking.serviceName} on ${DateFormat('MMM dd, yyyy').format(booking.appointmentDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep It'),
          ),
          FilledButton(
            onPressed: () {
              final success = bookingService.cancelBooking(booking.id);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Booking cancelled successfully'
                        : 'Failed to cancel booking',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
