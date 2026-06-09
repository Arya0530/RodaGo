// LOKASI: lib/pages/dashboard/owner_main_layout.dart
// PERUBAHAN dari versi lama:
//   - Tambah ikon lonceng di AppBar dengan badge unread count
//   - Badge di-refresh setiap 30 detik (polling)

import 'dart:async';
import 'package:flutter/material.dart';
import 'owner_dashboard_page.dart';
import 'kelola_mobil_page.dart';
import '../auth/login_page.dart';
import '../notifikasi/notifikasi_page.dart'; // ← TAMBAHAN
import '../../service/api_service.dart';     // ← TAMBAHAN
import '../../service/user_session.dart';
import 'laporan_keuangan_page.dart';

class OwnerMainLayout extends StatefulWidget {
  @override
  _OwnerMainLayoutState createState() => _OwnerMainLayoutState();
}

class _OwnerMainLayoutState extends State<OwnerMainLayout> {
  int _currentIndex = 0;

  // ── Notifikasi ──────────────────────────────────────────────
  int   _unreadCount = 0;
  Timer? _notifTimer;
  // ────────────────────────────────────────────────────────────

  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _pages = [
    OwnerDashboardPage(onNavigate: changeTab),
    KelolaMobilPage(),
    LaporanKeuanganPage(),
  ];

  final List<String> _titles = ['Dashboard Owner', 'Kelola Armada', 'Laporan Keuangan'];

  @override
  void initState() {
    super.initState();
    _refreshUnread();
    _notifTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshUnread());
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshUnread() async {
    final count = await ApiService.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  void _bukaNotifikasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiPage()),
    );
    _refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    // ===== VALIDASI ROLE =====
    if (UserSession.role != 'owner') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Akses Ditolak',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 8),
              Text(
                'Hanya pemilik kendaraan yang dapat mengakses dashboard ini',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  UserSession.hapus();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Kembali ke Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    // ========================

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        // ── Ikon lonceng dengan badge ──────────────────────────
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        // ────────────────────────────────────────────────────────
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _refreshUnread();
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: 'Armada'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Laporan'),
        ],
      ),
    );
  }
}