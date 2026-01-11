class ProductModel {
  final String? id; // Supabase ID (bisa null pas create)
  final String merchantId;
  final String name;
  final int originalPrice; // Harga Asli (Coret)
  final int price; // Harga Jual (Diskon)
  final int stock;
  final bool isActive;
  final String? imageUrl;

  ProductModel({
    this.id,
    required this.merchantId,
    required this.name,
    required this.originalPrice,
    required this.price,
    required this.stock,
    required this.isActive,
    this.imageUrl,
  });

  // Convert dari JSON Supabase (snake_case) ke Dart
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'].toString(),
      merchantId: map['merchant_id'] ?? '',
      name: map['name'] ?? '',
      originalPrice: map['original_price'] ?? 0,
      price: map['price'] ?? 0,
      stock: map['stock'] ?? 0,
      isActive: map['is_active'] ?? true,
      imageUrl: map['image_url'],
    );
  }

  // Convert ke JSON Supabase
  Map<String, dynamic> toMap() {
    return {
      'merchant_id': merchantId,
      'name': name,
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }
}
