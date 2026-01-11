import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil ID User yang lagi login
  String get currentMerchantId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. AMBIL DATA MENU (REALTIME)
  Stream<List<Map<String, dynamic>>> getMenuStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentMerchantId)
        .order('created_at', ascending: false);
  }

  // 2. TAMBAH PRODUK BARU (LENGKAP)
  Future<void> addProduct(
    String name,
    String? description,
    int originalPrice,
    int price,
    int stock,
    String? imageUrl,
  ) async {
    await _supabase.from('products').insert({
      'merchant_id': currentMerchantId,
      'name': name,
      'description': description, // ✅ Deskripsi Masuk DB
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
      'is_active': true,
      'image_url': imageUrl,
    });
  }

  // 3. UPDATE PRODUK (LENGKAP)
  Future<void> updateProduct(
    String id,
    String name,
    String? description,
    int originalPrice,
    int price,
    int stock,
    String? imageUrl,
  ) async {
    final data = {
      'name': name,
      'description': description, // ✅ Deskripsi Masuk DB
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
    };
    if (imageUrl != null) {
      data['image_url'] = imageUrl;
    }

    await _supabase.from('products').update(data).eq('id', id);
  }

  // 4. HAPUS PRODUK
  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  // 5. UPDATE STATUS TOKO (Buka/Tutup)
  Future<void> toggleShopStatus(bool isOpen) async {
    final check = await _supabase
        .from('merchants')
        .select()
        .eq('id', currentMerchantId)
        .maybeSingle();

    if (check == null) {
      await _supabase.from('merchants').insert({
        'id': currentMerchantId,
        'is_open': isOpen,
      });
    } else {
      await _supabase
          .from('merchants')
          .update({'is_open': isOpen})
          .eq('id', currentMerchantId);
    }
  }

  // 6. AMBIL STATUS TOKO
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

  // 7. CATAT PENJUALAN (TRANSAKSI)
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
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 8. HITUNG TOTAL PENDAPATAN (WALLET)
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

  // 9. AMBIL RIWAYAT TRANSAKSI
  Stream<List<Map<String, dynamic>>> getTransactionHistory() {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentMerchantId)
        .order('created_at', ascending: false);
  }

  // 10. GET DASHBOARD STATS (Buat Dashboard)
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
        .gte('created_at', startOfDay);

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

  // 11. AMBIL PRODUK STOK MENIPIS (<= 5)
  Stream<List<Map<String, dynamic>>> getLowStockProducts() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentMerchantId)
        .lte('stock', 5)
        .order('stock', ascending: true);
  }
}

extension on SupabaseStreamBuilder {
  lte(String s, int i) {}
}
