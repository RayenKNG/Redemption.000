import 'package:flutter/material.dart';
import 'package:saveplate/services/supabase_database_service.dart'; // ✅ Pake Supabase Service
import 'package:saveplate/models/product_model.dart';
import 'package:saveplate/screens/add_product_screen.dart';
import 'package:intl/intl.dart';

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
    const MenuTab(), // Halaman Menu
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
// 1. DASHBOARD TAB (SUPABASE VERSION)
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
// 3. MENU TAB (SUPABASE VERSION - FIXED!)
// ===============================================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = SupabaseDatabaseService(); // ✅ Pake Service Supabase

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text("Atur Menu"),
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
      // ✅ Stream-nya beda tipe datanya sama Firestore
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
              // ✅ CARA MAPPING DATA SUPABASE YANG BENAR
              final product = ProductModel.fromMap(snapshot.data![index]);

              return _buildProductCard(context, dbService, product);
            },
          );
        },
      ),
    );
  }

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
                      Text(
                        currency.format(product.price),
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
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
                    // ✅ FIX ERROR DELETE: Pake tanda seru (!) karena ID Supabase bisa null teorinya
                    if (product.id != null) {
                      db.deleteProduct(product.id!);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 4. WALLET TAB & 5. PROFILE TAB
// ===============================================================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Dompet")));
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Profil")));
}
