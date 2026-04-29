import 'package:flutter/material.dart';
import '../../service/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _isLoading       = false;
  String _selectedRole  = 'user';

  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validasi semua input sebelum kirim ke API
  String? _validasi() {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final phone    = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty)  return 'Nama lengkap wajib diisi!';
    if (name.length < 3) return 'Nama minimal 3 karakter!';

    if (email.isEmpty) return 'Email wajib diisi!';
    final emailValid = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!emailValid)   return 'Format email tidak valid!';

    if (phone.isEmpty) return 'Nomor HP wajib diisi!';
    // Hanya angka, minimal 9 digit (format Indonesia)
    final phoneValid = RegExp(r'^[0-9]{9,15}$').hasMatch(phone);
    if (!phoneValid)   return 'Nomor HP hanya angka, min. 9 digit!';

    if (password.isEmpty)    return 'Password wajib diisi!';
    if (password.length < 8) return 'Password minimal 8 karakter!';
    if (!password.contains(RegExp(r'[A-Z]')))
      return 'Password harus mengandung huruf kapital (A-Z)!';
    if (!password.contains(RegExp(r'[a-z]')))
      return 'Password harus mengandung huruf kecil (a-z)!';
    if (!password.contains(RegExp(r'[0-9]')))
      return 'Password harus mengandung angka (0-9)!';

    return null; // semua valid
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Join RodaGo today and start your journey",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),

              // Full Name
              Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Email
              Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Phone
              Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                "Hanya angka, tanpa spasi atau tanda hubung.",
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Contoh: 08123456789",
                  prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Password
              Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              // Info syarat password
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.teal, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Min. 8 karakter • Huruf kapital (A-Z) • Huruf kecil (a-z) • Angka (0-9)",
                        style: TextStyle(fontSize: 11, color: Colors.teal[700]),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "Buat password yang kuat",
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Role
              Text("Daftar Sebagai",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: Icon(
                      Icons.assignment_ind_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                      value: 'user',
                      child: Text('Penyewa Mobil (User)')),
                  DropdownMenuItem(
                      value: 'owner',
                      child: Text('Pemilik Rental (Owner)')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedRole = newValue);
                },
              ),
              SizedBox(height: 40),

              // Tombol Register
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          // Validasi Flutter dulu
                          final errorMsg = _validasi();
                          if (errorMsg != null) {
                            _showSnackBar(errorMsg, Colors.red);
                            return;
                          }

                          setState(() => _isLoading = true);

                          final result = await ApiService.register(
                            _nameController.text.trim(),
                            _emailController.text.trim(),
                            _phoneController.text.trim(),
                            _passwordController.text,
                            _selectedRole,
                          );

                          if (!mounted) return;
                          setState(() => _isLoading = false);

                          if (result['success'] == true) {
                            _showSnackBar(
                              'Registrasi berhasil! Silakan login.',
                              Colors.teal,
                            );
                            Navigator.pop(context);
                          } else {
                            _showSnackBar(
                              result['message']?.toString() ??
                                  'Registrasi gagal, coba lagi',
                              Colors.red,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          "Create Account",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
              SizedBox(height: 30),

              // Link ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}