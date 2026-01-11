import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil ID User yang lagi login
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ==========================================
  // 1. FITUR MENU (MERCHANT)
  // ==========================================

  // Ambil Menu Toko Sendiri
  Stream<List<Map<String, dynamic>>> getMerchantMenuStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentUserId)
        .order('created_at', ascending: false);
  }

  // ==========================================
  // 2. FITUR PESANAN (MERCHANT)
  // ==========================================

  // Ambil Orderan Masuk
  Stream<List<Map<String, dynamic>>> getMerchantOrdersStream() {
    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentUserId)
        .order('created_at', ascending: false);
  }

  // Ambil Nama Produk dari ID
  Future<Map<String, dynamic>> getProductById(String productId) async {
    return await _supabase
        .from('products')
        .select()
        .eq('id', productId)
        .single();
  }

  // ==========================================
  // 3. FITUR USER (PEMBELI)
  // ==========================================

  // Feed Makanan User
  // Ambil SEMUA Menu yang Ada (Food Rescue Feed buat User)
  Stream<List<Map<String, dynamic>>> getAllAvailableMenuStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('is_active', true) // Filter aktif aja
        .order('created_at', ascending: false)
        .map((event) {
          // ✅ FILTER MANUAL DI SINI (Client Side)
          // Cuma lolosin yang stoknya > 0
          return event
              .where((product) => (product['stock'] as int) > 0)
              .toList();
        });
  }

  // ==========================================
  // 4. TRANSAKSI (JUAL & BELI)
  // ==========================================

  // Merchant: Catat Penjualan Manual
  Future<void> recordSale(
    String productId,
    int quantity,
    int totalPrice,
  ) async {
    final productData = await _supabase
        .from('products')
        .select('stock')
        .eq('id', productId)
        .single();
    int currentStock = productData['stock'] as int;

    if (currentStock < quantity) throw Exception("Stok tidak cukup!");

    await _supabase
        .from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    await _supabase.from('transactions').insert({
      'merchant_id': currentUserId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // User: Beli Makanan
  Future<void> buyProduct(
    String productId,
    String merchantId,
    int quantity,
    int totalPrice,
  ) async {
    final productData = await _supabase
        .from('products')
        .select('stock')
        .eq('id', productId)
        .single();
    int currentStock = productData['stock'] as int;

    if (currentStock < quantity)
      throw Exception("Yah, stoknya abis keduluan orang lain!");

    await _supabase
        .from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    await _supabase.from('transactions').insert({
      'merchant_id': merchantId,
      'buyer_id': currentUserId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // 5. CRUD PRODUK
  // ==========================================

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

  // ==========================================
  // 6. DASHBOARD & STATUS
  // ==========================================

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
}
