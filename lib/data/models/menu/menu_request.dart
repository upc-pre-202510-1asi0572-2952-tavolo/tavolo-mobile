class MenuRequest {
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageBase64;

  MenuRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_base64': imageBase64,
    };
  }

}