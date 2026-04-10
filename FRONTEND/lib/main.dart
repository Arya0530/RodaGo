import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart'; // Pastiin file login_page.dart lu ada di folder lib

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RodaGo',
      debugShowCheckedModeBanner: false, // Ngilangin pita "DEBUG" merah di pojok kanan atas
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginPage(), // NAH INI YANG BIKIN DIA BUKA LOGIN DULUAN
    );
  }
}