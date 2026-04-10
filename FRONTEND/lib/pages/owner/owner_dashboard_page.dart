import 'package:flutter/material.dart';

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
              Expanded(child: _buildStatCard("Total Pendapatan", "Rp 4.5M", Icons.account_balance_wallet, Colors.green)),
              SizedBox(width: 16),
              Expanded(child: _buildStatCard("Mobil Aktif", "8", Icons.car_rental, Colors.orange)),
            ],
          ),
          SizedBox(height: 32),

          // Daftar Pesanan Masuk yang butuh Persetujuan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pesanan Masuk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text("Lihat Semua", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          SizedBox(height: 16),
          _buildRequestCard("Toyota Camry Hybrid", "Alex ", "15 Apr - 18 Apr"),
          _buildRequestCard("Mitsubishi Xpander", "Budi Santoso", "16 Apr - 17 Apr"),
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
  Widget _buildRequestCard(String mobil, String penyewa, String tanggal) {
    return Container(
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
                child: Text("Baru", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text("Penyewa: $penyewa", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text("Tanggal: $tanggal", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Divider(height: 24, color: Colors.grey[100]),
          
          // Tombol Terima & Tolak
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[300]!), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: Text("Tolak", style: TextStyle(color: Colors.red)),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text("Terima", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}