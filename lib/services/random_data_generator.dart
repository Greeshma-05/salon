import 'dart:math';
import '../models/salon_model.dart';
import '../models/stylist.dart';
import '../models/treatment.dart';
import '../models/appointment_model.dart';
import '../services/booking_service.dart';

class RandomDataGenerator {
  static final Random _random = Random();

  // Name lists
  static const List<String> _firstNames = [
    'Anjali',
    'Meera',
    'Priya',
    'Riya',
    'Sneha',
    'Kavya',
    'Divya',
    'Pooja',
    'Neha',
    'Aarti',
    'Simran',
    'Aditi',
    'Shreya',
    'Nikita',
    'Shweta',
    'Pallavi',
    'Ritika',
    'Sakshi',
    'Tanvi',
    'Vidya',
    'Zoya',
    'Ishita',
    'Komal',
    'Mansi',
  ];

  static const List<String> _lastNames = [
    'Sharma',
    'Patel',
    'Gupta',
    'Reddy',
    'Singh',
    'Mehta',
    'Kumar',
    'Verma',
    'Joshi',
    'Desai',
    'Shah',
    'Nair',
    'Rao',
    'Iyer',
    'Malhotra',
    'Kapoor',
    'Agarwal',
    'Chopra',
    'Bansal',
    'Khanna',
    'Bhatia',
    'Sinha',
    'Pillai',
    'Menon',
  ];

  static const List<String> _salonNames = [
    'Luxe Salon & Spa',
    'Beauty Haven',
    'Glamour Studio',
    'Divine Beauty',
    'The Style Lounge',
    'Radiance Salon',
    'Elite Beauty Bar',
    'Chic & Shine',
    'Bella Beauty Parlour',
    'Vanity Fair Salon',
    'Glam House',
    'Pure Bliss Spa',
    'Crown Beauty Studio',
    'Allure Salon',
    'Serenity Spa',
    'Elegance Beauty',
    'Silk & Shine',
    'Royal Touch Salon',
    'Bloom Beauty',
    'Zenith Spa',
  ];

