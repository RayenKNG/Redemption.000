import 'package:flutter/material.dart';
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

  Future<void> _recordSale() async {
    setState(() => _isLoading = true);
    try {
      // Simulasi jual 1 item
      await _db.recordSale(widget.product.id!, 1, widget.product.price);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("💰 Terjual! Masuk Dompet.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Column(
        children: [
          Container(
            height: 250,
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
                Text(
                  currency.format(widget.product.price),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Stok: ${widget.product.stock}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (widget.product.stock > 0 && !_isLoading)
                    ? _recordSale
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Catat Penjualan (1 Pcs)",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
