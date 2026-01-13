import 'package:flutter/material.dart';
import 'package:saveplate/screens/add_product_screen.dart';
import 'package:saveplate/screens/edit_product_screen.dart';
import 'package:saveplate/services/supabase_database_service.dart';
import 'package:saveplate/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:saveplate/services/auth_service.dart'; // Buat Logout

const Color kPrimaryColor = Color(0xFFFF6D00);
const Color kBgColor = Color(0xFFF9FAFB);

class MerchantMainScreen extends StatefulWidget {
  const MerchantMainScreen({super.key});
  @override
  State<MerchantMainScreen> createState() => _MerchantMainScreenState();
}

class _MerchantMainScreenState extends State<MerchantMainScreen> {
  int _currentIndex = 0;

  // ✅ UPDATE: SEKARANG ADA 4 HALAMAN
  final List<Widget> _pages = [
    const DashboardTab(),
    const OrdersTab(), // 👈 INI YANG TADI HILANG
    const MenuTab(),
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
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed, // Biar 4 icon muat rapi
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Dash",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Pesanan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: "Menu",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 1. DASHBOARD TAB (Dengan Refresh & UI Bagus)
// ===============================================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Future<void> _refreshData() async {
    // Trik Refresh: Karena pake StreamBuilder dia auto-update,
    // tapi kita kasih delay dikit biar user ngerasa nge-refresh.
    await Future.delayed(const Duration(seconds: 1));
  }

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
        title: const Text(
          "Dashboard Toko",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Switch Toko Buka/Tutup
          StreamBuilder<Map<String, dynamic>>(
            stream: db.getShopStatus(),
            builder: (context, snapshot) {
              bool isOpen = snapshot.data?['is_open'] ?? false;
              return Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isOpen,
                  activeColor: Colors.green,
                  onChanged: (val) => db.toggleShopStatus(val),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      // ✅ BUNGKUS DENGAN REFRESH INDICATOR
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: kPrimaryColor,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Biar bisa ditarik walau konten dikit
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Banner
              StreamBuilder<Map<String, dynamic>>(
                stream: db.getShopStatus(),
                builder: (context, snapshot) {
                  bool isOpen = snapshot.data?['is_open'] ?? false;
                  return Container(
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: (isOpen ? Colors.green : Colors.red)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      isOpen ? "Toko Sedang BUKA ✅" : "Toko Sedang TUTUP ⛔",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Statistik
              FutureBuilder<Map<String, dynamic>>(
                future: db.getDashboardStats(),
                builder: (context, snapshot) {
                  final data =
                      snapshot.data ?? {'today_revenue': 0, 'today_orders': 0};
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Omzet Hari Ini",
                          currency.format(data['today_revenue']),
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildStatCard(
                          "Total Pesanan",
                          "${data['today_orders']}x",
                          Icons.shopping_bag_outlined,
                          Colors.blue,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
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
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// ===============================================================
// 2. ORDERS TAB (UPDATE: Dengan Tombol Status)
// ===============================================================
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

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
        title: const Text(
          "Pesanan Masuk",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getMerchantOrdersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text("Belum ada pesanan masuk."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              final status = order['status'] ?? 'pending';

              return FutureBuilder<Map<String, dynamic>>(
                future: db.getProductById(order['product_id'].toString()),
                builder: (context, productSnap) {
                  final productName = productSnap.hasData
                      ? productSnap.data!['name']
                      : 'Loading...';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order #${order['id'].toString().substring(0, 4)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: status == 'done'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            "$productName (${order['quantity']}x)",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            currency.format(order['total_price']),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // TOMBOL AKSI MERCHANT
                          if (status == 'pending')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: () => db.updateOrderStatus(
                                  order['id'],
                                  'process',
                                ),
                                child: const Text(
                                  "Terima & Masak",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          if (status == 'process')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () =>
                                    db.updateOrderStatus(order['id'], 'done'),
                                child: const Text(
                                  "Pesanan Selesai",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ===============================================================
// 3. MENU TAB (CRUD Menu) - VERSI GRID CARD
// ===============================================================
class MenuTab extends StatelessWidget {
  // 👇 INI KUNCI BIAR GAK MERAH DI ATAS (_pages)
  // Jangan dihapus "const"-nya
  const MenuTab({super.key});

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
        title: const Text("Kelola Menu", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: db.getMerchantMenuStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Icon(Icons.no_food, size: 80, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Center(child: Text("Belum ada menu. Tambah dulu yuk!")),
                ],
              );
            }

            // TAMPILAN GRID (KARTU)
            return GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 Kolom
                childAspectRatio:
                    0.70, // Rasio Lebar : Tinggi (Disesuaikan biar muat tombol)
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = ProductModel.fromMap(snapshot.data![index]);

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. GAMBAR
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: product.imageUrl != null
                              ? Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  width: double.infinity,
                                  child: const Icon(
                                    Icons.fastfood,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),

                      // 2. TEXT INFO
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currency.format(product.price),
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Stok: ${product.stock}",
                              style: TextStyle(
                                fontSize: 11,
                                color: product.stock == 0
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 3. TOMBOL EDIT & HAPUS
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Tombol Edit (Kecil)
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditProductScreen(product: product),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),
                            ),

                            // Tombol Hapus (Kecil)
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Hapus Menu?"),
                                    content: Text(
                                      "Yakin mau hapus ${product.name}?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Batal"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          await db.deleteProduct(product.id!);
                                        },
                                        child: const Text(
                                          "Hapus",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  size: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ===============================================================
// 4. PROFILE TAB (Pastikan ini ada di paling bawah file)
// ===============================================================
class ProfileTab extends StatelessWidget {
  // PENTING: Harus ada 'const' di sini biar gak error di _pages
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange,
              child: Icon(Icons.store, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "Akun Merchant",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                // Logout dan kembali ke Login
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
