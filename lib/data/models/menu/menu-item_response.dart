class MenuItemResponse {
  final int id;
  final String name;
  final String description;
  final double price;

  MenuItemResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory MenuItemResponse.fromJson(Map<String, dynamic> json) {
    return MenuItemResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
    );
  }
}
