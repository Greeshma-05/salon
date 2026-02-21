import 'dart:async';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import '../models/appointment_model.dart';
import '../models/salon_model.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stockQuantity,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }
}

class AdminService {
  // Singleton pattern
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  // In-memory data storage
  final List<SalonModel> _salons = [];
  final List<ServiceModel> _services = [];
  final List<Product> _products = [];
  final List<StylistModel> _stylists = [];
  final List<AppointmentModel> _appointments = [];

  // Stream controllers for reactive updates
  final _salonsController = StreamController<List<SalonModel>>.broadcast();
  final _servicesController = StreamController<List<ServiceModel>>.broadcast();
  final _productsController = StreamController<List<Product>>.broadcast();
  final _stylistsController = StreamController<List<StylistModel>>.broadcast();
  final _appointmentsController =
      StreamController<List<AppointmentModel>>.broadcast();

  // Streams
  Stream<List<SalonModel>> get salonsStream => _salonsController.stream;
  Stream<List<ServiceModel>> get servicesStream => _servicesController.stream;
  Stream<List<Product>> get productsStream => _productsController.stream;
  Stream<List<StylistModel>> get stylistsStream => _stylistsController.stream;
  Stream<List<AppointmentModel>> get appointmentsStream =>
      _appointmentsController.stream;

