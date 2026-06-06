// ============================================================
// LOKASI FILE: lib/pages/auth/forgot_password_page.dart
// ============================================================
// Halaman reset password BARU — 1 halaman, langsung isi
// email + password baru + konfirmasi → tekan tombol → selesai.
// Tidak ada halaman lain (tidak ada OTP, tidak ada step ke-2).
// ============================================================

import 'package:flutter/material.dart';
import '../../service/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // ── Controller ───────────────────────────────────────────────
  final _emailCtrl   = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Indikator syarat password (reaktif) ──────────────────────
  bool get _ok8     => _newCtrl.text.length >= 8;
  bool get _okUpper => _newCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _okLower => _newCtrl.text.contains(RegExp(r'[a-z]'));
  bool get _okNum   => _newCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _okMatch =>
      _newCtrl.text == _confirmCtrl.text && _confirmCtrl.text.isNotEmpty;

  // ── Submit ───────────────────────────────────────────────────
  Future<void> _submit() async {
    final email   = _emailCtrl.text.trim();
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    // Validasi lokal sebelum hit API
    if (email.isEmpty) { _snackRed('Email wajib diisi!'); return; }
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _snackRed('Format email tidak valid!'); return;
    }
    if (newPass.isEmpty)    { _snackRed('Password baru wajib diisi!'); return; }
    if (!_ok8)              { _snackRed('Password minimal 8 karakter!'); return; }
    if (!_okUpper)          { _snackRed('Password harus ada huruf kapital (A-Z)!'); return; }
    if (!_okLower)          { _snackRed('Password harus ada huruf kecil (a-z)!'); return; }
    if (!_okNum)            { _snackRed('Password harus ada angka (0-9)!'); return; }
    if (newPass != confirm) { _snackRed('Konfirmasi password tidak cocok!'); return; }

    setState(() => _isLoading = true);

    final result = await ApiService.forgotPasswordReset(
      email                  : email,
      newPassword            : newPass,
      newPasswordConfirmation: confirm,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'Password berhasil diubah!'),
        backgroundColor: Colors.teal,
      ));
      // Kembali ke halaman login
      Navigator.pop(context);
    } else {
      _snackRed(result['message'] ?? 'Gagal mengubah password, coba lagi.');
    }
  }

  void _snackRed(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Ikon + Judul ─────────────────────────────────
              const SizedBox(height: 16),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: Colors.teal, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lupa Password?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                'Masukkan email akunmu dan buat password baru.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
              const SizedBox(height: 32),

              // ── Field Email ──────────────────────────────────
              const Text('Email Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Masukkan email terdaftar',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Field Password Baru ──────────────────────────
              const Text('Password Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newCtrl,
                obscureText: _obscureNew,
                onChanged: (_) => setState(() {}), // refresh indikator
                decoration: InputDecoration(
                  hintText: 'Buat password baru',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Indikator syarat password
              _syarat('Minimal 8 karakter',      _ok8),
              _syarat('Huruf kapital (A-Z)',      _okUpper),
              _syarat('Huruf kecil (a-z)',        _okLower),
              _syarat('Mengandung angka (0-9)',   _okNum),
              const SizedBox(height: 20),

              // ── Field Konfirmasi Password ────────────────────
              const Text('Konfirmasi Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Ulangi password baru',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  // Border hijau kalau cocok, merah kalau belum cocok
                  enabledBorder: _confirmCtrl.text.isEmpty
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        )
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: _okMatch ? Colors.teal : Colors.red.shade200,
                            width: 1.5,
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              // Pesan "tidak cocok" di bawah field konfirmasi
              if (_confirmCtrl.text.isNotEmpty && !_okMatch)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 4),
                  child: Text(
                    'Password tidak cocok',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 36),

              // ── Tombol Ubah Password ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Ubah Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Link kembali ke login
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text.rich(
                    TextSpan(
                      text: 'Sudah ingat password? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      children: const [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget baris syarat password (centang hijau / abu)
  Widget _syarat(String label, bool terpenuhi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            terpenuhi ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: terpenuhi ? Colors.teal : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: terpenuhi ? Colors.teal : Colors.grey[500],
              fontWeight: terpenuhi ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}