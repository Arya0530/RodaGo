import 'package:flutter/material.dart';

class InstruksiPembayaranPage extends StatelessWidget {
  final String metode;
  final String total;

  InstruksiPembayaranPage({required this.metode, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: BackButton(color: Colors.black)),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Instruksi Pembayaran", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text(metode, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  SizedBox(height: 16),
                  Text("8806 0812 3456 7890", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.5)),
                  SizedBox(height: 8),
                  Text("Salin Kode Bayar", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            SizedBox(height: 32),
            Text("Cara Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 16),
            _stepInstruksi("1", "Buka aplikasi mobile banking atau e-wallet Anda."),
            _stepInstruksi("2", "Pilih menu Transfer / Virtual Account."),
            _stepInstruksi("3", "Masukkan nomor Virtual Account di atas."),
            _stepInstruksi("4", "Pastikan nominal sesuai yaitu $total."),
            _stepInstruksi("5", "Selesaikan transaksi dan simpan bukti bayar."),
            Spacer(),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // EFEK LOADING SEBELUM SELESAI
                  showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(color: Colors.teal)));
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pop(context); // Tutup loading
                    Navigator.pop(context, true); // Balik ke proses_pembayaran dengan status TRUE
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text("Konfirmasi Sudah Bayar", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          CircleAvatar(radius: 10, backgroundColor: Colors.teal, child: Text(nomor, style: TextStyle(fontSize: 10, color: Colors.white))),
          SizedBox(width: 12),
          Expanded(child: Text(teks, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
        ],
      ),
    );
  }
}