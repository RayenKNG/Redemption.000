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
// 2. ORDERS TAB (INI YANG BARU & PENTING!)
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: db.getMerchantOrdersStream(), // Ambil data realtime
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    const Text(
                      "Belum ada pesanan masuk.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                // Kita butuh fetch detail produk biar tau nama makanannya
                // Karena di transaksi cuma ada ID Produk
                return FutureBuilder<Map<String, dynamic>>(
                  future: db.getProductById(order['product_id'].toString()),
                  builder: (context, productSnap) {
                    final productName = productSnap.hasData
                        ? productSnap.data!['name']
                        : 'Loading...';
                    final date = DateTime.parse(order['created_at']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border(
                          left: BorderSide(color: kPrimaryColor, width: 5),
                        ), // Garis warna di kiri
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order #${order['id']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                DateFormat('dd MMM HH:mm').format(date),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${order['quantity']} Porsi",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currency.format(order['total_price']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
// 3. MENU TAB (CRUD Menu)
// ===============================================================
class MenuTab extends StatelessWidget {
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
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
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

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

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = ProductModel.fromMap(snapshot.data![index]);
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[200],
                              width: 70,
                              height: 70,
                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          currency.format(product.price),
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Stok: ${product.stock}",
                          style: TextStyle(
                            color: product.stock < 5 ? Colors.red : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProductScreen(product: product),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            db.deleteProduct(product.id!);
                          },
                        ),
                      ],
                    ),
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
// 4. PROFILE TAB
// ===============================================================
class ProfileTab extends StatelessWidget {
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
