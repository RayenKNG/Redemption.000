import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORT SEMUA HALAMAN DI SINI
import 'package:saveplate/screens/merchant_home_screen.dart';
import 'package:saveplate/screens/home_screen.dart'; // 👈 INI DITAMBAHIN (BUAT USER)
import 'package:saveplate/screens/login_screen.dart';
import 'package:saveplate/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Init Supabase (HARUS SEBELUM runApp)
  await Supabase.initialize(
    url: 'https://ntdrrnrhgwnjvznbodno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50ZHJybnJoZ3duanZ6bmJvZG5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwNTQ0MDYsImV4cCI6MjA4MzYzMDQwNn0.-zkqv8PshNRTFLZVhxaUyTIxTb7bzHoO8gxrMdF1uVc',
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),

      // Halaman pertama kali dibuka
      home: const LoginScreen(),

      // ✅ DAFTAR RUTE LENGKAP
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),

        // Rute buat Merchant (Penjual)
        '/merchant_home': (context) => const MerchantMainScreen(),

        '/user_home': (context) => const HomeScreen(),
      },
    );
  }
}
