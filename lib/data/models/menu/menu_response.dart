class MenuResponse {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageBase64;

  MenuResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageBase64,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: ((json['price'] ?? 0) as num).toDouble(),
      category: json['category'] ?? '',
      imageBase64: json['imageBase64'] ?? '', // Corregido aquí
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageBase64': imageBase64, // Corregido aquí también
    };
  }
}