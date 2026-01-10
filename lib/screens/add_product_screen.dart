import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  bool _isLoading = false;

  // Fungsi Upload ke Firestore
  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Simpan ke Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'merchantId': user.uid,
        'name': _nameController.text,
        'price': int.parse(_priceController.text),
        'stock': int.parse(_stockController.text),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        // Nanti bisa tambah imageUrl kalau sudah main storage
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Menu Berhasil Ditambahkan!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Balik ke menu sebelumnya
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal upload: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Tambah Menu Baru",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel("Nama Makanan"),
              _buildTextField(
                _nameController,
                "Contoh: Nasi Goreng Spesial",
                TextInputType.text,
              ),

              const SizedBox(height: 15),
              _buildInputLabel("Harga (Rp)"),
              _buildTextField(
                _priceController,
                "Contoh: 15000",
                TextInputType.number,
              ),

              const SizedBox(height: 15),
              _buildInputLabel("Stok Tersedia"),
              _buildTextField(
                _stockController,
                "Contoh: 10",
                TextInputType.number,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6D00), // Warna Oren
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Simpan Menu",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    TextInputType type,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: (value) => value!.isEmpty ? "Wajib diisi" : null,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
      ),
    );
  }
}
