// LOKASI: lib/pages/owner/edit_mobil_page.dart
//
// PERUBAHAN DARI VERSI LAMA:
//   1. Kotak foto bisa diklik untuk ganti gambar (sama seperti TambahMobilPage)
//   2. Jika ada URL gambar lama, ditampilkan sebagai preview awal
//   3. Jika user pilih foto baru → preview berubah ke foto baru
//   4. Data dikirim multipart (bukan JSON) agar bisa sekalian kirim file

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../../service/mobil_service.dart';
import '../auth/login_page.dart';
import '../../service/user_session.dart';

class EditMobilPage extends StatefulWidget {
  final int    mobilId;
  final String namaMobil;
  final String hargaSewa;
  final String tipe;
  final int    kursi;
  final String transmisi;
  final String bahan_bakar;
  final String? deskripsi;   // tambahan: ambil deskripsi yang sudah ada
  final String? gambarUrl;   // tambahan: URL gambar yang sudah ada

  EditMobilPage({
    required this.mobilId,
    required this.namaMobil,
    required this.hargaSewa,
    required this.tipe,
    required this.kursi,
    required this.transmisi,
    required this.bahan_bakar,
    this.deskripsi,
    this.gambarUrl,
  });

  @override
  _EditMobilPageState createState() => _EditMobilPageState();
}

class _EditMobilPageState extends State<EditMobilPage> {
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;

  late String _tipe;
  late String _transmisi;
  late String _kursi;
  late String _bahan_bakar;

  // ── State foto baru (dipilih user) ──────────────────────────────
  Uint8List? _gambarBaruBytes; // bytes foto baru (null = tidak ganti)
  String?    _gambarBaruName;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController     = TextEditingController(text: widget.namaMobil);
    final hargaBersih   = widget.hargaSewa.replaceAll(RegExp(r'[^0-9]'), '');
    _hargaController    = TextEditingController(text: hargaBersih);
    _deskripsiController = TextEditingController(text: widget.deskripsi ?? '');

    _tipe        = widget.tipe;
    _transmisi   = widget.transmisi;
    _kursi       = widget.kursi.toString();
    _bahan_bakar = widget.bahan_bakar;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // ── Pilih foto baru ──────────────────────────────────────────────
  Future<void> _pilihFoto() async {
    final result = await FilePicker.platform.pickFiles(
      type    : FileType.image,
      withData: true, // WAJIB untuk Flutter Web
    );
    if (result == null) return;
    final file = result.files.first;
    setState(() {
      _gambarBaruBytes = file.bytes;
      _gambarBaruName  = file.name;
    });
  }

  // ── Simpan perubahan ─────────────────────────────────────────────
  Future<void> _simpanPerubahan() async {
    if (_namaController.text.trim().isEmpty || _hargaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan harga harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Selalu pakai multipart agar bisa sekalian kirim file jika ada
      await MobilService.updateMobilDenganGambar(
        mobilId    : widget.mobilId,
        data       : {
          'nama'       : _namaController.text.trim(),
          'harga'      : _hargaController.text.trim(),
          'tipe'       : _tipe,
          'kursi'      : _kursi,
          'transmisi'  : _transmisi,
          'bahan_bakar': _bahan_bakar,
          'deskripsi'  : _deskripsiController.text.trim(),
        },
        gambarBytes: _gambarBaruBytes, // null = tidak ganti gambar
        gambarName : _gambarBaruName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobil berhasil diperbarui!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context, true); // true = ada perubahan
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString();

      if (errorMessage.contains('Unauthorized') || errorMessage.contains('401')) {
        UserSession.hapus();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      } else if (errorMessage.contains('Anda tidak memiliki akses') ||
          errorMessage.contains('403')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda tidak memiliki akses untuk mengubah mobil ini'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          'Edit Mobil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Kotak Foto ─────────────────────────────────────────
            _buildKotakFoto(),
            const SizedBox(height: 32),

            _buildInputField('Nama Mobil', _namaController, isNumber: false),
            const SizedBox(height: 16),
            _buildInputField('Harga Sewa per Hari (Rp)', _hargaController, isNumber: true),

            const Divider(height: 48, thickness: 2, color: Color(0xFFF5F5F5)),
            const Text(
              'Spesifikasi Mobil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            _buildDropdownField(
              'Kategori', ['Economy', 'MPV', 'Luxury', 'SUV'],
              _tipe, (val) => setState(() => _tipe = val!),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: _buildDropdownField(
                  'Transmisi', ['Otomatis', 'Manual'],
                  _transmisi, (val) => setState(() => _transmisi = val!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  'Kapasitas', ['4', '5', '6', '7', '8'],
                  _kursi, (val) => setState(() => _kursi = val!),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            _buildDropdownField(
              'Bahan Bakar', ['Bensin', 'Diesel', 'Hybrid'],
              _bahan_bakar, (val) => setState(() => _bahan_bakar = val!),
            ),
            const SizedBox(height: 24),

            const Text(
              'Deskripsi Mobil',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan deskripsi atau catatan...',
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

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Widget kotak foto ────────────────────────────────────────────
  // Prioritas tampilan:
  //   1. Foto baru dipilih user (_gambarBaruBytes) → Image.memory
  //   2. Ada URL gambar lama (widget.gambarUrl)    → Image.network
  //   3. Tidak ada foto sama sekali               → placeholder ikon
  Widget _buildKotakFoto() {
    final adaFotoBaru  = _gambarBaruBytes != null;
    final adaFotoLama  = widget.gambarUrl != null && widget.gambarUrl!.isNotEmpty;
    final adaFoto      = adaFotoBaru || adaFotoLama;

    return GestureDetector(
      onTap: _pilihFoto,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: adaFoto ? Colors.black : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: adaFoto ? Colors.teal : Colors.grey[300]!,
            width: adaFoto ? 2 : 1,
          ),
        ),
        child: adaFoto
            ? Stack(
                children: [
                  // ── Tampilkan foto ───────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: adaFotoBaru
                        // Foto baru (bytes dari file picker)
                        ? Image.memory(
                            _gambarBaruBytes!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          )
                        // Foto lama (dari URL server)
                        : Image.network(
                            ApiService.perbaikiUrlGambar(widget.gambarUrl),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  // ── Overlay gelap + teks ─────────────────────────
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: Colors.black.withOpacity(0.35),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit, color: Colors.white, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          adaFotoBaru
                              ? 'Foto baru dipilih — ketuk untuk ganti'
                              : 'Ketuk untuk ganti foto',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            // ── Placeholder jika tidak ada foto ─────────────────────
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 44, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Ketuk untuk upload foto mobil',
                    style: TextStyle(
                        color: Colors.grey[500], fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Format JPG / PNG / WebP, maks 5MB',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isNumber = false}) {
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
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String selectedValue, ValueChanged<String?> onChanged) {
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
            borderRadius: BorderRadius.circular(15),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.teal),
              items: items
                  .map((v) => DropdownMenuItem<String>(
                        value: v,
                        child: Text(v,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 14)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}