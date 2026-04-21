import 'package:flutter/material.dart';
import 'detail_mobil_page.dart';
import '../auth/login_page.dart';
import '../services/user_session.dart';
import '../../service/mobil_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ["All", "Economy", "MPV", "SUV", "Luxury"];
  final TextEditingController _lokasiController = TextEditingController();
  DateTime? _tanggalCari;
  bool _isLoadingCari = false;

  // ========== PERUBAHAN: Ganti dummy dengan list dari API ==========
  List<dynamic> _allCars = [];          // Sekarang menyimpan data dari API
  bool _isLoadingMobil = true;           // Loading awal saat fetch mobil
  // =================================================================

  @override
  void initState() {
    super.initState();
    _fetchMobil(); // Panggil API saat halaman pertama kali dibuka
  }

  Future<void> _fetchMobil() async {
    try {
      final data = await MobilService.getMobilPublic();
      setState(() {
        _allCars = data;
        _isLoadingMobil = false;
      });
    } catch (e) {
      setState(() => _isLoadingMobil = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data mobil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika masih loading, tampilkan indikator
    if (_isLoadingMobil) {
      return Center(child: CircularProgressIndicator());
    }

    // Filter mobil berdasarkan kategori yang dipilih
    String activeCategory = _categories[_selectedCategoryIndex];
    List<dynamic> filteredCars = activeCategory == "All"
        ? _allCars
        : _allCars.where((car) => car['tipe'] == activeCategory).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER & LOGOUT (TIDAK BERUBAH)
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
                        Text(
                          UserSession.nama.isNotEmpty ? UserSession.nama : 'User',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    UserSession.hapus();
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: _lokasiController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_on_outlined, color: Colors.teal),
                        border: InputBorder.none,
                        hintText: "Lokasi Rental",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        icon: Icon(Icons.calendar_month_outlined, color: Colors.teal),
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
                        if (_lokasiController.text.isEmpty || _tanggalCari == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Isi lokasi dan tanggal dulu ya!"),
                              backgroundColor: Colors.red));
                          return;
                        }
                        setState(() => _isLoadingCari = true);
                        Future.delayed(Duration(seconds: 1), () {
                          setState(() => _isLoadingCari = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Menampilkan mobil di ${_lokasiController.text}"),
                              backgroundColor: Colors.teal));
                          // Nanti bisa ditambahkan logika filter lokasi sungguhan
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

            // DAFTAR MOBIL (DARI API)
            Text("Rekomendasi Mobil",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: 16),
            ...filteredCars.map((car) => _buildCarCard(
                context,
                car['nama'] ?? '',
                car['tipe'] ?? '',
                'Rp ${_formatCurrency(car['harga'] ?? 0)} / hari',
                car['gambar'] ?? '',
                car
            )).toList(),
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
          border: Border.all(color: isSelected ? Colors.teal : Colors.grey[200]!),
        ),
        child: Text(
          _categories[index],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(
      BuildContext context, String name, String type, String price, String imageUrl, dynamic carData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailMobilPage(namaMobil: name, carData: carData)));
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
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.directions_car, color: Colors.grey),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.directions_car, color: Colors.grey),
                    ),
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
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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

  String _formatCurrency(dynamic value) {
    int harga = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return harga.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (Match m) => '.');
  }
}