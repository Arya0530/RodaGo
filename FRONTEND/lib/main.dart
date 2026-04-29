import 'package:flutter/material.dart';
import 'service/user_session.dart';
import 'pages/auth/login_page.dart';
import 'pages/dashboard/main_layout.dart';

void main() async {
  // Wajib ada sebelum SharedPreferences diakses
  WidgetsFlutterBinding.ensureInitialized();

  // Coba muat sesi yang tersimpan di device
  final adaSesi = await UserSession.muat();

  runApp(MyApp(adaSesi: adaSesi));
}

class MyApp extends StatelessWidget {
  final bool adaSesi;
  const MyApp({required this.adaSesi});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RodaGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: false,
      ),
      // Semua role (user maupun owner) masuk ke MainLayout yang sama.
      // Perbedaan owner hanya muncul di halaman Profile (ada menu Dashboard Owner).
      home: adaSesi ? MainLayout() : LoginPage(),
    );
  }
}