import 'package:flutter/material.dart';
import 'dart:ui'; // Wajib buat Glassmorphism
import 'map_hunter_screen.dart';

// ==========================================
// 1. NAVIGASI UTAMA (DENGAN BOTTOM BAR KACA)
// ==========================================

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UltimateHomeScreen(),
    const Center(child: Text('Halaman Tiket', style: TextStyle(fontSize: 20))),
    const Center(child: Text('Halaman Profil', style: TextStyle(fontSize: 20))),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // MANTRA AJAIB: extendBody bikin konten bisa jalan di belakang navigasi bawah
      extendBody: true,

      body: _pages[_selectedIndex],

      // --- TOMBOL TENGAH (HUNTER) ---
      floatingActionButton: Container(
        height: 70,
        width: 70,
        margin: const EdgeInsets.only(bottom: 10), // Naik dikit biar pas
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapHunterScreen()),
            );
          },
          backgroundColor: const Color(0xFF2ECC71),
          elevation: 10,
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.map_outlined, size: 28, color: Colors.white),
              Text(
                "HUNT",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- BOTTOM NAV BAR GLASSMORPHISM (KEREN PARAH) ---
      bottomNavigationBar: ClipRRect(
        // Kita kasih lengkungan di ujung atas kiri-kanan
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          // EFEK BLUR UNTUK NAVIGASI BAWAH
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomAppBar(
            // Warna Putih Transparan (0.8 biar gak terlalu bening)
            color: Colors.white.withOpacity(0.8),
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavIcon(Icons.home_rounded, 0, "Home"),
                _buildNavIcon(Icons.confirmation_number_rounded, 1, "Tiket"),
                const SizedBox(width: 40), // Spasi tengah buat tombol Hunt
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
    return InkWell(
      onTap: () => index == 3 ? {} : _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade400,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? const Color(0xFF2ECC71)
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN HOME (BACKGROUND PREMIUM)
// ==========================================

class UltimateHomeScreen extends StatelessWidget {
  const UltimateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PERUBAHAN DI SINI BRO ---
      // Kita ganti jadi warna 'Off-White' / Abu sangat muda.
      // Ini bikin kartu warna putih jadi makin MENYALA.
      backgroundColor: const Color(0xFFF0F2F5),

      // -----------------------------
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- HEADER GLASSMORPHISM ---
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 140.0,
            floating: true,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 0,
            leading: const SizedBox(),

            // Flexible Space dengan efek Blur
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    // Kita kasih warna putih transparan, tapi agak lebih pekat dikit
                    // biar kontras sama background abu-abunya
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.5)),
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.zero,
                    expandedTitleScale: 1.0,
                    title: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(
                                    "https://i.pravatar.cc/150?img=12",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Halo, Hunter!",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Siap berburu?",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Jakarta",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SEARCH BAR
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  // Bayangan dibikin lebih soft biar nyatu sama background abu
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Cari Mystery Box...",
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- KONTEN BODY ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Banner
                  _buildBanner(),

                  const SizedBox(height: 30),
                  const Text(
                    "Kategori",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 20),

                  // Kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(
                        "Semua",
                        Icons.grid_view_rounded,
                        true,
                      ),
                      _buildCategoryItem(
                        "Roti",
                        Icons.bakery_dining_rounded,
                        false,
                      ),
                      _buildCategoryItem(
                        "Nasi",
                        Icons.rice_bowl_rounded,
                        false,
                      ),
                      _buildCategoryItem("Buah", Icons.eco_rounded, false),
                      _buildCategoryItem(
                        "Minum",
                        Icons.local_cafe_rounded,
                        false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Target Terdekat 🎯",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "Lihat Peta >",
                        style: TextStyle(
                          color: const Color(0xFF2ECC71),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // List Item Premium
                  _buildPremiumCard(
                    title: "Roti O 'Stasiun'",
                    distance: "200m",
                    price: "Rp 10.000",
                    original: "Rp 30.000",
                    imageUrl:
                        "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=2072",
                    stock: 2,
                    rating: "4.8",
                  ),
                  _buildPremiumCard(
                    title: "Sushi Tei Leftover",
                    distance: "1.2km",
                    price: "Rp 25.000",
                    original: "Rp 80.000",
                    imageUrl:
                        "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?q=80&w=2070",
                    stock: 5,
                    rating: "4.9",
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Function _buildBanner, _buildCategoryItem, _buildPremiumCard SAMA SEPERTI SEBELUMNYA) ...
  // Kalau kamu butuh kodingan function bawahnya lagi, bilang ya! Tapi harusnya masih ada di file kamu.

  // Biar aman, ini aku sertakan function pendukungnya biar gak error copy paste:

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070",
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Promo Hunter",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Selamatkan Roti,\nDapet Diskon 80%!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, bool isActive) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2ECC71) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            // Bayangan dikit biar nimbul dari background abu
            boxShadow: [
              if (!isActive)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard({
    required String title,
    required String distance,
    required String price,
    required String original,
    required String imageUrl,
    required int stock,
    required String rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        // Bayangan lebih soft
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                child: Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Mystery Box",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$distance • Pickup",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Sisa $stock",
                            style: TextStyle(
                              color: stock < 3 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      original,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