  static const List<String> _cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Lucknow',
    'Chandigarh',
    'Indore',
  ];

  static const List<String> _streets = [
    'MG Road',
    'Brigade Road',
    'Park Street',
    'Anna Salai',
    'Linking Road',
    'Commercial Street',
    'Sector 17',
    'FC Road',
    'Marine Drive',
    'Connaught Place',
  ];

  static const List<String> _serviceNames = [
    'Hair Spa Therapy',
    'Bridal Makeup Package',
    'Luxury Facial Treatment',
    'Keratin Hair Treatment',
    'Professional Nail Art',
    'D-Tan Body Treatment',
    'Hair Coloring Service',
    'Relaxing Head Massage',
    'Anti-Aging Facial',
    'Deep Tissue Massage',
    'Pedicure & Manicure',
    'Hair Styling',
    'Threading',
    'Waxing Service',
    'Bleach Treatment',
    'Body Polishing',
    'Aromatherapy',
    'Hot Stone Massage',
    'Body Wrap',
    'Hair Straightening',
  ];

  static const List<String> _skills = [
    'Hair Spa',
    'Bridal Makeup',
    'Hair Coloring',
    'Nail Art',
    'Keratin Treatment',
    'Luxury Facial',
    'D-Tan Treatment',
    'Head Massage',
    'Threading',
    'Waxing',
    'Hair Styling',
    'Pedicure',
    'Manicure',
    'Body Massage',
    'Bleach',
  ];

  static const List<String> _timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 PM',
    '06:00 PM',
    '06:30 PM',
    '07:00 PM',
    '07:30 PM',
    '08:00 PM',
  ];

  /// Generate random salons
  static List<SalonModel> generateRandomSalons({int count = 10}) {
    final salons = <SalonModel>[];
    final usedNames = <String>{};

    for (int i = 0; i < count; i++) {
      String name;
      do {
        name = _salonNames[_random.nextInt(_salonNames.length)];
      } while (usedNames.contains(name));
      usedNames.add(name);

      final city = _cities[_random.nextInt(_cities.length)];
      final street = _streets[_random.nextInt(_streets.length)];

      salons.add(
        SalonModel(
          id: 'salon_${i + 1}',
          name: name,
          description:
              'Premium ${_random.nextBool() ? "beauty" : "wellness"} services with expert stylists',
          address: '${_random.nextInt(500) + 1}, $street',
          city: city,
          state: _getCityState(city),
          zipCode: '${_random.nextInt(900000) + 100000}',
          phone: '+91 ${_random.nextInt(900000000) + 9000000000}',
          email:
              '${name.toLowerCase().replaceAll(' ', '').replaceAll('&', '')}@salon.com',
          ownerId: 'owner_${i + 1}',
          rating: _random.nextDouble() * 1.5 + 3.5, // 3.5 to 5.0
          totalReviews: _random.nextInt(200) + 50,
          openingHours: _generateOpeningHours(),
          images: [],
          createdAt: DateTime.now().subtract(
            Duration(days: _random.nextInt(365)),
          ),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return salons;
  }

  /// Generate random stylists
  static List<Stylist> generateRandomStylists({
    int count = 20,
    required List<String> salonIds,
  }) {
    final stylists = <Stylist>[];

    for (int i = 0; i < count; i++) {
      final firstName = _firstNames[_random.nextInt(_firstNames.length)];
      final lastName = _lastNames[_random.nextInt(_lastNames.length)];
      final salonId = salonIds[_random.nextInt(salonIds.length)];

      // Random 2-5 skills
      final skillCount = _random.nextInt(4) + 2;
      final selectedSkills = <String>[];
      final skillsCopy = List<String>.from(_skills);
      skillsCopy.shuffle();
      for (int j = 0; j < skillCount && j < skillsCopy.length; j++) {
        selectedSkills.add(skillsCopy[j]);
      }

      stylists.add(
        Stylist(
          id: 'stylist_${i + 1}',
          name: '$firstName $lastName',
          salonId: salonId,
          isAvailable: _random.nextBool(),
          skills: selectedSkills,
        ),
      );
    }

    return stylists;
  }

  /// Generate random treatments
  static List<Treatment> generateRandomTreatments({int count = 15}) {
    final treatments = <Treatment>[];
    final usedServices = <String>{};

    for (
      int i = 0;
      i < count && usedServices.length < _serviceNames.length;
      i++
    ) {
      String serviceName;
      do {
        serviceName = _serviceNames[_random.nextInt(_serviceNames.length)];
      } while (usedServices.contains(serviceName));
      usedServices.add(serviceName);

      treatments.add(
        Treatment(
          id: 'treatment_${i + 1}',
          name: serviceName,
          price: _random.nextDouble() * 200 + 30, // $30 to $230
          isAvailable: _random.nextBool(),
        ),
      );
    }

    return treatments;
  }

  /// Generate random appointments
  static List<AppointmentModel> generateRandomAppointments({
    int count = 30,
    required List<String> salonIds,
    required List<Stylist> stylists,
    required String userId,
  }) {
    final appointments = <AppointmentModel>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final salonId = salonIds[_random.nextInt(salonIds.length)];
      final salonStylists = stylists
          .where((s) => s.salonId == salonId)
          .toList();

      if (salonStylists.isEmpty) continue;

      final stylist = salonStylists[_random.nextInt(salonStylists.length)];
      final serviceName = _serviceNames[_random.nextInt(_serviceNames.length)];

      // Random date: 50% past, 50% future
      final isPast = _random.nextBool();
      final daysOffset = _random.nextInt(30) + 1;
      final appointmentDate = isPast
          ? now.subtract(Duration(days: daysOffset))
          : now.add(Duration(days: daysOffset));

      final timeSlot = _timeSlots[_random.nextInt(_timeSlots.length)];
      final price = _random.nextDouble() * 150 + 40; // $40 to $190

      final status = isPast
          ? (_random.nextBool() ? 'completed' : 'cancelled')
          : (_random.nextBool() ? 'confirmed' : 'pending');

      final paymentStatus = isPast
          ? (_random.nextBool() ? 'paid' : 'unpaid')
          : (_random.nextDouble() > 0.7 ? 'paid' : 'unpaid');

      appointments.add(
        AppointmentModel(
          id: 'appt_${DateTime.now().millisecondsSinceEpoch}_$i',
          customerId: userId,
          customerName: 'Demo User',
          customerPhone: '+91 9876543210',
          customerEmail: 'demo@user.com',
          salonId: salonId,
          salonName: 'Salon $salonId',
          serviceId: 'service_$i',
          serviceName: serviceName,
          stylistId: stylist.id,
          stylistName: stylist.name,
          appointmentDate: appointmentDate,
          timeSlot: timeSlot,
          duration: _random.nextInt(60) + 30, // 30-90 minutes
          totalPrice: price,
          status: status,
          paymentStatus: paymentStatus,
          notes: _random.nextBool() ? 'Special request for extra care' : null,
          createdAt: appointmentDate.subtract(
            Duration(days: _random.nextInt(5) + 1),
          ),
          updatedAt: DateTime.now(),
        ),
      );
    }

    return appointments;
  }

  /// Initialize all random data
  static Future<void> initializeRandomData({
    int salonCount = 10,
    int stylistCount = 20,
    int treatmentCount = 15,
    int appointmentCount = 30,
    String? userId,
  }) async {
    print('🎲 Generating random data...');

    // Generate salons
    final salons = generateRandomSalons(count: salonCount);
    print('✅ Generated ${salons.length} salons');

    // Generate stylists
    final salonIds = salons.map((s) => s.id).toList();
    final stylists = generateRandomStylists(
      count: stylistCount,
      salonIds: salonIds,
    );
    print('✅ Generated ${stylists.length} stylists');

    // Generate treatments
    final treatments = generateRandomTreatments(count: treatmentCount);
    print('✅ Generated ${treatments.length} treatments');

    // Generate appointments (only if userId provided)
    if (userId != null && userId.isNotEmpty) {
      final appointments = generateRandomAppointments(
        count: appointmentCount,
        salonIds: salonIds,
        stylists: stylists,
        userId: userId,
      );
      print('✅ Generated ${appointments.length} appointments');

      // Populate BookingService
      final bookingService = BookingService();
      for (final appointment in appointments) {
        await bookingService.bookAppointment(appointment);
      }
    }

    // Note: AdminService, StylistService, and TreatmentService have their own data
    // This generator creates additional random data if needed
    print('✨ Random data generation complete!');
  }

  // Helper methods
  static String _getCityState(String city) {
    const cityStateMap = {
      'Mumbai': 'Maharashtra',
      'Delhi': 'Delhi',
      'Bangalore': 'Karnataka',
      'Hyderabad': 'Telangana',
      'Chennai': 'Tamil Nadu',
      'Kolkata': 'West Bengal',
      'Pune': 'Maharashtra',
      'Ahmedabad': 'Gujarat',
      'Jaipur': 'Rajasthan',
      'Lucknow': 'Uttar Pradesh',
      'Chandigarh': 'Chandigarh',
      'Indore': 'Madhya Pradesh',
    };
    return cityStateMap[city] ?? 'Unknown';
  }

  static Map<String, dynamic> _generateOpeningHours() {
    final openTime = '${_random.nextInt(3) + 8}:00 AM'; // 8-10 AM
    final closeTime = '${_random.nextInt(3) + 7}:00 PM'; // 7-9 PM

    return {
      'Monday': '$openTime - $closeTime',
      'Tuesday': '$openTime - $closeTime',
      'Wednesday': '$openTime - $closeTime',
      'Thursday': '$openTime - $closeTime',
      'Friday': '$openTime - $closeTime',
      'Saturday': '$openTime - $closeTime',
      'Sunday': _random.nextBool() ? '$openTime - $closeTime' : 'Closed',
    };
  }

  /// Get random full name
  static String getRandomName() {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];
    return '$firstName $lastName';
  }

  /// Get random rating between 3.0 and 5.0
  static double getRandomRating() {
    return _random.nextDouble() * 2 + 3; // 3.0 to 5.0
  }

  /// Get random price between min and max
  static double getRandomPrice({double min = 30, double max = 300}) {
    return _random.nextDouble() * (max - min) + min;
  }

  /// Get random availability
  static bool getRandomAvailability() {
    return _random.nextBool();
  }

  /// Get random phone number
  static String getRandomPhone() {
    return '+91 ${_random.nextInt(900000000) + 9000000000}';
  }

  /// Get random email
  static String getRandomEmail(String name) {
    final domain = [
      'gmail.com',
      'yahoo.com',
      'outlook.com',
    ][_random.nextInt(3)];
    return '${name.toLowerCase().replaceAll(' ', '.')}@$domain';
  }
}
