import 'dart:async';
import 'dart:math';
import '../models/stylist.dart';

class StylistService {
  // Singleton pattern
  static final StylistService _instance = StylistService._internal();
  factory StylistService() => _instance;
  StylistService._internal() {
    _startAvailabilityUpdates();
  }

  // In-memory storage for stylists
  final List<Stylist> _stylists = [
    Stylist(
      id: '1',
      name: 'Anjali Sharma',
      salonId: '1',
      isAvailable: true,
      skills: ['Hair Spa', 'Hair Coloring', 'Bridal Makeup'],
    ),
    Stylist(
      id: '2',
      name: 'Meera Patel',
      salonId: '1',
      isAvailable: false,
      skills: ['Keratin Treatment', 'Luxury Facial', 'D-Tan Treatment'],
    ),
    Stylist(
      id: '3',
      name: 'Riya Desai',
      salonId: '2',
      isAvailable: true,
      skills: ['Nail Art', 'Head Massage', 'Bridal Makeup'],
    ),
    Stylist(
      id: '4',
      name: 'Sneha Gupta',
      salonId: '2',
      isAvailable: true,
      skills: ['Hair Coloring', 'Hair Spa', 'Luxury Facial'],
    ),
    Stylist(
      id: '5',
      name: 'Priya Reddy',
      salonId: '3',
      isAvailable: false,
      skills: ['Bridal Makeup', 'D-Tan Treatment', 'Keratin Treatment'],
    ),
    Stylist(
      id: '6',
      name: 'Kavya Singh',
      salonId: '3',
      isAvailable: true,
      skills: ['Head Massage', 'Nail Art', 'Hair Spa'],
    ),
    Stylist(
      id: '7',
      name: 'Divya Mehta',
      salonId: '4',
      isAvailable: true,
      skills: ['Hair Coloring', 'Luxury Facial', 'Bridal Makeup'],
    ),
    Stylist(
      id: '8',
      name: 'Aarti Kumar',
      salonId: '5',
      isAvailable: false,
      skills: ['Keratin Treatment', 'Hair Spa', 'D-Tan Treatment'],
    ),
    Stylist(
      id: '9',
      name: 'Pooja Verma',
      salonId: '6',
      isAvailable: true,
      skills: ['Nail Art', 'Head Massage', 'Hair Coloring'],
    ),
    Stylist(
      id: '10',
      name: 'Neha Joshi',
      salonId: '7',
      isAvailable: true,
      skills: [
        'Bridal Makeup',
        'Luxury Facial',
        'Keratin Treatment',
        'Hair Spa',
      ],
    ),
  ];

  // StreamController for real-time updates
  final _stylistsController = StreamController<List<Stylist>>.broadcast();
  Stream<List<Stylist>> get stylistsStream => _stylistsController.stream;

  Timer? _availabilityTimer;
  final Random _random = Random();

  // Start automatic availability updates
  void _startAvailabilityUpdates() {
    // Toggle availability every 8-15 seconds randomly
    _availabilityTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _toggleRandomAvailability();
    });
  }

  // Toggle random stylist's availability
  void _toggleRandomAvailability() {
    if (_stylists.isEmpty) return;

    // Select 1-3 random stylists to toggle
    final numberOfToggles = _random.nextInt(3) + 1;
    for (int i = 0; i < numberOfToggles; i++) {
      final randomIndex = _random.nextInt(_stylists.length);
      _stylists[randomIndex].isAvailable = !_stylists[randomIndex].isAvailable;
    }

    // Notify listeners
    _stylistsController.add(_stylists);
  }

  // Get all stylists
  List<Stylist> getAllStylists() {
    return List.unmodifiable(_stylists);
  }

  // Get stylists by salon ID
  List<Stylist> getStylistsBySalon(String salonId) {
    return _stylists.where((stylist) => stylist.salonId == salonId).toList();
  }

  // Get available stylists by salon ID
  List<Stylist> getAvailableStylists(String salonId) {
    return _stylists
        .where((stylist) => stylist.salonId == salonId && stylist.isAvailable)
        .toList();
  }

  // Get stylist by ID
  Stylist? getStylistById(String id) {
    try {
      return _stylists.firstWhere((stylist) => stylist.id == id);
    } catch (e) {
      return null;
    }
  }

  // Manually toggle stylist availability
  void toggleStylistAvailability(String id) {
    final index = _stylists.indexWhere((stylist) => stylist.id == id);
    if (index != -1) {
      _stylists[index].isAvailable = !_stylists[index].isAvailable;
      _stylistsController.add(_stylists);
    }
  }

  // Dispose resources
  void dispose() {
    _availabilityTimer?.cancel();
    _stylistsController.close();
  }
}
