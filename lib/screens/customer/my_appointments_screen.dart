import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  // final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  late Stream<List<AppointmentModel>> _appointmentsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Create a broadcast stream so it can be listened to multiple times
    _appointmentsStream = Stream.value(
      <AppointmentModel>[],
    ).asBroadcastStream();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view appointments')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUpcomingTab(user.uid), _buildPastTab(user.uid)],
      ),
    );
  }

  Widget _buildUpcomingTab(String customerId) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentsStream, // TODO: Replace with local storage
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                const Text('No upcoming appointments'),
              ],
            ),
          );
        }

        final appointments = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(appointments[index], true);
          },
        );
      },
    );
  }

  Widget _buildPastTab(String customerId) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentsStream, // TODO: Replace with local storage
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No past appointments'));
        }

        final allAppointments = snapshot.data!;
        final pastAppointments = allAppointments
            .where(
              (apt) =>
                  apt.appointmentDate.isBefore(DateTime.now()) ||
                  apt.status == 'completed' ||
                  apt.status == 'cancelled',
            )
            .toList();

        if (pastAppointments.isEmpty) {
          return const Center(child: Text('No past appointments'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pastAppointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(pastAppointments[index], false);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool canCancel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                _buildStatusChip(appointment.status),
                const Spacer(),
                _buildPaymentStatusChip(appointment.paymentStatus),
              ],
            ),

            const SizedBox(height: 16),

            // Salon & Service
            Text(
              appointment.salonName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.serviceName,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            // Date & Time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(appointment.appointmentDate),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(appointment.timeSlot),
              ],
            ),

            const SizedBox(height: 8),

            // Duration & Price
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text('${appointment.duration} mins'),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text('\$${appointment.totalPrice.toStringAsFixed(2)}'),
              ],
            ),

            // Stylist if available
            if (appointment.stylistName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text('Stylist: ${appointment.stylistName}'),
                ],
              ),
            ],

            // Notes if available
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            // Cancel button for upcoming appointments
            if (canCancel && appointment.canBeCancelled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelAppointment(appointment),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Appointment'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'confirmed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    Color color;

    switch (paymentStatus) {
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'refunded':
        color = Colors.blue;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        'Payment: ${paymentStatus.toUpperCase()}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Replace with local storage
        // await _firestoreService.cancelAppointment(
        //   appointment.id,
        //   'Cancelled by customer',
        // );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to cancel: $e')));
        }
      }
    }
  }
}
