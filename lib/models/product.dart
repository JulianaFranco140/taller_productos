class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  // La API de dummyjson llama "title" al nombre y "thumbnail" a la imagen.
  // El precio puede llegar como entero o decimal, por eso se lee como num.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['title'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['thumbnail'] as String,
    );
  }
}
