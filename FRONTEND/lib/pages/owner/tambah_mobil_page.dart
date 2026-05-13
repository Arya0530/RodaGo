// LOKASI: lib/pages/owner/tambah_mobil_page.dart
//
// PERUBAHAN DARI VERSI LAMA:
//   1. Kotak foto sekarang bisa diklik dan membuka file picker
//   2. Foto yang dipilih ditampilkan sebagai preview
//   3. Data dikirim ke API sebagai multipart (bukan JSON)
//      karena JSON tidak bisa membawa file binary
//   4. Pakai file_picker (bukan image_picker) karena support Flutter Web/Chrome

import 'dart:typed_data';                   // Uint8List — tipe bytes di Flutter Web
import 'package:file_picker/file_picker.dart'; // Package pemilih file
import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../auth/login_page.dart';
import '../../service/user_session.dart';

class TambahMobilPage extends StatefulWidget {
  @override
  _TambahMobilPageState createState() => _TambahMobilPageState();
}

class _TambahMobilPageState extends State<TambahMobilPage> {
  // ── Text Controllers ─────────────────────────────────────────────
  final _namaController      = TextEditingController();
  final _hargaController     = TextEditingController();
  final _deskripsiController = TextEditingController();

  // ── Dropdown values ──────────────────────────────────────────────
  String _tipe        = 'Economy';
  String _transmisi   = 'Otomatis';
  String _kursi       = '4';
  String _bahanBakar  = 'Bensin';

  // ── State foto ───────────────────────────────────────────────────
  // _gambarBytes : bytes foto yang dipilih user (null = belum pilih)
  // _gambarName  : nama file asli (misal: "foto_mobil.jpg")
  Uint8List? _gambarBytes;
  String?    _gambarName;

  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // ── Pilih foto dari file system ──────────────────────────────────
  // file_picker bekerja di Web (Chrome), Android, iOS, Desktop
  // withData: true → langsung baca bytes (penting untuk Flutter Web)
  Future<void> _pilihFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,   // hanya tampilkan file gambar
      withData: true,          // ← WAJIB untuk Flutter Web supaya bytes tersedia
    );

    // Kalau user batal (tekan Cancel di dialog), result = null
    if (result == null) return;

    final file = result.files.first;

    // file.bytes = Uint8List bytes (tersedia karena withData: true)
    // file.name  = nama file asli termasuk ekstensi
    setState(() {
      _gambarBytes = file.bytes;
      _gambarName  = file.name;
    });
  }

  // ── Simpan mobil ke server ────────────────────────────────────────
  Future<void> _simpanMobil() async {
    if (_namaController.text.trim().isEmpty) {
      _showSnackBar('Nama mobil wajib diisi!', Colors.red);
      return;
    }
    if (_hargaController.text.trim().isEmpty) {
      _showSnackBar('Harga sewa wajib diisi!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // Kirim sebagai multipart request (bukan JSON)
    // karena ada kemungkinan file ikut dikirim
    final result = await ApiService.tambahMobilDenganGambar(
      data: {
        'nama'       : _namaController.text.trim(),
        'harga'      : _hargaController.text.trim(),
        'tipe'       : _tipe,
        'kursi'      : _kursi,
        'transmisi'  : _transmisi,
        'bahan_bakar': _bahanBakar,
        'deskripsi'  : _deskripsiController.text.trim(),
      },
      gambarBytes: _gambarBytes,   // null kalau tidak pilih foto
      gambarName : _gambarName,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackBar('Mobil berhasil ditambahkan!', Colors.teal);
      Navigator.pop(context, true); // true = ada perubahan, supaya list bisa refresh
    } else {
      final msg = result['message']?.toString() ?? '';
      if (msg.contains('Unauthorized') || msg.contains('401')) {
        UserSession.hapus();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      } else {
        _showSnackBar('Gagal: $msg', Colors.red);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

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
          'Tambah Mobil Baru',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kotak Upload Foto ──────────────────────────────────
            _buildKotakFoto(),
            const SizedBox(height: 32),

            // ── Field Nama ─────────────────────────────────────────
            _buildInputField('Nama Mobil', 'Contoh: Honda Civic RS', _namaController),
            const SizedBox(height: 16),

            // ── Field Harga ────────────────────────────────────────
            _buildInputField('Harga Sewa per Hari (Rp)', 'Contoh: 500000',
                _hargaController, isNumber: true),

            const Divider(height: 48, thickness: 2, color: Color(0xFFF5F5F5)),
            const Text(
              'Spesifikasi Mobil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // ── Dropdown Kategori ──────────────────────────────────
            _buildDropdown('Kategori', ['Economy', 'MPV', 'Luxury', 'SUV'],
                _tipe, (v) => setState(() => _tipe = v!)),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: _buildDropdown('Transmisi', ['Otomatis', 'Manual'],
                    _transmisi, (v) => setState(() => _transmisi = v!)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown('Kursi', ['4', '5', '6', '7', '8'],
                    _kursi, (v) => setState(() => _kursi = v!)),
              ),
            ]),
            const SizedBox(height: 16),

            _buildDropdown('Bahan Bakar', ['Bensin', 'Diesel', 'Hybrid'],
                _bahanBakar, (v) => setState(() => _bahanBakar = v!)),
            const SizedBox(height: 24),

            // ── Deskripsi ──────────────────────────────────────────
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Kondisi, syarat khusus, atau info lainnya...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Tombol Simpan ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanMobil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Mobil',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Widget kotak foto ────────────────────────────────────────────
  // Menampilkan preview foto jika sudah dipilih,
  // atau placeholder ikon kamera jika belum.
  Widget _buildKotakFoto() {
    return GestureDetector(
      onTap: _pilihFoto, // ← tap → buka file picker
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: _gambarBytes != null ? Colors.black : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // Warna border berubah jika sudah ada foto
            color: _gambarBytes != null ? Colors.teal : Colors.grey[300]!,
            width: _gambarBytes != null ? 2 : 1,
          ),
        ),
        child: _gambarBytes != null
            // ── Ada foto → tampilkan preview ───────────────────────
            ? Stack(
                children: [
                  // Tampilkan gambar dari bytes (bukan dari URL/file path)
                  // Image.memory cocok untuk Flutter Web karena pakai bytes
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.memory(
                      _gambarBytes!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Overlay gelap + teks "Ketuk untuk ganti"
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: Colors.black.withOpacity(0.35),
                      ),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 28),
                        SizedBox(height: 6),
                        Text(
                          'Ketuk untuk ganti foto',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            // ── Belum ada foto → tampilkan placeholder ──────────────
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 44, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Ketuk untuk upload foto mobil',
                    style: TextStyle(
                        color: Colors.grey[500], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Format JPG / PNG / WebP, maks 5MB',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint,
      TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
              items: items
                  .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}