import 'package:flutter/material.dart';
import 'package:saveplate/screens/main_navigator_screen.dart'; // Sesuaikan path
import 'package:saveplate/services/auth_service.dart'; // Sesuaikan path
import 'package:saveplate/screens/login_screen.dart'; // Pastikan ada buat tombol 'Masuk'

// --- TEMA WARNA (Biar Konsisten) ---
class AppColors {
  static const Color primary = Color(0xFFFF6D00); // Orange SavePlate
  static const Color background = Color(0xFFF7F9FC); // Putih Abu Modern
  static const Color textDark = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);
  static const Color inputFill = Colors.white;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Buat toggle mata password
  bool _isConfirmVisible = false; // Buat toggle mata konfirmasi

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // 1. Validasi Input Dasar
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnack("Semua kolom wajib diisi!", Colors.red);
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showSnack("Format email tidak valid!", Colors.red);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack("Password dan konfirmasi tidak sama!", Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnack("Password minimal 6 karakter!", Colors.orange);
      return;
    }

    // 2. Proses Daftar
    setState(() => _isLoading = true);

    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        _showSnack("Akun berhasil dibuat! Selamat datang.", Colors.green);

        // Pindah ke Halaman Utama User
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainNavigatorScreenUser(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnack("Gagal mendaftar: ${e.toString()}", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- HEADER ---
                const Icon(
                  Icons.app_registration_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Buat Akun Baru",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Mulai selamatkan makanan dan\nhemat pengeluaranmu hari ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // --- FORM EMAIL ---
                _buildInputLabel("Alamat Email"),
                _buildTextField(
                  controller: _emailController,
                  hint: "contoh@email.com",
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // --- FORM PASSWORD ---
                _buildInputLabel("Kata Sandi"),
                _buildTextField(
                  controller: _passwordController,
                  hint: "Minimal 6 karakter",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggle: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 20),

                // --- FORM CONFIRM PASSWORD ---
                _buildInputLabel("Ulangi Kata Sandi"),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: "Masukkan ulang kata sandi",
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  isVisible: _isConfirmVisible,
                  onToggle: () =>
                      setState(() => _isConfirmVisible = !_isConfirmVisible),
                ),

                const SizedBox(height: 40),

                // --- TOMBOL DAFTAR ---
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "DAFTAR SEKARANG",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 25),

                // --- FOOTER (LOGIN LINK) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context), // Kembali ke Login
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER (Biar Codingan Rapi) ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Colors.grey[500],
                  ),
                  onPressed: onToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
