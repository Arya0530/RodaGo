// LOKASI: lib/pages/mobil/detail_mobil_page.dart
//
// PERUBAHAN DARI VERSI LAMA:
//   - Tombol "Pesan Sekarang" sekarang mengecek status KYC user dulu
//   - Jika belum verified → tampilkan dialog peringatan + tombol ke KycPage
//   - Jika sudah verified → lanjut ke form jadwal seperti biasa
//   - Semua logika lain (tampilan, form jadwal, popup berhasil) TIDAK BERUBAH

import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../pesanan/pesanan_page.dart';
import '../dashboard/main_layout.dart';
import '../profil/kyc_page.dart';
import '../../service/user_session.dart';

class DetailMobilPage extends StatelessWidget {
  final String namaMobil;
  final dynamic carData;

  DetailMobilPage({required this.namaMobil, this.carData});

@override
  Widget build(BuildContext context) {
    // --- TAMBAHIN 5 BARIS INI ---
    bool isOwner = false;
    if (carData != null && carData['user_id'] != null) {
      isOwner = carData['user_id'].toString() == UserSession.id.toString(); 
    }
    // ----------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Mobil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR MOBIL
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20)),
              child: carData != null &&
                      carData['gambar'] != null &&
                      carData['gambar'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        carData['gambar'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.directions_car,
                              size: 100, color: Colors.grey[400]);
                        },
                      ),
                    )
                  : Icon(Icons.directions_car,
                      size: 100, color: Colors.grey[400]),
            ),
            SizedBox(height: 24),

            // NAMA & HARGA
            Text(
              carData != null ? (carData['nama'] ?? namaMobil) : namaMobil,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 8),
            Text(
              carData != null
                  ? 'Rp ${_formatCurrency(carData['harga'] ?? 0)} / hari'
                  : 'Rp 1.500.000 / hari',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 24),

            // SPESIFIKASI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem(Icons.event_seat,
                    carData != null ? '${carData['kursi'] ?? 4} Kursi' : '4 Kursi'),
                _buildSpecItem(Icons.settings,
                    carData != null ? (carData['transmisi'] ?? 'Otomatis') : 'Otomatis'),
                _buildSpecItem(Icons.local_gas_station,
                    carData != null ? (carData['bahan_bakar'] ?? 'BBM Full') : 'BBM Full'),
                _buildSpecItem(Icons.bolt,
                    carData != null ? (carData['fitur'] ?? 'Hybrid') : 'Hybrid'),
              ],
            ),
            SizedBox(height: 32),

            // DESKRIPSI
            Text(
              'Deskripsi',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 12),
            Text(
              carData != null && carData['deskripsi'] != null
                  ? carData['deskripsi']
                  : 'Mobil $namaMobil ini merupakan varian mesin Hybrid yang sangat irit bahan bakar. '
                      'Cocok untuk perjalanan jauh tanpa pusing biaya bensin. Kondisi mesin prima dan siap pakai.',
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),

      // TOMBOL PESAN DI BAWAH
      bottomSheet: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -5))
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
  if (isOwner) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda tidak dapat menyewa mobil milik sendiri'),
      ),
    );
    return;
  }

  _cekKycLaluPesan(context);
},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              'Pesan Sekarang',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CEK STATUS KYC SEBELUM BUKA FORM PESAN
  //
  // Alur:
  //   1. Tampilkan loading sebentar
  //   2. Panggil API /api/kyc/status
  //   3. Jika verified → buka form jadwal
  //   4. Jika tidak → tampilkan dialog peringatan
  // ══════════════════════════════════════════════════════════════
  Future<void> _cekKycLaluPesan(BuildContext pageContext) async {
    // Tampilkan loading sementara
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      ),
    );

    final result = await ApiService.getKycStatus();

    // Tutup loading
    if (pageContext.mounted) Navigator.of(pageContext, rootNavigator: true).pop();
    if (!pageContext.mounted) return;

    final status = result['success'] == true
        ? (result['data']['status'] ?? 'unverified')
        : 'unverified';

    if (status == 'verified') {
      // KYC sudah verified → lanjut ke form jadwal
      _tampilkanFormJadwal(pageContext);
    } else {
      // Belum verified → tampilkan dialog peringatan
      _tampilkanDialogKyc(pageContext, status);
    }
  }

  // ── Dialog peringatan KYC belum selesai ─────────────────────────
  void _tampilkanDialogKyc(BuildContext pageContext, String status) {
    // Tentukan pesan sesuai status
    String judul;
    String pesan;
    String tombolAksi;
    IconData icon;
    Color   iconColor;

    switch (status) {
      case 'pending':
        judul      = 'Verifikasi Sedang Diproses';
        pesan      = 'Dokumen KTP dan SIM Anda sedang ditinjau oleh tim kami.\n\nBiasanya selesai dalam 1×24 jam. Silakan coba lagi setelah verifikasi selesai.';
        tombolAksi = 'Lihat Status';
        icon       = Icons.hourglass_top_rounded;
        iconColor  = Colors.orange;
        break;
      case 'rejected':
        judul      = 'Dokumen Ditolak';
        pesan      = 'Dokumen Anda sebelumnya ditolak.\n\nSilakan upload ulang KTP dan SIM yang sesuai agar bisa melanjutkan pemesanan.';
        tombolAksi = 'Upload Ulang';
        icon       = Icons.cancel_outlined;
        iconColor  = Colors.red;
        break;
      default: // unverified
        judul      = 'Verifikasi Akun Diperlukan';
        pesan      = 'Untuk menyewa mobil, Anda perlu memverifikasi identitas terlebih dahulu.\n\nSilakan upload KTP dan SIM Anda di halaman Verifikasi KYC.';
        tombolAksi = 'Verifikasi Sekarang';
        icon       = Icons.security;
        iconColor  = Colors.teal;
    }

    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 44),
            ),
            SizedBox(height: 16),
            Text(
              judul,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              pesan,
              style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Tombol ke KycPage (hanya untuk unverified & rejected)
            if (status != 'pending')
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.push(
                      pageContext,
                      MaterialPageRoute(builder: (_) => KycPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    tombolAksi,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form jadwal sewa dengan disable tanggal yang sudah dibooking ──────────
  void _tampilkanFormJadwal(BuildContext pageContext) async {
    // Ambil daftar tanggal yang sudah dibooking untuk mobil ini
    final bookedDates = await ApiService.getBookedDates(carData['id']);
    
    // Debug: Print raw data dari API
    print('=== DEBUG BOOKED DATES ===');
    print('Mobil ID: ${carData['id']}');
    print('Mobil Nama: ${carData['nama']}');
    print('Total bookings: ${bookedDates.length}');
    
    // Parse booking ranges menjadi set tanggal yang tidak bisa dipilih
    Set<DateTime> disabledDates = {};
    
    try {
      for (var i = 0; i < bookedDates.length; i++) {
        var booking = bookedDates[i];
        print('\nBooking #${i + 1}:');
        print('  Raw start: ${booking['start']}');
        print('  Raw end: ${booking['end']}');
        
        try {
          // Parse tanggal secara manual untuk menghindari timezone issue
          final startStr = booking['start'].toString().trim();
          final endStr = booking['end'].toString().trim();
          
          // Skip jika string kosong atau null
          if (startStr.isEmpty || endStr.isEmpty) continue;
          
          // Parse dengan berbagai cara (fallback)
          DateTime? start;
          DateTime? end;
          
          // Cara 1: Manual split (YYYY-MM-DD)
          if (startStr.contains('-')) {
            final startParts = startStr.split('-');
            if (startParts.length >= 3) {
              start = DateTime(
                int.parse(startParts[0]), 
                int.parse(startParts[1]), 
                int.parse(startParts[2].split(' ')[0]) // Ambil hanya tanggal, buang jam jika ada
              );
            }
          }
          
          if (endStr.contains('-')) {
            final endParts = endStr.split('-');
            if (endParts.length >= 3) {
              end = DateTime(
                int.parse(endParts[0]), 
                int.parse(endParts[1]), 
                int.parse(endParts[2].split(' ')[0]) // Ambil hanya tanggal, buang jam jika ada
              );
            }
          }
          
          // Cara 2: Fallback ke DateTime.parse jika cara 1 gagal
          if (start == null) {
            final parsed = DateTime.parse(startStr);
            start = DateTime(parsed.year, parsed.month, parsed.day);
          }
          if (end == null) {
            final parsed = DateTime.parse(endStr);
            end = DateTime(parsed.year, parsed.month, parsed.day);
          }
          
          // Tambahkan semua tanggal dalam rentang booking
          if (start != null && end != null) {
            for (var date = start; date.isBefore(end.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
              disabledDates.add(DateTime(date.year, date.month, date.day));
            }
          }
        } catch (e) {
          // Skip booking yang error parsing
          print('Error parsing booking date: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error processing booked dates: $e');
      // Jika ada error, tampilkan dialog peringatan tapi tetap lanjut
      if (pageContext.mounted) {
        ScaffoldMessenger.of(pageContext).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat memuat data booking. Silakan coba lagi.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    final ambilController   = TextEditingController();
    final kembaliController = TextEditingController();
    DateTime? tanggalAmbil;
    DateTime? tanggalKembali;

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext sheetContext, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                  left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atur Jadwal Sewa',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tanggal yang sudah dibooking tidak dapat dipilih',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Input tanggal ambil
                  TextField(
                    controller: ambilController,
                    readOnly: true,
                    onTap: () async {
                      // Normalisasi tanggal hari ini (set jam ke 00:00:00)
                      final today = DateTime.now();
                      final normalizedToday = DateTime(today.year, today.month, today.day);
                      
                      // Cari tanggal pertama yang available (tidak disabled)
                      DateTime firstAvailableDate = normalizedToday;
                      while (disabledDates.contains(firstAvailableDate)) {
                        firstAvailableDate = firstAvailableDate.add(Duration(days: 1));
                        // Safety: jangan loop lebih dari 1 tahun
                        if (firstAvailableDate.difference(normalizedToday).inDays > 365) {
                          firstAvailableDate = normalizedToday.add(Duration(days: 365));
                          break;
                        }
                      }
                      
                      // Debug: Print untuk troubleshoot
                      print('\n=== DATE PICKER OPENED ===');
                      print('Today: ${normalizedToday.year}-${normalizedToday.month}-${normalizedToday.day}');
                      print('Total disabled dates: ${disabledDates.length}');
                      print('Is today disabled? ${disabledDates.contains(normalizedToday)}');
                      print('First available date: ${firstAvailableDate.year}-${firstAvailableDate.month}-${firstAvailableDate.day}');
                      
                      DateTime? pickedDate = await showDatePicker(
                        context: sheetContext,
                        initialDate: firstAvailableDate,  // Mulai dari tanggal yang available
                        firstDate: normalizedToday,        // Minimum tetap hari ini
                        lastDate: DateTime(2030),
                        selectableDayPredicate: (DateTime date) {
                          // Normalisasi tanggal yang dicek
                          final normalizedDate = DateTime(date.year, date.month, date.day);
                          
                          // Debug: Print setiap pengecekan (hanya untuk 10 hari pertama)
                          final daysDiff = normalizedDate.difference(normalizedToday).inDays;
                          if (daysDiff < 10) {
                            final isDisabled = disabledDates.contains(normalizedDate);
                            print('  Day +$daysDiff (${normalizedDate.month}/${normalizedDate.day}): ${isDisabled ? "DISABLED" : "AVAILABLE"}');
                          }
                          
                          // Return true jika tanggal DAPAT dipilih (tidak ada di disabledDates)
                          return !disabledDates.contains(normalizedDate);
                        },
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.teal,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          tanggalAmbil       = pickedDate;
                          ambilController.text =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          // Reset tanggal kembali jika sudah diisi
                          tanggalKembali = null;
                          kembaliController.clear();
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tanggal Ambil',
                      prefixIcon:
                          Icon(Icons.calendar_today, color: Colors.teal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Input tanggal kembali
                  TextField(
                    controller: kembaliController,
                    readOnly: true,
                    onTap: () async {
                      if (tanggalAmbil == null) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          SnackBar(
                            content: Text('Pilih tanggal ambil terlebih dahulu'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Normalisasi tanggal ambil
                      final normalizedTanggalAmbil = DateTime(
                        tanggalAmbil!.year, 
                        tanggalAmbil!.month, 
                        tanggalAmbil!.day
                      );
                      final firstSelectableDate = normalizedTanggalAmbil.add(Duration(days: 1));

                      DateTime? pickedDate = await showDatePicker(
                        context: sheetContext,
                        initialDate: firstSelectableDate,
                        firstDate: firstSelectableDate,
                        lastDate: DateTime(2030),
                        selectableDayPredicate: (DateTime date) {
                          // Normalisasi tanggal yang dicek
                          final normalizedDate = DateTime(date.year, date.month, date.day);
                          
                          // Jika tanggal ini sudah dibooking, tidak bisa dipilih
                          if (disabledDates.contains(normalizedDate)) return false;
                          
                          // Cek apakah ada booking yang menghalangi rentang dari tanggalAmbil ke date ini
                          // Loop dari hari setelah tanggal ambil sampai tanggal yang dicek
                          for (var checkDate = normalizedTanggalAmbil.add(Duration(days: 1)); 
                               checkDate.isBefore(normalizedDate); 
                               checkDate = checkDate.add(Duration(days: 1))) {
                            final normalized = DateTime(checkDate.year, checkDate.month, checkDate.day);
                            if (disabledDates.contains(normalized)) return false;
                          }
                          return true;
                        },
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.teal,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          tanggalKembali       = pickedDate;
                          kembaliController.text =
                              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Tanggal Kembali',
                      prefixIcon:
                          Icon(Icons.event_available, color: Colors.teal),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      enabled: tanggalAmbil != null,
                    ),
                  ),
                  SizedBox(height: 32),

                  // Tombol Konfirmasi & Bayar
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (tanggalAmbil != null && tanggalKembali != null)
                          ? () async {
                              final mulai =
                                  '${tanggalAmbil!.year}-${tanggalAmbil!.month.toString().padLeft(2, '0')}-${tanggalAmbil!.day.toString().padLeft(2, '0')}';
                              final selesai =
                                  '${tanggalKembali!.year}-${tanggalKembali!.month.toString().padLeft(2, '0')}-${tanggalKembali!.day.toString().padLeft(2, '0')}';

                              final result = await ApiService.createBooking(
                                mobilId: carData['id'],
                                tanggalMulai: mulai,
                                tanggalSelesai: selesai,
                              );

                              if (result['success']) {
                                Navigator.pop(sheetContext);
                                _tampilkanPopupBerhasil(pageContext);
                              } else {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(
                                      content: Text(result['message'])),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        'Konfirmasi & Bayar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (tanggalAmbil != null && tanggalKembali != null)
                              ? Colors.white
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Popup pemesanan berhasil (tidak berubah) ─────────────────────
  void _tampilkanPopupBerhasil(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.teal, size: 80),
              SizedBox(height: 16),
              Text(
                'Pemesanan Berhasil!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              SizedBox(height: 8),
              Text(
                'Jadwal sewa $namaMobil Anda telah dikonfirmasi. Silakan cek menu Pesanan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.4),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true)
                        .pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => MainLayout(initialIndex: 1)),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Lihat Pesanan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.teal),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    int harga = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return harga
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.');
  }
}