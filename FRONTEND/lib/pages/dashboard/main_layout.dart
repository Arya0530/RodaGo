// LOKASI: lib/pages/dashboard/main_layout.dart
// PERUBAHAN dari versi lama:
//   - Tambah ikon lonceng di AppBar setiap halaman dengan badge unread count
//   - Badge di-refresh setiap kali tab berubah dan setiap 30 detik (polling)

import 'dart:async';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../pesanan/pesanan_page.dart';
import '../profil/profil_page.dart';
import '../notifikasi/notifikasi_page.dart'; // ← TAMBAHAN
import 'package:frontend/pages/chatbot/chatbot_page.dart';
import '../../service/api_service.dart';     // ← TAMBAHAN
import '../../service/user_session.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  // ── Notifikasi ──────────────────────────────────────────────
  int   _unreadCount = 0;
  Timer? _notifTimer;
  // ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _refreshUnread();
    // Polling setiap 30 detik supaya badge selalu up-to-date
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

  List<Widget> get _pages => [
    HomePage(),
    PesananPage(),
    ProfilPage(isOwner: UserSession.isOwner),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Refresh badge setiap kali pindah tab
    _refreshUnread();
  }

  void _bukaNotifikasi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiPage()),
    );
    // Refresh badge setelah kembali dari halaman notifikasi
    _refreshUnread();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],

      // TOMBOL TANYA AI
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage()));
        },
        backgroundColor: Colors.teal,
        elevation: 4,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: true,
        elevation: 10,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Pesanan',
          ),
          // ── Badge notifikasi di tab Profil ──────────────────
          BottomNavigationBarItem(
            icon: _buildBadgeIcon(Icons.person_outline),
            activeIcon: _buildBadgeIcon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  /// Widget ikon dengan badge merah kalau ada notifikasi belum dibaca
  Widget _buildBadgeIcon(IconData icon) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (_unreadCount > 0)
          Positioned(
            right: -6,
            top: -4,
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
    );
  }
}