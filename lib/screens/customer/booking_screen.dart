import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/salon_model.dart';
import '../../models/service_model.dart';
import '../../models/stylist_model.dart';
import '../../models/appointment_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../services/booking_service.dart';
import '../../services/pricing_service.dart';
import '../../widgets/dynamic_price_display.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final SalonModel salon;
  final ServiceModel service;

  const BookingScreen({super.key, required this.salon, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AdminService _adminService = AdminService();
  final _notesController = TextEditingController();

  StylistModel? _selectedStylist;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = [];
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot
      });
      _loadAvailableTimeSlots();
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    setState(() {
      _isLoadingSlots = true;
    });

    try {
      // Get available slots from AdminService
      final slots = _adminService.getAvailableTimeSlots(
        _selectedDate!,
        stylistId: _selectedStylist?.id,
      );

      setState(() {
        _availableTimeSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSlots = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading time slots: $e')));
      }
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    if (_selectedStylist == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a stylist')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingService = Provider.of<BookingService>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    // Check slot availability before booking
    if (!bookingService.checkSlotAvailability(
      _selectedStylist!.id,
      _selectedDate!,
      _selectedTimeSlot!,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Slot already booked! Please select another time.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      // Refresh available slots
      _loadAvailableTimeSlots();
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Get dynamic price
      final pricingService = Provider.of<PricingService>(
        context,
        listen: false,
      );
      final pricing = pricingService.getDynamicPrice(
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        basePrice: widget.service.price,
        bookingDate: _selectedDate,
      );

      // Create appointment
      final appointment = AppointmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: user.uid,
        customerName: user.name,
        customerPhone: user.phone,
        customerEmail: user.email,
        salonId: widget.salon.id,
        salonName: widget.salon.name,
        serviceId: widget.service.id,
        serviceName: widget.service.name,
        stylistId: _selectedStylist!.id,
        stylistName: _selectedStylist!.name,
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        duration: widget.service.duration,
        totalPrice: pricing.adjustedPrice,
        status: 'pending',
        paymentStatus: 'unpaid',
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Try to book appointment using BookingService
      final success = await bookingService.bookAppointment(appointment);

      setState(() {
        _isBooking = false;
      });

      if (!success) {
        // Slot was taken by another booking (race condition)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Slot was just booked! Please select another time.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          _loadAvailableTimeSlots();
        }
        return;
      }

      if (mounted) {
        // Navigate to payment screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(appointment: appointment),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.salon.name),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text('${widget.service.duration} mins'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Consumer<PricingService>(
                      builder: (context, pricingService, _) {
                        final pricing = pricingService.getDynamicPrice(
                          serviceId: widget.service.id,
                          serviceName: widget.service.name,
                          basePrice: widget.service.price,
                          bookingDate: _selectedDate,
                        );
                        return DynamicPriceDisplay(
                          pricing: pricing,
                          showDetails: true,
                          compact: false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Select Stylist (Optional)
            Text(
              'Select Stylist (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<StylistModel>>(
              stream: _adminService.stylistsStream,
              initialData: _adminService.stylists,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No stylist available'),
                    ),
                  );
                }

                final stylists = snapshot.data!;

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stylists.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "Any" option
                        return _buildStylistCard(null, 'Any Stylist');
                      }
                      return _buildStylistCard(stylists[index - 1], null);
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Select Date
            Text(
              'Select Date',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDate == null
                      ? 'Choose a date'
                      : DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectDate,
              ),
            ),

            const SizedBox(height: 24),

            // Select Time Slot
            if (_selectedDate != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Time Slot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_availableTimeSlots.isNotEmpty && !_isLoadingSlots)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_availableTimeSlots.length} available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoadingSlots)
                const Center(child: CircularProgressIndicator())
              else if (_availableTimeSlots.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No available time slots for this date'),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTimeSlots.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return FilterChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? slot : null;
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),
            ],

            // Notes
            Text(
              'Additional Notes (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requests or preferences?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Book Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isBooking ? null : _bookAppointment,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isBooking
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Booking'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylistCard(StylistModel? stylist, String? anyText) {
    final isSelected =
        _selectedStylist?.id == stylist?.id ||
        (stylist == null && _selectedStylist == null);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStylist = stylist;
          if (_selectedDate != null) {
            _loadAvailableTimeSlots();
          }
        });
      },
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  anyText != null
                      ? 'ANY'
                      : stylist!.name.substring(0, 1).toUpperCase(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                anyText ?? stylist!.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
