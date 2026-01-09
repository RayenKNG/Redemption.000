import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFF2ECC71)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),

                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          const Text(
                            "SavePlate",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            "Selamatkan makanan, selamatkan bumi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 30),

                          _buildGlassInput(Icons.email_outlined, "Email"),

                          const SizedBox(height: 20),

                          _buildGlassInput(
                            Icons.lock_outline,
                            "Password",
                            isPassword: true,
                          ),
                          // Tombol Login
                          SizedBox(
                            width: double
                                .infinity, // Lebar tombol mentok kiri-kanan
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.white, // Tombol warna Putih
                                foregroundColor: const Color(
                                  0xFF2ECC71,
                                ), // Teks warna Hijau
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5, // Ada bayangannya dikit
                              ),
                              onPressed: () {
                                // Nanti kita isi logika login di sini
                              },
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Tombol ke Halaman Daftar
                          TextButton(
                            onPressed: () {
                              // Nanti kita arahkan ke halaman register di sini
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: "Belum punya akun? ",
                                style: TextStyle(color: Colors.white70),
                                children: [
                                  TextSpan(
                                    text: "Daftar",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration
                                          .underline, // Garis bawah biar jelas link
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ), // Jarak napas terakhir di bawah
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassInput(
    IconData icon,
    String hint, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
