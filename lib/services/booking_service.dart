import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import 'stylist_service.dart';

class BookingService extends ChangeNotifier {
  // Singleton pattern
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final StylistService _stylistService = StylistService();

  // In-memory storage for appointments
  final List<AppointmentModel> _appointments = [];

  // Getters
  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);

  /// Check if a stylist is available for a specific date and time
  /// Returns true if slot is available, false if already booked
  bool checkSlotAvailability(String stylistId, DateTime date, String time) {
    // Check if any appointment exists with same stylist, date, and time
    final hasConflict = _appointments.any((appointment) {
      // Compare date (ignoring time component)
      final appointmentDate = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      final bookingDate = DateTime(date.year, date.month, date.day);

      return appointment.stylistId == stylistId &&
          appointmentDate.isAtSameMomentAs(bookingDate) &&
          appointment.timeSlot == time;
    });

    return !hasConflict;
  }

  /// Book a new appointment
  /// Returns true if booking successful, false if slot is unavailable
  Future<bool> bookAppointment(AppointmentModel appointment) async {
    // Validate stylist ID
    if (appointment.stylistId == null || appointment.stylistId!.isEmpty) {
      return false;
    }

    // Check slot availability first
    if (!checkSlotAvailability(
      appointment.stylistId!,
      appointment.appointmentDate,
      appointment.timeSlot,
    )) {
      return false;
    }

    // Add appointment to list
    _appointments.add(appointment);

    // Update stylist availability to false (busy)
    _stylistService.toggleStylistAvailability(appointment.stylistId!);

    // Notify listeners to update UI
    notifyListeners();

    return true;
  }

  /// Get all bookings for a specific user
  List<AppointmentModel> getUserBookings(String userId) {
    return _appointments
        .where((appointment) => appointment.customerId == userId)
        .toList()
      ..sort(
        (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
      ); // Sort by date, newest first
  }

  /// Get upcoming bookings for a user
  List<AppointmentModel> getUpcomingBookings(String userId) {
    final now = DateTime.now();
    return _appointments
        .where(
          (appointment) =>
              appointment.customerId == userId &&
              appointment.appointmentDate.isAfter(now),
        )
        .toList()
      ..sort(
        (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
      ); // Sort ascending
  }

  /// Get past bookings for a user
  List<AppointmentModel> getPastBookings(String userId) {
    final now = DateTime.now();
    return _appointments
        .where(
          (appointment) =>
              appointment.customerId == userId &&
              appointment.appointmentDate.isBefore(now),
        )
        .toList()
      ..sort(
        (a, b) => b.appointmentDate.compareTo(a.appointmentDate),
      ); // Sort descending
  }

  /// Cancel a booking
  /// Returns true if cancellation successful, false if booking not found
  bool cancelBooking(String id) {
    final index = _appointments.indexWhere(
      (appointment) => appointment.id == id,
    );

    if (index == -1) {
      return false;
    }

    // Get the appointment before removing
    final appointment = _appointments[index];

    // Remove appointment from list
    _appointments.removeAt(index);

    // Update stylist availability back to true (available) if stylist exists
    if (appointment.stylistId != null) {
      _stylistService.toggleStylistAvailability(appointment.stylistId!);
    }

    // Notify listeners to update UI
    notifyListeners();

    return true;
  }

  /// Get appointment by ID
  AppointmentModel? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((appointment) => appointment.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all appointments for a specific stylist
  List<AppointmentModel> getStylistAppointments(String stylistId) {
    return _appointments
        .where((appointment) => appointment.stylistId == stylistId)
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  /// Get appointments for a specific date
  List<AppointmentModel> getAppointmentsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      return appointmentDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Update appointment status
  void updateAppointmentStatus(String id, String status) {
    final index = _appointments.indexWhere(
      (appointment) => appointment.id == id,
    );
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: status);
      notifyListeners();
    }
  }

  /// Update payment status
  void updatePaymentStatus(String id, String paymentStatus) {
    final index = _appointments.indexWhere(
      (appointment) => appointment.id == id,
    );
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        paymentStatus: paymentStatus,
      );
      notifyListeners();
    }
  }

  /// Update approval status
  void updateApprovalStatus(String id, String approvalStatus) {
    final index = _appointments.indexWhere(
      (appointment) => appointment.id == id,
    );
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        approvalStatus: approvalStatus,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Approve booking
  bool approveBooking(String id) {
    final appointment = getAppointmentById(id);
    if (appointment == null) return false;

    updateApprovalStatus(id, 'approved');
    updateAppointmentStatus(id, 'confirmed');
    return true;
  }

  /// Reject booking and free up the slot
  bool rejectBooking(String id) {
    final appointment = getAppointmentById(id);
    if (appointment == null) return false;

    updateApprovalStatus(id, 'rejected');
    updateAppointmentStatus(id, 'cancelled');

    // Free up stylist availability
    if (appointment.stylistId != null) {
      _stylistService.toggleStylistAvailability(appointment.stylistId!);
    }

    return true;
  }

  /// Get pending approval bookings
  List<AppointmentModel> getPendingApprovalBookings() {
    return _appointments
        .where((appointment) => appointment.approvalStatus == 'pending')
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Get all bookings (for admin)
  List<AppointmentModel> getAllBookings() {
    return List.unmodifiable(_appointments);
  }

  /// Clear all appointments (for testing/reset)
  void clearAllAppointments() {
    _appointments.clear();
    notifyListeners();
  }
}
