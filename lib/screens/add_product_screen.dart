import 'dart:io'; // Buat handle file gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Buat ambil foto
import 'package:firebase_storage/firebase_storage.dart'; // Buat upload foto
import 'package:cloud_firestore/cloud_firestore.dart'; // Buat simpan data teks

// TEMA WARNA (Clean Orange)
const Color kPrimaryOrange = Color(0xFFFF6D00);
const Color kTextDark = Color(0xFF1F2937);

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controller Text Input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceOriginalController =
      TextEditingController();
  final TextEditingController _priceDiscountController =
      TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _imageFile; // Variabel buat simpan foto sementara
  bool _isLoading = false; // Variabel buat loading spinner

  // LOGIC 1: AMBIL GAMBAR DARI GALERI
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // LOGIC 2: UPLOAD KE FIREBASE (MAGIC HAPPENS HERE)
  Future<void> _uploadProduct() async {
    // 1. Validasi Input (Wajib isi semua)
    if (_imageFile == null ||
        _nameController.text.isEmpty ||
        _priceDiscountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Foto dan Data Wajib Diisi!"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Mulai Loading

    try {
      // 2. Upload Gambar ke Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch
          .toString(); // Nama file unik
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'products/$fileName.jpg',
      );
      await storageRef.putFile(_imageFile!);
      String imageUrl = await storageRef
          .getDownloadURL(); // Dapet Link Download

      // 3. Simpan Data ke Firestore Database
      // TODO: Nanti ganti "MERCHANT_ID_TEST" dengan FirebaseAuth.instance.currentUser!.uid
      String merchantId = "MERCHANT_ID_TEST";

      await FirebaseFirestore.instance.collection('products').add({
        'merchant_id': merchantId,
        'name': _nameController.text,
        'price_original': int.parse(_priceOriginalController.text),
        'price_discount': int.parse(_priceDiscountController.text),
        'stock': int.parse(_stockController.text),
        'description': _descController.text,
        'image_url': imageUrl,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      });

      // 4. Sukses!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Menu Berhasil Disimpan!"),
          ),
        );
        Navigator.pop(context); // Balik ke halaman sebelumnya
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Gagal: $e")),
      );
    } finally {
      setState(() => _isLoading = false); // Stop Loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tambah Menu",
          style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kTextDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KOTAK UPLOAD GAMBAR
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Sentuh untuk tambah foto",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 25),

            // INPUT FIELD
            _buildInput("Nama Makanan", _nameController),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildInput(
                    "Harga Asli",
                    _priceOriginalController,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInput(
                    "Harga Diskon",
                    _priceDiscountController,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInput("Stok Awal", _stockController, isNumber: true),
            const SizedBox(height: 15),
            _buildInput("Deskripsi Singkat", _descController, maxLines: 3),

            const SizedBox(height: 30),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "PUBLIKASIKAN MENU",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget biar kodingan rapi
  Widget _buildInput(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
