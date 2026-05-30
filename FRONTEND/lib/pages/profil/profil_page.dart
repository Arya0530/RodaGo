// LOKASI: lib/pages/profil/profil_page.dart
// PERUBAHAN dari versi lama:
//   - Tambah ikon lonceng di AppBar dengan badge unread count
//   - Klik lonceng → buka NotifikasiPage

import 'package:flutter/material.dart';
import 'edit_profil_page.dart';
import 'bantuan_page.dart';
import 'keamanan_page.dart';
import 'pembayaran_page.dart';
import '../auth/login_page.dart';
import 'kyc_page.dart';
import '../owner/owner_main_layout.dart';
import '../notifikasi/notifikasi_page.dart'; // ← TAMBAHAN
import '../../service/user_session.dart';
import '../../service/api_service.dart';

class ProfilPage extends StatefulWidget {
  final bool isOwner;
  const ProfilPage({super.key, required this.isOwner});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _kycStatus  = 'loading';
  int    _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
    _refreshUnread();
  }

  Future<void> _loadKycStatus() async {
    final result = await ApiService.getKycStatus();
    if (!mounted) return;
    setState(() {
      _kycStatus = result['success'] == true
          ? (result['data']['status'] ?? 'unverified')
          : 'unverified';
    });
  }

  Future<void> _refreshUnread() async {
    final count = await ApiService.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  void _bukaNotifikasi() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage()));
    _refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // ── Ikon lonceng dengan badge ──────────────────────────
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: _bukaNotifikasi,
                tooltip: 'Notifikasi',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        // ────────────────────────────────────────────────────────
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ── Header profil ──────────────────────────────────
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal[100],
                    child: const Icon(Icons.person, size: 50, color: Colors.teal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UserSession.nama.isNotEmpty ? UserSession.nama : 'User',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    '${UserSession.email} | ${UserSession.phone}',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Banner KYC ─────────────────────────────────────
            _buildKycBanner(),
            if (_kycStatus != 'verified') const SizedBox(height: 32),
            if (_kycStatus == 'verified') const SizedBox(height: 16),

            // ── Menu Settings ──────────────────────────────────
            _buildMenuOption(context, Icons.person_outline,       'Edit Profil',         EditProfilPage()),
            _buildMenuOption(context, Icons.credit_card_outlined, 'Metode Pembayaran',   PembayaranPage()),
            _buildMenuOption(context, Icons.lock_outline,         'Pengaturan Keamanan', KeamananPage()),
            _buildMenuOption(context, Icons.help_outline,         'Pusat Bantuan',       BantuanPage()),

            if (UserSession.isOwner)
              _buildMenuOption(context, Icons.admin_panel_settings, 'Dashboard Owner', OwnerMainLayout()),

            const SizedBox(height: 32),

            // ── Logout ─────────────────────────────────────────
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout, color: Colors.red),
              ),
              title: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red[200]),
              onTap: () {
                UserSession.hapus();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycBanner() {
    if (_kycStatus == 'loading') {
      return Container(
        height: 80,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2)),
      );
    }
    if (_kycStatus == 'verified') return const SizedBox.shrink();

    Color bgColor; Color borderColor; Color iconColor; IconData icon;
    String judul; String pesan; String tombolLabel; Color tombolColor;

    switch (_kycStatus) {
      case 'pending':
        bgColor = Colors.blue[50]!; borderColor = Colors.blue[200]!; iconColor = Colors.blue;
        icon = Icons.hourglass_top_rounded; judul = 'Sedang Ditinjau';
        pesan = 'Dokumen Anda sedang diperiksa tim kami.'; tombolLabel = 'Lihat Status'; tombolColor = Colors.blue;
        break;
      case 'rejected':
        bgColor = Colors.red[50]!; borderColor = Colors.red[200]!; iconColor = Colors.red;
        icon = Icons.cancel_outlined; judul = 'Dokumen Ditolak';
        pesan = 'Silakan upload ulang dokumen Anda.'; tombolLabel = 'Upload Ulang'; tombolColor = Colors.red;
        break;
      default:
        bgColor = Colors.orange[50]!; borderColor = Colors.orange[200]!; iconColor = Colors.orange;
        icon = Icons.warning_amber_rounded; judul = 'Verifikasi Akun (KYC)';
        pesan = 'Upload KTP & SIM agar bisa mulai menyewa mobil.'; tombolLabel = 'Verifikasi'; tombolColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(judul, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 15)),
          const SizedBox(height: 4),
          Text(pesan, style: TextStyle(color: iconColor.withOpacity(0.85), fontSize: 12)),
        ])),
        ElevatedButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => KycPage()));
            _loadKycStatus();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: tombolColor, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(tombolLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, Widget? pageLanjutan) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          if (pageLanjutan != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => pageLanjutan));
          }
        },
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.teal),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}