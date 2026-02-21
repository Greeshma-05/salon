import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../models/appointment_model.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final AdminService _adminService = AdminService();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _adminService.appointmentsStream,
              initialData: _adminService.appointments,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No appointments available'));
                }

                var appointments = snapshot.data!;
                if (_filterStatus != 'all') {
                  appointments = appointments
                      .where((a) => a.status == _filterStatus)
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(appointment.status),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          appointment.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(appointment.serviceName),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy • hh:mm a',
                              ).format(appointment.appointmentDate),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: _buildStatusChip(appointment.status),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  'Customer',
                                  appointment.customerName,
                                ),
                                _buildInfoRow(
                                  'Phone',
                                  appointment.customerPhone,
                                ),
                                _buildInfoRow(
                                  'Service',
                                  appointment.serviceName,
                                ),
                                if (appointment.stylistName != null)
                                  _buildInfoRow(
                                    'Stylist',
                                    appointment.stylistName!,
                                  ),
                                _buildInfoRow(
                                  'Time Slot',
                                  appointment.timeSlot,
                                ),
                                _buildInfoRow(
                                  'Duration',
                                  '${appointment.duration} min',
                                ),
                                _buildInfoRow(
                                  'Price',
                                  '\$${appointment.totalPrice.toStringAsFixed(2)}',
                                ),
                                _buildInfoRow(
                                  'Payment',
                                  appointment.paymentStatus,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateStatus(
                                          appointment.id,
                                          'confirmed',
                                        ),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Confirm'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateStatus(
                                          appointment.id,
                                          'completed',
                                        ),
                                        icon: const Icon(
                                          Icons.check_circle,
                                          size: 18,
                                        ),
                                        label: const Text('Complete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateStatus(
                                      appointment.id,
                                      'cancelled',
                                    ),
                                    icon: const Icon(Icons.cancel, size: 18),
                                    label: const Text('Cancel'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            _buildFilterChip('Pending', 'pending'),
            _buildFilterChip('Confirmed', 'confirmed'),
            _buildFilterChip('Completed', 'completed'),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterStatus = value;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateStatus(String id, String status) {
    _adminService.updateAppointmentStatus(id, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment status updated to $status')),
    );
  }
}
