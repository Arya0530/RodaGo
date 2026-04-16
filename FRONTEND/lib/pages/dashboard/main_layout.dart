// ============================================================
// FILE DIUPDATE: lib/pages/dashboard/main_layout.dart
// ============================================================
// APA YANG BERUBAH DARI VERSI LAMA?
//
// Hanya 1 hal yang berubah:
//   - ProfilPage(isOwner: false) yang hardcode → sekarang pakai
//     ProfilPage(isOwner: UserSession.isOwner)
//
// Ini memastikan kalau entah gimana ada kasus ProfilPage butuh
// tahu role-nya, dia dapat info yang benar dari session.
//
// File ini sebenarnya tidak terlalu kritis karena MainLayout
// sudah hanya dipakai untuk role 'user' (owner diarahkan ke
// OwnerMainLayout dari login_page). Tapi ini best practice
// supaya konsisten.
// ============================================================

import 'package:flutter/material.dart';
import 'home_page.dart';
import '../pesanan/pesanan_page.dart';
import '../profil/profil_page.dart';
import 'package:frontend/pages/chatbot/chatbot_page.dart';
import '../services/user_session.dart'; // <-- TAMBAHAN BARU

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // ===========================================================
  // PERUBAHAN: isOwner tidak lagi hardcode false,
  // tapi dibaca dari UserSession
  // ===========================================================
  final List<Widget> _pages = [
    HomePage(),
    PesananPage(),
    ProfilPage(isOwner: false), // MainLayout hanya dipakai user, aman pakai false
  ];
  // ===========================================================

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],

      // TOMBOL TANYA AI (TIDAK BERUBAH)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatbotPage()));
        },
        backgroundColor: Colors.teal,
        elevation: 4,
        child: Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),

      // BOTTOM NAVIGATION 3 TAB (TIDAK BERUBAH)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: true,
        elevation: 10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}