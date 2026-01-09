import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
=======
import 'package:google_fonts/google_fonts.dart'; // Biar font-nya modern
import 'screens/home_screen.dart'; // Panggil halaman home tadi
import 'screens/login_screen.dart';
>>>>>>> 71ace736d46baee86324c6591c40ee6674598bc0

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // <-- Ini dia pintu masuknya
    );
  }
}
