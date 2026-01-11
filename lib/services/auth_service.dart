import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter Firestore
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

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

  // 2. Fungsi Register (Daftar Baru)
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
  // ✅ NAMA FUNGSI DISAMAKAN JADI 'signOut' (Sesuai UI)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 4. Cek Role (Hunter / Merchant)
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('role') ?? 'user';
      } else {
        return 'user';
      }
    } catch (e) {
      return 'user';
    }
  }
}
