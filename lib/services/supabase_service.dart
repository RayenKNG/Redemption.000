import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _client = Supabase.instance.client;

  // ✅ UPDATE: Nama bucket jadi 'saveplate'
  final String _bucketName = 'saveplate';

  Future<String?> uploadImage(File imageFile) async {
    try {
      final String fileName =
          'menu/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 1. Upload ke Supabase
      // upsert: true biar kalau nama sama dia nimpa (aman)
      await _client.storage
          .from(_bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // 2. Ambil Public URL
      final String publicUrl = _client.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      print("✅ URL GAMBAR: $publicUrl"); // Cek di Terminal nanti
      return publicUrl;
    } catch (e) {
      print("❌ GAGAL UPLOAD: $e");
      return null;
    }
  }
}
