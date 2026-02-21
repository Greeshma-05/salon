class Treatment {
  final String id;
  final String name;
  final double price;
  bool isAvailable; // Mutable for dynamic updates

  Treatment({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
  });

  // Convert Treatment to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'isAvailable': isAvailable};
  }

  // Create Treatment from JSON
  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool,
    );
  }

  // Create a copy with modified fields
  Treatment copyWith({
    String? id,
    String? name,
    double? price,
    bool? isAvailable,
  }) {
    return Treatment(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
