// ============================================================
// FILE DIUPDATE: lib/pages/dashboard/home_page.dart
// ============================================================
// APA YANG BERUBAH DARI VERSI LAMA?
//
// Hanya 2 baris yang berubah di bagian HEADER:
//   - "Good Morning 👋" → tetap sama
//   - Teks "Arya" (hardcode) diganti dengan UserSession.nama
//     sehingga nama yang tampil sesuai dengan siapa yang login
//
// Semua tampilan, logika filter kategori, pencarian, kartu mobil
// dll TIDAK ADA YANG BERUBAH sama sekali.
// ============================================================

import 'package:flutter/material.dart';
import 'detail_mobil_page.dart';
import '../auth/login_page.dart';
import '../services/user_session.dart'; // <-- TAMBAHAN BARU

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ["All", "Economy", "MPV", "Luxury"];
  final TextEditingController _lokasiController = TextEditingController();
  DateTime? _tanggalCari;
  bool _isLoadingCari = false;

  final List<Map<String, String>> _allCars = [
    {"name": "Toyota Camry Hybrid", "type": "Luxury", "price": "Rp 1.500.000 / hari"},
    {"name": "Mitsubishi Xpander", "type": "MPV", "price": "Rp 450.000 / hari"},
    {"name": "Honda Brio", "type": "Economy", "price": "Rp 300.000 / hari"},
    {"name": "Toyota Alphard", "type": "Luxury", "price": "Rp 2.500.000 / hari"},
    {"name": "Daihatsu Xenia", "type": "MPV", "price": "Rp 400.000 / hari"},
  ];

  @override
  Widget build(BuildContext context) {
    String activeCategory = _categories[_selectedCategoryIndex];
    List<Map<String, String>> filteredCars = activeCategory == "All"
        ? _allCars
        : _allCars.where((car) => car["type"] == activeCategory).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER & LOGOUT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.teal[100],
                        child: Icon(Icons.person, color: Colors.teal)),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Good Morning 👋",
                            style:
                                TextStyle(color: Colors.grey[500], fontSize: 12)),
                        // ===========================================================
                        // PERUBAHAN: Dari hardcode "Arya" → pakai UserSession.nama
                        // Kalau nama kosong (belum login), tampilkan "User" sebagai fallback
                        // ===========================================================
                        Text(
                          UserSession.nama.isNotEmpty ? UserSession.nama : 'User',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                        ),
                        // ===========================================================
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    UserSession.hapus(); // <-- TAMBAHAN BARU: bersihkan session saat logout
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.logout, color: Colors.red),
                  ),
                )
              ],
            ),
            SizedBox(height: 32),

            Text("Search For a Car ✨",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 24),

            // KOTAK PENCARIAN (TIDAK BERUBAH)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, 5))
                ],
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: _lokasiController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_on_outlined,
                            color: Colors.teal),
                        border: InputBorder.none,
                        hintText: "Lokasi Rental",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            _tanggalCari = picked;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_month_outlined,
                            color: Colors.teal),
                        border: InputBorder.none,
                        hintText: _tanggalCari != null
                            ? "${_tanggalCari!.day}/${_tanggalCari!.month}/${_tanggalCari!.year}"
                            : "Pilih Tanggal",
                        hintStyle: TextStyle(
                            color: _tanggalCari != null
                                ? Colors.black87
                                : Colors.grey[400],
                            fontWeight: _tanggalCari != null
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Kembalikan ke lokasi yang sama",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_lokasiController.text.isEmpty ||
                            _tanggalCari == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Isi lokasi dan tanggal dulu ya!"),
                              backgroundColor: Colors.red));
                          return;
                        }
                        setState(() {
                          _isLoadingCari = true;
                        });
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() {
                            _isLoadingCari = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Menampilkan mobil di ${_lokasiController.text}"),
                              backgroundColor: Colors.teal));
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoadingCari
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text("Cari Mobil",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 32),

            // KATEGORI MOBIL (TIDAK BERUBAH)
            Text("Categories",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                    _categories.length,
                    (index) => _buildCategoryChip(index)),
              ),
            ),
            SizedBox(height: 24),

            // DAFTAR MOBIL (TIDAK BERUBAH)
            Text("Rekomendasi Mobil",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 16),
            ...filteredCars
                .map((car) => _buildCarCard(
                    context, car["name"]!, car["type"]!, car["price"]!))
                .toList(),
            if (filteredCars.isEmpty)
              Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Belum ada mobil di kategori ini",
                          style: TextStyle(color: Colors.grey)))),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(int index) {
    bool isSelected = (_selectedCategoryIndex == index);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: isSelected ? Colors.teal : Colors.grey[200]!),
        ),
        child: Text(
          _categories[index],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(
      BuildContext context, String name, String type, String price) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailMobilPage(namaMobil: name)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12)),
              child: Image.network(
                  "https://tse1.mm.bing.net/th/id/OIP.DsOCw4WiRonNlhEHqCEjJgHaE8?w=720&h=480&rs=1&pid=ImgDetMain&o=7&rm=3",
                  fit: BoxFit.cover),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87)),
                  SizedBox(height: 4),
                  Text(type,
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12)),
                  SizedBox(height: 8),
                  Text(price,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
          ],
        ),
      ),
    );
  }
}