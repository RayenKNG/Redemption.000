import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:saveplate/screens/merchant_home_screen.dart';
import 'package:saveplate/screens/login_screen.dart';
import 'package:saveplate/screens/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());

  await Supabase.initialize(
    url: 'https://ntdrrnrhgwnjvznbodno.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50ZHJybnJoZ3duanZ6bmJvZG5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwNTQ0MDYsImV4cCI6MjA4MzYzMDQwNn0.-zkqv8PshNRTFLZVhxaUyTIxTb7bzHoO8gxrMdF1uVc',
  );
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
        // Warna seed pake DeepOrange biar nyambung sama gradasi Peach/Orange
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),

      // --- PERBAIKAN DISINI ---
      // Kita set home langsung ke MerchantMainScreen()
      // supaya error merah hilang dan langsung masuk ke Dashboard baru.
      home: const LoginScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/merchant_home': (context) => const MerchantMainScreen(),
      },
    );
  }
}
