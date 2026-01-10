import 'package:flutter/material.dart';
import 'dart:ui'; // Buat sedikit efek blur di navbar
import 'package:saveplate/screens/add_product_screen.dart';

// --- KONFIGURASI WARNA (Clean & Professional Orange) ---
const Color kPrimaryColor = Color(0xFFFF6D00); // Orange Utama
const Color kBgColor = Color(0xFFF9FAFB); // Background Abu Putih Bersih
const Color kTextDark = Color(0xFF1F2937); // Hitam Soft

class MerchantMainScreen extends StatefulWidget {
  const MerchantMainScreen({super.key});

  @override
  State<MerchantMainScreen> createState() => _MerchantMainScreenState();
}

class _MerchantMainScreenState extends State<MerchantMainScreen> {
  int _currentIndex = 0;

  // DAFTAR HALAMAN FITUR (Semua fitur ada di sini)
  final List<Widget> _pages = [
    const DashboardTab(), // Beranda
    const OrdersTab(), // Manajemen Pesanan
    const MenuTab(), // CRUD Menu
    const WalletTab(), // Keuangan
    const ProfileTab(), // Setting Toko
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: _pages[_currentIndex],

      // NAVIGASI BAWAH (Floating & Clean)
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
// 1. DASHBOARD TAB (HOME)
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
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                "https://via.placeholder.com/150",
              ), // Foto Toko
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo, Owner! 👋",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "Roti Makmur",
                  style: TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isShopOpen,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => isShopOpen = val),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS TOKO CARD
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: isShopOpen ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isShopOpen
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    color: isShopOpen ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isShopOpen ? "Toko Sedang BUKA" : "Toko Sedang TUTUP",
                    style: TextStyle(
                      color: isShopOpen ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // HERO CARD (OMZET)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8F00), Color(0xFFFF6D00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pendapatan Bersih Hari Ini",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Rp 1.450.000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "24 Pesanan Selesai",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              "Ringkasan Cepat",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 15),

            // GRID STATISTIK
            Row(
              children: [
                _buildStatCard(
                  "Pesanan Baru",
                  "3",
                  Icons.notifications_active,
                  Colors.orange,
                ),
                const SizedBox(width: 15),
                _buildStatCard(
                  "Stok Habis",
                  "2",
                  Icons.warning_amber_rounded,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// 2. ORDERS TAB (MANAJEMEN PESANAN LENGKAP)
// ===============================================================
class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Daftar Pesanan",
            style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: kPrimaryColor,
            tabs: [
              Tab(text: "Baru (3)"),
              Tab(text: "Diproses (1)"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(status: "new"),
            _buildOrderList(status: "process"),
            _buildOrderList(status: "done"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList({required String status}) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              // Header Order
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#ORD-00${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "10 Menit lalu",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      "Rp 35.000",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Items
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _buildItemRow("2x Donat Coklat", "Rp 10.000"),
                    _buildItemRow("1x Roti Tawar", "Rp 15.000"),
                  ],
                ),
              ),
              // Action Buttons (Hanya untuk New & Process)
              if (status != "done")
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      if (status == "new") ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text("Tolak"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                            ),
                            child: const Text("Terima"),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text("Selesai & Siap Diambil"),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemRow(String name, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: kTextDark)),
          Text(price, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ===============================================================
// 3. MENU TAB (CRUD PRODUK)
// ===============================================================
class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Atur Menu",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor, // Pastikan variabel warna ini sudah ada
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Menu", style: TextStyle(color: Colors.white)),
        onPressed: () {
          // INI LOGIC PINDAH HALAMANNYA
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
      ),
    );
  }

  Widget _buildMenuTile(String name, String price, int stock, bool isActive) {
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
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Stok: $stock",
                  style: TextStyle(
                    color: isActive ? Colors.grey : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeColor: Colors.green,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 4. WALLET TAB (KEUANGAN)
// ===============================================================
class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Dompet Toko",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: kTextDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Saldo Bisa Ditarik",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Rp 1.450.000",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kTextDark,
                      ),
                      child: const Text("Tarik Dana (Withdraw)"),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Riwayat Transaksi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),
            _buildHistoryItem("Penjualan #ORD-001", "+ Rp 35.000", true),
            _buildHistoryItem("Penarikan Dana", "- Rp 500.000", false),
            _buildHistoryItem("Penjualan #ORD-002", "+ Rp 15.000", true),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String amount, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// 5. PROFILE TAB (PENGATURAN)
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
              backgroundImage: NetworkImage("https://via.placeholder.com/150"),
            ),
            const SizedBox(height: 15),
            const Text(
              "Toko Roti Makmur",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "roti.makmur@gmail.com",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text("Edit Profil Toko"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Jam Operasional"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text("Printer Struk"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Keluar", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
