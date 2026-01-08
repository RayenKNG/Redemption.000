import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
