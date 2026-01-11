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
  // ... import dan class SupabaseDatabaseService yang lama ...

  // 👇 TAMBAHKAN INI DI DALAM CLASS:

  // 1. CATAT TRANSAKSI (Kurangi Stok + Simpan Riwayat)
  Future<void> recordSale(
    String productId,
    int quantity,
    int totalPrice,
  ) async {
    // A. Kurangi Stok
    final productData = await _supabase
        .from('products')
        .select('stock')
        .eq('id', productId)
        .single();
    int currentStock = productData['stock'] as int;

    if (currentStock < quantity) throw Exception("Stok abis bro!");

    await _supabase
        .from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    // B. Simpan ke Tabel Transaksi
    await _supabase.from('transactions').insert({
      'merchant_id': currentMerchantId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
    });
  }

  // 2. HITUNG TOTAL DUIT (OMZET)
  Future<int> getTotalRevenue() async {
    final res = await _supabase
        .from('transactions')
        .select('total_price')
        .eq('merchant_id', currentMerchantId);
    int total = 0;
    for (var item in res) {
      total += (item['total_price'] as int);
    }
    return total;
  }

  // 3. AMBIL RIWAYAT TRANSAKSI
  Stream<List<Map<String, dynamic>>> getTransactionHistory() {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentMerchantId)
        .order('created_at', ascending: false);
  }

  // ... (Kodingan sebelumnya biarkan saja) ...

  // 9. UPDATE PRODUK (Edit Menu)
  Future<void> updateProduct(
    String id,
    String name,
    int originalPrice,
    int price,
    int stock,
    String? imageUrl,
  ) async {
    final data = {
      'name': name,
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
    };
    // Kalau ada gambar baru, update link-nya. Kalau null, biarin link lama.
    if (imageUrl != null) {
      data['image_url'] = imageUrl;
    }

    await _supabase.from('products').update(data).eq('id', id);
  }

  // 10. GET DASHBOARD STATS (Buat isi Dashboard biar gak kosong)
  Future<Map<String, dynamic>> getDashboardStats() async {
    // A. Hitung Total Produk Aktif
    final products = await _supabase
        .from('products')
        .select('id')
        .eq('merchant_id', currentMerchantId)
        .eq('is_active', true);

    // B. Hitung Penjualan Hari Ini
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final transactions = await _supabase
        .from('transactions')
        .select('total_price')
        .eq('merchant_id', currentMerchantId)
        .gte('created_at', startOfDay); // Ambil yg >= hari ini jam 00:00

    int todayRevenue = 0;
    for (var t in transactions) {
      todayRevenue += (t['total_price'] as int);
    }

    return {
      'total_products': products.length,
      'today_revenue': todayRevenue,
      'today_orders': transactions.length,
    };
  }
}
