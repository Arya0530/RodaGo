import 'package:flutter/material.dart';
import 'owner_dashboard_page.dart';
import 'kelola_mobil_page.dart';
import '../auth/login_page.dart';
import '../services/user_session.dart';

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
    // ===== VALIDASI ROLE =====
    if (UserSession.role != 'owner') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text('Akses Ditolak', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 8),
              Text('Hanya pemilik kendaraan yang dapat mengakses dashboard ini', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  UserSession.hapus();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: Text('Kembali ke Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    // ========================

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