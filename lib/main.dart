import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // Biar font-nya modern
import 'screens/home_screen.dart'; // Panggil halaman home tadi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase (Kita siapkan dari sekarang biar nanti Login lancar)
  // Kalau error di tahap ini, nanti kita komen dulu baris di bawah ini
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hilangkan label 'Debug' di pojok
      title: 'SaveBite',
      theme: ThemeData(
        // Kita pakai font 'Poppins' biar kayak startup kekinian
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(), // <-- Ini dia pintu masuknya
    );
  }
}
