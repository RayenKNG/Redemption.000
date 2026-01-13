import 'package:flutter/material.dart';
import 'package:saveplate/services/supabase_database_service.dart';
import 'package:intl/intl.dart';

class UserOrdersScreen extends StatelessWidget {
  const UserOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = SupabaseDatabaseService();
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Warna background abu muda
      appBar: AppBar(
        title: const Text(
          "Pesanan Saya 📦",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: db.getUserOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Belum ada pesanan aktif.",
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
              final status = order['status'] ?? 'pending';

              // Ambil Detail Produk (Nama & Gambar)
              return FutureBuilder<Map<String, dynamic>>(
                future: db.getProductById(order['product_id'].toString()),
                builder: (context, productSnap) {
                  // Kalau loading/error, pake placeholder sementara
                  final productName = productSnap.hasData
                      ? productSnap.data!['name']
                      : 'Memuat...';
                  final imageUrl = productSnap.hasData
                      ? productSnap.data!['image_url']
                      : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 0, // Flat design biar modern
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // MUNCUL POPUP DETAIL TRACKING
                        _showTrackingDialog(
                          context,
                          order['id'],
                          status,
                          productName,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            // 1. Gambar Produk (Kecil di kiri)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: imageUrl != null
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : const Icon(
                                        Icons.fastfood,
                                        color: Colors.grey,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // 2. Info Pesanan
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${order['quantity']} Porsi • ${currency.format(order['total_price'])}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Badge Status (Kecil)
                                  _buildStatusBadge(status),
                                ],
                              ),
                            ),

                            // 3. Panah Kanan (Indikasi bisa diklik)
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
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

  // Widget Badge Status (Warna-warni)
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'process':
        color = Colors.blue;
        text = "Sedang Disiapkan";
        break;
      case 'done':
        color = Colors.green;
        text = "Selesai";
        break;
      default:
        color = Colors.orange;
        text = "Menunggu Konfirmasi";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // POPUP TRACKING (Menunggu -> Masak -> Selesai)
  void _showTrackingDialog(
    BuildContext context,
    String orderId,
    String status,
    String productName,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              const Text(
                "Status Pesanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                productName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // STEP 1: Menunggu
              _buildStepItem(
                title: "Pesanan Diterima",
                subtitle: "Menunggu konfirmasi merchant",
                isActive: true, // Selalu aktif kalau pesanan udah masuk
                isLast: false,
              ),
              // STEP 2: Proses
              _buildStepItem(
                title: "Sedang Disiapkan",
                subtitle: "Merchant sedang menyiapkan makananmu",
                isActive: status == 'process' || status == 'done',
                isLast: false,
              ),
              // STEP 3: Selesai
              _buildStepItem(
                title: "Pesanan Selesai",
                subtitle: "Silakan ambil / nikmati makananmu",
                isActive: status == 'done',
                isLast: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // Widget Item Alur (Garis & Titik)
  Widget _buildStepItem({
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isActive ? Colors.green : Colors.grey[300],
              size: 24,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20), // Spasi antar step
            ],
          ),
        ),
      ],
    );
  }
}
