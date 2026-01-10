import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart'; // Paket buat GPS

class MapHunterScreen extends StatefulWidget {
  const MapHunterScreen({super.key});

  @override
  State<MapHunterScreen> createState() => _MapHunterScreenState();
}

class _MapHunterScreenState extends State<MapHunterScreen> {
  // 1. Controller buat ngatur Mapnya
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // 2. Lokasi Awal (Misal: Monas Jakarta) buat default sebelum GPS dapet
  static const LatLng _initialPosition = LatLng(-6.175392, 106.827153);

  // 3. Variabel buat nyimpen lokasi user & marker toko
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Location _locationService = Location();
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Cari lokasi user pas dibuka
    _loadDummyMarkers(); // Isi peta pake data toko boongan dulu
  }

  // --- FUNGSI 1: DAPETIN LOKASI USER ---
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Cek servis GPS nyala gak
    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return; // Kalau gak dinyalain, nyerah
      }
    }

    // Cek izin aplikasi akses lokasi
    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _isLoadingLocation = false);
        return; // Kalau gak diizinin, nyerah
      }
    }

    // Ambil lokasi terkini
    final locationData = await _locationService.getLocation();
    setState(() {
      _currentPosition = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      _isLoadingLocation = false;
    });

    // Geser kamera map ke lokasi user
    if (_currentPosition != null) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition!, zoom: 15),
        ),
      );
    }
  }

  // --- FUNGSI 2: DATA TOKO DUMMY (BOONGAN) ---
  void _loadDummyMarkers() {
    // Ceritanya ini data dari Firebase nanti
    List<Map<String, dynamic>> dummyStores = [
      {
        "id": "toko1",
        "name": "Roti O 'Stasiun'",
        "lat": -6.176392, "lng": 106.828153, // Dekat Monas dikit
        "stock": "Sisa 2 Paket",
        "price": "Rp 10.000",
      },
      {
        "id": "toko2",
        "name": "Dunkin KW",
        "lat": -6.174392,
        "lng": 106.826153,
        "stock": "Sisa 5 Paket",
        "price": "Rp 20.000",
      },
      {
        "id": "toko3",
        "name": "Nasi Padang Murah",
        "lat": -6.177392,
        "lng": 106.829153,
        "stock": "Habis",
        "price": "Rp 15.000",
      },
    ];

    setState(() {
      for (var store in dummyStores) {
        _markers.add(
          Marker(
            markerId: MarkerId(store['id']),
            position: LatLng(store['lat'], store['lng']),
            // Kalau stok habis warnanya beda
            icon: BitmapDescriptor.defaultMarkerWithHue(
              store['stock'] == "Habis"
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueGreen,
            ),
            onTap: () {
              // Pas diklik, munculin Bottom Sheet keren
              _showStoreDetails(context, store);
            },
          ),
        );
      }
    });
  }

  // --- FUNGSI 3: TAMPILAN DETAIL PAS KLIK MARKER (BOTTOM SHEET) ---
  void _showStoreDetails(BuildContext context, Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Garis kecil di atas buat narik
              Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  // Gambar Toko Dummy
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: NetworkImage("https://via.placeholder.com/80"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(Icons.store, color: Colors.grey),
                  ),
                  const SizedBox(width: 15),
                  // Detail Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          store['stock'],
                          style: TextStyle(
                            color: store['stock'] == "Habis"
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          store['price'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2ECC71),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Tombol Aksi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: store['stock'] == "Habis"
                      ? null
                      : () {
                          // Nanti arahin ke Google Maps buat navigasi
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Buka Rute... (Segera Hadir)"),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: const Icon(Icons.directions),
                  label: const Text("Petunjuk Arah"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack biar bisa numpuk Search Bar di atas Map
      body: Stack(
        children: [
          // LAYER 1: GOOGLE MAPS (Paling Bawah)
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true, // Titik biru lokasi kita
            myLocationButtonEnabled:
                false, // Tombol bawaan dimatiin, kita bikin sendiri
            zoomControlsEnabled: false, // Tombol zoom +/- dimatiin biar bersih
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              // Kalau lokasi user udah dapet duluan sebelum map jadi, langsung geser
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(_currentPosition!),
                );
              }
            },
          ),

          // LAYER 2: LOADING INDICATOR (Kalau lagi nyari GPS)
          if (_isLoadingLocation)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
            ),

          // LAYER 3: SEARCH BAR MELAYANG (Di Atas)
          Positioned(
            top: 50, // Jarak dari atas status bar
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari lokasi atau toko...",
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // TOMBOL UNTUK BALIK KE POSISI KITA (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: _getUserLocation, // Panggil fungsi cari lokasi lagi
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2ECC71),
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
