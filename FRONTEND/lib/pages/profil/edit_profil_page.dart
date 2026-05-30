// LOKASI: lib/pages/profil/edit_profil_page.dart
// PERUBAHAN dari versi lama:
//   - Tidak lagi dummy — data diambil dari UserSession, disimpan ke API
//   - Ada bagian opsional ganti password (tampil/sembunyi lewat toggle)
//   - Setelah simpan berhasil, UserSession di-update otomatis

import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../../service/user_session.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  // Controller diisi dari UserSession saat init
  late final TextEditingController _namaCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final TextEditingController _oldPassCtrl  = TextEditingController();
  final TextEditingController _newPassCtrl  = TextEditingController();
  final TextEditingController _konfPassCtrl = TextEditingController();

  bool _gantiPassword  = false; // toggle section ganti password
  bool _loading        = false;
  bool _showOldPass    = false;
  bool _showNewPass    = false;
  bool _showKonfPass   = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl  = TextEditingController(text: UserSession.nama);
    _emailCtrl = TextEditingController(text: UserSession.email);
    _phoneCtrl = TextEditingController(text: UserSession.phone);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _konfPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final nama  = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    // Validasi dasar di sisi client
    if (nama.isEmpty || email.isEmpty || phone.isEmpty) {
      _showSnack('Nama, email, dan nomor HP tidak boleh kosong.', isError: true);
      return;
    }

    if (_gantiPassword) {
      if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty || _konfPassCtrl.text.isEmpty) {
        _showSnack('Isi semua field password.', isError: true);
        return;
      }
      if (_newPassCtrl.text != _konfPassCtrl.text) {
        _showSnack('Konfirmasi password baru tidak cocok.', isError: true);
        return;
      }
    }

    setState(() => _loading = true);

    final result = await ApiService.updateProfile(
      name : nama,
      email: email,
      phone: phone,
      currentPassword          : _gantiPassword ? _oldPassCtrl.text : null,
      newPassword              : _gantiPassword ? _newPassCtrl.text : null,
      newPasswordConfirmation  : _gantiPassword ? _konfPassCtrl.text : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      // Update sesi lokal dengan data terbaru dari server
      final userData = result['data'] as Map<String, dynamic>;
      UserSession.nama  = userData['name']  ?? UserSession.nama;
      UserSession.email = userData['email'] ?? UserSession.email;
      UserSession.phone = userData['phone'] ?? UserSession.phone;

      _showSnack('Profil berhasil diperbarui!');
      Navigator.pop(context);
    } else {
      _showSnack(result['message'] ?? 'Gagal menyimpan profil.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

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
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO PROFIL (placeholder, belum upload)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal[100],
                    child: const Icon(Icons.person, size: 50, color: Colors.teal),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── DATA UTAMA ──────────────────────────────────────
            _buildTextField('Nama Lengkap', _namaCtrl, hint: 'Masukkan nama lengkap'),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailCtrl, hint: 'Masukkan email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField('Nomor HP', _phoneCtrl, hint: 'Contoh: 08123456789', keyboardType: TextInputType.phone),

            const SizedBox(height: 28),

            // ── TOGGLE GANTI PASSWORD ───────────────────────────
            InkWell(
              onTap: () => setState(() {
                _gantiPassword = !_gantiPassword;
                if (!_gantiPassword) {
                  _oldPassCtrl.clear();
                  _newPassCtrl.clear();
                  _konfPassCtrl.clear();
                }
              }),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.teal),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ganti Password',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                    Icon(
                      _gantiPassword ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            // ── FORM GANTI PASSWORD (hanya muncul jika toggle aktif) ──
            if (_gantiPassword) ...[
              const SizedBox(height: 16),
              _buildPasswordField('Password Lama', _oldPassCtrl, _showOldPass, () => setState(() => _showOldPass = !_showOldPass)),
              const SizedBox(height: 16),
              _buildPasswordField('Password Baru', _newPassCtrl, _showNewPass, () => setState(() => _showNewPass = !_showNewPass)),
              const SizedBox(height: 16),
              _buildPasswordField('Konfirmasi Password Baru', _konfPassCtrl, _showKonfPass, () => setState(() => _showKonfPass = !_showKonfPass)),
            ],

            const SizedBox(height: 40),

            // ── TOMBOL SIMPAN ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  disabledBackgroundColor: Colors.teal.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widget helper ─────────────────────────────────────────────

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.teal, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool visible,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.teal, width: 1.5)),
            suffixIcon: IconButton(
              icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}