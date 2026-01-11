import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ WAJIB: Buat cek siapa yang login
import 'package:saveplate/models/product_model.dart';
import 'package:saveplate/services/supabase_database_service.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final SupabaseDatabaseService _db = SupabaseDatabaseService();
  bool _isLoading = false;

  // ✅ FUNGSI TRANSAKSI PINTAR (MERCHANT VS USER)
  Future<void> _handleTransaction() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      // LOGIKA:
      // Kalau ID yang login == ID Pemilik Toko -> Mode Kasir (Catat Penjualan)
      // Kalau beda -> Mode Pembeli (Beli Online)

      if (currentUser?.uid == widget.product.merchantId) {
        // --- MODE KASIR (MERCHANT) ---
        await _db.recordSale(widget.product.id!, 1, widget.product.price);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("💰 Penjualan Tercatat (Masuk Dompet)"),
            ),
          );
        }
      } else {
        // --- MODE PEMBELI (USER) ---
        await _db.buyProduct(
          widget.product.id!,
          widget.product.merchantId,
          1,
          widget.product.price,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Berhasil Dibeli! Selamat Menikmati."),
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context); // Balik ke menu sebelumnya
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Cek apakah user yg login adalah pemilik toko
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.product.merchantId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR PRODUK
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: widget.product.imageUrl != null
                  ? Image.network(widget.product.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood, size: 80, color: Colors.grey),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA & HARGA
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // DESKRIPSI (Kalau ada)
                  if (widget.product.description != null &&
                      widget.product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        widget.product.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ),

                  const Divider(),
                  const SizedBox(height: 10),

                  // HARGA & STOK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.product.originalPrice >
                              widget.product.price)
                            Text(
                              currency.format(widget.product.originalPrice),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          Text(
                            currency.format(widget.product.price),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6D00),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Sisa Stok: ${widget.product.stock}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ INI DIA BOTTOM NAVIGATION BAR YANG LU CARI BRO!
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
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
        child: SafeArea(
          child: ElevatedButton(
            onPressed: (widget.product.stock > 0 && !_isLoading)
                ? _handleTransaction
                : null, // Kalau stok abis, tombol mati
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6D00),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    // Teks tombol berubah sesuai siapa yang login
                    widget.product.stock <= 0
                        ? "STOK HABIS"
                        : (isOwner
                              ? "Catat Penjualan (Kasir)"
                              : "Beli Sekarang"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
