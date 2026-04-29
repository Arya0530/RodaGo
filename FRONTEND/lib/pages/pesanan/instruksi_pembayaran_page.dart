import 'package:flutter/material.dart';
import '../../service/api_service.dart';

class InstruksiPembayaranPage extends StatefulWidget {
  final String metode;
  final String total;
  final int bookingId; // ✅ TAMBAHAN

  InstruksiPembayaranPage({
    required this.metode,
    required this.total,
    required this.bookingId, // ✅ TAMBAHAN
  });

  @override
  _InstruksiPembayaranPageState createState() => _InstruksiPembayaranPageState();
}

class _InstruksiPembayaranPageState extends State<InstruksiPembayaranPage> {
  bool _isLoading = false;

  Future<void> _konfirmasiBayar() async {
    setState(() => _isLoading = true);

    // ✅ Panggil API sungguhan
    final result = await ApiService.payBooking(widget.bookingId);

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (result['success'] == true) {
      // ✅ Tampilkan dialog tiket dengan kode unik dari server
      _tampilkanTiket(
        kodeTiket: result['kode_tiket'],
        namaMobil: result['nama_mobil'],
        tanggal: '${result['tanggal_mulai']} - ${result['tanggal_selesai']}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memproses pembayaran'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _tampilkanTiket({
    required String kodeTiket,
    required String namaMobil,
    required String tanggal,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header sukses
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.teal[50], shape: BoxShape.circle),
              child: Icon(Icons.check_circle, color: Colors.teal, size: 56),
            ),
            SizedBox(height: 16),
            Text('Pembayaran Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 4),
            Text('Tunjukkan kode tiket ini ke pihak rental',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            SizedBox(height: 20),

            // Kode tiket unik
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Text('KODE TIKET', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2)),
                SizedBox(height: 8),
                Text(
                  '#$kodeTiket',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3),
                ),
                SizedBox(height: 12),
                Divider(color: Colors.white24),
                SizedBox(height: 8),
                Text(namaMobil,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(tanggal, style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            SizedBox(height: 20),

            // Tombol selesai
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);      // tutup dialog tiket
                  Navigator.pop(context, true);  // balik ke pesanan_page dengan true
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Lihat Pesanan Saya',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: Colors.black)),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Instruksi Pembayaran",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                Text(widget.metode,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                SizedBox(height: 16),
                Text("8806 0812 3456 7890",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        letterSpacing: 1.5)),
                SizedBox(height: 8),
                Text("Salin Kode Bayar",
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
            ),
            SizedBox(height: 32),
            Text("Cara Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _stepInstruksi("1", "Buka aplikasi mobile banking atau e-wallet Anda."),
            _stepInstruksi("2", "Pilih menu Transfer / Virtual Account."),
            _stepInstruksi("3", "Masukkan nomor Virtual Account di atas."),
            _stepInstruksi("4", "Pastikan nominal sesuai yaitu ${widget.total}."),
            _stepInstruksi("5", "Selesaikan transaksi dan simpan bukti bayar."),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // ✅ Panggil _konfirmasiBayar, bukan simulasi
                onPressed: _isLoading ? null : _konfirmasiBayar,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: _isLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text("Konfirmasi Sudah Bayar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepInstruksi(String nomor, String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
              radius: 10,
              backgroundColor: Colors.teal,
              child: Text(nomor,
                  style: TextStyle(fontSize: 10, color: Colors.white))),
          SizedBox(width: 12),
          Expanded(child: Text(teks, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }
}