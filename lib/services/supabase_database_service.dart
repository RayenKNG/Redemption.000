import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil ID User yang login
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ====================================================
  // 1. GET DATA (Untuk Dashboard & Menu)
  // ====================================================

  // Buat Merchant: Ambil menu toko sendiri
  Stream<List<Map<String, dynamic>>> getMerchantMenuStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentUserId)
        .order('created_at', ascending: false);
  }

  // Buat User: Ambil SEMUA menu yang tersedia (Food Rescue)
  Stream<List<Map<String, dynamic>>> getAllAvailableMenuStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .gt('stock', 0) // Cuma yang ada stoknya
        .order('created_at', ascending: false);
  }

  // ====================================================
  // 2. CRUD PRODUK (Tambah/Edit/Hapus)
  // ====================================================

  Future<void> addProduct(
    String name,
    String? description,
    int originalPrice,
    int price,
    int stock,
    String? imageUrl,
  ) async {
    await _supabase.from('products').insert({
      'merchant_id': currentUserId,
      'name': name,
      'description': description,
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
      'is_active': true,
      'image_url': imageUrl,
    });
  }

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
      'description': description,
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
    };
    if (imageUrl != null) data['image_url'] = imageUrl;
    await _supabase.from('products').update(data).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  // ====================================================
  // 3. TRANSAKSI (JUAL BELI) - INI YANG BIKIN ERROR TADI
  // ====================================================

  // 👉 OPSI A: recordSale (Dipakai Merchant buat Jual Manual/Kasir)
  Future<void> recordSale(
    String productId,
    int quantity,
    int totalPrice,
  ) async {
    // 1. Cek Stok
    final productData = await _supabase
        .from('products')
        .select('stock')
        .eq('id', productId)
        .single();
    int currentStock = productData['stock'] as int;
    if (currentStock < quantity) throw Exception("Stok tidak cukup!");

    // 2. Kurangi Stok
    await _supabase
        .from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    // 3. Catat Transaksi (Merchant ID = Current User)
    await _supabase.from('transactions').insert({
      'merchant_id': currentUserId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // 👉 OPSI B: buyProduct (Dipakai User buat Beli Online)
  Future<void> buyProduct(
    String productId,
    String merchantId,
    int quantity,
    int totalPrice,
  ) async {
    // 1. Cek Stok
    final productData = await _supabase
        .from('products')
        .select('stock')
        .eq('id', productId)
        .single();
    int currentStock = productData['stock'] as int;
    if (currentStock < quantity)
      throw Exception("Yah, stoknya abis keduluan orang lain!");

    // 2. Kurangi Stok
    await _supabase
        .from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    // 3. Catat Transaksi (Ada Buyer ID-nya)
    await _supabase.from('transactions').insert({
      'merchant_id': merchantId, // Masuk ke dompet Merchant
      'buyer_id': currentUserId, // Dicatat siapa yang beli
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ====================================================
  // 4. LAIN-LAIN (Status Toko & Statistik)
  // ====================================================

  Stream<Map<String, dynamic>> getShopStatus() {
    return _supabase
        .from('merchants')
        .stream(primaryKey: ['id'])
        .eq('id', currentUserId)
        .map((event) {
          if (event.isEmpty) return {'is_open': false};
          return event.first;
        });
  }

  Future<void> toggleShopStatus(bool isOpen) async {
    final check = await _supabase
        .from('merchants')
        .select()
        .eq('id', currentUserId)
        .maybeSingle();
    if (check == null) {
      await _supabase.from('merchants').insert({
        'id': currentUserId,
        'is_open': isOpen,
      });
    } else {
      await _supabase
          .from('merchants')
          .update({'is_open': isOpen})
          .eq('id', currentUserId);
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final transactions = await _supabase
        .from('transactions')
        .select('total_price')
        .eq('merchant_id', currentUserId)
        .gte('created_at', startOfDay);

    int todayRevenue = 0;
    for (var t in transactions) {
      todayRevenue += (t['total_price'] as int);
    }

    return {'today_revenue': todayRevenue, 'today_orders': transactions.length};
  }
}

extension on SupabaseStreamBuilder {
  gt(String s, int i) {}
}
