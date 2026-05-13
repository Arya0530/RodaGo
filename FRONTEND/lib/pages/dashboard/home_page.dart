// LOKASI: lib/pages/home/home_page.dart

import 'package:flutter/material.dart';
import 'detail_mobil_page.dart';
import '../auth/login_page.dart';
import '../../service/user_session.dart';
import '../../service/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── Kategori ────────────────────────────────────────────────
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Economy', 'MPV', 'SUV', 'Luxury'];

  // ── Data mobil ──────────────────────────────────────────────
  // _allCars  : data awal dari /api/mobil/public (semua mobil tersedia)
  // _carsTampil: data yang sedang ditampilkan (bisa hasil search)
  List<dynamic> _allCars    = [];
  List<dynamic> _carsTampil = [];
  bool _isLoadingMobil = true;

  // ── Data kota dari /api/cities ───────────────────────────────
  // Format tiap item: {"id": 1, "name": "Surabaya", "province": "Jawa Timur"}
  List<dynamic> _cities        = [];
  String?       _selectedCity;   // name kota yang dipilih, null = belum pilih
  bool _isLoadingCities = true;

  // ── Tanggal pencarian ────────────────────────────────────────
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  // ── State tombol Cari ────────────────────────────────────────
  bool _isSearching  = false; // loading saat tombol Cari ditekan
  bool _sudahDicari  = false; // true setelah search berhasil dilakukan

  // ════════════════════════════════════════════════════════════
  // INIT
  // ════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _fetchMobilPublic(); // Muat semua mobil tersedia di awal
    _fetchCities();      // Muat daftar kota untuk dropdown
  }

  // ════════════════════════════════════════════════════════════
  // FETCH DATA
  // ════════════════════════════════════════════════════════════

  /// Ambil semua mobil tersedia dari /api/mobil/public
  /// Dipanggil sekali saat halaman pertama dibuka.
  Future<void> _fetchMobilPublic() async {
    try {
      final data = await ApiService.getMobilPublic();
      setState(() {
        _allCars     = data;
        _carsTampil  = data; // tampilkan semua di awal
        _isLoadingMobil = false;
      });
    } catch (e) {
      setState(() => _isLoadingMobil = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data mobil: $e')),
        );
      }
    }
  }

  /// Ambil daftar kota dari /api/cities
  /// Hanya kota yang ada rental aktif + punya mobil tersedia.
  Future<void> _fetchCities() async {
    final data = await ApiService.getCities();
    setState(() {
      _cities        = data;
      _isLoadingCities = false;
    });
  }

  // ════════════════════════════════════════════════════════════
  // AKSI PENCARIAN
  // ════════════════════════════════════════════════════════════

  /// Dipanggil saat tombol "Cari Mobil" ditekan.
  ///
  /// ATURAN:
  /// - Kota    : WAJIB dipilih
  /// - Tanggal : WAJIB keduanya diisi
  ///
  /// Kirim ke /api/mobil/search dengan parameter:
  ///   city_name       = nama kota yang dipilih (rentals.city harus sama persis)
  ///   tanggal_mulai   = YYYY-MM-DD
  ///   tanggal_selesai = YYYY-MM-DD
  ///
  /// Server akan:
  ///   1. Filter mobil milik owner yang rentals.city = city_name
  ///   2. Exclude mobil yang sudah di-booking di rentang tanggal itu
  ///   3. Return hanya mobil tersedia
  Future<void> _cariMobil() async {
    // Validasi input
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kota dulu ya!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal mulai dan selesai dulu ya!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    // Format tanggal ke YYYY-MM-DD untuk dikirim ke API
    final mulai = _formatTanggalApi(_tanggalMulai!);
    final selesai = _formatTanggalApi(_tanggalSelesai!);

    final result = await ApiService.searchMobil(
      cityName      : _selectedCity!,   // nama kota persis seperti di rentals.city
      tanggalMulai  : mulai,
      tanggalSelesai: selesai,
    );

    setState(() => _isSearching = false);

    if (result['success'] == true) {
      final List<dynamic> hasilCari = result['data'] ?? [];
      setState(() {
        _carsTampil   = hasilCari;
        _sudahDicari  = true;
        // Reset filter kategori ke All saat hasil baru masuk
        _selectedCategoryIndex = 0;
      });

      if (hasilCari.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak ada mobil tersedia di $_selectedCity '
                'pada tanggal yang dipilih.'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mencari mobil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Reset pencarian → kembali tampilkan semua mobil (data awal)
  void _resetPencarian() {
    setState(() {
      _selectedCity          = null;
      _tanggalMulai          = null;
      _tanggalSelesai        = null;
      _carsTampil            = _allCars;
      _sudahDicari           = false;
      _selectedCategoryIndex = 0;
    });
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMobil) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    // Filter kategori tipe mobil dari data yang sedang ditampilkan
    final activeCategory = _categories[_selectedCategoryIndex];
    final List<dynamic> filteredCars = activeCategory == 'All'
        ? _carsTampil
        : _carsTampil
            .where((car) => car['tipe'] == activeCategory)
            .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────
            _buildHeader(context),
            const SizedBox(height: 32),

            const Text(
              'Search For a Car ✨',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // ── KOTAK PENCARIAN ──────────────────────────────────
            _buildSearchBox(),
            const SizedBox(height: 16),

            // ── BANNER HASIL PENCARIAN (muncul setelah Cari ditekan) ──
            if (_sudahDicari) _buildBannerHasil(),
            if (_sudahDicari) const SizedBox(height: 16),

            // ── FILTER KATEGORI ──────────────────────────────────
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _categories.length,
                  (i) => _buildCategoryChip(i),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── JUDUL DAFTAR MOBIL ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _sudahDicari
                      ? 'Mobil di $_selectedCity'
                      : 'Rekomendasi Mobil',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${filteredCars.length} mobil',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── DAFTAR MOBIL ─────────────────────────────────────
            ...filteredCars.map((car) => _buildCarCard(context, car)).toList(),

            if (filteredCars.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        _sudahDicari
                            ? 'Tidak ada mobil tersedia\ndi kota dan tanggal ini'
                            : 'Belum ada mobil di kategori ini',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // WIDGET HELPERS
  // ════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal[100],
              child: const Icon(Icons.person, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good Morning 👋',
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(
                  UserSession.nama.isNotEmpty ? UserSession.nama : 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
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
              MaterialPageRoute(builder: (_) => LoginPage()),
              (route) => false,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.logout, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          // ── Dropdown Kota ──────────────────────────────────
          // Sumber data: GET /api/cities (tabel cities)
          // Hanya tampilkan kota yang ada rental aktif + mobil tersedia
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isLoadingCities
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.teal, size: 20),
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Memuat kota...',
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCity,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.teal),
                      hint: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.teal, size: 20),
                          const SizedBox(width: 12),
                          Text('Pilih Kota',
                              style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                      // _cities berisi list dari GET /api/cities
                      // Setiap item: {"id": 1, "name": "Surabaya", ...}
                      // value = city['name'] karena rentals.city menyimpan nama kota (string)
                      items: _cities.map<DropdownMenuItem<String>>((city) {
                        return DropdownMenuItem<String>(
                          value: city['name'].toString(),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.teal, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  city['name'].toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Tampilkan provinsi sebagai sub-label
                              if (city['province'] != null)
                                Text(
                                  city['province'].toString(),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                          // Jika kota diubah setelah pencarian, reset tampilan
                          if (_sudahDicari) {
                            _sudahDicari = false;
                            _carsTampil  = _allCars;
                          }
                        });
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // ── Tanggal Mulai ──────────────────────────────────
          _buildInputTanggal(
            label: 'Tanggal Mulai',
            icon: Icons.calendar_today_outlined,
            tanggal: _tanggalMulai,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  _tanggalMulai = picked;
                  // Reset tanggal selesai jika lebih awal dari mulai
                  if (_tanggalSelesai != null &&
                      _tanggalSelesai!.isBefore(picked)) {
                    _tanggalSelesai = null;
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // ── Tanggal Selesai ────────────────────────────────
          _buildInputTanggal(
            label: 'Tanggal Selesai',
            icon: Icons.event_available_outlined,
            tanggal: _tanggalSelesai,
            onPick: () async {
              final picked = await showDatePicker(
                context: context,
                // Minimal 1 hari setelah tanggal mulai
                initialDate: _tanggalMulai != null
                    ? _tanggalMulai!.add(const Duration(days: 1))
                    : DateTime.now().add(const Duration(days: 1)),
                firstDate: _tanggalMulai != null
                    ? _tanggalMulai!.add(const Duration(days: 1))
                    : DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() => _tanggalSelesai = picked);
              }
            },
          ),
          const SizedBox(height: 20),

          // ── Tombol Cari ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _cariMobil,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.teal[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Cari Mobil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Input tanggal readonly — ketuk untuk buka date picker
  Widget _buildInputTanggal({
    required String   label,
    required IconData icon,
    required DateTime? tanggal,
    required VoidCallback onPick,
  }) {
    final ada = tanggal != null;
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ada ? Colors.teal.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: ada ? Colors.teal : Colors.teal[300], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ada
                    ? '${tanggal.day.toString().padLeft(2, '0')}/'
                        '${tanggal.month.toString().padLeft(2, '0')}/'
                        '${tanggal.year}'
                    : label,
                style: TextStyle(
                  color:
                      ada ? Colors.black87 : Colors.grey[400],
                  fontWeight:
                      ada ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            if (ada)
              Icon(Icons.check_circle,
                  color: Colors.teal[300], size: 18),
          ],
        ),
      ),
    );
  }

  /// Banner info setelah pencarian berhasil
  Widget _buildBannerHasil() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.teal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menampilkan mobil di $_selectedCity  '
              '(${_formatTanggalTampil(_tanggalMulai!)} – '
              '${_formatTanggalTampil(_tanggalSelesai!)})',
              style: const TextStyle(
                color: Colors.teal,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Tombol reset → kembali ke tampilan semua mobil
          GestureDetector(
            onTap: _resetPencarian,
            child: const Icon(Icons.close, color: Colors.teal, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(int index) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey[200]!,
          ),
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

  Widget _buildCarCard(BuildContext context, dynamic car) {
    final String nama      = car['nama']      ?? '';
    final String tipe      = car['tipe']      ?? '';
    final String imageUrl  = car['gambar']    ?? '';
    final String namaRental = car['nama_rental'] ?? '';
    final String kotaRental = car['kota_rental'] ?? '';
    final String harga     = 'Rp ${_formatCurrency(car['harga'] ?? 0)} / hari';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailMobilPage(namaMobil: nama, carData: car),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Gambar mobil
            Container(
              width: 100,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.directions_car,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.directions_car, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // Info mobil
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(tipe,
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 4),

                  // Info rental & kota (dari join di backend)
                  if (namaRental.isNotEmpty || kotaRental.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.store_outlined,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            namaRental.isNotEmpty
                                ? '$namaRental · $kotaRental'
                                : kotaRental,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),

                  Text(
                    harga,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // FORMAT HELPERS
  // ════════════════════════════════════════════════════════════

  /// Format tanggal ke YYYY-MM-DD untuk dikirim ke API
  String _formatTanggalApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Format tanggal ke DD/MM/YYYY untuk ditampilkan di UI
  String _formatTanggalTampil(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  /// Format angka ke format rupiah: 150000 → "150.000"
  String _formatCurrency(dynamic value) {
    int harga =
        value is int ? value : int.tryParse(value.toString()) ?? 0;
    return harga
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => '.',
        );
  }
}