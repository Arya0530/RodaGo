import 'package:flutter/material.dart';
import 'detail_pesanan_masuk_page.dart';
import 'kelola_mobil_page.dart';

class OwnerDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Dashboard owner ", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.notifications_outlined, color: Colors.black87), onPressed: () {})
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          Text("Ringkasan Bisnis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 16),
          
          // Kartu Statistik Pendapatan & Pesanan
          Row(
            children: [
              Expanded(child: _buildStatCard("Total Pendapatan", "Rp 5 JT", Icons.account_balance_wallet, Colors.green)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard("Mobil Aktif", "8", Icons.car_rental, Colors.orange)),
            ],
          ),
          SizedBox(height: 16),
          
          // Tombol Akses Cepat ke Kelola Armada
          _buildQuickAccessCard(context),
          SizedBox(height: 32),

          // Daftar Pesanan Masuk yang butuh Persetujuan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pesanan Masuk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          SizedBox(height: 16),
         _buildRequestCard(context, "Toyota Camry Hybrid", "Alex Morgan", "15 Apr - 18 Apr"),
         _buildRequestCard(context, "Mitsubishi Xpander", "Budi Santoso", "16 Apr - 17 Apr"),
        ],
      ),
    );
  }

  // Desain Kartu Statistik
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
        ],
      ),
    );
  }

  // Desain Kartu Permintaan Sewa Baru
// Desain Kartu Permintaan Sewa Baru (SEKARANG BISA DIKLIK!)
  Widget _buildRequestCard(BuildContext context, String mobil, String penyewa, String tanggal) {
    return GestureDetector(
      onTap: () {
        // Pas diklik, pindah ke halaman Detail buat ngecek KTP & SIM!
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => DetailPesananMasukPage(namaPenyewa: penyewa, namaMobil: mobil, tanggal: tanggal)
          )
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(mobil, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                  child: Text("Cek Dokumen", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text("Penyewa: $penyewa", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            Text("Tanggal: $tanggal", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 8),
            // Tombol Terima/Tolak di sini UDAH DIHAPUS, dipindah ke halaman detail!
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Ketuk untuk detail", style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.teal),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget Akses Cepat ke Kelola Armada
  Widget _buildQuickAccessCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KelolaMobilPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.directions_car, color: Colors.teal, size: 28),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kelola Armada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    Text("Tambah, edit, atau hapus mobil", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
          ],
        ),
      ),
    );
  }
} 