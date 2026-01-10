import 'package:flutter/material.dart';
import 'login_screen.dart'; // Buat logout nanti

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  bool _isShopOpen = true; // Status Toko (Buka/Tutup)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F5,
      ), // Background abu muda biar konten nonjol
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, Mitra!",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Text(
              "Toko Roti Makmur", // Nama Toko Mockup
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Tombol Logout Kecil
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATUS TOKO (Card Hijau)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isShopOpen
                    ? const Color(0xFF2ECC71)
                    : Colors.grey, // Hijau kalau buka
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isShopOpen
                        ? const Color(0xFF2ECC71).withOpacity(0.4)
                        : Colors.grey.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isShopOpen ? "TOKO BUKA" : "TOKO TUTUP",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isShopOpen
                            ? "Pembeli bisa melihat menu kamu"
                            : "Kamu sedang istirahat",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isShopOpen,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green[800],
                    onChanged: (val) {
                      setState(() => _isShopOpen = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2. RINGKASAN HARI INI (Grid)
            const Text(
              "Ringkasan Hari Ini",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard(
                  "Pesanan",
                  "12",
                  Icons.receipt_long,
                  Colors.orange,
                ),
                const SizedBox(width: 15),
                _buildStatCard(
                  "Pendapatan",
                  "Rp 250rb",
                  Icons.monetization_on,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 3. DAFTAR MAKANAN (List)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Menu Penyelamatan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(onPressed: () {}, child: const Text("Lihat Semua")),
              ],
            ),

            // Dummy Item 1
            _buildFoodItem("Paket Roti Sisa", "Sisa 3", "Rp 15.000", true),
            // Dummy Item 2
            _buildFoodItem("Donat Kemarin", "Habis", "Rp 10.000", false),
            // Dummy Item 3
            _buildFoodItem("Nasi Goreng Malam", "Sisa 5", "Rp 12.000", true),
          ],
        ),
      ),

      // --- TOMBOL TAMBAH MENU (FAB) ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Nanti ke halaman tambah menu
        },
        backgroundColor: const Color(0xFF2ECC71),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Menu"),
      ),
    );
  }

  // Widget Kecil buat Kotak Statistik
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // Widget Kecil buat List Makanan
  Widget _buildFoodItem(
    String name,
    String stock,
    String price,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          // Gambar Dummy (Kotak Abu)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.fastfood, color: Colors.grey[400]),
          ),
          const SizedBox(width: 15),
          // Info Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Status Stock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF2ECC71).withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              stock,
              style: TextStyle(
                color: isActive ? const Color(0xFF2ECC71) : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
