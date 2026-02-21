import 'dart:async';
import 'dart:math';
import '../models/treatment.dart';

class TreatmentService {
  // Singleton pattern
  static final TreatmentService _instance = TreatmentService._internal();
  factory TreatmentService() => _instance;
  TreatmentService._internal() {
    _startAvailabilityUpdates();
  }

  // In-memory storage for treatments
  final List<Treatment> _treatments = [
    Treatment(
      id: '1',
      name: 'Hair Spa Therapy',
      price: 75.00,
      isAvailable: true,
    ),
    Treatment(
      id: '2',
      name: 'Bridal Makeup Package',
      price: 250.00,
      isAvailable: false,
    ),
    Treatment(
      id: '3',
      name: 'Luxury Facial Treatment',
      price: 120.00,
      isAvailable: true,
    ),
    Treatment(
      id: '4',
      name: 'Keratin Hair Treatment',
      price: 180.00,
      isAvailable: true,
    ),
    Treatment(
      id: '5',
      name: 'Professional Nail Art',
      price: 45.00,
      isAvailable: false,
    ),
    Treatment(
      id: '6',
      name: 'D-Tan Body Treatment',
      price: 95.00,
      isAvailable: true,
    ),
    Treatment(
      id: '7',
      name: 'Hair Coloring Service',
      price: 85.00,
      isAvailable: true,
    ),
    Treatment(
      id: '8',
      name: 'Relaxing Head Massage',
      price: 40.00,
      isAvailable: false,
    ),
    Treatment(
      id: '9',
      name: 'Anti-Aging Facial',
      price: 150.00,
      isAvailable: true,
    ),
    Treatment(
      id: '10',
      name: 'Deep Tissue Massage',
      price: 110.00,
      isAvailable: true,
    ),
  ];

  // StreamController for real-time updates
  final _treatmentsController = StreamController<List<Treatment>>.broadcast();
  Stream<List<Treatment>> get treatmentsStream => _treatmentsController.stream;

  Timer? _availabilityTimer;
  final Random _random = Random();

  // Start automatic availability updates
  void _startAvailabilityUpdates() {
    // Toggle availability every 10 seconds
    _availabilityTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _toggleRandomAvailability();
    });
  }

  // Toggle random treatment's availability
  void _toggleRandomAvailability() {
    if (_treatments.isEmpty) return;

    // Select 2-4 random treatments to toggle
    final numberOfToggles = _random.nextInt(3) + 2;
    for (int i = 0; i < numberOfToggles; i++) {
      final randomIndex = _random.nextInt(_treatments.length);
      _treatments[randomIndex].isAvailable =
          !_treatments[randomIndex].isAvailable;
    }

    // Notify listeners
    _treatmentsController.add(_treatments);
  }

  // Get all treatments
  List<Treatment> getAllTreatments() {
    return List.unmodifiable(_treatments);
  }

  // Get available treatments only
  List<Treatment> getAvailableTreatments() {
    return _treatments.where((treatment) => treatment.isAvailable).toList();
  }

  // Get treatment by ID
  Treatment? getTreatmentById(String id) {
    try {
      return _treatments.firstWhere((treatment) => treatment.id == id);
    } catch (e) {
      return null;
    }
  }

  // Manually toggle treatment availability
  void toggleTreatmentAvailability(String id) {
    final index = _treatments.indexWhere((treatment) => treatment.id == id);
    if (index != -1) {
      _treatments[index].isAvailable = !_treatments[index].isAvailable;
      _treatmentsController.add(_treatments);
    }
  }

  // Dispose resources
  void dispose() {
    _availabilityTimer?.cancel();
    _treatmentsController.close();
  }
}
