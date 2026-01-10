import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _bucketName =
      'product-images'; // ⚠️ Pastikan nama bucket ini ada di Supabase

  Future<String?> uploadImage(File imageFile) async {
    try {
      final String fileName =
          'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage
          .from(_bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      return _client.storage.from(_bucketName).getPublicUrl(fileName);
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
