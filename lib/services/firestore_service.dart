import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Panggil koleksi 'products' di Firebase
  final CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );

  // CREATE: Tambah Produk
  Future<void> addProduct(
    String name,
    int price,
    int stock, {
    String? imageUrl,
  }) {
    return products.add({
      'name': name,
      'price': price,
      'stock': stock,
      'isActive': true,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ: Ambil Data (Live)
  Stream<QuerySnapshot> getProducts() {
    return products.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE: Hapus Produk
  Future<void> deleteProduct(String id) {
    return products.doc(id).delete();
  }
}
