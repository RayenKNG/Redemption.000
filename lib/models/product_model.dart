class ProductModel {
  final String id;
  final String name;
  final int price;
  final int stock;
  final bool isActive;
  final String? imageUrl; // ✅ Ada URL Gambar

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.isActive,
    this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      name: data['name'] ?? 'Tanpa Nama',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }
}
