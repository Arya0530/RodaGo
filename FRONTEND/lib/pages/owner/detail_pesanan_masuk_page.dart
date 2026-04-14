import 'package:flutter/material.dart';

class DetailPesananMasukPage extends StatelessWidget {
  final String namaPenyewa;
  final String namaMobil;
  final String tanggal;

  // Constructor buat nangkep data dari dashboard
  DetailPesananMasukPage({
    required this.namaPenyewa, 
    required this.namaMobil, 
    required this.tanggal
  });

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
        title: Text("Detail Penyewa", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO PESANAN
            Text("Informasi Pesanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16),
            _buildInfoRow("Mobil", namaMobil),
            _buildInfoRow("Penyewa", namaPenyewa),
            _buildInfoRow("Jadwal Sewa", tanggal),
            _buildInfoRow("Total Harga", "Rp 1.500.000", isBold: true),
            
            Divider(height: 48, color: Colors.grey[200], thickness: 2),

            // DOKUMEN KYC (KTP & SIM) 👇 Ini yang lu maksud bro!
            Text("Dokumen Verifikasi (KYC)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Text("Harap periksa keaslian dokumen sebelum menyetujui pesanan.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 16),

            Text("1. E-KTP", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildDokumenDummy("KTP"), // Pura-puranya gambar KTP

            SizedBox(height: 24),

            Text("2. SIM A", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildDokumenDummy("SIM A"), // Pura-puranya gambar SIM

            SizedBox(height: 100), // Spasi bawah
          ],
        ),
      ),

      // TOMBOL TERIMA / TOLAK DI BAWAH LAYAR
      bottomSheet: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pesanan ditolak."), backgroundColor: Colors.red));
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red[300]!), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 16)
                ),
                child: Text("Tolak", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pesanan berhasil diterima!"), backgroundColor: Colors.teal));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text("Terima", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu buat bikin baris info text
  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isBold ? Colors.teal : Colors.black87)),
        ],
      ),
    );
  }

  // Fungsi pembantu buat bikin kotak abu-abu pura-puranya foto KTP/SIM
  Widget _buildDokumenDummy(String jenis) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text("Preview Gambar $jenis", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}