// LOKASI: lib/pages/owner/laporan_keuangan_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../service/api_service.dart';

class LaporanKeuanganPage extends StatefulWidget {
  const LaporanKeuanganPage({Key? key}) : super(key: key);

  @override
  _LaporanKeuanganPageState createState() => _LaporanKeuanganPageState();
}

class _LaporanKeuanganPageState extends State<LaporanKeuanganPage> {
  bool _isLoading = true;
  List<dynamic> _riwayatTransaksi = [];
  
  int _totalPendapatanBulanIni = 0;
  int _hariTersewa = 0;
  int _jumlahTrip = 0;
  
  Map<int, double> _monthlyData = {};
  List<int> _last6Months = [];

  @override
  void initState() {
    super.initState();
    _initMonths();
    _fetchLaporan();
  }

  void _initMonths() {
    int currentMonth = DateTime.now().month;
    for (int i = 5; i >= 0; i--) {
      int m = currentMonth - i;
      if (m <= 0) m += 12; 
      _last6Months.add(m);
      _monthlyData[m] = 0.0;
    }
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getOwnerBookings();

    if (result['success'] == true) {
      final semuaPesanan = result['data'] as List<dynamic>;
      final transaksiSelesai = semuaPesanan.where((p) => p['status'] == 'completed' || p['status'] == 'paid').toList();

      int hitungBulanIni = 0;
      int hitungHari = 0;
      int hitungTrip = 0;
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      for (var p in transaksiSelesai) {
        int harga = (int.tryParse(p['total_harga'].toString()) ?? 0);
        
        try {
          DateTime start = DateTime.parse(p['tanggal_mulai'].toString());
          DateTime end = DateTime.parse(p['tanggal_selesai'].toString());
          int durasi = end.difference(start).inDays;
          if (durasi <= 0) durasi = 1;

          if (_monthlyData.containsKey(start.month)) {
            _monthlyData[start.month] = (_monthlyData[start.month] ?? 0.0) + harga.toDouble();
          }

          if (start.month == currentMonth && start.year == currentYear) {
            hitungBulanIni += harga;
            hitungHari += durasi;
            hitungTrip += 1;
          }
        } catch (_) {}
      }

      setState(() {
        _riwayatTransaksi = transaksiSelesai;
        _totalPendapatanBulanIni = hitungBulanIni;
        _hariTersewa = hitungHari;
        _jumlahTrip = hitungTrip;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(int angka) {
    return angka.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.');
  }

  String _formatShort(int angka) {
    if (angka >= 1000000) return '${(angka / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    if (angka >= 1000) return '${(angka / 1000).toStringAsFixed(0)}rb';
    return angka.toString();
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    int biayaOperasional = (_totalPendapatanBulanIni * 0.2).toInt();
    int labaBersih = _totalPendapatanBulanIni - biayaOperasional;
    int utilisasi = _hariTersewa > 0 ? ((_hariTersewa / 30) * 100).clamp(0, 100).toInt() : 0;
    int rataTarif = _hariTersewa > 0 ? (_totalPendapatanBulanIni ~/ _hariTersewa) : 0;
    int rataDurasi = _jumlahTrip > 0 ? (_hariTersewa ~/ _jumlahTrip) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      // 👇 APPBAR SUDAH DIHAPUS DARI SINI AGAR TIDAK DOUBLE 👇
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PENDAPATAN BULAN INI', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('Rp ${_formatRupiah(_totalPendapatanBulanIni)}', style: const TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(6)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.trending_up, color: Colors.teal[700], size: 14),
                                    const SizedBox(width: 4),
                                    Text('+12% vs bulan lalu', style: TextStyle(color: Colors.teal[700], fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: _buildSubCard('Biaya Operasional', 'Rp ${_formatRupiah(biayaOperasional)}', Colors.red[700]!)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildSubCard('Laba Bersih', 'Rp ${_formatRupiah(labaBersih)}', Colors.teal[700]!)),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text('Ringkasan Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildGridBox('Hari Tersewa', '$_hariTersewa', 'hari', 'dari 30 hari', Colors.black87)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGridBox('Utilisasi', '$utilisasi', '%', 'target 80%', Colors.teal[700]!)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildGridBox('Jumlah Sewa', '$_jumlahTrip', 'trip', 'rata-rata $rataDurasi hari/trip', Colors.black87)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGridBox('Tarif Rata-rata', 'Rp ${_formatShort(rataTarif)}', '', 'per hari', Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text('Pendapatan 6 Bulan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.only(top: 30, bottom: 10, right: 10, left: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              // 👇 PERBAIKAN ANTI-NaN: Pastikan outputnya selalu double
                              maxY: _totalPendapatanBulanIni > 0 ? (_totalPendapatanBulanIni * 1.5).toDouble() : 1000000.0,
                              minY: 0.0,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      if (value.isNaN) return const SizedBox();
                                      int idx = value.toInt();
                                      if (idx >= 0 && idx < _last6Months.length) {
                                        bool isCurrent = idx == 5;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _getMonthName(_last6Months[idx]),
                                            style: TextStyle(
                                              color: isCurrent ? Colors.black87 : Colors.grey[500],
                                              fontSize: 11,
                                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(6, (index) {
                                int month = _last6Months[index];
                                double val = _monthlyData[month] ?? 0.0;
                                Color barColor = (index == 5) ? Colors.teal[800]! : Colors.teal[200]!;
                                return _makeBarGroup(index, val, barColor);
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text('Transaksi Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: _riwayatTransaksi.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(30),
                                  child: Center(child: Text('Belum ada transaksi.', style: TextStyle(color: Colors.grey))),
                                )
                              : Column(
                                  children: _riwayatTransaksi.take(5).map((trx) => _buildTransactionItem(trx)).toList(),
                                ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubCard(String title, String amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(color: amountColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGridBox(String title, String mainValue, String suffix, String sub, Color valColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(mainValue, style: TextStyle(color: valColor, fontSize: 24, fontWeight: FontWeight.bold)),
              if (suffix.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(suffix, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ]
            ],
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: Colors.black54, fontSize: 11)),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.isNaN ? 0.0 : y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> trx) {
    int harga = int.tryParse(trx['total_harga'].toString()) ?? 0;
    String dateStr = trx['tanggal_mulai'] ?? '';
    String tglTampil = dateStr;
    try {
      DateTime dt = DateTime.parse(dateStr);
      tglTampil = '${dt.day} ${_getMonthName(dt.month)}';
    } catch (_) {}

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.vpn_key_rounded, color: Colors.teal[600], size: 20),
          ),
          title: Text(trx['nama_penyewa'] ?? 'Penyewa', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text('$tglTampil • Mobil: ${trx['nama_mobil'] ?? '-'}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          trailing: Text('+${_formatShort(harga)}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const Divider(height: 1, indent: 60, endIndent: 10, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}