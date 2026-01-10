import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  final AuthService _authService = AuthService();

  // 👇 Data Dummy dulu buat nge-test tampilan (Nanti kita ganti pake Firebase)
  final List<Map<String, dynamic>> _dummyProducts = [
    {
      "name": "Nasi Goreng Spesial",
      "price": 15000,
      "stock": 5,
      "image": "https://via.placeholder.com/150", // Gambar contoh
    },
    {
      "name": "Ayam Bakar Madu",
      "price": 20000,
      "stock": 2,
      "image": "https://via.placeholder.com/150",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5,
      ), // Abu-abu muda biar konten nonjol
      // 1. APP BAR (Bagian Atas)
      appBar: AppBar(
        title: const Text(
          "Dashboard Toko",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2ECC71), // Hijau SavePlate
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),

      // 2. BODY (Isi Konten)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Menu Makanan Kamu",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Grid buat nampilin makanan
            Expanded(
              child: _dummyProducts.isEmpty
                  ? _buildEmptyState() // Tampilan kalau kosong
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2 Kolom ke samping
                            childAspectRatio:
                                0.75, // Perbandingan lebar:tinggi kartu
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _dummyProducts.length,
                      itemBuilder: (context, index) {
                        final product = _dummyProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        ),
      ),

      // 3. FLOATING ACTION BUTTON (Tombol Tambah)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2ECC71),
        onPressed: () {
          // Nanti kita arahin ke halaman tambah produk di sini
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fitur Tambah Produk Coming Soon!")),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 👇 Widget Kecil: Tampilan Kartu Produk
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                image: DecorationImage(
                  image: NetworkImage(product['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Info Produk
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${product['price']}",
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Stok: ${product['stock']}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👇 Widget Kecil: Tampilan Kalau Kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fastfood_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada makanan dijual.",
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
