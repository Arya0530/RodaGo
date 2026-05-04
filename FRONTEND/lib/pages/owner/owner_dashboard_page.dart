import 'package:flutter/material.dart';
import 'detail_pesanan_masuk_page.dart';
import 'kelola_mobil_page.dart';
import '../../service/api_service.dart';

class OwnerDashboardPage extends StatefulWidget {
  final Function(int)? onNavigate;

  const OwnerDashboardPage({Key? key, this.onNavigate}) : super(key: key);

  @override
  _OwnerDashboardPageState createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  bool _isLoading = true;

  // Data pesanan masuk (pending + unpaid + active)
  List<dynamic> _pesananMasuk = [];

  // Data dashboard: pendapatan + jumlah pesanan
  String _totalPendapatan     = 'Rp 0';
  int    _jumlahPesananMasuk  = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // =========================================================================
  // Load semua data dashboard sekaligus (parallel request)
  // =========================================================================
  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);

    // Jalankan 2 request bersamaan agar lebih cepat
    final results = await Future.wait([
      ApiService.getOwnerBookings(),   // daftar pesanan masuk
      ApiService.getOwnerDashboard(),  // statistik pendapatan
    ]);

    final pesananResult   = results[0];
    final dashboardResult = results[1];

    setState(() {
      _isLoading = false;

      // Pesanan masuk
      _pesananMasuk = (pesananResult['success'] == true)
          ? pesananResult['data'] ?? []
          : [];

      // Statistik dashboard
      if (dashboardResult['success'] == true) {
        final data       = dashboardResult['data'] as Map<String, dynamic>;
        final pendapatan = data['total_pendapatan'] ?? 0;

        _jumlahPesananMasuk = data['jumlah_pesanan_masuk'] ?? 0;
        _totalPendapatan    = 'Rp ${_formatRupiah(pendapatan)}';
      }
    });
  }

  // =========================================================================
  // Helper: format angka jadi 1.500.000
  // =========================================================================
  String _formatRupiah(dynamic angka) {
    final n = int.tryParse(angka.toString()) ?? 0;
    final s = n.toString();
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Tidak pakai Scaffold/AppBar — sudah dihandle OwnerMainLayout
    return RefreshIndicator(
      color: Colors.teal,
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Ringkasan Bisnis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // ── Stat Cards: Pendapatan + Pesanan Masuk ──────────────────────
          Row(children: [
            Expanded(
              child: _buildStatCard(
                'Total Pendapatan',
                _isLoading ? '...' : _totalPendapatan,
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Pesanan Masuk',
                _isLoading ? '...' : _jumlahPesananMasuk.toString(),
                Icons.inbox_rounded,
                Colors.orange,
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Quick Access: Kelola Armada ─────────────────────────────────
          _buildQuickAccessCard(context),
          const SizedBox(height: 32),

          // ── Header list pesanan masuk ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pesanan Masuk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (!_isLoading && _pesananMasuk.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pesananMasuk.length} baru',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── List pesanan ────────────────────────────────────────────────
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            )
          else if (_pesananMasuk.isEmpty)
            _buildEmptyState()
          else
            ..._pesananMasuk.map((p) => _buildRequestCard(context, p)).toList(),
        ],
      ),
    );
  }

  // =========================================================================
  // Widget: Empty state saat tidak ada pesanan
  // =========================================================================
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(children: [
        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(
          'Tidak ada pesanan masuk',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Pesanan baru akan muncul di sini',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ]),
    );
  }

  // =========================================================================
  // Widget: Card satu pesanan masuk
  // =========================================================================
  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> pesanan) {
    final tanggal = '${pesanan['tanggal_mulai']} - ${pesanan['tanggal_selesai']}';

    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPesananMasukPage(
              bookingId   : pesanan['id'] as int,
              namaMobil   : pesanan['nama_mobil']   ?? '-',
              tanggal     : tanggal,
              totalHarga  : pesanan['total_harga']?.toString() ?? '0',
              namaPenyewa : pesanan['nama_penyewa']  ?? '-',
              emailPenyewa: pesanan['email_penyewa'] ?? '-',
              phonePenyewa: pesanan['phone_penyewa'] ?? '-',
            ),
          ),
        );
        // Reload dashboard jika ada perubahan status
        if (changed == true) _loadDashboard();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pesanan['nama_mobil'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Penyewa: ${pesanan['nama_penyewa'] ?? '-'}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            Text(
              'Tanggal: $tanggal',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Ketuk untuk detail',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Widget: Stat card (pendapatan / pesanan masuk)
  // =========================================================================
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Widget: Quick access ke halaman Kelola Mobil
  // =========================================================================
  Widget _buildQuickAccessCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onNavigate?.call(1); // pindah ke tab Kelola Mobil
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.teal,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kelola Armada',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Tambah, edit, atau hapus mobil',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ]),
            const Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
          ],
        ),
      ),
    );
  }
}