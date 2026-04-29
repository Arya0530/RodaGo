import 'package:flutter/material.dart';
import 'proses_pembayaran_page.dart';
import '../../service/api_service.dart'; // Sesuaikan path import project kamu

class PesananPage extends StatefulWidget {
  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  bool _isLoading = true;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // ── Ambil pesanan dari API (otomatis hanya milik user yang login) ──────────
  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getMyBookings();

    setState(() {
      _isLoading = false;
      _bookings = (result['success'] == true) ? result['data'] ?? [] : [];
    });
  }

  // ── Filter per tab ────────────────────────────────────────────────────────
  List<dynamic> get _aktif => _bookings
      .where((b) => ['pending', 'unpaid', 'active'].contains(b['status']))
      .toList();
  List<dynamic> get _selesai =>
      _bookings.where((b) => b['status'] == 'completed').toList();
  List<dynamic> get _dibatalkan =>
      _bookings.where((b) => b['status'] == 'cancelled').toList();

  // ── Cancel pesanan ────────────────────────────────────────────────────────
  Future<void> _cancelBooking(int id, String namaMobil) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pesanan'),
        content: Text('Yakin ingin membatalkan pesanan $namaMobil?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Tidak', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Ya, Batalkan',
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (ok != true) return;

    final result = await ApiService.cancelBooking(id);
    if (!mounted) return;

    if (result['success'] == true) {
      _showSnackbar('Pesanan berhasil dibatalkan.', Colors.grey[700]!);
      _loadBookings();
    } else {
      _showSnackbar(result['message'] ?? 'Gagal membatalkan', Colors.red);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Pesanan Saya',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
                icon: const Icon(Icons.refresh, color: Colors.teal),
                onPressed: _loadBookings),
          ],
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : RefreshIndicator(
                color: Colors.teal,
                onRefresh: _loadBookings,
                child: TabBarView(
                  children: [
                    _buildList(_aktif, 'Belum ada pesanan aktif'),
                    _buildList(_selesai, 'Belum ada pesanan selesai'),
                    _buildList(_dibatalkan, 'Belum ada pesanan dibatalkan'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildList(List<dynamic> list, String pesanKosong) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(pesanKosong,
                style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildOrderCard(list[i]),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> booking) {
    final status    = booking['status'] ?? 'pending';
    final id        = booking['id'] as int;
    final namaMobil = booking['nama_mobil'] ?? '-';
    final tanggal   =
        '${booking['tanggal_mulai']} - ${booking['tanggal_selesai']}';
    final harga     = _formatHarga(booking['total_harga']);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText  = 'Menunggu Konfirmasi';
        statusIcon  = Icons.access_time_filled;
        break;
      case 'unpaid':
        statusColor = Colors.red;
        statusText  = 'Belum Dibayar';
        statusIcon  = Icons.warning_rounded;
        break;
      case 'active':
        statusColor = Colors.teal;
        statusText  = 'Disewa (Lunas)';
        statusIcon  = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText  = 'Selesai';
        statusIcon  = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusText  = 'Dibatalkan';
        statusIcon  = Icons.cancel;
    }

    return Container(
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama mobil + badge status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(namaMobil,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(statusText,
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(tanggal,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ]),
          const SizedBox(height: 4),

          Row(children: [
            Icon(Icons.monetization_on_outlined,
                size: 14, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Text(harga,
                style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ]),

          // Countdown bayar kalau unpaid
          if (status == 'unpaid' && booking['deadline_bayar'] != null) ...[
            const SizedBox(height: 8),
            _buildCountdown(booking['deadline_bayar']),
          ],

          Divider(height: 24, color: Colors.grey[100], thickness: 1),

          // Tombol aksi sesuai status
          if (status == 'pending')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _cancelBooking(id, namaMobil),
                style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Batalkan Pesanan',
                    style: TextStyle(color: Colors.red)),
              ),
            ),

          if (status == 'unpaid')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _prosesPembayaran(booking),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0),
                child: const Text('Bayar Sekarang',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          if (status == 'active')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _tampilkanTiketQR(id),
                icon: const Icon(Icons.qr_code, color: Colors.teal, size: 18),
                label: const Text('Lihat Tiket',
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),

          // Info kenapa dibatalkan
          if (status == 'cancelled')
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                _alasanCancel(booking['cancelled_by']),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdown(String deadlineIso) {
    try {
      final deadline = DateTime.parse(deadlineIso).toLocal();
      final sisa     = deadline.difference(DateTime.now());

      if (sisa.isNegative) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
          child: const Row(children: [
            Icon(Icons.timer_off, color: Colors.red, size: 14),
            SizedBox(width: 6),
            Text('Waktu bayar habis — segera dibatalkan sistem',
                style: TextStyle(color: Colors.red, fontSize: 11)),
          ]),
        );
      }

      final jam   = sisa.inHours;
      final menit = sisa.inMinutes % 60;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.timer_outlined, color: Colors.orange, size: 14),
          const SizedBox(width: 6),
          Text(
            'Bayar dalam ${jam}j ${menit}m sebelum otomatis batal',
            style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ]),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  String _alasanCancel(dynamic cancelledBy) {
    switch (cancelledBy?.toString()) {
      case 'user':   return 'Dibatalkan oleh Anda';
      case 'owner':  return 'Ditolak oleh pemilik rental';
      case 'system': return 'Otomatis dibatalkan karena melewati batas waktu pembayaran (24 jam)';
      default:       return 'Pesanan dibatalkan';
    }
  }

  void _prosesPembayaran(Map<String, dynamic> booking) async {
  bool? hasil = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProsesPembayaranPage(
        namaMobil:  booking['nama_mobil'] ?? '-',
        totalHarga: _formatHarga(booking['total_harga']),
        bookingId:  booking['id'] as int, // ✅ TAMBAHAN
      ),
    ),
  );
  if (hasil == true) {
    _showSnackbar('Pembayaran berhasil! Tiket diterbitkan. 🎉', Colors.teal);
    _loadBookings(); // otomatis refresh → pesanan masuk tab Completed
  }
}

  void _tampilkanTiketQR(int bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tiket Pengambilan',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tunjukkan QR Code ini ke pihak rental',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16)),
              child:
                  const Icon(Icons.qr_code_2, size: 140, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              '#RDG-${bookingId.toString().padLeft(4, '0')}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                  fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  String _formatHarga(dynamic angka) {
    try {
      final num = int.parse(angka.toString());
      final str = num.toString();
      String result = '';
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result = '.' + result;
        result = str[i] + result;
        count++;
      }
      return 'Rp $result';
    } catch (_) {
      return 'Rp $angka';
    }
  }
}