// LOKASI: lib/pages/profil/kyc_page.dart
//
// PERUBAHAN DARI VERSI LAMA (dummy):
//   - Saat halaman dibuka, langsung cek status KYC dari API
//   - Kotak upload KTP & SIM pakai file_picker, bukan dummy
//   - Tombol "Kirim Dokumen" melakukan POST multipart ke /api/kyc/upload
//   - Tampilan berubah sesuai status: unverified / pending / verified / rejected

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../service/api_service.dart';

class KycPage extends StatefulWidget {
  @override
  _KycPageState createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  // ── Status dari server ───────────────────────────────────────
  String _kycStatus    = 'loading'; // loading | unverified | pending | verified | rejected
  String _rejectionNote = '';

  // ── File yang dipilih user ───────────────────────────────────
  Uint8List? _ktpBytes;
  String?    _ktpName;
  Uint8List? _simBytes;
  String?    _simName;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  // ── Muat status KYC dari server ──────────────────────────────
  Future<void> _loadStatus() async {
    final result = await ApiService.getKycStatus();
    if (!mounted) return;
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      setState(() {
        _kycStatus     = data['status'] ?? 'unverified';
        _rejectionNote = data['rejection_note'] ?? '';
      });
    } else {
      setState(() => _kycStatus = 'unverified');
    }
  }

  // ── Pilih file KTP ───────────────────────────────────────────
  Future<void> _pilihKtp() async {
    final result = await FilePicker.platform.pickFiles(
      type    : FileType.image,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      _ktpBytes = result.files.first.bytes;
      _ktpName  = result.files.first.name;
    });
  }

  // ── Pilih file SIM ───────────────────────────────────────────
  Future<void> _pilihSim() async {
    final result = await FilePicker.platform.pickFiles(
      type    : FileType.image,
      withData: true,
    );
    if (result == null) return;
    setState(() {
      _simBytes = result.files.first.bytes;
      _simName  = result.files.first.name;
    });
  }

  // ── Kirim dokumen ke API ─────────────────────────────────────
  Future<void> _kirimDokumen() async {
    if (_ktpBytes == null || _simBytes == null) return;

    setState(() => _isSending = true);

    final result = await ApiService.uploadKyc(
      ktpBytes: _ktpBytes!,
      ktpName : _ktpName!,
      simBytes: _simBytes!,
      simName : _simName!,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (result['success'] == true) {
      setState(() {
        _kycStatus = 'pending';
        _ktpBytes  = null;
        _simBytes  = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Dokumen berhasil dikirim!'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengirim dokumen'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verifikasi KYC',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _kycStatus == 'loading'
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    // ── Sudah verified ───────────────────────────────────────────
    if (_kycStatus == 'verified') {
      return _buildStatusView(
        icon : Icons.verified_user,
        color: Colors.teal,
        judul: 'Akun Terverifikasi',
        pesan: 'KTP dan SIM Anda telah diverifikasi. Anda sudah bisa menyewa mobil.',
      );
    }

    // ── Menunggu review admin ────────────────────────────────────
    if (_kycStatus == 'pending') {
      return _buildStatusView(
        icon : Icons.hourglass_top_rounded,
        color: Colors.orange,
        judul: 'Sedang Ditinjau',
        pesan: 'Dokumen Anda sedang diperiksa oleh tim kami.\nBiasanya selesai dalam 1×24 jam.',
      );
    }

    // ── Ditolak — tampilkan form upload ulang + catatan penolakan ─
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner info / catatan penolakan
          if (_kycStatus == 'rejected') ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(children: [
                Icon(Icons.cancel_outlined, color: Colors.red, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'Dokumen Ditolak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                        fontSize: 15,
                      ),
                    ),
                    if (_rejectionNote.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        'Alasan: $_rejectionNote',
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      'Silakan upload ulang dokumen yang sesuai.',
                      style: TextStyle(color: Colors.red[700], fontSize: 13),
                    ),
                  ]),
                ),
              ]),
            ),
            SizedBox(height: 24),
          ] else ...[
            // Banner info biasa (unverified)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Icon(Icons.security, color: Colors.teal, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Data Anda aman dan dienkripsi. Kami membutuhkan identitas asli untuk keamanan penyewaan lepas kunci.',
                    style: TextStyle(color: Colors.teal[800], fontSize: 13, height: 1.5),
                  ),
                ),
              ]),
            ),
            SizedBox(height: 32),
          ],

          // ── Upload KTP ─────────────────────────────────────────
          Text(
            '1. Foto E-KTP',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Pastikan foto KTP terlihat jelas, tidak buram, dan tidak terpotong.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          SizedBox(height: 16),
          _buildUploadBox(
            title    : 'Upload KTP',
            isUploaded: _ktpBytes != null,
            bytes    : _ktpBytes,
            onTap    : _pilihKtp,
          ),

          SizedBox(height: 32),

          // ── Upload SIM ─────────────────────────────────────────
          Text(
            '2. Foto SIM A',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'Wajib melampirkan SIM A yang masih berlaku untuk layanan lepas kunci.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          SizedBox(height: 16),
          _buildUploadBox(
            title    : 'Upload SIM A',
            isUploaded: _simBytes != null,
            bytes    : _simBytes,
            onTap    : _pilihSim,
          ),

          SizedBox(height: 48),

          // ── Tombol Kirim ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: (_ktpBytes != null && _simBytes != null && !_isSending)
                  ? _kirimDokumen
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isSending
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Kirim Dokumen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: (_ktpBytes != null && _simBytes != null)
                            ? Colors.white
                            : Colors.grey[500],
                      ),
                    ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Halaman status (verified / pending) ─────────────────────────
  Widget _buildStatusView({
    required IconData icon,
    required Color    color,
    required String   judul,
    required String   pesan,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: color),
            ),
            SizedBox(height: 24),
            Text(
              judul,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              pesan,
              style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Kotak upload foto ────────────────────────────────────────────
  Widget _buildUploadBox({
    required String    title,
    required bool      isUploaded,
    required Uint8List? bytes,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: isUploaded ? Colors.black : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? Colors.teal : Colors.grey[300]!,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: isUploaded && bytes != null
            ? Stack(
                children: [
                  // Preview foto yang dipilih
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      bytes,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Overlay gelap + teks ganti
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(0.4),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 32),
                        SizedBox(height: 6),
                        Text(
                          'File dipilih — ketuk untuk ganti',
                          style: TextStyle(
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.grey[400], size: 40),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Format JPG / PNG, maks 2MB',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}