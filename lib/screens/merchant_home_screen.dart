import 'package:flutter/material.dart';
import 'dart:ui'; // Efek Modern
import 'package:saveplate/screens/add_product_screen.dart';
import 'package:saveplate/screens/edit_product_screen.dart';
import 'package:saveplate/services/supabase_database_service.dart';
import 'package:saveplate/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:saveplate/services/auth_service.dart';

class MerchantMainScreen extends StatefulWidget {
  const MerchantMainScreen({super.key});
  @override
  State<MerchantMainScreen> createState() => _MerchantMainScreenState();
}

class _MerchantMainScreenState extends State<MerchantMainScreen> {
  int _currentIndex = 0;

  // ✅ 5 TAB: DASHBOARD, PESANAN, MENU, WALLET, PROFIL
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
      backgroundColor: const Color(0xFFF0F2F5),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: const Color(0xFFFF6D00),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dash"),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Pesanan"),
              BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: "Menu"),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: "Wallet"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1. DASHBOARD TAB (Ringkasan)
// ==========================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Dashboard Toko", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: FutureBuilder<Map<String, dynamic>>(
        future: db.getDashboardStats(),
        builder: (context, snap) {
          final data = snap.data ?? {'total_orders': 0};
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatCard("Total Pesanan", "${data['total_orders']}", Icons.shopping_bag, Colors.blue),
                const SizedBox(height: 15),
                _buildStatCard("Rating Toko", "4.9", Icons.star, Colors.orange),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(color: Colors.grey))]),
        ],
      ),
    );
  }
}

// ==========================================
// 2. ORDERS TAB (ALUR PROSES PEMESANAN) 🔥
// ==========================================
class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final db = SupabaseDatabaseService();
  bool _isLoading = false; // Biar tombol gak dipencet 2x

  // Fungsi Update Status dengan Loading
  Future<void> _handleUpdateStatus(String id, String status) async {
    setState(() => _isLoading = true);
    await db.updateOrderStatus(id, status);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(status == 'process' ? "Pesanan diterima! Sedang dikemas." : "Pesanan Selesai!"),
        backgroundColor: status == 'process' ? Colors.blue : Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Daftar Pesanan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getMerchantOrdersStream(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text("Belum ada pesanan masuk."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              final order = snap.data![i];
              String status = order['status'] ?? 'pending';

              // TENTUKAN WARNA & TEKS STATUS
              Color color = Colors.grey;
              String label = "Menunggu";
              if (status == 'process') { color = Colors.blue; label = "Sedang Dikemas"; }
              if (status == 'done') { color = Colors.green; label = "Selesai"; }

              return FutureBuilder<Map<String, dynamic>>(
                future: db.getProductById(order['product_id'].toString()),
                builder: (context, pSnap) {
                  final pName = pSnap.data?['name'] ?? "Loading...";
                  final pImg = pSnap.data?['image_url'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER KARTU
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("#${order['id'].toString().substring(0, 4)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(label.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          
                          // ISI PESANAN
                          Row(
                            children: [
                              ClipRRect(borderRadius: BorderRadius.circular(10), child: pImg != null ? Image.network(pImg, width: 60, height: 60, fit: BoxFit.cover) : const Icon(Icons.fastfood, size: 40)),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text("${order['quantity']} Porsi • ${currency.format(order['total_price'])}", style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // TOMBOL AKSI (ALUR PROSES)
                          SizedBox(
                            width: double.infinity,
                            child: _isLoading 
                            ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                            : status == 'pending'
                              ? ElevatedButton.icon(
                                  onPressed: () => _handleUpdateStatus(order['id'], 'process'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text("TERIMA & PROSES"),
                                )
                              : status == 'process'
                                ? ElevatedButton.icon(
                                    onPressed: () => _handleUpdateStatus(order['id'], 'done'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                                    icon: const Icon(Icons.done_all),
                                    label: const Text("PESANAN SELESAI"),
                                  )
                                : OutlinedButton.icon(
                                    onPressed: null, // Disabled kalau udah selesai
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    label: const Text("Sudah Selesai", style: TextStyle(color: Colors.green)),
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

// ==========================================
// 3. MENU TAB (CRUD)
// ==========================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});
  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Menu Makanan"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF6D00),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getMerchantMenuStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snap.data!.length,
            itemBuilder: (context, i) {
              final p = ProductModel.fromMap(snap.data![i]);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: p.imageUrl != null ? Image.network(p.imageUrl!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.fastfood)),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Stok: ${p.stock} | ${f.format(p.price)}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => db.deleteProduct(p.id!)),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: p))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. WALLET TAB (DUMMY FUNCTIONING)
// ==========================================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Dompet Saya"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: db.getDashboardStats(),
              builder: (context, snap) {
                final totalWallet = snap.data?['total_wallet'] ?? 0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      const Text("Saldo Tersedia", style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text(f.format(totalWallet), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permintaan penarikan dikirim! (Simulasi)"), backgroundColor: Colors.green)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("TARIK DANA", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. PROFILE TAB
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            await AuthService().signOut();
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text("Keluar Aplikasi", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}