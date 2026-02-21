class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role; // 'customer' or 'admin'
  final DateTime createdAt;
  final String? profileImage;
  final int loyaltyPoints;
  final String? address;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.profileImage,
    this.loyaltyPoints = 0,
    this.address,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'address': address,
      'profileImage': profileImage,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'customer',
      createdAt: DateTime.parse(map['createdAt']),
      profileImage: map['profileImage'],
      address: map['address'],
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? role,
    DateTime? createdAt,
    String? profileImage,
    int? loyaltyPoints,
    String? address,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      address: address ?? this.address,
    );
  }
}
