import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ WAJIB (Buat Rupiah)

// ✅ WAJIB: MODEL & SERVICE
import 'package:saveplate/models/product_model.dart';
import 'package:saveplate/services/supabase_database_service.dart';

// ✅ WAJIB: HALAMAN-HALAMAN LAIN
import 'package:saveplate/screens/product_detail_screen.dart';
import 'package:saveplate/screens/edit_product_screen.dart';
import 'package:saveplate/screens/add_product_screen.dart'; // 👈 INI YANG TADI KURANG BRO!

// --- KONFIGURASI WARNA ---
const Color kPrimaryColor = Color(0xFFFF6D00);
const Color kBgColor = Color(0xFFF9FAFB);
const Color kTextDark = Color(0xFF1F2937);

class MerchantMainScreen extends StatefulWidget {
  const MerchantMainScreen({super.key});

  @override
  State<MerchantMainScreen> createState() => _MerchantMainScreenState();
}

class _MerchantMainScreenState extends State<MerchantMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardTab(),
    const OrdersTab(),
    const MenuTab(),
    const WalletTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Beranda",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Pesanan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: "Menu",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: "Dompet",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 1. DASHBOARD TAB (UPDATE: ADA STATISTIKNYA)
// ===============================================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          "Dashboard Owner",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS TOKO CARD
            StreamBuilder<Map<String, dynamic>>(
              stream: dbService.getShopStatus(),
              builder: (context, snapshot) {
                bool isOpen = snapshot.data?['is_open'] ?? false;
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isOpen ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOpen ? "TOKO SEDANG BUKA" : "TOKO TUTUP",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isOpen ? Colors.green : Colors.red,
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
            const SizedBox(height: 20),

            // STATISTIK REALTIME (FutureBuilder)
            FutureBuilder<Map<String, dynamic>>(
              future: dbService.getDashboardStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LinearProgressIndicator());
                }

                final data =
                    snapshot.data ??
                    {
                      'today_revenue': 0,
                      'today_orders': 0,
                      'total_products': 0,
                    };

                return Row(
                  children: [
                    // CARD 1: PENDAPATAN HARI INI
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Omzet Hari Ini",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              currency.format(data['today_revenue']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // CARD 2: TOTAL ORDER
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Pesanan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${data['today_orders']} Order",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 25),
            const Text(
              "Menu Laris Manis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Placeholder Grafik/List
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  "Grafik Penjualan Akan Muncul Disini",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 2. ORDERS TAB
// ===============================================================
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Pesanan")));
}

// ===============================================================
// 3. MENU TAB (SUDAH DIPERBAIKI TOTAL)
// ===============================================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();

    // ✅ KEMBALIKAN KE SCAFFOLD (JANGAN DIBUNGKUS GESTURE DISINI)
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          "Atur Menu",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada menu, yuk tambah!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final product = ProductModel.fromMap(snapshot.data![index]);
              // Panggil fungsi kartu di bawah
              return _buildProductCard(context, dbService, product);
            },
          );
        },
      ),
    );
  }

  // 👇 FITUR EDIT & HAPUS ADA DISINI
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

    // ✅ GESTURE DETECTOR ITU DISINI TEMPATNYA (Bungkus Kartu)
    return GestureDetector(
      onTap: () {
        // Klik Kartu -> Pindah ke Detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
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
            // 1. GAMBAR & LABEL
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    color: Colors.grey[200],
                    image: product.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(product.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.imageUrl == null
                      ? const Icon(Icons.fastfood, size: 50, color: Colors.grey)
                      : null,
                ),
                if (isOutOfStock)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "HABIS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (!isOutOfStock)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Food Rescue",
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

            // 2. INFO & TOMBOL AKSI (EDIT + DELETE)
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
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Sisa Stok: ${product.stock}",
                          style: TextStyle(
                            fontSize: 12,
                            color: isOutOfStock ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 👇 INI DIA TOMBOL EDIT & HAPUS BERDAMPINGAN
                  Row(
                    children: [
                      // TOMBOL EDIT (Pensil)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProductScreen(product: product),
                            ),
                          );
                        },
                      ),

                      // TOMBOL HAPUS (Sampah + Pop Up)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          // Pop-up Konfirmasi
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Hapus Menu?"),
                              content: Text(
                                "Yakin mau hapus '${product.name}'?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Gak Jadi"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (product.id != null)
                                      db.deleteProduct(product.id!);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} // ===============================================================

// 4. WALLET TAB (BENDAHARA - SUDAH FIX)
// ===============================================================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text("Dompet Bendahara"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Total Saldo
          FutureBuilder<int>(
            future: db.getTotalRevenue(),
            builder: (context, snapshot) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: kTextDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Total Pendapatan",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      currency.format(snapshot.data ?? 0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Transaksi Terakhir",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // List Riwayat
          Expanded(
            child: StreamBuilder(
              stream: db.getTransactionHistory(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final data = snapshot.data as List;
                if (data.isEmpty)
                  return const Center(child: Text("Belum ada duit masuk bro"));

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final tx = data[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.greenAccent,
                        child: Icon(Icons.attach_money, color: Colors.green),
                      ),
                      title: Text("Penjualan #${tx['id']}"),
                      subtitle: Text(
                        DateFormat(
                          'dd MMM HH:mm',
                        ).format(DateTime.parse(tx['created_at'])),
                      ),
                      trailing: Text(
                        "+ ${currency.format(tx['total_price'])}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 5. PROFILE TAB
// ===============================================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Profil")));
}
