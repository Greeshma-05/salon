import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/salon.dart';

/// Service to handle geolocation and nearby salon discovery
class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore? get firestore {
    try {
      if (Firebase.apps.isEmpty) {
        return null;
      }
      _firestore ??= FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      print('Firebase not initialized: $e');
      return null;
    }
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result == LocationPermission.whileInUse ||
          result == LocationPermission.always;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);

    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }

  /// Fetch nearby salons from Firebase within a radius (in km)
  Future<List<Salon>> getNearbySalons({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    try {
      final fs = firestore;
      if (fs == null) {
        print('Firebase not initialized, returning empty salon list');
        return [];
      }

      final salonsSnapshot = await fs.collection('salons').get();

      final nearbySalons = <Salon>[];

      for (final doc in salonsSnapshot.docs) {
        try {
          final salonData = doc.data();
          final salonLat = (salonData['latitude'] as num?)?.toDouble() ?? 0.0;
          final salonLon = (salonData['longitude'] as num?)?.toDouble() ?? 0.0;

          final distance = calculateDistance(
            latitude,
            longitude,
            salonLat,
            salonLon,
          );

          if (distance <= radiusKm) {
            final salon = Salon.fromMap({...salonData, 'id': doc.id});
            salon.distanceKm = distance;
            nearbySalons.add(salon);
          }
        } catch (e) {
          print('Error processing salon doc: $e');
          continue;
        }
      }

      // Sort by distance
      nearbySalons.sort(
        (a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0),
      );
      return nearbySalons;
    } catch (e) {
      print('Error fetching nearby salons: $e');
      return [];
    }
  }

  /// Search salons by location name (city/area)
  Future<List<Salon>> searchSalonsByLocation(String locationQuery) async {
    try {
      final fs = firestore;
      if (fs == null) return [];

      final salonsSnapshot = await fs
          .collection('salons')
          .where('location', isGreaterThanOrEqualTo: locationQuery)
          .where('location', isLessThan: locationQuery + 'z')
          .get();

      return salonsSnapshot.docs
          .map((doc) => Salon.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error searching salons by location: $e');
      return [];
    }
  }

  /// Update salon location in Firebase (for admin)
  Future<void> updateSalonLocation(
    String salonId,
    double latitude,
    double longitude,
  ) async {
    try {
      final fs = firestore;
      if (fs == null) return;

      await fs.collection('salons').doc(salonId).update({
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Error updating salon location: $e');
      rethrow;
    }
  }
}

// Helper class for math operations
class Math {
  static double sin(double x) => _sine(x);
  static double cos(double x) => _cosine(x);
  static double atan2(double y, double x) => _atan2(y, x);
  static double sqrt(double x) => x < 0 ? 0 : _sqrt(x);

  // Approximation functions for trigonometric operations
  static double _sine(double x) {
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;

    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  static double _cosine(double x) {
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;

    double result = 1;
    double term = 1;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _atan2(double y, double x) {
    const pi = 3.141592653589793;
    if (x > 0) return (y / x).atan();
    if (x < 0 && y >= 0) return (y / x).atan() + pi;
    if (x < 0 && y < 0) return (y / x).atan() - pi;
    if (x == 0 && y > 0) return pi / 2;
    if (x == 0 && y < 0) return -pi / 2;
    return 0;
  }

  static double _sqrt(double x) {
    if (x < 0) return 0;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}

extension on double {
  double atan() {
    final sign = this >= 0 ? 1.0 : -1.0;
    final x = this.abs();
    double result =
        (1.5707963267948966 -
        1.0 /
            (x +
                (0.2871 * x * x + 0.2847) /
                    (1 + (0.2871 + 0.2847 * x) * x))); // π/2
    return sign * result;
  }
}
