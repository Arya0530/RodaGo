import 'package:flutter/material.dart';
import 'owner_dashboard_page.dart';
import 'kelola_mobil_page.dart';

class OwnerMainLayout extends StatefulWidget {
  @override
  _OwnerMainLayoutState createState() => _OwnerMainLayoutState();
}

class _OwnerMainLayoutState extends State<OwnerMainLayout> {
  int _currentIndex = 0;

  // Cek bagian ini! Kemungkinan di laptop lu ini kosong gara2 salah copas
  final List<Widget> _pages = [
    OwnerDashboardPage(), 
    KelolaMobilPage(),    
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
        ],
      ),
    );
  }
}