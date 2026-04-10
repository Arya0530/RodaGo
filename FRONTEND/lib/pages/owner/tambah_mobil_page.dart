import 'package:flutter/material.dart';

class TambahMobilPage extends StatelessWidget {
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
        title: Text("Tambah Mobil Baru", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KOTAK UPLOAD FOTO MOBIL
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text("Upload Foto Mobil", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Format JPG/PNG, maks 2MB", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            SizedBox(height: 32),

            // FORM INPUT DATA MOBIL
            _buildInputField("Nama Mobil", "Contoh: Honda Civic RS"),
            SizedBox(height: 16),
            _buildInputField("Kategori", "Contoh: Economy / MPV / Luxury"),
            SizedBox(height: 16),
            _buildInputField("Harga Sewa per Hari (Rp)", "Contoh: 500000"),
            SizedBox(height: 16),
            _buildInputField("Nomor Polisi", "Contoh: N 1234 ABC"),
            SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Pura-puranya sukses nyimpen data
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Mobil berhasil ditambahkan ke armada!"), backgroundColor: Colors.teal)
                  );
                  Navigator.pop(context); // Balik otomatis ke daftar armada
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Simpan Mobil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu biar kodingan TextField rapi
  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}