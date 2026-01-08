import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; // Biar font-nya modern
import 'screens/home_screen.dart'; // Panggil halaman home tadi
import 'screens/login_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();  <-- KASIH GARIS MIRING (//)

  // Matikan dulu baris ini biar aplikasi mau jalan walau tanpa database
  // await Firebase.initializeApp();             <-- KASIH GARIS MIRING (//)

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
      home: const LoginScreen(), // <-- Ini dia pintu masuknya
    );
  }
}
