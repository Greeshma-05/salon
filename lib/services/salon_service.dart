import 'dart:math';
import '../models/simple_salon.dart';

class SalonService {
  // In-memory storage for salons
  static final List<SimpleSalon> _salons = [
    SimpleSalon(
      id: '1',
      name: 'Glamour Studio',
      address: '123 Fashion Street, Mumbai',
      latitude: 19.0760,
      longitude: 72.8777,
      rating: 4.8,
      services: ['Hair Spa', 'Bridal Makeup', 'Nail Art', 'Hair Coloring'],
    ),
    SimpleSalon(
      id: '2',
      name: 'Beauty Haven',
      address: '456 Style Avenue, Mumbai',
      latitude: 19.1136,
      longitude: 72.8697,
      rating: 4.5,
      services: ['Luxury Facial', 'Keratin Treatment', 'D-Tan Treatment'],
    ),
    SimpleSalon(
      id: '3',
      name: 'Elegant Touch',
      address: '789 Spa Lane, Mumbai',
      latitude: 19.0970,
      longitude: 72.9074,
      rating: 4.7,
      services: ['Head Massage', 'Hair Coloring', 'Bridal Makeup'],
    ),
    SimpleSalon(
      id: '4',
      name: 'Royal Beauty',
      address: '321 Luxury Road, Mumbai',
      latitude: 19.0544,
      longitude: 72.8320,
      rating: 4.9,
      services: ['Hair Spa', 'Luxury Facial', 'Nail Art', 'Keratin Treatment'],
    ),
    SimpleSalon(
      id: '5',
      name: 'Diva Salon',
      address: '555 Glam Boulevard, Mumbai',
      latitude: 19.1197,
      longitude: 72.9081,
      rating: 4.6,
      services: ['D-Tan Treatment', 'Hair Coloring', 'Head Massage'],
    ),
    SimpleSalon(
      id: '6',
      name: 'Sparkle & Shine',
      address: '888 Beauty Plaza, Mumbai',
      latitude: 19.0330,
      longitude: 72.8479,
      rating: 4.4,
      services: ['Bridal Makeup', 'Nail Art', 'Hair Spa'],
    ),
    SimpleSalon(
      id: '7',
      name: 'Radiant Glow',
      address: '999 Wellness Center, Mumbai',
      latitude: 19.1450,
      longitude: 72.8250,
      rating: 4.8,
      services: [
        'Luxury Facial',
        'Keratin Treatment',
        'D-Tan Treatment',
        'Head Massage',
      ],
    ),
    SimpleSalon(
      id: '8',
      name: 'Chic Studio',
      address: '147 Trendy Street, Mumbai',
      latitude: 19.0896,
      longitude: 72.8656,
      rating: 4.3,
      services: ['Hair Coloring', 'Nail Art', 'Hair Spa'],
    ),
    SimpleSalon(
      id: '9',
      name: 'Bliss Spa & Salon',
      address: '258 Serenity Road, Mumbai',
      latitude: 19.1025,
      longitude: 72.8933,
      rating: 4.7,
      services: [
        'Bridal Makeup',
        'Luxury Facial',
        'Head Massage',
        'Keratin Treatment',
      ],
    ),
    SimpleSalon(
      id: '10',
      name: 'Elite Beauty Lounge',
      address: '369 Premium Avenue, Mumbai',
      latitude: 19.0650,
      longitude: 72.8520,
      rating: 5.0,
      services: [
        'Hair Spa',
        'D-Tan Treatment',
        'Nail Art',
        'Hair Coloring',
        'Bridal Makeup',
      ],
    ),
  ];

  // Calculate distance between two coordinates using Haversine formula
  // Returns distance in kilometers
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Get nearby salons within specified radius (default 10km)
  List<SimpleSalon> getNearbySalons(
    double userLat,
    double userLng, {
    double radiusKm = 10.0,
  }) {
    final List<Map<String, dynamic>> salonsWithDistance = [];

    for (var salon in _salons) {
      final double distance = calculateDistance(
        userLat,
        userLng,
        salon.latitude,
        salon.longitude,
      );

      if (distance <= radiusKm) {
        salonsWithDistance.add({'salon': salon, 'distance': distance});
      }
    }

    // Sort by distance (nearest first)
    salonsWithDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    return salonsWithDistance
        .map((item) => item['salon'] as SimpleSalon)
        .toList();
  }

  // Get all salons
  List<SimpleSalon> getAllSalons() {
    return List.unmodifiable(_salons);
  }

  // Get salon by ID
  SimpleSalon? getSalonById(String id) {
    try {
      return _salons.firstWhere((salon) => salon.id == id);
    } catch (e) {
      return null;
    }
  }
}
