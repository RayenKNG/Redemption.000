import 'dart:async'; // Buat Timer Splash Screen
import 'dart:math' as math; // Buat Animasi Muter
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';

// ✅ IMPORT SCREEN LAIN
import 'package:saveplate/screens/merchant_home_screen.dart';
import 'package:saveplate/screens/home_screen.dart';
import 'package:saveplate/screens/login_screen.dart';
import 'package:saveplate/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Init Supabase
  await Supabase.initialize(
    url: 'https://ntdrrnrhgwnjvznbodno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50ZHJybnJoZ3duanZ6bmJvZG5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwNTQ0MDYsImV4cCI6MjA4MzYzMDQwNn0.-zkqv8PshNRTFLZVhxaUyTIxTb7bzHoO8gxrMdF1uVc',
  );

  // 3. Init Notifikasi
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaveBite',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6D00)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      // 🔥 Panggil Splash Screen
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/merchant_home': (context) => const MerchantMainScreen(),
        '/user_home': (context) => const HomeScreen(),
      },
    );
  }
}

// ==========================================
// 🌟 SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah halaman setelah 4 detik
    Timer(const Duration(seconds: 4), () {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 👇 PANGGIL WIDGET LOADING DI BAWAH
    return const GlobalLoading(size: 150);
  }
}

// ==========================================
// 🌀 WIDGET GLOBAL LOADING (DITARUH DISINI BIAR GAK ERROR)
// ==========================================
class GlobalLoading extends StatefulWidget {
  final double size;
  const GlobalLoading({super.key, this.size = 120.0});

  @override
  State<GlobalLoading> createState() => _GlobalLoadingState();
}

class _GlobalLoadingState extends State<GlobalLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Logo Muter
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Container(
                width: widget.size,
                height: widget.size,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                // ⚠️ PASTIKAN ADA FILE GAMBAR INI DI ASSETS KAMU
                child: ClipOval(
                  child: Image.asset(
                    'assets/global_logo.png', // Pastikan nama file ini benar
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Kalau gambar gak ketemu, tampilkan icon pengganti biar gak crash
                      return const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Memuat Data...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: widget.size * 1.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: Color(0xFFF1F2F6),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
