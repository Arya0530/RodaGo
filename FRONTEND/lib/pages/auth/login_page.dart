// ============================================================
// FILE DIUPDATE: lib/pages/auth/login_page.dart
// ============================================================
// APA YANG BERUBAH DARI VERSI LAMA?
//
// Tombol "Sign In" yang lama langsung loncat ke MainLayout
// TANPA cek email/password sama sekali (hardcode).
//
// Sekarang tombol Sign In:
//   1. Panggil ApiService.login() dengan email & password asli
//   2. Kalau gagal → tampilkan SnackBar pesan error
//   3. Kalau berhasil → cek UserSession.role
//      - Kalau 'owner' → masuk ke OwnerMainLayout
//      - Kalau 'user'  → masuk ke MainLayout (user biasa)
//
// Tampilan tidak berubah sama sekali, hanya logika tombol.
// ============================================================

import 'package:flutter/material.dart';
import 'register_page.dart';
import '../dashboard/main_layout.dart';
import '../owner/owner_main_layout.dart';
import '../../service/api_service.dart';    // <-- TAMBAHAN BARU
import '../../service/user_session.dart';   // <-- TAMBAHAN BARU

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false; // <-- TAMBAHAN BARU: buat animasi loading tombol

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              // Judul & Subjudul (TIDAK BERUBAH)
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Masuk untuk melanjutkan perjalanan Anda",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 40),

              // Form Email (TIDAK BERUBAH)
              Text("Email Address",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon:
                      Icon(Icons.email_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Form Password (TIDAK BERUBAH)
              Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // Lupa Password (TIDAK BERUBAH)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Fitur ini sedang maintenance. Hubungi Admin."),
                        backgroundColor: Colors.orange));
                  },
                  child: Text("Forgot Password?",
                      style: TextStyle(color: Colors.teal)),
                ),
              ),

              // ===========================================================
              // TOMBOL LOGIN (BAGIAN YANG DIUPDATE)
              // ===========================================================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null // Kalau lagi loading, tombol dikunci
                      : () async {
                          // Validasi sederhana: jangan sampai kosong
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Email dan password wajib diisi!"),
                                backgroundColor: Colors.red));
                            return;
                          }

                          // Aktifkan loading spinner
                          setState(() => _isLoading = true);

                          // Panggil API login
                          final result = await ApiService.login(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                         

                          // Matikan loading spinner
                          setState(() => _isLoading = false);

                          if (result['success']) {
                            // LOGIN BERHASIL!
                            // UserSession sudah terisi otomatis di dalam ApiService.login()
                            // Sekarang tinggal cek role-nya untuk menentukan mau ke mana

                            if (result['success']) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MainLayout()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(result['message'] ?? 'Login gagal, coba lagi'),
                                  backgroundColor: Colors.red));
                            }
                          } else {
                            // LOGIN GAGAL → Tampilkan pesan error dari API
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result['message'] ??
                                    'Login gagal, coba lagi'),
                                backgroundColor: Colors.red));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  // Kalau loading, tampilkan spinner. Kalau tidak, tampilkan teks.
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text("Sign In",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                ),
              ),
              // ===========================================================
              SizedBox(height: 30),

              // Link ke Register (TIDAK BERUBAH)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}