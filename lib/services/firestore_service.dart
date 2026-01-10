import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );

  // Dapatkan User ID yang lagi login
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. CREATE: Tambah Produk Baru
  Future<void> addProduct(String name, int price, int stock) async {
    if (currentUserId.isEmpty) throw Exception("User belum login");

    await _products.add({
      'merchantId': currentUserId, // Produk ini milik merchant yang login
      'name': name,
      'price': price,
      'stock': stock,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. READ: Ambil Semua Produk Punya Merchant Ini
  Stream<QuerySnapshot> getMerchantProducts() {
    // Filter: Cuma ambil produk yang merchantId-nya sama dengan User yang login
    return _products
        .where('merchantId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 3. UPDATE: Edit Status / Stok
  Future<void> updateProduct(String id, {bool? isActive, int? stock}) async {
    Map<String, dynamic> data = {};
    if (isActive != null) data['isActive'] = isActive;
    if (stock != null) data['stock'] = stock;

    await _products.doc(id).update(data);
  }

  // 4. DELETE: Hapus Produk
  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}
