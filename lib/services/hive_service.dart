import 'package:hive_flutter/hive_flutter.dart';
import '../models/salon.dart';
import '../models/service.dart';
import '../models/booking.dart';

class HiveService {
  static const String salonsBox = 'salons';
  static const String servicesBox = 'services';
  static const String bookingsBox = 'bookings';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(SalonAdapter());
    Hive.registerAdapter(ServiceAdapter());
    Hive.registerAdapter(BookingAdapter());

    // Open boxes
    await Hive.openBox<Salon>(salonsBox);
    await Hive.openBox<Service>(servicesBox);
    await Hive.openBox<Booking>(bookingsBox);
  }

  // ==================== SALON OPERATIONS ====================

  static Future<void> addSalon(Salon salon) async {
    final box = Hive.box<Salon>(salonsBox);
    await box.put(salon.id, salon);
  }

  static Salon? getSalon(String id) {
    final box = Hive.box<Salon>(salonsBox);
    return box.get(id);
  }

  static List<Salon> getAllSalons() {
    final box = Hive.box<Salon>(salonsBox);
    return box.values.toList();
  }

  static Future<void> updateSalon(Salon salon) async {
    final box = Hive.box<Salon>(salonsBox);
    await box.put(salon.id, salon);
  }

  static Future<void> deleteSalon(String id) async {
    final box = Hive.box<Salon>(salonsBox);
    await box.delete(id);
  }

  // ==================== SERVICE OPERATIONS ====================

  static Future<void> addService(Service service) async {
    final box = Hive.box<Service>(servicesBox);
    await box.put(service.id, service);
  }

  static Service? getService(String id) {
    final box = Hive.box<Service>(servicesBox);
    return box.get(id);
  }

  static List<Service> getAllServices() {
    final box = Hive.box<Service>(servicesBox);
    return box.values.toList();
  }

  static Future<void> updateService(Service service) async {
    final box = Hive.box<Service>(servicesBox);
    await box.put(service.id, service);
  }

  static Future<void> deleteService(String id) async {
    final box = Hive.box<Service>(servicesBox);
    await box.delete(id);
  }

  // ==================== BOOKING OPERATIONS ====================

  static Future<void> addBooking(Booking booking) async {
    final box = Hive.box<Booking>(bookingsBox);
    await box.put(booking.id, booking);
  }

  static Booking? getBooking(String id) {
    final box = Hive.box<Booking>(bookingsBox);
    return box.get(id);
  }

  static List<Booking> getAllBookings() {
    final box = Hive.box<Booking>(bookingsBox);
    return box.values.toList();
  }

  static List<Booking> getUpcomingBookings() {
    final box = Hive.box<Booking>(bookingsBox);
    return box.values.where((booking) => booking.isUpcoming).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<Booking> getPastBookings() {
    final box = Hive.box<Booking>(bookingsBox);
    return box.values.where((booking) => booking.isPast).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> updateBooking(Booking booking) async {
    final box = Hive.box<Booking>(bookingsBox);
    await box.put(booking.id, booking);
  }

  static Future<void> deleteBooking(String id) async {
    final box = Hive.box<Booking>(bookingsBox);
    await box.delete(id);
  }

  // ==================== UTILITY OPERATIONS ====================

  static Future<void> clearAllData() async {
    await Hive.box<Salon>(salonsBox).clear();
    await Hive.box<Service>(servicesBox).clear();
    await Hive.box<Booking>(bookingsBox).clear();
  }

  static Future<void> seedSampleData() async {
    // Sample salons
    final salon1 = Salon(
      id: '1',
      name: 'Glamour Studio',
      location: '123 Main St, New York',
      rating: 4.5,
      services: [
        Service(id: 's1', name: 'Haircut', price: 50.0, duration: 45),
        Service(id: 's2', name: 'Hair Coloring', price: 120.0, duration: 120),
      ],
    );

    final salon2 = Salon(
      id: '2',
      name: 'Beauty Haven',
      location: '456 Oak Ave, Los Angeles',
      rating: 4.8,
      services: [
        Service(id: 's3', name: 'Manicure', price: 35.0, duration: 30),
        Service(id: 's4', name: 'Pedicure', price: 45.0, duration: 45),
        Service(id: 's5', name: 'Facial', price: 80.0, duration: 60),
      ],
    );

    final salon3 = Salon(
      id: '3',
      name: 'Style & Grace',
      location: '789 Park Blvd, Chicago',
      rating: 4.3,
      services: [
        Service(id: 's6', name: 'Massage', price: 100.0, duration: 90),
        Service(id: 's7', name: 'Blow Dry', price: 40.0, duration: 30),
      ],
    );

    await addSalon(salon1);
    await addSalon(salon2);
    await addSalon(salon3);

    // Sample booking
    final booking = Booking(
      id: 'b1',
      salonName: 'Glamour Studio',
      serviceName: 'Haircut',
      date: DateTime.now().add(const Duration(days: 3)),
      time: '10:00 AM',
    );

    await addBooking(booking);
  }
}
