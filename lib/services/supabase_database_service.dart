import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Buat ambil User ID

class SupabaseDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil ID Merchant yang lagi login dari Firebase Auth
  String get currentMerchantId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. READ (Ambil Menu Realtime)
  Stream<List<Map<String, dynamic>>> getMenuStream() {
    // Filter berdasarkan merchant_id biar yg muncul cuma produk toko ini
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentMerchantId)
        .order('created_at', ascending: false);
  }

  // 2. CREATE (Tambah Menu Baru)
  Future<void> addProduct(
    String name,
    int originalPrice,
    int price,
    int stock,
    String? imageUrl,
  ) async {
    await _supabase.from('products').insert({
      'merchant_id': currentMerchantId,
      'name': name,
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
      'is_active': true,
      'image_url': imageUrl,
    });
  }

  // 3. DELETE (Hapus Menu)
  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  // 4. UPDATE TOKO (Buka/Tutup) - Disimpan di tabel 'merchants'
  // Pastikan lu udah bikin tabel 'merchants' di Supabase ya!
  Future<void> toggleShopStatus(bool isOpen) async {
    // Cek dulu datanya ada gak
    final check = await _supabase
        .from('merchants')
        .select()
        .eq('id', currentMerchantId)
        .maybeSingle();

    if (check == null) {
      // Kalo belum ada, insert baru
      await _supabase.from('merchants').insert({
        'id': currentMerchantId,
        'is_open': isOpen,
      });
    } else {
      // Kalo udah ada, update
      await _supabase
          .from('merchants')
          .update({'is_open': isOpen})
          .eq('id', currentMerchantId);
    }
  }

  // 5. GET STATUS TOKO
  Stream<Map<String, dynamic>> getShopStatus() {
    return _supabase
        .from('merchants')
        .stream(primaryKey: ['id'])
        .eq('id', currentMerchantId)
        .map((event) {
          if (event.isEmpty) return {'is_open': false};
          return event.first;
        });
  }
}
