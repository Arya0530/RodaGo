import 'package:flutter/material.dart';
import 'home_page.dart';
import '../pesanan/pesanan_page.dart';
import '../profil/profil_page.dart';
import 'package:frontend/pages/chatbot/chatbot_page.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Daftar halaman untuk tiap tab
 // Daftar halaman untuk tiap tab
  final List<Widget> _pages = [
    HomePage(),
    PesananPage(), // <--- LU LUPA NAMBAHIN INI DI TENGAH-TENGAH BRO!
    ProfilPage(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex], // Nampilin halaman sesuai tab yang diklik
      
      // TOMBOL TANYA AI (NGAMBANG)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotPage()));
        },
        backgroundColor: Colors.teal, // Hijau Emerald RodaGo
        elevation: 4,
        child: Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      
      // BOTTOM NAVIGATION 3 TAB
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