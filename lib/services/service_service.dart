import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/service_model.dart';

class ServiceService extends ChangeNotifier {
  static final ServiceService _instance = ServiceService._internal();
  factory ServiceService() => _instance;
  ServiceService._internal();

  static const String _servicesKey = 'services_data';
  final StreamController<List<ServiceModel>> _servicesController =
      StreamController<List<ServiceModel>>.broadcast();

  // Get all services
  Stream<List<ServiceModel>> getServices() async* {
    final prefs = await SharedPreferences.getInstance();
    final servicesJson = prefs.getString(_servicesKey);

    if (servicesJson == null) {
      yield [];
      return;
    }

    final services = Map<String, dynamic>.from(jsonDecode(servicesJson));
    yield services.entries
        .map(
          (e) =>
              ServiceModel.fromMap(Map<String, dynamic>.from(e.value), e.key),
        )
        .where((service) => service.isActive)
        .toList();
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getString(_servicesKey);

      if (servicesJson == null) return null;

      final services = Map<String, dynamic>.from(jsonDecode(servicesJson));
      final serviceData = services[id];

      if (serviceData == null) return null;

      return ServiceModel.fromMap(Map<String, dynamic>.from(serviceData), id);
    } catch (e) {
      throw Exception('Failed to get service: ${e.toString()}');
    }
  }

  // Get all services (synchronous)
  List<ServiceModel> getAllServices() {
    // This will be populated from stream/SharedPreferences
    // For now return empty list - use getServices() stream instead
    return [];
  }

  // Get all services list (async)
  Future<List<ServiceModel>> getAllServicesList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getString(_servicesKey);

      if (servicesJson == null) return [];

      final services = Map<String, dynamic>.from(jsonDecode(servicesJson));
      return services.entries
          .map(
            (e) =>
                ServiceModel.fromMap(Map<String, dynamic>.from(e.value), e.key),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting all services: $e');
      return [];
    }
  }

  // Add service (admin only)
  Future<void> addService(ServiceModel service) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getString(_servicesKey);
      final services = servicesJson != null
          ? Map<String, dynamic>.from(jsonDecode(servicesJson))
          : <String, dynamic>{};

      final serviceId = DateTime.now().millisecondsSinceEpoch.toString();
      services[serviceId] = service.toMap();
      await prefs.setString(_servicesKey, jsonEncode(services));
      notifyListeners();
      debugPrint('✅ Service added: ${service.name}');
    } catch (e) {
      throw Exception('Failed to add service: ${e.toString()}');
    }
  }

  // Update service (admin only)
  Future<void> updateService(String id, ServiceModel service) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getString(_servicesKey);

      if (servicesJson == null) return;

      final services = Map<String, dynamic>.from(jsonDecode(servicesJson));
      if (services.containsKey(id)) {
        services[id] = service.toMap();
        await prefs.setString(_servicesKey, jsonEncode(services));
        notifyListeners();
        debugPrint('✅ Service updated: ${service.name}');
      }
    } catch (e) {
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  // Delete service (admin only)
  Future<void> deleteService(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final servicesJson = prefs.getString(_servicesKey);

      if (servicesJson == null) return;

      final services = Map<String, dynamic>.from(jsonDecode(servicesJson));
      services.remove(id);
      await prefs.setString(_servicesKey, jsonEncode(services));
      notifyListeners();
      debugPrint('❌ Service deleted: $id');
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }

  // Activate service
  Future<void> activateService(String id) async {
    final service = await getServiceById(id);
    if (service != null) {
      await updateService(id, service.copyWith(isActive: true));
      debugPrint('✅ Service activated: ${service.name}');
    }
  }

  // Deactivate service
  Future<void> deactivateService(String id) async {
    final service = await getServiceById(id);
    if (service != null) {
      await updateService(id, service.copyWith(isActive: false));
      debugPrint('⏸️ Service deactivated: ${service.name}');
    }
  }

  // Toggle service active status
  Future<void> toggleServiceStatus(String id) async {
    final service = await getServiceById(id);
    if (service != null) {
      await updateService(id, service.copyWith(isActive: !service.isActive));
    }
  }

  @override
  void dispose() {
    _servicesController.close();
    super.dispose();
  }
}
