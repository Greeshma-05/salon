import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/salon_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import '../models/appointment_model.dart';
import '../models/feedback_model.dart';

class FirestoreService {
  static const String _salonsKey = 'salons_data';
  static const String _appointmentsKey = 'appointments_data';
  static const String _feedbackKey = 'feedback_data';

  // ==================== SALON CRUD ====================

  /// Create a new salon
  Future<String> createSalon(SalonModel salon) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salonsJson = prefs.getString(_salonsKey);
      final salons = salonsJson != null
          ? Map<String, dynamic>.from(jsonDecode(salonsJson))
          : <String, dynamic>{};

      final salonId = DateTime.now().millisecondsSinceEpoch.toString();
      salons[salonId] = salon.toMap();
      await prefs.setString(_salonsKey, jsonEncode(salons));

      return salonId;
    } catch (e) {
      throw Exception('Failed to create salon: ${e.toString()}');
    }
  }

  /// Get salon by ID
  Future<SalonModel?> getSalonById(String salonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salonsJson = prefs.getString(_salonsKey);

      if (salonsJson == null) return null;

      final salons = Map<String, dynamic>.from(jsonDecode(salonsJson));
      final salonData = salons[salonId];

      if (salonData == null) return null;

      return SalonModel.fromMap(Map<String, dynamic>.from(salonData), salonId);
    } catch (e) {
      throw Exception('Failed to get salon: ${e.toString()}');
    }
  }

  /// Get all salons (returns Future instead of Stream for simplicity)
  Future<List<SalonModel>> getAllSalonsOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salonsJson = prefs.getString(_salonsKey);

      if (salonsJson == null) return [];

      final salons = Map<String, dynamic>.from(jsonDecode(salonsJson));
      return salons.entries
          .map(
            (e) =>
                SalonModel.fromMap(Map<String, dynamic>.from(e.value), e.key),
          )
          .where((salon) => salon.isActive)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all salons as Stream (for compatibility)
  Stream<List<SalonModel>> getAllSalons() async* {
    yield await getAllSalonsOnce();
  }

  // ==================== APPOINTMENT CRUD ====================

  /// Create appointment
  Future<String> createAppointment(AppointmentModel appointment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getString(_appointmentsKey);
      final appointments = appointmentsJson != null
          ? Map<String, dynamic>.from(jsonDecode(appointmentsJson))
          : <String, dynamic>{};

      final appointmentId = DateTime.now().millisecondsSinceEpoch.toString();
      appointments[appointmentId] = appointment.toMap();
      await prefs.setString(_appointmentsKey, jsonEncode(appointments));

      return appointmentId;
    } catch (e) {
      throw Exception('Failed to create appointment: ${e.toString()}');
    }
  }

  /// Get appointments by customer ID
  Stream<List<AppointmentModel>> getAppointmentsByCustomerId(
    String customerId,
  ) async* {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getString(_appointmentsKey);

    if (appointmentsJson == null) {
      yield [];
      return;
    }

    final appointments = Map<String, dynamic>.from(
      jsonDecode(appointmentsJson),
    );
    final customerAppointments = appointments.entries
        .where((e) {
          final data = Map<String, dynamic>.from(e.value);
          return data['customerId'] == customerId;
        })
        .map(
          (e) => AppointmentModel.fromMap(
            Map<String, dynamic>.from(e.value),
            e.key,
          ),
        )
        .toList();

    yield customerAppointments;
  }

  /// Get upcoming appointments
  Stream<List<AppointmentModel>> getUpcomingAppointments(
    String customerId,
  ) async* {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getString(_appointmentsKey);

    if (appointmentsJson == null) {
      yield [];
      return;
    }

    final appointments = Map<String, dynamic>.from(
      jsonDecode(appointmentsJson),
    );
    final now = DateTime.now();
    final upcomingAppointments = appointments.entries
        .where((e) {
          final data = Map<String, dynamic>.from(e.value);
          final appointmentDate = DateTime.parse(data['appointmentDate']);
          return data['customerId'] == customerId &&
              appointmentDate.isAfter(now);
        })
        .map(
          (e) => AppointmentModel.fromMap(
            Map<String, dynamic>.from(e.value),
            e.key,
          ),
        )
        .toList();

    yield upcomingAppointments;
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointmentsJson = prefs.getString(_appointmentsKey);

      if (appointmentsJson == null) return;

      final appointments = Map<String, dynamic>.from(
        jsonDecode(appointmentsJson),
      );
      if (appointments.containsKey(appointmentId)) {
        final appointment = Map<String, dynamic>.from(
          appointments[appointmentId],
        );
        appointment['status'] = 'cancelled';
        appointment['cancellationReason'] = reason;
        appointment['updatedAt'] = DateTime.now().toIso8601String();
        appointments[appointmentId] = appointment;
        await prefs.setString(_appointmentsKey, jsonEncode(appointments));
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: ${e.toString()}');
    }
  }

  // ==================== STUB METHODS ====================
  // These methods are stubs to prevent errors in screens that use them

  Future<List<String>> getAvailableTimeSlots(
    String salonId,
    DateTime date, {
    String? stylistId,
  }) async {
    // Return some default time slots
    return [
      '09:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '01:00 PM',
      '02:00 PM',
      '03:00 PM',
      '04:00 PM',
      '05:00 PM',
    ];
  }

  Future<void> bookAppointment(AppointmentModel appointment) async {
    await createAppointment(appointment);
  }

  Stream<List<SalonModel>> getSalonsByOwnerId(String ownerId) async* {
    yield [];
  }

  Future<void> updateSalon(String salonId, SalonModel salon) async {}
  Future<void> deleteSalon(String salonId) async {}
  Future<String> addService(String salonId, ServiceModel service) async {
    return '';
  }

  Future<void> updateService(
    String salonId,
    String serviceId,
    ServiceModel service,
  ) async {}
  Future<void> deleteService(String salonId, String serviceId) async {}
  Stream<List<ServiceModel>> getServicesBySalonId(String salonId) async* {
    yield [];
  }

  Future<String> addStylist(String salonId, StylistModel stylist) async {
    return '';
  }

  Future<void> updateStylist(
    String salonId,
    String stylistId,
    StylistModel stylist,
  ) async {}
  Future<void> deleteStylist(String salonId, String stylistId) async {}
  Stream<List<StylistModel>> getStylistsBySalonId(String salonId) async* {
    yield [];
  }

  Stream<List<AppointmentModel>> getAppointmentsBySalonId(
    String salonId,
  ) async* {
    yield [];
  }

  Stream<List<AppointmentModel>> getAppointmentsByStylistId(
    String stylistId,
  ) async* {
    yield [];
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {}
  Future<void> assignStylist(String appointmentId, String stylistId) async {}
  Future<String> addFeedback(FeedbackModel feedback) async {
    return '';
  }

  Stream<List<FeedbackModel>> getFeedbackBySalonId(String salonId) async* {
    yield [];
  }

  Stream<List<FeedbackModel>> getFeedbackByCustomerId(
    String customerId,
  ) async* {
    yield [];
  }
}
