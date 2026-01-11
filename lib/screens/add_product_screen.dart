import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveplate/services/supabase_service.dart'; // Storage
import 'package:saveplate/services/supabase_database_service.dart'; // Database Baru

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController =
      TextEditingController(); // ✅ Added Description Controller
  final _originalPriceController = TextEditingController(); // Harga Coret
  final _priceController = TextEditingController(); // Harga Jual
  final _stockController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  final SupabaseStorageService _storageService = SupabaseStorageService();
  final SupabaseDatabaseService _dbService = SupabaseDatabaseService();

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        // Upload gambar dulu
        imageUrl = await _storageService.uploadImage(_selectedImage!);
      }

      // Simpan ke Database Supabase
      await _dbService.addProduct(
        _nameController.text,
        _descriptionController.text, // ✅ Pass description
        int.parse(_originalPriceController.text),
        int.parse(_priceController.text),
        int.parse(_stockController.text),
        imageUrl, // ✅ Pass imageUrl as String? (removed incorrect 'as int')
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu Berhasil Disimpan!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Menu Rescue")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Upload Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 50,
                            color: Colors.grey,
                          ),
                          Text(
                            "Foto Makanan (Wajib)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Makanan",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Isi dulu bro" : null,
            ),
            const SizedBox(height: 15),

            // ✅ Added Description Input Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Deskripsi (Opsional)",
                border: OutlineInputBorder(),
                hintText: "Contoh: Roti isi coklat lumer, tahan 2 hari.",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _originalPriceController,
                    decoration: const InputDecoration(
                      labelText: "Harga Asli",
                      suffixText: "IDR",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Wajib" : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: "Harga Jual",
                      suffixText: "IDR",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? "Wajib" : null,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5, bottom: 15),
              child: Text(
                " *Harga Jual harus lebih murah biar laku keras!",
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),

            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: "Stok Tersedia",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Wajib" : null,
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Simpan Menu",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