  // Getters
  List<SalonModel> get salons => List.unmodifiable(_salons);
  List<ServiceModel> get services => List.unmodifiable(_services);
  List<Product> get products => List.unmodifiable(_products);
  List<StylistModel> get stylists => List.unmodifiable(_stylists);
  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);

  // Initialize with sample data
  void initializeData() {
    if (_salons.isEmpty) {
      _salons.addAll([
        SalonModel(
          id: 's1',
          name: 'Luxe Salon & Spa',
          description:
              'Premium salon offering haircut, coloring, and spa services',
          address: '123 Main Street',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          phone: '555-0100',
          email: 'info@luxesalon.com',
          ownerId: 'admin1',
          openingHours: {
            'monday': '9:00-20:00',
            'tuesday': '9:00-20:00',
            'wednesday': '9:00-20:00',
            'thursday': '9:00-20:00',
            'friday': '9:00-20:00',
            'saturday': '9:00-20:00',
            'sunday': '10:00-18:00',
          },
          rating: 4.8,
          totalReviews: 120,
          images: [],
          imageUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SalonModel(
          id: 's2',
          name: 'Beauty Haven',
          description: 'Your one-stop destination for beauty and wellness',
          address: '456 Park Avenue',
          city: 'Los Angeles',
          state: 'CA',
          zipCode: '90001',
          phone: '555-0200',
          email: 'contact@beautyhaven.com',
          ownerId: 'admin1',
          openingHours: {
            'monday': '8:00-21:00',
            'tuesday': '8:00-21:00',
            'wednesday': '8:00-21:00',
            'thursday': '8:00-21:00',
            'friday': '8:00-21:00',
            'saturday': '8:00-21:00',
            'sunday': '8:00-21:00',
          },
          rating: 4.6,
          totalReviews: 85,
          images: [],
          imageUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        SalonModel(
          id: 's3',
          name: 'Glamour Studio',
          description: 'Modern salon with expert stylists and latest trends',
          address: '789 Fashion Boulevard',
          city: 'Miami',
          state: 'FL',
          zipCode: '33101',
          phone: '555-0300',
          email: 'hello@glamourstudio.com',
          ownerId: 'admin1',
          openingHours: {
            'tuesday': '10:00-19:00',
            'wednesday': '10:00-19:00',
            'thursday': '10:00-19:00',
            'friday': '10:00-19:00',
            'saturday': '10:00-19:00',
          },
          rating: 4.9,
          totalReviews: 200,
          images: [],
          imageUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      _salonsController.add(_salons);
    }

    if (_services.isEmpty) {
      _services.addAll([
        ServiceModel(
          id: '1',
          salonId: 's1',
          name: 'Haircut',
          description: 'Professional haircut with styling',
          price: 50.0,
          duration: 45,
          category: 'Hair',
          imageUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ServiceModel(
          id: '2',
          salonId: 's1',
          name: 'Hair Coloring',
          description: 'Full hair coloring service',
          price: 120.0,
          duration: 120,
          category: 'Hair',
          imageUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ServiceModel(
          id: '3',
          salonId: 's1',
          name: 'Facial',
          description: 'Deep cleansing facial treatment',
          price: 80.0,
          duration: 60,
          category: 'Skin',
          imageUrl: '',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      _servicesController.add(_services);
    }

    if (_products.isEmpty) {
      _products.addAll([
        Product(
          id: '1',
          name: 'Shampoo',
          price: 25.0,
          category: 'Hair Care',
          stockQuantity: 50,
        ),
        Product(
          id: '2',
          name: 'Hair Color',
          price: 45.0,
          category: 'Hair Color',
          stockQuantity: 30,
        ),
        Product(
          id: '3',
          name: 'Face Mask',
          price: 35.0,
          category: 'Skin Care',
          stockQuantity: 40,
        ),
      ]);
      _productsController.add(_products);
    }

    if (_stylists.isEmpty) {
      _stylists.addAll([
        StylistModel(
          id: '1',
          salonId: 's1',
          name: 'Emma Wilson',
          bio: 'Expert hair stylist with 5 years experience',
          phone: '555-0101',
          email: 'emma@salon.com',
          specializations: ['Haircut', 'Styling'],
          yearsOfExperience: 5,
          rating: 4.8,
          profileImage: '',
          isAvailable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        StylistModel(
          id: '2',
          salonId: 's1',
          name: 'Sarah Johnson',
          bio: 'Professional color expert with 7 years experience',
          phone: '555-0102',
          email: 'sarah@salon.com',
          specializations: ['Hair Coloring', 'Highlights'],
          yearsOfExperience: 7,
          rating: 4.9,
          profileImage: '',
          isAvailable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        StylistModel(
          id: '3',
          salonId: 's1',
          name: 'Mike Davis',
          bio: 'Skin care specialist with 4 years experience',
          phone: '555-0103',
          email: 'mike@salon.com',
          specializations: ['Facial', 'Skin Treatment'],
          yearsOfExperience: 4,
          rating: 4.7,
          profileImage: '',
          isAvailable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      _stylistsController.add(_stylists);
    }

    if (_appointments.isEmpty) {
      _appointments.addAll([
        // Past Appointments
        AppointmentModel(
          id: '1',
          customerId: 'c1',
          customerName: 'John Doe',
          customerPhone: '555-1234',
          customerEmail: 'john@email.com',
          salonId: 's1',
          salonName: 'Luxe Salon & Spa',
          serviceId: '1',
          serviceName: 'Haircut',
          stylistId: '1',
          stylistName: 'Emma Wilson',
          appointmentDate: DateTime.now().subtract(const Duration(days: 7)),
          timeSlot: '10:00 AM',
          duration: 45,
          totalPrice: 50.0,
          status: 'completed',
          paymentStatus: 'paid',
          notes: 'Great service!',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        AppointmentModel(
          id: '2',
          customerId: 'c2',
          customerName: 'Jane Smith',
          customerPhone: '555-5678',
          customerEmail: 'jane@email.com',
          salonId: 's2',
          salonName: 'Beauty Haven',
          serviceId: '2',
          serviceName: 'Hair Coloring',
          stylistId: '2',
          stylistName: 'Sarah Johnson',
          appointmentDate: DateTime.now().subtract(const Duration(days: 5)),
          timeSlot: '2:00 PM',
          duration: 120,
          totalPrice: 120.0,
          status: 'completed',
          paymentStatus: 'paid',
          notes: 'Love the new color',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        AppointmentModel(
          id: '3',
          customerId: 'c3',
          customerName: 'Bob Wilson',
          customerPhone: '555-9012',
          customerEmail: 'bob@email.com',
          salonId: 's1',
          salonName: 'Luxe Salon & Spa',
          serviceId: '3',
          serviceName: 'Facial',
          stylistId: '3',
          stylistName: 'Mike Davis',
          appointmentDate: DateTime.now().subtract(const Duration(days: 3)),
          timeSlot: '11:00 AM',
          duration: 60,
          totalPrice: 80.0,
          status: 'completed',
          paymentStatus: 'paid',
          notes: '',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        AppointmentModel(
          id: '4',
          customerId: 'c4',
          customerName: 'Alice Brown',
          customerPhone: '555-2345',
          customerEmail: 'alice@email.com',
          salonId: 's3',
          salonName: 'Glamour Studio',
          serviceId: '1',
          serviceName: 'Haircut',
          stylistId: '1',
          stylistName: 'Emma Wilson',
          appointmentDate: DateTime.now().subtract(const Duration(days: 2)),
          timeSlot: '3:00 PM',
          duration: 45,
          totalPrice: 50.0,
          status: 'completed',
          paymentStatus: 'unpaid',
          notes: 'Will pay at next visit',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        AppointmentModel(
          id: '5',
          customerId: 'c5',
          customerName: 'Charlie Davis',
          customerPhone: '555-3456',
          customerEmail: 'charlie@email.com',
          salonId: 's1',
          salonName: 'Luxe Salon & Spa',
          serviceId: '2',
          serviceName: 'Hair Coloring',
          stylistId: '2',
          stylistName: 'Sarah Johnson',
          appointmentDate: DateTime.now().subtract(const Duration(days: 1)),
          timeSlot: '1:00 PM',
          duration: 120,
          totalPrice: 120.0,
          status: 'completed',
          paymentStatus: 'paid',
          notes: 'Excellent work',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        // Upcoming Appointments
        AppointmentModel(
          id: '6',
          customerId: 'c6',
          customerName: 'Diana Martinez',
          customerPhone: '555-4567',
          customerEmail: 'diana@email.com',
          salonId: 's2',
          salonName: 'Beauty Haven',
          serviceId: '3',
          serviceName: 'Facial',
          stylistId: '3',
          stylistName: 'Mike Davis',
          appointmentDate: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '10:00 AM',
          duration: 60,
          totalPrice: 80.0,
          status: 'confirmed',
          paymentStatus: 'paid',
          notes: 'Looking forward to it',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now(),
        ),
        AppointmentModel(
          id: '7',
          customerId: 'c7',
          customerName: 'Eva Garcia',
          customerPhone: '555-5678',
          customerEmail: 'eva@email.com',
          salonId: 's1',
          salonName: 'Luxe Salon & Spa',
          serviceId: '1',
          serviceName: 'Haircut',
          stylistId: '1',
          stylistName: 'Emma Wilson',
          appointmentDate: DateTime.now().add(const Duration(days: 2)),
          timeSlot: '9:00 AM',
          duration: 45,
          totalPrice: 50.0,
          status: 'pending',
          paymentStatus: 'unpaid',
          notes: '',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
        AppointmentModel(
          id: '8',
          customerId: 'c8',
          customerName: 'Frank Lee',
          customerPhone: '555-6789',
          customerEmail: 'frank@email.com',
          salonId: 's3',
          salonName: 'Glamour Studio',
          serviceId: '2',
          serviceName: 'Hair Coloring',
          stylistId: '2',
          stylistName: 'Sarah Johnson',
          appointmentDate: DateTime.now().add(const Duration(days: 3)),
          timeSlot: '11:00 AM',
          duration: 120,
          totalPrice: 120.0,
          status: 'confirmed',
          paymentStatus: 'unpaid',
          notes: 'First time here',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AppointmentModel(
          id: '9',
          customerId: 'c9',
          customerName: 'Grace Kim',
          customerPhone: '555-7890',
          customerEmail: 'grace@email.com',
          salonId: 's2',
          salonName: 'Beauty Haven',
          serviceId: '1',
          serviceName: 'Haircut',
          stylistId: '1',
          stylistName: 'Emma Wilson',
          appointmentDate: DateTime.now().add(const Duration(days: 5)),
          timeSlot: '4:00 PM',
          duration: 45,
          totalPrice: 50.0,
          status: 'pending',
          paymentStatus: 'unpaid',
          notes: 'Regular customer',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AppointmentModel(
          id: '10',
          customerId: 'c10',
          customerName: 'Henry Wang',
          customerPhone: '555-8901',
          customerEmail: 'henry@email.com',
          salonId: 's1',
          salonName: 'Luxe Salon & Spa',
          serviceId: '3',
          serviceName: 'Facial',
          stylistId: '3',
          stylistName: 'Mike Davis',
          appointmentDate: DateTime.now().add(const Duration(days: 7)),
          timeSlot: '12:00 PM',
          duration: 60,
          totalPrice: 80.0,
          status: 'pending',
          paymentStatus: 'unpaid',
          notes: 'Relaxation time',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      _appointmentsController.add(_appointments);
    }
  }

  // Services CRUD
  void addService(ServiceModel service) {
    _services.add(service);
    _servicesController.add(_services);
  }

  void updateService(ServiceModel service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
      _servicesController.add(_services);
    }
  }

  void deleteService(String id) {
    _services.removeWhere((s) => s.id == id);
    _servicesController.add(_services);
  }

  // Products CRUD
  void addProduct(Product product) {
    _products.add(product);
    _productsController.add(_products);
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      _productsController.add(_products);
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    _productsController.add(_products);
  }

  // Stylists CRUD
  void addStylist(StylistModel stylist) {
    _stylists.add(stylist);
    _stylistsController.add(_stylists);
  }

  void updateStylist(StylistModel stylist) {
    final index = _stylists.indexWhere((s) => s.id == stylist.id);
    if (index != -1) {
      _stylists[index] = stylist;
      _stylistsController.add(_stylists);
    }
  }

  void deleteStylist(String id) {
    _stylists.removeWhere((s) => s.id == id);
    _stylistsController.add(_stylists);
  }

  // Appointments Management
  void updateAppointmentStatus(String id, String status) {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _appointmentsController.add(_appointments);
    }
  }

  void updatePaymentStatus(String id, String paymentStatus) {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        paymentStatus: paymentStatus,
        updatedAt: DateTime.now(),
      );
      _appointmentsController.add(_appointments);
    }
  }

  // Analytics
  int get totalBookings => _appointments.length;

  double get totalRevenue {
    return _appointments
        .where((a) => a.paymentStatus == 'paid')
        .fold(0.0, (sum, a) => sum + a.totalPrice);
  }

  int get paidAppointmentsCount {
    return _appointments.where((a) => a.paymentStatus == 'paid').length;
  }

  int get unpaidAppointmentsCount {
    return _appointments.where((a) => a.paymentStatus == 'unpaid').length;
  }

  Map<String, int> getAppointmentsByStatus() {
    return {
      'pending': _appointments.where((a) => a.status == 'pending').length,
      'confirmed': _appointments.where((a) => a.status == 'confirmed').length,
      'completed': _appointments.where((a) => a.status == 'completed').length,
      'cancelled': _appointments.where((a) => a.status == 'cancelled').length,
    };
  }

  Map<String, double> getRevenueByService() {
    final Map<String, double> revenue = {};
    for (var appointment in _appointments.where(
      (a) => a.paymentStatus == 'paid',
    )) {
      revenue[appointment.serviceName] =
          (revenue[appointment.serviceName] ?? 0) + appointment.totalPrice;
    }
    return revenue;
  }

  // Slot Availability Checking
  bool isSlotAvailable(String? stylistId, DateTime date, String timeSlot) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Check if any appointment exists with same stylist, date, and time
    return !_appointments.any((appointment) {
      // Skip cancelled appointments
      if (appointment.status == 'cancelled') return false;

      // Normalize appointment date
      final appointmentDate = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );

      // Check if stylist, date, and time match
      return appointment.stylistId == stylistId &&
          appointmentDate.isAtSameMomentAs(normalizedDate) &&
          appointment.timeSlot == timeSlot;
    });
  }

  // Get available time slots for a specific date and stylist
  List<String> getAvailableTimeSlots(DateTime date, {String? stylistId}) {
    // All possible time slots
    final allTimeSlots = [
      '9:00 AM',
      '9:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
      '12:00 PM',
      '12:30 PM',
      '1:00 PM',
      '1:30 PM',
      '2:00 PM',
      '2:30 PM',
      '3:00 PM',
      '3:30 PM',
      '4:00 PM',
      '4:30 PM',
      '5:00 PM',
      '5:30 PM',
      '6:00 PM',
      '6:30 PM',
      '7:00 PM',
      '7:30 PM',
      '8:00 PM',
    ];

    // Filter out booked slots
    return allTimeSlots.where((slot) {
      return isSlotAvailable(stylistId, date, slot);
    }).toList();
  }

  // Book a new appointment
  bool bookAppointment(AppointmentModel appointment) {
    // Validate slot availability
    if (!isSlotAvailable(
      appointment.stylistId,
      appointment.appointmentDate,
      appointment.timeSlot,
    )) {
      return false; // Slot not available
    }

    // Add appointment
    _appointments.add(appointment);
    _appointmentsController.add(_appointments);
    return true; // Booking successful
  }

  void dispose() {
    _servicesController.close();
    _productsController.close();
    _stylistsController.close();
    _appointmentsController.close();
  }
}
