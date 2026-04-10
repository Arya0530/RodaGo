import 'package:flutter/material.dart';

class KycPage extends StatefulWidget {
  @override
  _KycPageState createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  // Variabel dummy buat pura-pura fotonya udah ke-upload
  bool _isKtpUploaded = false;
  bool _isSimUploaded = false;

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
        title: Text("Verifikasi KYC", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.teal, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Data Anda aman dan dienkripsi. Kami membutuhkan identitas asli untuk keamanan penyewaan lepas kunci.",
                      style: TextStyle(color: Colors.teal[800], fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Bagian Upload KTP
            Text("1. Foto E-KTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Text("Pastikan foto KTP terlihat jelas, tidak buram, dan tidak terpotong.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 16),
            _buildUploadBox(
              title: "Upload KTP",
              isUploaded: _isKtpUploaded,
              onTap: () {
                setState(() {
                  _isKtpUploaded = !_isKtpUploaded; // Pura-puranya nge-upload
                });
              },
            ),

            SizedBox(height: 32),

            // Bagian Upload SIM
            Text("2. Foto SIM A", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Text("Wajib melampirkan SIM A yang masih berlaku untuk layanan lepas kunci.", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            SizedBox(height: 16),
            _buildUploadBox(
              title: "Upload SIM A",
              isUploaded: _isSimUploaded,
              onTap: () {
                setState(() {
                  _isSimUploaded = !_isSimUploaded; // Pura-puranya nge-upload
                });
              },
            ),

            SizedBox(height: 48),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isKtpUploaded && _isSimUploaded) 
                  ? () {
                      // Nanti logika kirim gambar ke AWS S3 + API Laravel taruh di sini
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Dokumen berhasil dikirim untuk verifikasi!"), backgroundColor: Colors.teal)
                      );
                      Navigator.pop(context);
                    }
                  : null, // Tombol mati kalau belum upload dua-duanya
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  "Kirim Dokumen", 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: (_isKtpUploaded && _isSimUploaded) ? Colors.white : Colors.grey[500])
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembantu buat bikin kotak upload foto (border putus-putus)
  Widget _buildUploadBox({required String title, required bool isUploaded, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: isUploaded ? Colors.teal[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? Colors.teal : Colors.grey[300]!,
            width: isUploaded ? 2 : 1,
            // Idealnya pake package dotted_border, tapi biar cepet kita pake solid border aja dulu
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.camera_alt_outlined, 
            color: isUploaded ? Colors.teal : Colors.grey[400], 
            size: 40
          ),
          SizedBox(height: 12),
          Text(
            isUploaded ? "File berhasil diunggah" : title,
            style: TextStyle(
              color: isUploaded ? Colors.teal : Colors.grey[600],
              fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isUploaded) ...[
            SizedBox(height: 4), // ✅ JARAK DI SINI
            Text(
              "Ketuk untuk mengganti file",
              style: TextStyle(
                color: Colors.teal[300],
                fontSize: 12,
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}