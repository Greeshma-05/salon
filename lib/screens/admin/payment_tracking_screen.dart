import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/payment_report_service.dart';
import '../../models/appointment_model.dart';

class PaymentTrackingScreen extends StatefulWidget {
  const PaymentTrackingScreen({Key? key}) : super(key: key);

  @override
  State<PaymentTrackingScreen> createState() => _PaymentTrackingScreenState();
}

class _PaymentTrackingScreenState extends State<PaymentTrackingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedService;
  String? _selectedStylist;
  String _selectedTab = 'all'; // all, paid, pending, refunded

  @override
  Widget build(BuildContext context) {
    final paymentService = Provider.of<PaymentReportService>(context);
    final summary = paymentService.getPaymentSummary(
      startDate: _startDate,
      endDate: _endDate,
      serviceFilter: _selectedService,
      stylistFilter: _selectedStylist,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportReport(paymentService),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(summary),

          // Filters
          _buildFilters(paymentService),

          // Tab Selection
          _buildTabSelector(),

          // Payment List
          Expanded(child: _buildPaymentList(summary)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(PaymentSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Paid',
              '\$${summary.totalPaid.toStringAsFixed(2)}',
              '${summary.paidCount} bookings',
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Pending',
              '\$${summary.totalPending.toStringAsFixed(2)}',
              '${summary.pendingCount} bookings',
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Refunded',
              '\$${summary.totalRefunded.toStringAsFixed(2)}',
              '${summary.refundedCount} bookings',
              Colors.red,
              Icons.money_off,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(PaymentReportService paymentService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Date Filter
                _buildFilterChip(
                  icon: Icons.calendar_today,
                  label: _startDate != null && _endDate != null
                      ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                      : 'Date Range',
                  onTap: _selectDateRange,
                  isSelected: _startDate != null && _endDate != null,
                  onClear: _startDate != null
                      ? () => setState(() {
                          _startDate = null;
                          _endDate = null;
                        })
                      : null,
                ),
                const SizedBox(width: 8),
                // Service Filter
                _buildFilterChip(
                  icon: Icons.spa,
                  label: _selectedService ?? 'Service',
                  onTap: () => _selectService(paymentService),
                  isSelected: _selectedService != null,
                  onClear: _selectedService != null
                      ? () => setState(() => _selectedService = null)
                      : null,
                ),
                const SizedBox(width: 8),
                // Stylist Filter
                _buildFilterChip(
                  icon: Icons.person,
                  label: _getStylistName() ?? 'Stylist',
                  onTap: () => _selectStylist(paymentService),
                  isSelected: _selectedStylist != null,
                  onClear: _selectedStylist != null
                      ? () => setState(() => _selectedStylist = null)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
    VoidCallback? onClear,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (onClear != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab('all', 'All'),
          _buildTab('paid', 'Paid'),
          _buildTab('pending', 'Pending'),
          _buildTab('refunded', 'Refunded'),
        ],
      ),
    );
  }

  Widget _buildTab(String value, String label) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentList(PaymentSummary summary) {
    var bookings = summary.bookings;

    // Filter by selected tab
    if (_selectedTab != 'all') {
      bookings = bookings
          .where((b) => b.paymentStatus.toLowerCase() == _selectedTab)
          .toList();
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildPaymentCard(bookings[index]),
    );
  }

  Widget _buildPaymentCard(AppointmentModel booking) {
    final paymentColor = _getPaymentStatusColor(booking.paymentStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: paymentColor.withOpacity(0.2),
          child: Icon(
            _getPaymentStatusIcon(booking.paymentStatus),
            color: paymentColor,
          ),
        ),
        title: Text(
          booking.customerName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${booking.serviceName} • ${booking.stylistName ?? 'N/A'}',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 2),
            Text(
              '${DateFormat('MMM d, yyyy').format(booking.appointmentDate)} at ${booking.timeSlot}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${booking.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: paymentColor,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: paymentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.paymentStatus,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: paymentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'unpaid':
        return Colors.orange;
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
      case 'unpaid':
        return Icons.pending;
      case 'refunded':
        return Icons.money_off;
      default:
        return Icons.payment;
    }
  }

  String? _getStylistName() {
    if (_selectedStylist == null) return null;
    final paymentService = Provider.of<PaymentReportService>(
      context,
      listen: false,
    );
    final stylists = paymentService.getUniqueStylists();
    final stylist = stylists.firstWhere(
      (s) => s['id'] == _selectedStylist,
      orElse: () => {'name': _selectedStylist!},
    );
    return stylist['name'];
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _selectService(PaymentReportService paymentService) async {
    final services = paymentService.getUniqueServices();

    if (services.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No services found')));
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Service'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: services.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(services[index]),
              onTap: () => Navigator.pop(context, services[index]),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() => _selectedService = selected);
    }
  }

  Future<void> _selectStylist(PaymentReportService paymentService) async {
    final stylists = paymentService.getUniqueStylists();

    if (stylists.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No stylists found')));
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Stylist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: stylists.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(stylists[index]['name']!),
              onTap: () => Navigator.pop(context, stylists[index]['id']),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() => _selectedStylist = selected);
    }
  }

  Future<void> _exportReport(PaymentReportService paymentService) async {
    final csv = paymentService.exportPaymentReportToCSV(
      startDate: _startDate,
      endDate: _endDate,
      serviceFilter: _selectedService,
      stylistFilter: _selectedStylist,
    );

    await Clipboard.setData(ClipboardData(text: csv));

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Successful'),
          content: const Text(
            'Payment report has been copied to clipboard in CSV format. '
            'You can paste it into Excel or Google Sheets.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
