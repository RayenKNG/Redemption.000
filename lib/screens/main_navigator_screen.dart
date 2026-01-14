import 'dart:async'; // ✅ Wajib ada buat Notifikasi Stream
import 'package:flutter/material.dart';
import 'dart:ui'; // Buat Efek Kaca (Glassmorphism)
import 'package:intl/intl.dart';
import 'package:saveplate/services/auth_service.dart';
import 'package:saveplate/services/supabase_database_service.dart';
import 'package:saveplate/models/product_model.dart';
import 'package:saveplate/screens/product_detail_screen.dart';
import 'package:saveplate/screens/map_hunter_screen.dart';

// ==========================================
// 1. NAVIGASI UTAMA (USER - DENGAN NOTIFIKASI)
// ==========================================

class MainNavigatorScreenUser extends StatefulWidget {
  const MainNavigatorScreenUser({super.key});

  @override
  State<MainNavigatorScreenUser> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreenUser> {
  int _selectedIndex = 0;

  // 🔥 VARIABEL NOTIFIKASI REAL-TIME 🔥
  StreamSubscription? _userOrderSub;
  List<String> _finishedOrderIds = []; // Daftar ID pesanan yang udah selesai (biar gak notif 2x)
  int? _previousOrderCount; // Jumlah orderan sebelumnya (buat deteksi order baru)
  bool _isFirstLoad = true; // Biar pas baru buka aplikasi gak langsung bunyi

  // LIST HALAMAN
  final List<Widget> _pages = [
    const UltimateHomeScreen(), 
    const UserOrdersTab(),      
    const UserProfileTab(),     
  ];

  @override
  void initState() {
    super.initState();
    _setupUserNotifications(); // 👂 Pasang "Telinga" pas aplikasi dibuka
  }

  @override
  void dispose() {
    _userOrderSub?.cancel(); // 🔇 Lepas "Telinga" pas aplikasi ditutup biar hemat baterai
    super.dispose();
  }

  // LOGIKA NOTIFIKASI CANGGIH
  void _setupUserNotifications() {
    final db = SupabaseDatabaseService();
    
    // Dengerin Stream Orderan User
    _userOrderSub = db.getUserOrdersStream().listen((orders) {
      
      if (!_isFirstLoad) { // Jangan notif pas baru banget loading awal
        
        // 1. CEK: Apakah User Baru Aja Beli? (Jumlah order nambah)
        if (_previousOrderCount != null && orders.length > _previousOrderCount!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.shopping_bag, color: Colors.white), 
                  SizedBox(width: 10), 
                  Expanded(child: Text("Pesanan Berhasil Dibuat! Menunggu konfirmasi Merchant.")),
                ]
              ),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // 2. CEK: Apakah Ada Pesanan yang Selesai? (Status jadi 'done')
        for (var o in orders) {
          // Kalau statusnya 'done' DAN ID-nya belum pernah kita notif sebelumnya
          if (o['status'] == 'done' && !_finishedOrderIds.contains(o['id'].toString())) {
            
            // Munculin Notif HORE
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white), 
                    SizedBox(width: 10), 
                    Expanded(child: Text("HORE! Pesanan kamu sudah siap! Silakan ambil makanannya. 🍽️")),
                  ]
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 5),
              ),
            );

