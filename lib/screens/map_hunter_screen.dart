import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapHunterScreen extends StatefulWidget {
  const MapHunterScreen({super.key});

  @override
  State<MapHunterScreen> createState() => _MapHunterScreenState();
}

class _MapHunterScreenState extends State<MapHunterScreen> {
  // Koordinat Default (Misal: Monas, Jakarta). Nanti diganti GPS asli.
  final LatLng _center = const LatLng(-6.175392, 106.827153);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- LAPISAN 1: PETA (BACKGROUND) ---
          FlutterMap(
            options: MapOptions(
              initialCenter: _center, // Posisi awal peta
              initialZoom: 15.0, // Zoom level (makin besar makin dekat)
            ),
            children: [
              TileLayer(
                // Mengambil gambar peta dari OpenStreetMap (Gratis)
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.saveplate',
              ),
              // Marker Layer (Ikon-ikon Makanan)
              MarkerLayer(
                markers: [
                  // Contoh Marker 1 (Roti Bu Siti)
                  Marker(
                    point: LatLng(-6.175392, 106.827153),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  // Contoh Marker 2 (Nasi Goreng)
                  Marker(
                    point: LatLng(-6.176000, 106.828000),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- LAPISAN 2: HEADER SEARCH (ATAS) ---
          Positioned(
            top: 50, // Jarak dari atas (biar gak ketabrak jam HP)
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    "Cari Mystery Box terdekat...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // --- LAPISAN 3: KARTU MAKANAN (BAWAH) ---
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 140, // Tinggi area scroll kartu
              child: ListView(
                scrollDirection: Axis.horizontal, // Scroll ke samping
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Kartu 1
                  _buildFoodCard(
                    title: "Roti Bu Siti",
                    price: "Rp 10.000",
                    originalPrice: "Rp 30.000",
                    distance: "200m",
                    color: Colors.orange.shade100,
                  ),
                  const SizedBox(width: 15),
                  // Kartu 2
                  _buildFoodCard(
                    title: "Nasi Padang Berkah",
                    price: "Rp 15.000",
                    originalPrice: "Rp 40.000",
                    distance: "500m",
                    color: Colors.green.shade100,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Hunter'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Tiket'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // Widget kecil buat bikin desain Kartu Makanan
  Widget _buildFoodCard({
    required String title,
    required String price,
    required String originalPrice,
    required String distance,
    required Color color,
  }) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Kotak Gambar Misterius
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.question_mark,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          // Info Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  distance,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 10,
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
