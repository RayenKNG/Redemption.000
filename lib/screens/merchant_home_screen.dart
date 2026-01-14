import 'dart:async'; // Tambah ini buat StreamSubscription
import 'package:flutter/material.dart';
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
  
  // Variabel buat Notifikasi
  StreamSubscription? _orderSubscription;
  int? _previousOrderCount;
  int? _previousWalletAmount;
  bool _isFirstLoad = true; // Biar pas baru buka gak langsung bunyi

  final List<Widget> _pages = [
    const DashboardTab(),
    const OrdersTab(),
    const MenuTab(),
    const WalletTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel(); // Matikan listener pas keluar biar hemat memori
    super.dispose();
  }

  // 🔥 LOGIC NOTIFIKASI MERCHANT
  void _setupNotifications() {
    final db = SupabaseDatabaseService();
    
    // Kita dengerin stream orderan
    _orderSubscription = db.getMerchantOrdersStream().listen((orders) {
      // 1. Hitung Saldo Saat Ini (Cuma yang status 'done')
      int currentWallet = 0;
      for (var o in orders) {
        if (o['status'] == 'done') currentWallet += (o['total_price'] as int);
      }

      // 2. Hitung Jumlah Pesanan Saat Ini
      int currentOrderCount = orders.length;

      // 3. Logic Notifikasi (Skip pas loading pertama)
      if (!_isFirstLoad) {
        
        // Cek Pesanan Baru (Jumlah nambah)
        if (_previousOrderCount != null && currentOrderCount > _previousOrderCount!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(children: [Icon(Icons.notifications_active, color: Colors.white), SizedBox(width: 10), Text("TING! Ada Pesanan Baru Masuk! 📦")]),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Cek Uang Masuk (Saldo nambah)
        if (_previousWalletAmount != null && currentWallet > _previousWalletAmount!) {
          final diff = currentWallet - _previousWalletAmount!;
          final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [const Icon(Icons.monetization_on, color: Colors.white), const SizedBox(width: 10), Text("CHING! Uang Masuk ${f.format(diff)} 💰")]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Update data terakhir
      setState(() {
        _previousOrderCount = currentOrderCount;
        _previousWalletAmount = currentWallet;
        _isFirstLoad = false; // Loading pertama selesai
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: const Color(0xFFFF6D00),
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
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
// 1. DASHBOARD TAB
// ==========================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), elevation: 0),
      body: FutureBuilder<Map<String, dynamic>>(
        future: db.getDashboardStats(),
        builder: (context, snap) {
          final data = snap.data ?? {'total_orders': 0, 'total_wallet': 0};
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatCard("Total Pesanan", "${data['total_orders']}", Icons.shopping_bag, Colors.blue),
                const SizedBox(height: 15),
                _buildStatCard("Pendapatan", "Rp ${NumberFormat('#,###', 'id_ID').format(data['total_wallet'])}", Icons.account_balance_wallet, Colors.green),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color) {
    return Container(
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
// 2. ORDERS TAB (TAB UTAMA TRANSAKSI)
// ==========================================
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Kelola Pesanan", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFFFF6D00),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF6D00),
            tabs: [
              Tab(text: "Masuk"),   
              Tab(text: "Proses"),  
              Tab(text: "Selesai"), 
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderListByStatus(statusFilter: 'pending'), 
            OrderListByStatus(statusFilter: 'process'), 
            OrderListByStatus(statusFilter: 'done'),    
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET LIST PESANAN (LOGIC PINDAH TAB)
// ==========================================
class OrderListByStatus extends StatefulWidget {
  final String statusFilter;
  const OrderListByStatus({super.key, required this.statusFilter});

  @override
  State<OrderListByStatus> createState() => _OrderListByStatusState();
}

class _OrderListByStatusState extends State<OrderListByStatus> {
  final db = SupabaseDatabaseService();
  String? _loadingId;

  // Fungsi saat tombol ditekan
  Future<void> _processOrder(String id, String nextStatus) async {
    setState(() => _loadingId = id); 
    
    try {
      await db.updateOrderStatus(id, nextStatus);
      if (mounted) {
        // Notif manual pas tombol ditekan
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(nextStatus == 'process' ? "Pesanan Diproses! Pindah ke tab Proses." : "Pesanan Selesai! Saldo Bertambah."),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loadingId = null); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: db.getMerchantOrdersStream(), 
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snap.data ?? [];
        final orders = allOrders.where((o) {
          final status = o['status'] ?? 'pending';
          return status == widget.statusFilter;
        }).toList();

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Text("Tidak ada pesanan di sini", style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final order = orders[i];
            final orderId = order['id'].toString();

            return FutureBuilder<Map<String, dynamic>>(
              future: db.getProductById(order['product_id'].toString()),
              builder: (context, pSnap) {
                final pName = pSnap.data?['name'] ?? "Loading...";
                final pImg = pSnap.data?['image_url'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: pImg != null 
                                ? Image.network(pImg, width: 60, height: 60, fit: BoxFit.cover) 
                                : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("${order['quantity']} Porsi • ${f.format(order['total_price'])}", style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        // TOMBOL LOGIC (BERUBAH SESUAI TAB)
                        SizedBox(
                          width: double.infinity,
                          child: _loadingId == orderId
                              ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                              : widget.statusFilter == 'pending'
                                  ? ElevatedButton(
                                      onPressed: () => _processOrder(orderId, 'process'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                      child: const Text("TERIMA ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    )
                                  : widget.statusFilter == 'process'
                                      ? ElevatedButton(
                                          onPressed: () => _processOrder(orderId, 'done'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          child: const Text("SELESAIKAN ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        )
                                      : const OutlinedButton(
                                          onPressed: null,
                                          child: Text("Transaksi Berhasil ✅", style: TextStyle(color: Colors.green)),
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
    );
  }
}

// ==========================================
// 3. MENU TAB
// ==========================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});
  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Saya"), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF6D00),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
        label: const Text("Tambah", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
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
              return Card(
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: p.imageUrl != null 
                      ? Image.network(p.imageUrl!, width: 60, height: 60, fit: BoxFit.cover) 
                      : const Icon(Icons.fastfood, size: 40),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Stok: ${p.stock} | ${f.format(p.price)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: p)))),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => db.deleteProduct(p.id!)),
                    ],
                  ),
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
// 4. WALLET & PROFILE (SISA TAB)
// ==========================================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});
  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text("Dompet"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<Map<String, dynamic>>(
          future: db.getDashboardStats(),
          builder: (context, snap) {
            final totalWallet = snap.data?['total_wallet'] ?? 0;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFFF6D00).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Text("Saldo Dapat Ditarik", style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(f.format(totalWallet), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Penarikan Dikirim!"), backgroundColor: Colors.green)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("TARIK DANA", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () async {
          await AuthService().signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: const Text("Logout", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}