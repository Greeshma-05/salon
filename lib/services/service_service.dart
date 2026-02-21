import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/service_model.dart';

class ServiceService {
  static const String _servicesKey = 'services_data';

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
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }
}
