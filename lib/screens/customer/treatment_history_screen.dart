import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../widgets/appointment_card.dart';

class TreatmentHistoryScreen extends StatefulWidget {
  const TreatmentHistoryScreen({super.key});

  @override
  State<TreatmentHistoryScreen> createState() => _TreatmentHistoryScreenState();
}

class _TreatmentHistoryScreenState extends State<TreatmentHistoryScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'All'; // All, Paid, Unpaid

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() => _isLoading = true);

    try {
      final past = _appointmentService.getPastAppointments();
      final upcoming = _appointmentService.getUpcomingAppointments();
      final appointments = [...upcoming, ...past];
      setState(() {
        _appointments = appointments;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredAppointments = _appointments;
    } else {
      _filteredAppointments = _appointments
          .where((apt) => apt.paymentStatus == _selectedFilter)
          .toList();
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paidCount = _appointments.where((apt) => apt.isPaid).length;
    final unpaidCount = _appointments.length - paidCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Treatment History'), elevation: 0),
      body: Column(
        children: [
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _appointments.length.toString(),
                    Colors.blue,
                    Icons.history,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Paid',
                    paidCount.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Unpaid',
                    unpaidCount.toString(),
                    Colors.red,
                    Icons.pending,
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Paid'),
                const SizedBox(width: 8),
                _buildFilterChip('Unpaid'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Appointments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _loadAppointments();
                    },
                    child: ListView.builder(
                      itemCount: _filteredAppointments.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        final appointment = _filteredAppointments[index];
                        return AppointmentCard(
                          appointment: appointment,
                          onTap: () => _showAppointmentDetails(appointment),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _changeFilter(label),
      selectedColor: Colors.purple,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Appointment Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('Service', appointment.serviceName),
            const SizedBox(height: 12),
            _buildDetailRow('Date', appointment.formattedDate),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Payment Status',
              appointment.paymentStatus,
              valueColor: appointment.isPaid ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Products Used:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              appointment.productsUsedText,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            if (!appointment.isPaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _appointmentService.updatePaymentStatus(
                      appointment.id,
                      'Paid',
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadAppointments();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment status updated to Paid'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Mark as Paid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 14, color: valueColor)),
        ),
      ],
    );
  }
}
