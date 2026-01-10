import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ WAJIB
import 'package:saveplate/services/firestore_service.dart'; // ✅ WAJIB
import 'package:saveplate/models/product_model.dart'; // ✅ WAJIB
import 'package:saveplate/screens/add_product_screen.dart';

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

  // ✅ DAFTAR HALAMAN BERSIH (Hanya panggil nama class)
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
// 1. DASHBOARD TAB (HOME) - TIDAK BERUBAH
// ===============================================================
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool isShopOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Roti Makmur",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        actions: [
          Switch(
            value: isShopOpen,
            activeColor: Colors.green,
            onChanged: (val) => setState(() => isShopOpen = val),
          ),
        ],
      ),
      body: const Center(child: Text("Dashboard Content Here")),
    );
  }
}

// ===============================================================
// 2. ORDERS TAB - TIDAK BERUBAH
// ===============================================================
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Orders Content")));
  }
}

// ===============================================================
// 3. MENU TAB (BAGIAN INI YANG KITA PERBAIKI TOTAL)
// ===============================================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Panggil Service Firebase
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Atur Menu",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
      ),
      // 2. Pake StreamBuilder buat Live Data
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getProducts(),
        builder: (context, snapshot) {
          // Kalau Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kalau Data Kosong
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_food, size: 80, color: Colors.grey[300]),
                  Text(
                    "Belum ada menu, tambah dulu yuk!",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Kalau Ada Data
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              // Convert Data Firebase ke ProductModel
              ProductModel product = ProductModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              // Panggil Fungsi Tampilan (Widget) di bawah
              return _buildMenuTile(context, firestoreService, product);
            },
          );
        },
      ),
    );
  }

  // 3. Fungsi Widget dipindah ke DALAM class MenuTab
  Widget _buildMenuTile(
    BuildContext context,
    FirestoreService service,
    ProductModel product,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          // Gambar Produk
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              image: product.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl == null
                ? const Icon(Icons.fastfood, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 15),

          // Info Produk
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
                  "Rp ${product.price}",
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Stok: ${product.stock}",
                  style: TextStyle(
                    color: product.stock > 0 ? Colors.grey : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Hapus (Sampah)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              // Panggil Service Hapus
              service.deleteProduct(product.id);
            },
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 4. WALLET TAB - TIDAK BERUBAH
// ===============================================================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Wallet Content")));
  }
}

// ===============================================================
// 5. PROFILE TAB - TIDAK BERUBAH
// ===============================================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Profile Content")));
  }
}
