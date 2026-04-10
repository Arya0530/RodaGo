import 'package:flutter/material.dart';
import 'tambah_mobil_page.dart';

class KelolaMobilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Kelola Armada", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          // List Mobil yang dipunya si Owner
          _buildCarItem("Toyota Camry Hybrid", "Rp 1.500.000 / hari", "Tersedia", Colors.green),
          _buildCarItem("Mitsubishi Xpander", "Rp 450.000 / hari", "Sedang Disewa", Colors.orange),
          _buildCarItem("Honda Brio", "Rp 300.000 / hari", "Tersedia", Colors.green),
        ],
      ),
  floatingActionButton: FloatingActionButton.extended(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TambahMobilPage()),
    );
  },
  backgroundColor: Colors.teal,
  icon: Icon(Icons.add, color: Colors.white),
  label: Text(
    "Tambah Mobil",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
),
    );
  } // <-- INI PENTING BANGET

  // Desain List Mobil Owner
  Widget _buildCarItem(String name, String price, String status, Color statusColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 60,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.directions_car, color: Colors.grey[400]),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(price, style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 8),
                Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Tombol Edit & Hapus
          IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
          IconButton(icon: Icon(Icons.delete_outline, color: Colors.red), onPressed: () {}),
        ],
      ),
    );
  }
}