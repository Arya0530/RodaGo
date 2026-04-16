// ============================================================
// FILE DIUPDATE: lib/pages/profil/profil_page.dart
// ============================================================
// APA YANG BERUBAH DARI VERSI LAMA?
//
// 1. Nama "Arya" (hardcode) → diganti UserSession.nama
// 2. Email "Arya@email.com | +62..." → diganti UserSession.email & phone
// 3. Menu "Masuk Mode Owner (Admin)" → sekarang HANYA MUNCUL
//    kalau UserSession.isOwner == true (role = 'owner')
//    Kalau login sebagai user biasa, menu ini TERSEMBUNYI otomatis.
// 4. Tombol logout sekarang memanggil UserSession.hapus() dulu
//    sebelum redirect ke LoginPage
//
// Semua tampilan lain (KYC banner, menu edit profil, dll)
// TIDAK BERUBAH sama sekali.
// ============================================================

import 'package:flutter/material.dart';
import 'edit_profil_page.dart';
import 'bantuan_page.dart';
import 'keamanan_page.dart';
import 'pembayaran_page.dart';
import '../auth/login_page.dart';
import 'kyc_page.dart';
import '../owner/owner_main_layout.dart';
import '../services/user_session.dart'; // <-- TAMBAHAN BARU

class ProfilPage extends StatelessWidget {
  final bool isOwner;

  const ProfilPage({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Profil Saya",
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
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
                  // ===========================================================
                  // PERUBAHAN: Nama & email dari UserSession, bukan hardcode
                  // ===========================================================
                  Text(
                    UserSession.nama.isNotEmpty ? UserSession.nama : 'User',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  Text(
                    '${UserSession.email} | ${UserSession.phone}',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  // ===========================================================
                ],
              ),
            ),
            SizedBox(height: 32),

            // BANNER KYC (TIDAK BERUBAH)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Verifikasi Akun (KYC)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                                fontSize: 16)),
                        SizedBox(height: 4),
                        Text(
                            "Upload KTP & SIM agar bisa mulai menyewa mobil.",
                            style: TextStyle(
                                color: Colors.orange[700], fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => KycPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Verifikasi",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            SizedBox(height: 32),

            // MENU SETTINGS (TIDAK BERUBAH)
            _buildMenuOption(
                context, Icons.person_outline, "Edit Profil", EditProfilPage()),
            _buildMenuOption(context, Icons.credit_card_outlined,
                "Metode Pembayaran", PembayaranPage()),
            _buildMenuOption(context, Icons.lock_outline,
                "Pengaturan Keamanan", KeamananPage()),
            _buildMenuOption(
                context, Icons.help_outline, "Pusat Bantuan", BantuanPage()),

            // ===========================================================
            // PERUBAHAN: Menu Owner hanya tampil kalau role = 'owner'
            // Sebelumnya selalu tampil untuk semua user.
            // Sekarang pakai UserSession.isOwner sebagai kondisi.
            // ===========================================================
            if (UserSession.isOwner)
              _buildMenuOption(
                context,
                Icons.admin_panel_settings,
                "Dashboard Owner",
                OwnerMainLayout(),
              ),
            // ===========================================================

            SizedBox(height: 32),

            // TOMBOL LOGOUT (DIUPDATE: tambah UserSession.hapus())
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.logout, color: Colors.red),
              ),
              title: Text("Keluar Akun",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red)),
              trailing:
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[200]),
              onTap: () {
                UserSession.hapus(); // <-- TAMBAHAN BARU: bersihkan session
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
      BuildContext context, IconData icon, String title, Widget? pageLanjutan) {
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