import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Tambah Import Ini

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get _firestore => FirebaseFirestore.instance;

  // 1. Fungsi Login (Masuk)
  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Terjadi kesalahan login";
    } catch (e) {
      throw "Terjadi kesalahan tidak terduga";
    }
  }

  // 2. Fungsi Register (Daftar Baru) -> INI YANG BARU KITA TAMBAH
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Gagal mendaftar";
    } catch (e) {
      throw "Terjadi kesalahan saat mendaftar";
    }
  }

  // 3. Fungsi Logout (Keluar)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 👇 4. FUNGSI BARU: CEK ROLE (HUNTER / MERCHANT)
  Future<String> getUserRole(String uid) async {
    try {
      // Cari data user di koleksi 'users' berdasarkan UID
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        // Ambil data 'role' dari database (misal: "merchant" atau "user")
        return doc.get('role') ?? 'user';
      } else {
        // Kalau datanya gak ada, anggap aja user biasa
        return 'user';
      }
    } catch (e) {
      return 'user'; // Default kalau error
    }
  }
}
