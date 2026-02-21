import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';

enum AppointmentFilter { all, today, thisWeek, completed, pendingApproval }

class CustomerAppointmentDetailsScreen extends StatefulWidget {
  const CustomerAppointmentDetailsScreen({super.key});

  @override
  State<CustomerAppointmentDetailsScreen> createState() =>
      _CustomerAppointmentDetailsScreenState();
}

class _CustomerAppointmentDetailsScreenState
    extends State<CustomerAppointmentDetailsScreen> {
  AppointmentFilter _selectedFilter = AppointmentFilter.all;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Appointments')),
        body: const Center(child: Text('Please login to view appointments')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Appointments List
          Expanded(
            child: Consumer<BookingService>(
              builder: (context, bookingService, _) {
                final allAppointments = bookingService.getUserBookings(
                  user.uid,
                );
                final filteredAppointments = _filterAppointments(
                  allAppointments,
                );

                if (filteredAppointments.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(
                      context,
                      filteredAppointments[index],
                    );
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('All', AppointmentFilter.all),
          const SizedBox(width: 8),
          _buildFilterChip('Today', AppointmentFilter.today),
          const SizedBox(width: 8),
          _buildFilterChip('This Week', AppointmentFilter.thisWeek),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', AppointmentFilter.completed),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', AppointmentFilter.pendingApproval),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AppointmentFilter filter) {
    final isSelected = _selectedFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Service Name & Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(appointment.status),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Customer Info
            _buildInfoRow(
              context,
              Icons.person,
              'Customer',
              appointment.customerName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.phone,
              'Phone',
              appointment.customerPhone,
            ),
            const SizedBox(height: 8),

            // Salon Info
            _buildInfoRow(context, Icons.store, 'Salon', appointment.salonName),
            const SizedBox(height: 8),

            // Stylist Info
            _buildInfoRow(
              context,
              Icons.face,
              'Stylist',
              appointment.stylistName,
            ),
            const SizedBox(height: 8),

            // Date & Time
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Date',
              DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.access_time,
              'Time',
              '${appointment.timeSlot} (${appointment.duration} mins)',
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Payment & Booking Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Status',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      _buildPaymentBadge(appointment.paymentStatus),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${appointment.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Notes if available
            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(appointment.notes, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case 'completed':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String paymentStatus) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            paymentStatus.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_selectedFilter) {
      case AppointmentFilter.today:
        message = 'No appointments today';
        break;
      case AppointmentFilter.thisWeek:
        message = 'No appointments this week';
        break;
      case AppointmentFilter.completed:
        message = 'No completed appointments';
        break;
      case AppointmentFilter.pendingApproval:
        message = 'No pending appointments';
        break;
      default:
        message = 'No appointments found';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Appointments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', AppointmentFilter.all),
            _buildFilterOption('Today', AppointmentFilter.today),
            _buildFilterOption('This Week', AppointmentFilter.thisWeek),
            _buildFilterOption('Completed', AppointmentFilter.completed),
            _buildFilterOption(
              'Pending Approval',
              AppointmentFilter.pendingApproval,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, AppointmentFilter filter) {
    return RadioListTile<AppointmentFilter>(
      title: Text(label),
      value: filter,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
        });
        Navigator.of(context).pop();
      },
    );
  }

  List<AppointmentModel> _filterAppointments(
    List<AppointmentModel> appointments,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(
      const Duration(days: 6, hours: 23, minutes: 59),
    );

    switch (_selectedFilter) {
      case AppointmentFilter.today:
        return appointments.where((apt) {
          final aptDate = DateTime(
            apt.appointmentDate.year,
            apt.appointmentDate.month,
            apt.appointmentDate.day,
          );
          return aptDate == today;
        }).toList();

      case AppointmentFilter.thisWeek:
        return appointments.where((apt) {
          return apt.appointmentDate.isAfter(weekStart) &&
              apt.appointmentDate.isBefore(weekEnd);
        }).toList();

      case AppointmentFilter.completed:
        return appointments
            .where((apt) => apt.status.toLowerCase() == 'completed')
            .toList();

      case AppointmentFilter.pendingApproval:
        return appointments
            .where((apt) => apt.status.toLowerCase() == 'pending')
            .toList();

      case AppointmentFilter.all:
      default:
        return appointments;
    }
  }
}
