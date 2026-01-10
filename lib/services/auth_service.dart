import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
}
