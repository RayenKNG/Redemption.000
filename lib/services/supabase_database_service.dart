import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseDatabaseService {
  // 1. Inisialisasi Supabase Client
  final SupabaseClient _supabase = Supabase.instance.client;

  // 2. Helper buat ambil ID User yang lagi login (baik Merchant atau Pembeli)
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ==========================================
  // BAGIAN A: FITUR KHUSUS MERCHANT (PENJUAL)
  // ==========================================

  // [STREAM] Ambil Menu Toko Sendiri (Realtime)
  // Dipakai di: Tab Menu
  Stream<List<Map<String, dynamic>>> getMerchantMenuStream() {
    return _supabase.from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentUserId)
        .order('created_at', ascending: false);
  }

  // [STREAM] Ambil Pesanan Masuk (Realtime)
  // Dipakai di: Tab Pesanan (Masuk/Proses/Selesai)
  Stream<List<Map<String, dynamic>>> getMerchantOrdersStream() {
    return _supabase.from('transactions')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', currentUserId)
        .order('created_at', ascending: false);
  }

  // [UPDATE] Ganti Status Pesanan
  // Pending -> Process -> Done
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase.from('transactions')
          .update({'status': newStatus})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  // [INSERT] Catat Penjualan Manual (Kasir Offline)
  // ✅ FUNGSI INI YANG TADI ERROR "UNDEFINED"
  Future<void> recordSale(String productId, int quantity, int totalPrice) async {
    // 1. Cek Stok Dulu
    final productData = await _supabase.from('products').select('stock').eq('id', productId).single();
    int currentStock = productData['stock'] as int;
    
    if (currentStock < quantity) throw Exception("Stok tidak cukup!");

    // 2. Kurangi Stok
    await _supabase.from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    // 3. Catat Transaksi (Langsung status 'done' karena ini kasir)
    await _supabase.from('transactions').insert({
      'merchant_id': currentUserId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': 'done', 
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // BAGIAN B: CRUD PRODUK (TAMBAH/EDIT/HAPUS)
  // ==========================================

  // Tambah Produk Baru
  Future<void> addProduct(String name, String? description, int originalPrice, int price, int stock, String? imageUrl) async {
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

  // Edit Produk
  Future<void> updateProduct(String id, String name, String? description, int originalPrice, int price, int stock, String? imageUrl) async {
    final data = {
      'name': name,
      'description': description,
      'original_price': originalPrice,
      'price': price,
      'stock': stock,
    };
    // Kalau ada gambar baru, update. Kalau null, jangan diapa-apain.
    if (imageUrl != null) data['image_url'] = imageUrl;
    
    await _supabase.from('products').update(data).eq('id', id);
  }

  // Hapus Produk
  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  // Ambil 1 Produk (Detail)
  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      return await _supabase.from('products').select().eq('id', productId).single();
    } catch (e) {
      // Return dummy kalau produknya udah kehapus biar gak error merah
      return {'name': 'Produk Dihapus', 'image_url': null};
    }
  }

  // ==========================================
  // BAGIAN C: DASHBOARD & TOKO
  // ==========================================

  // Hitung Statistik Dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await _supabase.from('transactions')
        .select('total_price, status')
        .eq('merchant_id', currentUserId);
    
    int totalWallet = 0;
    int totalOrders = res.length;
    
    for (var t in res) {
      // Uang cuma dihitung kalau statusnya 'done'
      if (t['status'] == 'done') {
        totalWallet += (t['total_price'] as int);
      }
    }
    return {'total_wallet': totalWallet, 'total_orders': totalOrders};
  }

  // Cek Toko Buka/Tutup (Realtime)
  Stream<Map<String, dynamic>> getShopStatus() {
    return _supabase.from('merchants').stream(primaryKey: ['id']).eq('id', currentUserId)
        .map((event) => event.isEmpty ? {'is_open': false} : event.first);
  }

  // Ganti Status Buka/Tutup
  Future<void> toggleShopStatus(bool isOpen) async {
    // Cek dulu datanya ada gak
    final check = await _supabase.from('merchants').select().eq('id', currentUserId).maybeSingle();
    
    if (check == null) {
      // Kalau belum ada, buat baru
      await _supabase.from('merchants').insert({'id': currentUserId, 'is_open': isOpen});
    } else {
      // Kalau udah ada, update aja
      await _supabase.from('merchants').update({'is_open': isOpen}).eq('id', currentUserId);
    }
  }

  // ==========================================
  // BAGIAN D: FITUR KHUSUS USER (PEMBELI)
  // ==========================================

  // User Beli Produk (Online Order)
  Future<void> buyProduct(String productId, String merchantId, int quantity, int totalPrice) async {
    // 1. Cek Stok
    final productData = await _supabase.from('products').select('stock').eq('id', productId).single();
    int currentStock = productData['stock'] as int;
    
    if (currentStock < quantity) throw Exception("Stok habis, bro!");

    // 2. Kurangi Stok
    await _supabase.from('products')
        .update({'stock': currentStock - quantity})
        .eq('id', productId);

    // 3. Buat Pesanan (Status awal: PENDING)
    // Ini yang nanti masuk ke Tab "Masuk" di Merchant
    await _supabase.from('transactions').insert({
      'merchant_id': merchantId,
      'buyer_id': currentUserId,
      'product_id': productId,
      'quantity': quantity,
      'total_price': totalPrice,
      'status': 'pending', 
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // User Lihat Riwayat Pesanan Sendiri
  Stream<List<Map<String, dynamic>>> getUserOrdersStream() {
    return _supabase.from('transactions')
        .stream(primaryKey: ['id'])
        .eq('buyer_id', currentUserId)
        .order('created_at', ascending: false);
  }

  // User Lihat Semua Menu yang Tersedia
  Stream<List<Map<String, dynamic>>> getAllAvailableMenuStream() {
    return _supabase.from('products')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((event) => event.where((p) => (p['stock'] as int) > 0).toList());
  }
}