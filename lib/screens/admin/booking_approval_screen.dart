import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/booking_service.dart';
import '../../services/notification_service.dart';

class BookingApprovalScreen extends StatefulWidget {
  const BookingApprovalScreen({super.key});

  @override
  State<BookingApprovalScreen> createState() => _BookingApprovalScreenState();
}

class _BookingApprovalScreenState extends State<BookingApprovalScreen> {
  String _selectedFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Approvals')),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Consumer<BookingService>(
              builder: (context, bookingService, _) {
                final bookings = _getFilteredBookings(bookingService);

                if (bookings.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    return _buildBookingCard(bookings[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Pending', 'pending', Icons.pending_actions),
            const SizedBox(width: 8),
            _buildFilterChip('Approved', 'approved', Icons.check_circle),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected', Icons.cancel),
            const SizedBox(width: 8),
            _buildFilterChip('All', 'all', Icons.list),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 4), Text(label)],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  List<AppointmentModel> _getFilteredBookings(BookingService service) {
    final allBookings = service.getAllBookings();

    switch (_selectedFilter) {
      case 'pending':
        return allBookings.where((b) => b.approvalStatus == 'pending').toList();
      case 'approved':
        return allBookings
            .where((b) => b.approvalStatus == 'approved')
            .toList();
      case 'rejected':
        return allBookings
            .where((b) => b.approvalStatus == 'rejected')
            .toList();
      case 'all':
      default:
        return allBookings;
    }
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;

    switch (_selectedFilter) {
      case 'pending':
        message = 'No pending approvals';
        icon = Icons.check_circle_outline;
        break;
      case 'approved':
        message = 'No approved bookings';
        icon = Icons.event_available;
        break;
      case 'rejected':
        message = 'No rejected bookings';
        icon = Icons.event_busy;
        break;
      default:
        message = 'No bookings yet';
        icon = Icons.calendar_today;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(AppointmentModel booking) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final Color statusColor;
    final IconData statusIcon;
    final String statusText;

    switch (booking.approvalStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.customerPhone,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.content_cut, 'Service', booking.serviceName),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.person,
              'Stylist',
              booking.stylistName ?? 'Not assigned',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              dateFormat.format(booking.appointmentDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.access_time, 'Time', booking.timeSlot),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.attach_money,
              'Price',
              '\$${booking.totalPrice.toStringAsFixed(2)}',
            ),
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'Notes', booking.notes!),
            ],
            if (booking.approvalStatus == 'pending') ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectBooking(booking),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _approveBooking(booking),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _approveBooking(AppointmentModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Booking'),
        content: Text('Approve booking for ${booking.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final bookingService = Provider.of<BookingService>(
                context,
                listen: false,
              );
              final notificationService = Provider.of<NotificationService>(
                context,
                listen: false,
              );

              // Approve the booking
              final success = bookingService.approveBooking(booking.id);

              if (success) {
                // Send approval notification
                notificationService.sendBookingApprovalNotification(
                  booking,
                  approved: true,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking approved for ${booking.customerName}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectBooking(AppointmentModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Text(
          'Reject booking for ${booking.customerName}? The time slot will become available again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final bookingService = Provider.of<BookingService>(
                context,
                listen: false,
              );
              final notificationService = Provider.of<NotificationService>(
                context,
                listen: false,
              );

              // Reject the booking
              final success = bookingService.rejectBooking(booking.id);

              if (success) {
                // Send rejection notification
                notificationService.sendBookingApprovalNotification(
                  booking,
                  approved: false,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking rejected for ${booking.customerName}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
