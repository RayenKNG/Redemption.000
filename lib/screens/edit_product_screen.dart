import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveplate/models/product_model.dart';
import 'package:saveplate/services/supabase_service.dart';
import 'package:saveplate/services/supabase_database_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product; // Data lama
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _originalPriceController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  File? _newImage;
  bool _isLoading = false;

  final _storage = SupabaseStorageService();
  final _db = SupabaseDatabaseService();

  @override
  void initState() {
    super.initState();
    // Isi form pake data lama
    _nameController = TextEditingController(text: widget.product.name);
    _originalPriceController = TextEditingController(
      text: widget.product.originalPrice.toString(),
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_newImage != null) {
        imageUrl = await _storage.uploadImage(
          _newImage!,
        ); // Upload baru kalo diganti
      }

      await _db.updateProduct(
        widget.product.id!,
        _nameController.text,
        int.parse(_originalPriceController.text),
        int.parse(_priceController.text),
        int.parse(_stockController.text),
        imageUrl, // Kirim null kalau gak ganti gambar (di handle service)
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu Berhasil Diupdate!")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Menu")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: () async {
                final img = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (img != null) setState(() => _newImage = File(img.path));
              },
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                  image: _newImage != null
                      ? DecorationImage(
                          image: FileImage(_newImage!),
                          fit: BoxFit.cover,
                        )
                      : (widget.product.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.product.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: (_newImage == null && widget.product.imageUrl == null)
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Ketuk gambar untuk mengganti",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Menu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _originalPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Harga Asli",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Harga Diskon",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Stok",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Update Data",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
