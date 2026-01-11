import 'package:flutter/material.dart';
import 'package:saveplate/screens/add_product_screen.dart';
import 'package:saveplate/screens/product_detail_screen.dart'; // ✅ WAJIB IMPORT INI
import 'package:saveplate/services/supabase_database_service.dart'; // ✅ WAJIB
import 'package:saveplate/models/product_model.dart'; // ✅ WAJIB
import 'package:intl/intl.dart'; // ✅ WAJIB

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
// 1. DASHBOARD TAB
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
      body: const Center(child: Text("Statistik Penjualan (Coming Soon)")),
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
// 3. MENU TAB (FIXED GESTURE DETECTOR)
// ===============================================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService();

    // ❌ DULU KAMU SALAH NARUH GESTURE DETECTOR DISINI
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
              // Panggil Widget Kartu di bawah
              return _buildProductCard(context, dbService, product);
            },
          );
        },
      ),
    );
  }

  // 👇 LOGIC CARD + NAVIGASI ADA DI SINI (BUKAN DI ATAS)
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

    // ✅ GESTURE DETECTOR YANG BENAR ADA DISINI
    // Dia membungkus Container kartu, bukan membungkus Scaffold.
    return GestureDetector(
      onTap: () {
        // Pindah ke halaman detail pas diklik
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
            // GAMBAR & STATUS
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

            // INFO PRODUK
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
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      if (product.id != null) db.deleteProduct(product.id!);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
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
