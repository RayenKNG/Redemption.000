class FoodModel {
  // Ini adalah bahan-bahan yang wajib ada untuk setiap makanan
  final String id;
  final String name; // Nama makanan (misal: Roti Bakar)
  final String description; // Keterangan (misal: Sisa 2 porsi)
  final int price; // Harga diskon (15000)
  final int originalPrice; // Harga asli (30000)
  final String imageUrl; // Link foto makanan
  final String merchantName; // Nama tokonya (misal: Toko Roti A)
  final double rating; // Rating toko

  // Ini adalah 'konstruktor' (cara bikin objeknya nanti)
  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.merchantName,
    required this.rating,
  });
}

// --- DATA DUMMY (DATA PURA-PURA) ---
// Kita pakai ini dulu biar tampilan tidak kosong sebelum konek ke Firebase
List<FoodModel> dummyFoods = [
  FoodModel(
    id: '1',
    name: 'Paket Donat Sisa',
    description: 'Donat varian coklat & keju, kondisi masih sangat layak.',
    price: 20000,
    originalPrice: 45000,
    imageUrl:
        'https://images.unsplash.com/photo-1551024601-569d6f8e6176?q=80&w=1000&auto=format&fit=crop',
    merchantName: 'Dunkin KW',
    rating: 4.5,
  ),
  FoodModel(
    id: '2',
    name: 'Nasi Padang Lauk Ayam',
    description: 'Sisa kuota katering makan siang, belum disentuh.',
    price: 15000,
    originalPrice: 28000,
    imageUrl:
        'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=1000&auto=format&fit=crop',
    merchantName: 'RM Minang Rasa',
    rating: 4.8,
  ),
  FoodModel(
    id: '3',
    name: 'Croissant Butter',
    description: 'Roti fresh oven tadi pagi, tidak habis terjual.',
    price: 12000,
    originalPrice: 25000,
    imageUrl:
        'https://images.unsplash.com/photo-1555507036-ab1f40388085?q=80&w=1000&auto=format&fit=crop',
    merchantName: 'Bakery Mewah',
    rating: 4.7,
  ),
];
