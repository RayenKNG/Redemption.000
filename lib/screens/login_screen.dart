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
          // Langkah 1: Gradasi warna Hijau SavePlate
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9), // Hijau sangat muda (atas kiri)
              Color(0xFF2ECC71), // Hijau Emerald (bawah kanan)
            ],
          ),
        ),
        // Kita siapin Stack buat numpuk elemen kaca nanti
        child: Stack(
          children: [
            // Kosong dulu, nanti kita isi dekorasi & form login
          ],
        ),
      ),
    );
  }
}
