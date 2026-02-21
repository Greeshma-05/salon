import 'package:flutter_test/flutter_test.dart';
import 'package:salon/models/appointment.dart';
import 'package:salon/services/appointment_service.dart';

void main() {
  group('Treatment History Tests', () {
    test('Appointment model should format date correctly', () {
      final appointment = Appointment(
        id: '1',
        serviceName: 'Haircut',
        productsUsed: ['Shampoo', 'Conditioner'],
        date: DateTime(2026, 3, 15),
        paymentStatus: 'Paid',
      );

      expect(appointment.formattedDate, 'March 15, 2026');
    });

    test('Appointment model should identify paid status', () {
      final paidAppointment = Appointment(
        id: '1',
        serviceName: 'Haircut',
        productsUsed: ['Shampoo'],
        date: DateTime.now(),
        paymentStatus: 'Paid',
      );

      final unpaidAppointment = Appointment(
        id: '2',
        serviceName: 'Facial',
        productsUsed: ['Face Mask'],
        date: DateTime.now(),
        paymentStatus: 'Unpaid',
      );

      expect(paidAppointment.isPaid, true);
      expect(unpaidAppointment.isPaid, false);
    });

    test('Appointment model should format products list', () {
      final appointment = Appointment(
        id: '1',
        serviceName: 'Hair Treatment',
        productsUsed: ['Shampoo', 'Conditioner', 'Hair Serum'],
        date: DateTime.now(),
        paymentStatus: 'Paid',
      );

      expect(appointment.productsUsedText, 'Shampoo, Conditioner, Hair Serum');
    });

    test('AppointmentService should return all appointments', () async {
      final service = AppointmentService();
      final appointments = await service.getUserAppointments();

      expect(appointments, isNotEmpty);
      expect(appointments.length, greaterThan(0));
    });

    test('AppointmentService should filter paid appointments', () async {
      final service = AppointmentService();
      final paidAppointments = await service.getPaidAppointments();

      for (final appointment in paidAppointments) {
        expect(appointment.paymentStatus, 'Paid');
      }
    });

    test('AppointmentService should filter unpaid appointments', () async {
      final service = AppointmentService();
      final unpaidAppointments = await service.getUnpaidAppointments();

      for (final appointment in unpaidAppointments) {
        expect(appointment.paymentStatus, 'Unpaid');
      }
    });

    test('AppointmentService should update payment status', () async {
      final service = AppointmentService();

      // Get an appointment
      final appointments = await service.getUserAppointments();
      final testAppointment = appointments.first;

      // Update status
      await service.updatePaymentStatus(testAppointment.id, 'Paid');

      // Verify update
      final updated = await service.getAppointmentById(testAppointment.id);
      expect(updated?.paymentStatus, 'Paid');
    });

    test('Appointment should support copyWith', () {
      final appointment = Appointment(
        id: '1',
        serviceName: 'Haircut',
        productsUsed: ['Shampoo'],
        date: DateTime(2026, 1, 1),
        paymentStatus: 'Unpaid',
      );

      final updated = appointment.copyWith(paymentStatus: 'Paid');

      expect(updated.id, '1');
      expect(updated.serviceName, 'Haircut');
      expect(updated.paymentStatus, 'Paid');
    });

    test('Appointment should convert to and from JSON', () {
      final appointment = Appointment(
        id: '1',
        serviceName: 'Haircut',
        productsUsed: ['Shampoo', 'Conditioner'],
        date: DateTime(2026, 3, 15),
        paymentStatus: 'Paid',
      );

      final json = appointment.toJson();
      final fromJson = Appointment.fromJson(json);

      expect(fromJson.id, appointment.id);
      expect(fromJson.serviceName, appointment.serviceName);
      expect(fromJson.productsUsed, appointment.productsUsed);
      expect(fromJson.paymentStatus, appointment.paymentStatus);
      expect(fromJson.date.day, appointment.date.day);
      expect(fromJson.date.month, appointment.date.month);
      expect(fromJson.date.year, appointment.date.year);
    });
  });
}
