import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- TEMA WARNA ---
class AppColors {
  static const Color primary = Color(0xFF2D3436);
  static const Color accent = Color(0xFFFF7675);
  static const Color background = Color(0xFFF7F9FC);
}

class RegisterMerchantScreen extends StatefulWidget {
  const RegisterMerchantScreen({super.key});

  @override
  State<RegisterMerchantScreen> createState() => _RegisterMerchantScreenState();
}

class _RegisterMerchantScreenState extends State<RegisterMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isObscure = true;

  // Controller
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔥 LOGIC DAFTAR PAKAI FIREBASE
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Buat Akun di Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Simpan Data Toko di Cloud Firestore
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('merchants').doc(uid).set({
          'store_name': _storeNameController.text.trim(),
          'owner_name': _ownerNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'merchant', // Penanda kalau ini akun penjual
          'created_at': FieldValue.serverTimestamp(),
          'balance': 0, // Saldo awal nol
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registrasi Berhasil! Selamat Datang."),
              backgroundColor: Colors.green,
            ),
          );
          // Langsung masuk ke Home atau Login
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "Terjadi kesalahan.";
      if (e.code == 'weak-password') message = "Password terlalu lemah.";
      if (e.code == 'email-already-in-use') message = "Email sudah terdaftar.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daftar Mitra",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Gunakan Firebase untuk mendaftar toko.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),

                // INFORMASI TOKO
                const _SectionTitle(title: "Info Toko"),
                const SizedBox(height: 15),
                _CustomTextField(
                  controller: _storeNameController,
                  label: "Nama Toko",
                  icon: Icons.store,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),
                const SizedBox(height: 15),
                _CustomTextField(
                  controller: _addressController,
                  label: "Alamat",
                  icon: Icons.map,
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                ),

                const SizedBox(height: 25),

                // KONTAK
                const _SectionTitle(title: "Kontak"),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _CustomTextField(
                        controller: _ownerNameController,
                        label: "Pemilik",
                        icon: Icons.person,
                        validator: (v) => v!.isEmpty ? "Wajib" : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CustomTextField(
                        controller: _phoneController,
                        label: "No. HP",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? "Wajib" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // AKUN LOGIN
                const _SectionTitle(title: "Akun Login"),
                const SizedBox(height: 15),
                _CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      !v!.contains('@') ? "Email tidak valid" : null,
                ),
                const SizedBox(height: 15),
                _CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  obscureText: _isObscure,
                  validator: (v) => v!.length < 6 ? "Min 6 karakter" : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),

                const SizedBox(height: 40),

                // TOMBOL DAFTAR
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Daftar Sekarang",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget TextField Custom (Sama kayak sebelumnya biar rapi)
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
