// LOKASI: lib/pages/pesanan/e_receipt_page.dart

import 'package:flutter/material.dart';

class EReceiptPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const EReceiptPage({Key? key, required this.booking}) : super(key: key);

  String _formatTanggal(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      const bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatHarga(dynamic angka) {
    try {
      final num = int.parse(angka.toString());
      final str = num.toString();
      String result = '';
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) result = '.$result';
        result = str[i] + result;
        count++;
      }
      return 'Rp $result';
    } catch (_) {
      return 'Rp $angka';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = booking['id']?.toString() ?? '0000';
    final namaMobil = booking['nama_mobil'] ?? 'Kendaraan';
    final tanggalMulai = _formatTanggal(booking['tanggal_mulai']);
    final tanggalSelesai = _formatTanggal(booking['tanggal_selesai']);
    final totalHarga = _formatHarga(booking['total_harga']);

    int durasi = 1;
    try {
      final start = DateTime.parse(booking['tanggal_mulai']);
      final end = DateTime.parse(booking['tanggal_selesai']);
      durasi = end.difference(start).inDays;
      if (durasi <= 0) durasi = 1;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // 1. BACKGROUND HIJAU (Ukurannya dikecilin jadi 200)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Text('E-Receipt', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Membagikan tiket...')));
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Logo RodaGo dikecilin dikit
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.teal[900]!.withOpacity(0.5), blurRadius: 10)],
                            ),
                            child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 8),
                          const Text('RodaGo', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                  ),

                  // 2. KARTU TIKET
                  SafeArea(
                    child: Padding(
                      // Jarak atas (top) dipangkas biar gak kepanjangan
                      padding: const EdgeInsets.only(top: 140, left: 20, right: 20, bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: [
                            // --- DETAIL TRANSAKSI ---
                            Padding(
                              padding: const EdgeInsets.all(20), // Padding dalam dikecilin
                              child: Column(
                                children: [
                                  _buildInfoRow('Booking ID', '#HR2026${bookingId.padLeft(5, '0')}', valueColor: Colors.teal, isBold: true),
                                  _buildInfoRow('Tanggal', tanggalMulai, isBold: true),
                                  _buildInfoRow('Waktu', '10:00 AM', isBold: true),
                                  _buildInfoRow('Metode Bayar', 'Virtual Account', isBold: true),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Kendaraan', '$namaMobil\n$durasi Hari', valueAlign: TextAlign.right, isBold: true, subText: true),
                                  const SizedBox(height: 8),
                                  _buildInfoRow('Ambil', '$tanggalMulai • 10:00 AM', isBold: true),
                                  _buildInfoRow('Kembali', '$tanggalSelesai • 10:00 AM', isBold: true),
                                  _buildInfoRow('Lokasi', '📍 RodaGo Hub', isBold: true, valueColor: Colors.teal),
                                ],
                              ),
                            ),

                            // --- EFEK POTONGAN TIKET & GARIS PUTUS-PUTUS ---
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const _DashedLine(),
                                Positioned(left: -15, child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFF4F7F6), shape: BoxShape.circle))),
                                Positioned(right: -15, child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFFF4F7F6), shape: BoxShape.circle))),
                              ],
                            ),

                            // --- TOTAL & BARCODE ---
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sewa Kendaraan ($durasi Hari)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      Text(totalHarga, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Box Total Dibayar Hijau
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Dibayar', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                        Text(totalHarga, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Barcode
                                  Container(
                                    height: 45, // Barcode dipendekin
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(45, (index) {
                                        double w = (index % 3 == 0) ? 3.0 : ((index % 5 == 0) ? 1.0 : 2.0);
                                        return Container(width: w, color: Colors.black87);
                                      }),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('MR2025012567${bookingId.padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                                  const SizedBox(height: 12),
                                  
                                  // Badge Terverifikasi
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.teal), borderRadius: BorderRadius.circular(20)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.check, color: Colors.teal, size: 14),
                                        SizedBox(width: 4),
                                        Text('Pembayaran Terverifikasi', style: TextStyle(color: Colors.teal, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 3. TOMBOL DOWNLOAD (Dipindah ke luar Stack biar aman di bawah)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F7F6),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-Receipt berhasil diunduh!')));
                },
                icon: const Icon(Icons.download, color: Colors.white, size: 20),
                label: const Text('Unduh E-Receipt', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Jarak bawah (_buildInfoRow) dikurangin dari 16 jadi 10
  Widget _buildInfoRow(String title, String value, {Color? valueColor, bool isBold = false, TextAlign valueAlign = TextAlign.right, bool subText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12))),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: valueAlign,
              style: TextStyle(
                color: valueColor ?? (subText ? Colors.grey[600] : Colors.black87),
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth, height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
            );
          }),
        );
      },
    );
  }
}