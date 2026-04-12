import 'package:flutter/material.dart';

class EditProfilPage extends StatelessWidget {
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
        title: Text("Edit Profil", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            // FOTO PROFIL BISA DIKLIK
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal[100],
                  child: Icon(Icons.person, size: 50, color: Colors.teal),
                ),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                )
              ],
            ),
            SizedBox(height: 32),

            // FORM EDIT DATA
            _buildTextField("Nama Lengkap", "Arya"),
            SizedBox(height: 16),
            _buildTextField("Email", "Arya@email.com"),
            SizedBox(height: 16),
            _buildTextField("Nomor HP", "+62 812-3456-7890"),
            SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Pura-puranya loading nyimpen data
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.teal));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu buat bikin textfield biar kodingan rapi
  Widget _buildTextField(String label, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8),
        TextFormField(
          initialValue: placeholder,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
          ),
        ),
      ],
    );
  }
}