import 'package:flutter/material.dart';
import '../../service/api_service.dart'; // Sesuaikan path project kamu

class DetailPesananMasukPage extends StatefulWidget {
  final int    bookingId;
  final String namaPenyewa;
  final String namaMobil;
  final String tanggal;
  final String totalHarga;
  final String emailPenyewa;
  final String phonePenyewa;

  const DetailPesananMasukPage({
    Key? key,
    required this.bookingId,
    required this.namaPenyewa,
    required this.namaMobil,
    required this.tanggal,
    required this.totalHarga,
    required this.emailPenyewa,
    required this.phonePenyewa,
  }) : super(key: key);

  @override
  _DetailPesananMasukPageState createState() => _DetailPesananMasukPageState();
}

class _DetailPesananMasukPageState extends State<DetailPesananMasukPage> {
  bool _isLoading = false;

  // ── Owner TERIMA ────────────────────────────────────────────────────────────
  Future<void> _handleTerima() async {
    final ok = await _konfirmasi(
      judul: 'Terima Pesanan',
      isi: 'Terima pesanan dari ${widget.namaPenyewa}?\n\nUser punya 24 jam untuk membayar.',
      tombol: 'Terima',
      warna: Colors.teal,
    );
    if (ok != true) return;

    setState(() => _isLoading = true);
    final result = await ApiService.terimaBooking(widget.bookingId);
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackbar('Pesanan diterima! User punya 24 jam untuk bayar.', Colors.teal);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, true); // true = ada perubahan → dashboard refresh
    } else {
      _showSnackbar(result['message'] ?? 'Gagal menerima pesanan', Colors.red);
    }
  }

  // ── Owner TOLAK ─────────────────────────────────────────────────────────────
  Future<void> _handleTolak() async {
    final ok = await _konfirmasi(
      judul: 'Tolak Pesanan',
      isi: 'Yakin ingin menolak pesanan dari ${widget.namaPenyewa}?\n\nPesanan akan langsung dibatalkan.',
      tombol: 'Tolak',
      warna: Colors.red,
    );
    if (ok != true) return;

    setState(() => _isLoading = true);
    final result = await ApiService.tolakBooking(widget.bookingId);
    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackbar('Pesanan ditolak.', Colors.grey[700]!);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      _showSnackbar(result['message'] ?? 'Gagal menolak pesanan', Colors.red);
    }
  }

  Future<bool?> _konfirmasi({
    required String judul,
    required String isi,
    required String tombol,
    required Color warna,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: warna),
              child: Text(tombol, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
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
        title: const Text('Detail Penyewa',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge ID pesanan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                'Booking #RDG-${widget.bookingId.toString().padLeft(4, '0')}',
                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Info pesanan
            const Text('Informasi Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildInfoRow('Mobil', widget.namaMobil, isBold: true),
            _buildInfoRow('Penyewa', widget.namaPenyewa, isBold: true),
            _buildInfoRow('Email', widget.emailPenyewa, isBold: true),
            _buildInfoRow('No. HP', widget.phonePenyewa, isBold: true),
            _buildInfoRow('Jadwal Sewa', widget.tanggal, isBold: true),
            _buildInfoRow('Total Harga', _formatHarga(widget.totalHarga), isBold: true),

            Divider(height: 40, color: Colors.grey[200], thickness: 1.5),

            // Dokumen KYC
            const Text('Dokumen Verifikasi (KYC)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 6),
            Text('Periksa keaslian dokumen sebelum menyetujui pesanan.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 16),

            const Text('1. E-KTP', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDokumenDummy('KTP'),
            const SizedBox(height: 20),

            const Text('2. SIM A', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildDokumenDummy('SIM A'),
          ],
        ),
      ),

      // Tombol Terima / Tolak di bawah
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleTolak,
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Tolak', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleTerima,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0),
                    child: const Text('Terima', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ]),
      ),
    );
  }

 Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kiri
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),

        // Value kanan
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.w600,

                // semua bold tetap hitam,
                // hanya Total yang warna teal
                color: label == 'Total'
                    ? Colors.teal
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDokumenDummy(String jenis) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.image_outlined, size: 44, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('Preview Gambar $jenis', style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }

  String _formatHarga(String angka) {
    try {
      final num = int.parse(angka);
      final str = num.toString();
      String result = '';
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result = '.' + result;
        result = str[i] + result;
        count++;
      }
      return 'Rp $result';
    } catch (_) {
      return 'Rp $angka';
    }
  }
}