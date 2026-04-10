import 'package:flutter/material.dart';
import 'owner_dashboard_page.dart';
import 'kelola_mobil_page.dart';
// Kita pinjem halaman profil user aja biar lu ga usah coding ulang 
import '../profil/profil_page.dart'; 

class OwnerMainLayout extends StatefulWidget {
  @override
  _OwnerMainLayoutState createState() => _OwnerMainLayoutState();
}

class _OwnerMainLayoutState extends State<OwnerMainLayout> {
  int _currentIndex = 0;

  // 3 Tab buat si Owner
  final List<Widget> _pages = [
    OwnerDashboardPage(), // Tab 1: Dashboard Duit & Notif
    KelolaMobilPage(),    // Tab 2: Tambah/Edit Mobil
    ProfilPage(),         // Tab 3: Profil Owner (Pinjem dari yg user punya aja gpp)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: "Armada"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}