import 'package:flutter/material.dart';
import 'edit_profil_page.dart';
import 'bantuan_page.dart';
import 'keamanan_page.dart';
import 'pembayaran_page.dart';
import '../auth/login_page.dart';
import 'kyc_page.dart';
import '../owner/owner_main_layout.dart'; // <--- KITA PANGGIL LAYOUT YANG ADA MENU BAWAHNYA!

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Profil Saya", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: [
            // HEADER PROFIL
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal[100],
                    child: Icon(Icons.person, size: 50, color: Colors.teal),
                  ),
                  SizedBox(height: 16),
                  Text("Arya", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text("Arya@email.com | +62 812-3456-7890", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            ),
            SizedBox(height: 32),

            // BANNER KYC (VERIFIKASI KTP/SIM) - Ini persiapan buat AWS S3 lu minggu depan!
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Verifikasi Akun (KYC)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800], fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Upload KTP & SIM agar bisa mulai menyewa mobil.", style: TextStyle(color: Colors.orange[700], fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // BUKA HALAMAN KYC
                      Navigator.push(context, MaterialPageRoute(builder: (context) => KycPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Verifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            SizedBox(height: 32),
// MENU SETTINGS
            _buildMenuOption(context, Icons.person_outline, "Edit Profil", EditProfilPage()),
            _buildMenuOption(context, Icons.credit_card_outlined, "Metode Pembayaran", PembayaranPage()),
            _buildMenuOption(context, Icons.lock_outline, "Pengaturan Keamanan", KeamananPage()), 
            _buildMenuOption(context, Icons.help_outline, "Pusat Bantuan", BantuanPage()),
   _buildMenuOption(
  context,
  Icons.admin_panel_settings,
  "Masuk Mode Owner (Admin)",
  OwnerMainLayout(),
),
            SizedBox(height: 32),

            // TOMBOL LOGOUT
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.logout, color: Colors.red),
              ),
              title: Text("Keluar Akun", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[200]),
             onTap: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    (route) => false, // hapus semua halaman sebelumnya
  );
},
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI BANTUAN BUAT BIKIN LIST MENU BIAR KODINGAN RAPI
 Widget _buildMenuOption(BuildContext context, IconData icon, String title, Widget? pageLanjutan) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () async {
        await Future.delayed(Duration(milliseconds: 100));
        if (pageLanjutan != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageLanjutan),
          );
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    ),
  );
}
}