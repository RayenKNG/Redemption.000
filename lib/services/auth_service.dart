import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Ini adalah alat dari Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi Login
  Future<User?> login({required String email, required String password}) async {
    try {
      // Mencoba login ke Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Kalau berhasil, kembalikan data user-nya
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Kalau gagal (misal password salah), lempar errornya
      throw e.message ?? "Terjadi kesalahan login";
    } catch (e) {
      throw "Terjadi kesalahan tidak terduga";
    }
  }

  // Fungsi Logout (Disiapkan buat nanti)
  Future<void> logout() async {
    await _auth.signOut();
  }
}