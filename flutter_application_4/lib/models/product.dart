class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String description;
  final double price;
  final String image;
  bool isFavorite; // Favori durumunu takip etmek için

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.image,
    this.isFavorite = false, // Varsayılan olarak favori değil
  });

  // JSON'dan nesneye dönüştürme (Null Güvenliği Eklenmiş)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? "",
      name: json['name'] ?? "Bilinmeyen Ürün",
      brand: json['brand'] ?? "Markasız",
      category: json['category'] ?? "Genel",
      description: json['description'] ?? "Açıklama bulunmuyor.",
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image'] ?? "https://via.placeholder.com/150",
      isFavorite: false, // JSON'dan ilk yüklendiğinde favori değil
    );
  }
}