            // Tandai ID ini biar gak notif lagi
            _finishedOrderIds.add(o['id'].toString());
          }
        }

      } else {
        // LOAD PERTAMA: Cuma catat data awal, jangan notif dulu
        for (var o in orders) {
          if (o['status'] == 'done') _finishedOrderIds.add(o['id'].toString());
        }
        _isFirstLoad = false;
      }

      // Update Data Terakhir
      if (mounted) {
        setState(() {
          _previousOrderCount = orders.length;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      body: _pages[_selectedIndex],

      // --- TOMBOL TENGAH (HUNTER) ---
      floatingActionButton: Container(
        height: 70, width: 70,
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MapHunterScreen())),
          backgroundColor: const Color(0xFF2ECC71),
          elevation: 10,
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.map_outlined, size: 28, color: Colors.white),
              Text("HUNT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAV BAR GLASSMORPHISM ---
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomAppBar(
            color: Colors.white.withOpacity(0.8),
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home_rounded, 0, "Home"),
                _buildNavIcon(Icons.confirmation_number_rounded, 1, "Pesanan"),
                const SizedBox(width: 40), // Spasi tengah
                _buildNavIcon(Icons.notifications_rounded, 3, "Notif"),
                _buildNavIcon(Icons.person_rounded, 2, "Profil"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;
    // Index 3 (Notif) dimatiin onTap-nya karena cuma hiasan visual di sini (notif udah pake SnackBar)
    return InkWell(
      onTap: () => index == 3 ? {} : _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade400)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN HOME (Glassmorphism)
// ==========================================

class UltimateHomeScreen extends StatelessWidget {
  const UltimateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent, expandedHeight: 140.0, floating: true, pinned: true, elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  child: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero, expandedTitleScale: 1.0,
                    title: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 18, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12")),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: const [Text("Halo, Hunter!", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)), Text("Siap berburu?", style: TextStyle(color: Colors.grey, fontSize: 10))]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(),
                  const SizedBox(height: 30),
                  const Text("Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildCategoryItem("Semua", Icons.grid_view_rounded, true), _buildCategoryItem("Roti", Icons.bakery_dining_rounded, false), _buildCategoryItem("Nasi", Icons.rice_bowl_rounded, false), _buildCategoryItem("Buah", Icons.eco_rounded, false), _buildCategoryItem("Minum", Icons.local_cafe_rounded, false)]),
                  const SizedBox(height: 30),
                  const Text("Target Terdekat 🎯", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 20),
                  
                  // LIST MAKANAN
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: db.getAllAvailableMenuStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("Belum ada menu.");
                      return Column(
                        children: snapshot.data!.map((data) {
                          final product = ProductModel.fromMap(data);
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                            child: _buildPremiumCard(title: product.name, price: currency.format(product.price), original: currency.format(product.originalPrice), imageUrl: product.imageUrl ?? "https://via.placeholder.com/150", stock: product.stock),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() => Container(width: double.infinity, height: 160, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), image: const DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070"), fit: BoxFit.cover)), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)])), child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Promo Hunter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text("Diskon 80%!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))])));
  
  Widget _buildCategoryItem(String label, IconData icon, bool isActive) => Column(children: [Container(height: 60, width: 60, decoration: BoxDecoration(color: isActive ? const Color(0xFF2ECC71) : Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [if (!isActive) BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))]), child: Icon(icon, color: isActive ? Colors.white : Colors.grey, size: 28)), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? Colors.black : Colors.grey))]);

  Widget _buildPremiumCard({required String title, required String price, required String original, required String imageUrl, required int stock}) => Container(margin: const EdgeInsets.only(bottom: 20), height: 260, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]), child: Column(children: [ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover)), Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("Sisa $stock", style: TextStyle(color: stock < 3 ? Colors.red : Colors.green))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(original, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)), Text(price, style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 18, fontWeight: FontWeight.bold))])]))]));
}

// ==========================================
// 📦 3. HALAMAN PESANAN
// ==========================================

class UserOrdersTab extends StatelessWidget {
  const UserOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(title: const Text("Pesanan Saya"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getUserOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada pesanan."));

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];
              final status = order['status'] ?? 'pending';
              
              // Warna Status
              Color statusColor = Colors.orange;
              if (status == 'process') statusColor = Colors.blue;
              if (status == 'done') statusColor = Colors.green;

              return FutureBuilder<Map<String, dynamic>>(
                future: db.getProductById(order['product_id'].toString()),
                builder: (context, prodSnap) {
                  final prodName = prodSnap.hasData ? prodSnap.data!['name'] : 'Loading...';
                  final prodImage = prodSnap.hasData ? prodSnap.data!['image_url'] : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: prodImage != null ? Image.network(prodImage, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.fastfood),
                      ),
                      title: Text(prodName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Status: ${status.toUpperCase()}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      trailing: Text(currency.format(order['total_price']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
// 4. HALAMAN PROFIL
// ==========================================

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(padding: const EdgeInsets.fromLTRB(20, 60, 20, 30), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]), child: Column(children: [Row(children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2ECC71), width: 3)), child: const CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"))), const SizedBox(width: 20), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Hunter Sejati", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF2ECC71).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text("PRO MEMBER", style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.bold, fontSize: 10)))])])])),
            Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Text("Pengaturan Akun", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 10), _buildMenuCard(Icons.person_outline, "Edit Profil"), _buildMenuCard(Icons.lock_outline, "Keamanan & Password"), _buildMenuCard(Icons.payment, "Metode Pembayaran"), const SizedBox(height: 20), const Text("Lainnya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)), const SizedBox(height: 10), _buildMenuCard(Icons.history, "Riwayat Pesanan"), _buildMenuCard(Icons.help_outline, "Pusat Bantuan"), const SizedBox(height: 30), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), foregroundColor: Colors.red, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () async { await AuthService().signOut(); if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false); }, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.logout_rounded, color: Colors.red), SizedBox(width: 10), Text("Keluar Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]))), const SizedBox(height: 100)])),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: ListTile(leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.black87)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey), onTap: () {}));
}