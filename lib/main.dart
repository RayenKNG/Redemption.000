import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

// Import Screen
// Pastikan file "merchant_home_screen.dart" isinya kode FULL yang gua kasih sebelumnya ya!
import 'package:saveplate/screens/merchant_home_screen.dart';
import 'package:saveplate/screens/login_screen.dart';
import 'package:saveplate/screens/register_screen.dart';

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
        // Warna seed pake DeepOrange biar nyambung sama gradasi Peach/Orange
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),

      // --- PERBAIKAN DISINI ---
      // Kita set home langsung ke MerchantMainScreen()
      // supaya error merah hilang dan langsung masuk ke Dashboard baru.
      home: const MerchantMainScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/merchant_home': (context) => const MerchantMainScreen(),
      },
    );
  }
}
