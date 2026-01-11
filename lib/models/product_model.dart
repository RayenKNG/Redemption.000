class ProductModel {
  final String? id;
  final String merchantId;
  final String name;
  final String? description; // ✅ BARU: Deskripsi
  final int originalPrice;
  final int price;
  final int stock;
  final bool isActive;
  final String? imageUrl;

  ProductModel({
    this.id,
    required this.merchantId,
    required this.name,
    this.description, // ✅ BARU
    required this.originalPrice,
    required this.price,
    required this.stock,
    required this.isActive,
    this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'].toString(),
      merchantId: map['merchant_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'], // ✅ BARU
      originalPrice: map['original_price'] ?? 0,
      price: map['price'] ?? 0,
      stock: map['stock'] ?? 0,
      isActive: map['is_active'] ?? true,
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchant_id': merchantId,
      'name': name,
      'description': description, // ✅ BARU
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }
}
