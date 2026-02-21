import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class CustomerManagementService extends ChangeNotifier {
  static final CustomerManagementService _instance =
      CustomerManagementService._internal();
  factory CustomerManagementService() => _instance;
  CustomerManagementService._internal();

  // In-memory storage for demo customers
  final List<UserModel> _customers = [
    UserModel(
      uid: 'cust_001',
      email: 'priya.sharma@email.com',
      name: 'Priya Sharma',
      phone: '+1 (555) 123-4567',
      role: 'customer',
      createdAt: DateTime(2024, 1, 15),
      loyaltyPoints: 450,
      address: '123 Main Street, Apt 4B, New York, NY 10001',
    ),
    UserModel(
      uid: 'cust_002',
      email: 'anjali.patel@email.com',
      name: 'Anjali Patel',
      phone: '+1 (555) 234-5678',
      role: 'customer',
      createdAt: DateTime(2024, 2, 10),
      loyaltyPoints: 320,
      address: '456 Oak Avenue, Los Angeles, CA 90001',
    ),
    UserModel(
      uid: 'cust_003',
      email: 'meera.reddy@email.com',
      name: 'Meera Reddy',
      phone: '+1 (555) 345-6789',
      role: 'customer',
      createdAt: DateTime(2024, 3, 5),
      loyaltyPoints: 580,
      address: '789 Pine Road, Chicago, IL 60601',
    ),
    UserModel(
      uid: 'cust_004',
      email: 'kavya.singh@email.com',
      name: 'Kavya Singh',
      phone: '+1 (555) 456-7890',
      role: 'customer',
      createdAt: DateTime(2024, 4, 20),
      loyaltyPoints: 210,
      address: '321 Elm Street, Houston, TX 77001',
    ),
    UserModel(
      uid: 'cust_005',
      email: 'divya.mehta@email.com',
      name: 'Divya Mehta',
      phone: '+1 (555) 567-8901',
      role: 'customer',
      createdAt: DateTime(2024, 5, 12),
      loyaltyPoints: 150,
      address: '654 Maple Drive, Phoenix, AZ 85001',
    ),
    UserModel(
      uid: 'cust_006',
      email: 'sneha.kumar@email.com',
      name: 'Sneha Kumar',
      phone: '+1 (555) 678-9012',
      role: 'customer',
      createdAt: DateTime(2024, 6, 8),
      loyaltyPoints: 720,
      address: '987 Cedar Lane, Philadelphia, PA 19101',
    ),
    UserModel(
      uid: 'cust_007',
      email: 'riya.desai@email.com',
      name: 'Riya Desai',
      phone: '+1 (555) 789-0123',
      role: 'customer',
      createdAt: DateTime(2024, 7, 15),
      loyaltyPoints: 390,
      address: '147 Birch Court, San Antonio, TX 78201',
    ),
    UserModel(
      uid: 'cust_008',
      email: 'pooja.verma@email.com',
      name: 'Pooja Verma',
      phone: '+1 (555) 890-1234',
      role: 'customer',
      createdAt: DateTime(2024, 8, 22),
      loyaltyPoints: 275,
      address: '258 Willow Way, San Diego, CA 92101',
    ),
  ];

  /// Get all customers
  List<UserModel> getAllCustomers() {
    return List.unmodifiable(_customers);
  }

  /// Get customer by ID
  UserModel? getCustomerById(String uid) {
    try {
      return _customers.firstWhere((customer) => customer.uid == uid);
    } catch (e) {
      return null;
    }
  }

  /// Search customers by name, email, or phone
  List<UserModel> searchCustomers(String query) {
    if (query.isEmpty) return getAllCustomers();

    final lowerQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
          customer.email.toLowerCase().contains(lowerQuery) ||
          customer.phone.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get top customers by loyalty points
  List<UserModel> getTopCustomers({int limit = 5}) {
    final sorted = List<UserModel>.from(_customers)
      ..sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
    return sorted.take(limit).toList();
  }

  /// Export customers to CSV format
  String exportToCSV() {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Name,Email,Phone,Address,Loyalty Points,Joined Date');

    // Data rows
    for (var customer in _customers) {
      buffer.writeln(
        '"${customer.name}","${customer.email}","${customer.phone}","${customer.address ?? 'N/A'}",${customer.loyaltyPoints},"${customer.createdAt.toIso8601String()}"',
      );
    }

    return buffer.toString();
  }

  /// Simulate phone call
  void simulateCall(String phoneNumber) {
    debugPrint('📞 Simulating call to $phoneNumber');
    // In a real app, this would use url_launcher to open tel: link
  }

  /// Simulate email
  void simulateEmail(String email) {
    debugPrint('📧 Simulating email to $email');
    // In a real app, this would use url_launcher to open mailto: link
  }

  /// Get customer statistics
  Map<String, dynamic> getCustomerStats() {
    return {
      'totalCustomers': _customers.length,
      'totalLoyaltyPoints': _customers.fold<int>(
        0,
        (sum, customer) => sum + customer.loyaltyPoints,
      ),
      'averageLoyaltyPoints': _customers.isEmpty
          ? 0
          : _customers.fold<int>(
                  0,
                  (sum, customer) => sum + customer.loyaltyPoints,
                ) /
                _customers.length,
      'newThisMonth': _customers.where((customer) {
        final now = DateTime.now();
        return customer.createdAt.year == now.year &&
            customer.createdAt.month == now.month;
      }).length,
    };
  }
}
