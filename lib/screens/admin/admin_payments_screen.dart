import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../models/appointment_model.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final AdminService _adminService = AdminService();
  String _filterPayment = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: _adminService.appointmentsStream,
              initialData: _adminService.appointments,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No payment records available'),
                  );
                }

                var appointments = snapshot.data!;
                if (_filterPayment == 'paid') {
                  appointments = appointments
                      .where((a) => a.paymentStatus == 'paid')
                      .toList();
                } else if (_filterPayment == 'unpaid') {
                  appointments = appointments
                      .where((a) => a.paymentStatus == 'unpaid')
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final isPaid = appointment.paymentStatus == 'paid';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPaid
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          child: Icon(
                            isPaid ? Icons.check_circle : Icons.pending,
                            color: isPaid ? Colors.green : Colors.orange,
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
                                'MMM dd, yyyy',
                              ).format(appointment.appointmentDate),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${appointment.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPaid ? 'PAID' : 'UNPAID',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid
                                      ? Colors.green.shade900
                                      : Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showPaymentDialog(appointment),
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

  Widget _buildSummaryCards() {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _adminService.appointmentsStream,
      initialData: _adminService.appointments,
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        final totalRevenue = appointments
            .where((a) => a.paymentStatus == 'paid')
            .fold(0.0, (sum, a) => sum + a.totalPrice);
        final paidCount = appointments
            .where((a) => a.paymentStatus == 'paid')
            .length;
        final unpaidCount = appointments
            .where((a) => a.paymentStatus == 'unpaid')
            .length;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Revenue',
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Icons.monetization_on,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Paid',
                  paidCount.toString(),
                  Icons.check_circle,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Unpaid',
                  unpaidCount.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Paid', 'paid'),
          _buildFilterChip('Unpaid', 'unpaid'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterPayment == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterPayment = value;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  void _showPaymentDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Customer', appointment.customerName),
            _buildDetailRow('Service', appointment.serviceName),
            _buildDetailRow(
              'Date',
              DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
            ),
            _buildDetailRow(
              'Amount',
              '\$${appointment.totalPrice.toStringAsFixed(2)}',
            ),
            _buildDetailRow('Status', appointment.paymentStatus.toUpperCase()),
          ],
        ),
        actions: [
          if (appointment.paymentStatus == 'unpaid')
            ElevatedButton.icon(
              onPressed: () {
                _adminService.updatePaymentStatus(appointment.id, 'paid');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment marked as paid')),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Mark as Paid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
