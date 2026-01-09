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
    // Kita return Scaffold dulu biar layar ada isinya (putih polos + teks)
    return const Scaffold(body: Center(child: Text("Setup Login Screen")));
  }
}
