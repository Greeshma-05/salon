import 'package:flutter_test/flutter_test.dart';
import 'package:salon/models/salon.dart';
import 'package:salon/models/service.dart';
import 'package:salon/models/booking.dart';

void main() {
  group('Hive Models Tests', () {
    test('Service model should format duration correctly', () {
      final service1 = Service(
        id: '1',
        name: 'Haircut',
        price: 50.0,
        duration: 45,
      );

      expect(service1.formattedDuration, '45 min');

      final service2 = Service(
        id: '2',
        name: 'Hair Coloring',
        price: 120.0,
        duration: 150, // 2 hours 30 minutes
      );

      expect(service2.formattedDuration, '2 hours 30 min');
    });

    test('Service model should format price correctly', () {
      final service = Service(
        id: '1',
        name: 'Haircut',
        price: 50.0,
        duration: 45,
      );

      expect(service.formattedPrice, '\$50.00');
    });

    test('Booking model should format date correctly', () {
      final booking = Booking(
        id: '1',
        salonName: 'Glamour Salon',
        serviceName: 'Haircut',
        date: DateTime(2024, 3, 15),
        time: '10:00 AM',
      );

      expect(booking.formattedDate, 'March 15, 2024 at 10:00 AM');
    });

    test('Booking model should correctly identify past dates', () {
      final pastBooking = Booking(
        id: '1',
        salonName: 'Glamour Salon',
        serviceName: 'Haircut',
        date: DateTime.now().subtract(const Duration(days: 1)),
        time: '10:00 AM',
      );

      expect(pastBooking.isPast, true);
      expect(pastBooking.isUpcoming, false);
    });

    test('Booking model should correctly identify upcoming dates', () {
      final upcomingBooking = Booking(
        id: '1',
        salonName: 'Glamour Salon',
        serviceName: 'Haircut',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '10:00 AM',
      );

      expect(upcomingBooking.isUpcoming, true);
      expect(upcomingBooking.isPast, false);
    });

    test('Booking model should correctly identify today\'s dates', () {
      final todayBooking = Booking(
        id: '1',
        salonName: 'Glamour Salon',
        serviceName: 'Haircut',
        date: DateTime.now(),
        time: '10:00 AM',
      );

      expect(todayBooking.isToday, true);
    });

    test('Salon model should create from JSON', () {
      final json = {
        'id': '1',
        'name': 'Glamour Salon',
        'location': 'Downtown',
        'rating': 4.5,
        'services': [
          {'id': 's1', 'name': 'Haircut', 'price': 50.0, 'duration': 45},
        ],
      };

      final salon = Salon.fromJson(json);

      expect(salon.id, '1');
      expect(salon.name, 'Glamour Salon');
      expect(salon.location, 'Downtown');
      expect(salon.rating, 4.5);
      expect(salon.services.length, 1);
      expect(salon.services[0].name, 'Haircut');
    });

    test('Salon model should convert to JSON', () {
      final service = Service(
        id: 's1',
        name: 'Haircut',
        price: 50.0,
        duration: 45,
      );

      final salon = Salon(
        id: '1',
        name: 'Glamour Salon',
        location: 'Downtown',
        rating: 4.5,
        services: [service],
      );

      final json = salon.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Glamour Salon');
      expect(json['location'], 'Downtown');
      expect(json['rating'], 4.5);
      expect((json['services'] as List).length, 1);
    });

    test('Models should support copyWith', () {
      final service = Service(
        id: '1',
        name: 'Haircut',
        price: 50.0,
        duration: 45,
      );

      final updatedService = service.copyWith(price: 60.0);

      expect(updatedService.id, '1');
      expect(updatedService.name, 'Haircut');
      expect(updatedService.price, 60.0);
      expect(updatedService.duration, 45);
    });
  });
}
