import '../models/appointment.dart';

class AppointmentService {
  // In-memory storage for appointments
  static final List<Appointment> _appointments = [
    // Past Appointments (5)
    Appointment(
      id: '1',
      serviceName: 'Bridal Makeup',
      productsUsed: ['Foundation', 'Lipstick', 'Eye Shadow', 'Setting Spray'],
      date: DateTime.now().subtract(const Duration(days: 15)),
      stylist: 'Anjali',
      paymentStatus: 'Paid',
    ),
    Appointment(
      id: '2',
      serviceName: 'Hair Coloring',
      productsUsed: ['Hair Dye', 'Developer', 'Toner', 'Color Protector'],
      date: DateTime.now().subtract(const Duration(days: 10)),
      stylist: 'Meera',
      paymentStatus: 'Paid',
    ),
    Appointment(
      id: '3',
      serviceName: 'Luxury Facial',
      productsUsed: ['Cleanser', 'Exfoliator', 'Gold Face Mask', 'Moisturizer'],
      date: DateTime.now().subtract(const Duration(days: 7)),
      stylist: 'Riya',
      paymentStatus: 'Unpaid',
    ),
    Appointment(
      id: '4',
      serviceName: 'Keratin Treatment',
      productsUsed: [
        'Keratin Solution',
        'Clarifying Shampoo',
        'Smoothing Serum',
      ],
      date: DateTime.now().subtract(const Duration(days: 3)),
      stylist: 'Sneha',
      paymentStatus: 'Paid',
    ),
    Appointment(
      id: '5',
      serviceName: 'D-Tan Treatment',
      productsUsed: ['De-Tan Pack', 'Scrub', 'Aloe Vera Gel', 'Sunscreen'],
      date: DateTime.now().subtract(const Duration(days: 1)),
      stylist: 'Anjali',
      paymentStatus: 'Unpaid',
    ),

    // Upcoming Appointments (5)
    Appointment(
      id: '6',
      serviceName: 'Hair Spa',
      productsUsed: [
        'Hair Mask',
        'Argan Oil',
        'Deep Conditioner',
        'Heat Protector',
      ],
      date: DateTime.now().add(const Duration(days: 2)),
      stylist: 'Meera',
      paymentStatus: 'Unpaid',
    ),
    Appointment(
      id: '7',
      serviceName: 'Nail Art',
      productsUsed: ['Nail Polish', 'Gel', 'Rhinestones', 'Top Coat'],
      date: DateTime.now().add(const Duration(days: 5)),
      stylist: 'Riya',
      paymentStatus: 'Paid',
    ),
    Appointment(
      id: '8',
      serviceName: 'Head Massage',
      productsUsed: ['Massage Oil', 'Hair Tonic', 'Essential Oils'],
      date: DateTime.now().add(const Duration(days: 7)),
      stylist: 'Sneha',
      paymentStatus: 'Unpaid',
    ),
    Appointment(
      id: '9',
      serviceName: 'Bridal Makeup',
      productsUsed: [
        'Airbrush Foundation',
        'HD Powder',
        'Glitter',
        'False Lashes',
      ],
      date: DateTime.now().add(const Duration(days: 10)),
      stylist: 'Anjali',
      paymentStatus: 'Paid',
    ),
    Appointment(
      id: '10',
      serviceName: 'Luxury Facial',
      productsUsed: [
        'Diamond Scrub',
        'Vitamin C Serum',
        'Hydrating Mask',
        'SPF Cream',
      ],
      date: DateTime.now().add(const Duration(days: 14)),
      stylist: 'Meera',
      paymentStatus: 'Unpaid',
    ),
  ];

  // Get upcoming appointments (sorted by nearest date first)
  List<Appointment> getUpcomingAppointments() {
    final upcoming = _appointments
        .where((a) => a.date.isAfter(DateTime.now()))
        .toList();
    upcoming.sort((a, b) => a.date.compareTo(b.date)); // Nearest first
    return upcoming;
  }

  // Get past appointments (sorted by most recent first)
  List<Appointment> getPastAppointments() {
    final past = _appointments
        .where((a) => a.date.isBefore(DateTime.now()))
        .toList();
    past.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    return past;
  }

  // Add a new appointment
  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  // Update appointment payment status
  void updatePaymentStatus(String appointmentId, String newStatus) {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        paymentStatus: newStatus,
      );
    }
  }

  // Delete an appointment
  void deleteAppointment(String appointmentId) {
    _appointments.removeWhere((apt) => apt.id == appointmentId);
  }

  // Get appointment by ID
  Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((apt) => apt.id == appointmentId);
    } catch (e) {
      return null;
    }
  }
}
