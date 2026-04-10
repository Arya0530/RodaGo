import 'package:flutter/material.dart';

class BantuanPage extends StatelessWidget {
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
        title: Text("Pusat Bantuan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          Text("Pertanyaan Sering Diajukan (FAQ)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          SizedBox(height: 16),
          
          // DAFTAR PERTANYAAN (Pake ExpansionTile biar bisa di-klik buka tutup)
          _buildFAQ("Apa syarat menyewa mobil di RodaGo?", "Anda hanya perlu melakukan verifikasi akun (KYC) dengan mengunggah foto KTP asli dan SIM A yang masih berlaku."),
          _buildFAQ("Apakah bisa bayar di tempat (Cash)?", "Saat ini RodaGo hanya melayani pembayaran secara online (Transfer Bank / E-Wallet) demi keamanan transaksi."),
          _buildFAQ("Apakah saya bisa membatalkan pesanan?", "Bisa. Pembatalan H-1 sebelum penyewaan akan direfund 100%. Pembatalan pada hari H akan dikenakan potongan 50%."),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Card(
  elevation: 0,
  margin: EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[200]!),
      borderRadius: BorderRadius.circular(15),
    ),
    child: ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(answer, style: TextStyle(color: Colors.grey[600], height: 1.5)),
        ),
      ],
    ),
  ),
);
  }
}