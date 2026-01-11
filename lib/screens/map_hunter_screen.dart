import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // ✅ Pake Flutter Map (Gratis)
import 'package:latlong2/latlong.dart'; // ✅ Koordinat

class MapHunterScreen extends StatefulWidget {
  const MapHunterScreen({super.key});

  @override
  State<MapHunterScreen> createState() => _MapHunterScreenState();
}

class _MapHunterScreenState extends State<MapHunterScreen> {
  // Lokasi Default (Misal: Monas, Jakarta) - Ganti sesuka hati
  final LatLng _center = const LatLng(-6.175392, 106.827153);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hunter Map 🗺️"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center, // Posisi awal map
          initialZoom: 15.0, // Level zoom awal
        ),
        children: [
          // 1. LAYER PETA (Pakai OpenStreetMap - GRATIS)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.saveplate', // Ganti nama package kalau mau
          ),

          // 2. LAYER MARKER (Penanda Lokasi)
          MarkerLayer(
            markers: [
              // Marker 1: Posisi Kita (Pusat)
              Marker(
                point: _center,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.person_pin_circle,
                  color: Colors.blue,
                  size: 50,
                ),
              ),

              // Marker 2: Contoh Toko (Roti O)
              Marker(
                point: const LatLng(
                  -6.176000,
                  106.828000,
                ), // Koordinat deket Monas
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    // Aksi kalau marker diklik
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Mystery Box Ditemukan! 🎁"),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Tombol Center
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Nanti bisa ditambah logika buat balik ke lokasi user
        },
        backgroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
