import 'package:flutter/material.dart';
import 'package:saveplate/services/supabase_database_service.dart'; // Pake DB baru
import 'package:saveplate/models/product_model.dart';
import 'package:saveplate/screens/add_product_screen.dart';
import 'package:intl/intl.dart'; // Add 'intl' di pubspec.yaml buat format duit

// ... Class MerchantMainScreen tetep sama ...

// ===============================================================
// 1. DASHBOARD TAB (UPDATE: Fitur Buka Tutup Toko)
// ===============================================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, Boss!",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "Roti Makmur",
              style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // SWITCH BUKA TUTUP TOKO REALTIME
          StreamBuilder<Map<String, dynamic>>(
            stream: dbService.getShopStatus(),
            builder: (context, snapshot) {
              bool isOpen = false;
              if (snapshot.hasData) isOpen = snapshot.data!['is_open'] ?? false;

              return Container(
                margin: const EdgeInsets.only(right: 15),
                child: Row(
                  children: [
                    Text(
                      isOpen ? "BUKA" : "TUTUP",
                      style: TextStyle(
                        color: isOpen ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isOpen,
                      activeColor: Colors.green,
                      onChanged: (val) => dbService.toggleShopStatus(val),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text("Isi Dashboard Statistik Disini...")),
    );
  }
}

// ... OrdersTab biarin dulu ...

// ===============================================================
// 3. MENU TAB (UPDATE: Card Cantik & Logic Stok)
// ===============================================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text("Manajemen Menu"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: dbService.getMenuStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(
              child: Text("Belum ada menu, jual sisa makananmu sekarang!"),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final product = ProductModel.fromMap(snapshot.data![index]);
              return _buildProductCard(context, dbService, product);
            },
          );
        },
      ),
    );
  }

  // 👇 CARD BARU: Lebih Visual & User Friendly
  Widget _buildProductCard(
    BuildContext context,
    SupabaseDatabaseService db,
    ProductModel product,
  ) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    bool isOutOfStock = product.stock <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. BAGIAN GAMBAR & STATUS STOK
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  image: product.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: product.imageUrl == null
                    ? const Icon(Icons.fastfood, size: 50, color: Colors.grey)
                    : null,
              ),
              // Overlay kalau habis
              if (isOutOfStock)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "STOK HABIS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              // Badge Diskon
              if (!isOutOfStock)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Hemat Makanan!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 2. BAGIAN DETAIL INFO
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Harga Coret vs Harga Jual
                      Row(
                        children: [
                          Text(
                            currency.format(product.originalPrice),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currency.format(product.price),
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Indikator Stok
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 14,
                            color: isOutOfStock ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOutOfStock
                                ? "Stok: 0 (Restock yuk!)"
                                : "Sisa Stok: ${product.stock}",
                            style: TextStyle(
                              color: isOutOfStock
                                  ? Colors.red
                                  : Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tombol Hapus / Edit
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => db.deleteProduct(product.id!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
