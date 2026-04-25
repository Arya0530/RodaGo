import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../pesanan/pesanan_page.dart';
import '../dashboard/main_layout.dart';


class DetailMobilPage extends StatelessWidget {
  final String namaMobil;
  final dynamic carData;

  DetailMobilPage({required this.namaMobil, this.carData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Detail Mobil", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GAMBAR MOBIL
            Container(
              width: double.infinity, height: 220,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: carData != null && carData['gambar'] != null && carData['gambar'].toString().isNotEmpty
                  ? Image.network(
                      carData['gambar'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.directions_car, size: 100, color: Colors.grey[400]);
                      },
                    )
                  : Icon(Icons.directions_car, size: 100, color: Colors.grey[400]),
            ),
            SizedBox(height: 24),

            // NAMA & HARGA
            Text(
              carData != null ? (carData['nama'] ?? namaMobil) : namaMobil,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
            SizedBox(height: 8),
            Text(
              carData != null ? 'Rp ${_formatCurrency(carData['harga'] ?? 0)} / hari' : 'Rp 1.500.000 / hari',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)
            ),
            SizedBox(height: 24),

            // SPESIFIKASI
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                _buildSpecItem(Icons.event_seat, carData != null ? '${carData['kursi'] ?? 4} Kursi' : "4 Kursi"),
                _buildSpecItem(Icons.settings, carData != null ? (carData['transmisi'] ?? 'Otomatis') : "Otomatis"),
                _buildSpecItem(Icons.local_gas_station, carData != null ? (carData['bahan_bakar'] ?? 'BBM Full') : "BBM Full"),
                _buildSpecItem(Icons.bolt, carData != null ? (carData['fitur'] ?? 'Hybrid') : "Hybrid"),
              ],
            ),
            SizedBox(height: 32),

            // DESKRIPSI
            Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 12),
            Text(
                carData != null && carData['deskripsi'] != null
                    ? carData['deskripsi']
                    : "Mobil $namaMobil ini merupakan varian mesin Hybrid yang sangat irit bahan bakar. "
                      "Cocok untuk perjalanan jauh tanpa pusing biaya bensin. Kondisi mesin prima dan siap pakai.",
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
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            onPressed: () {
              _tampilkanFormJadwal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text("Pesan Sekarang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.teal),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _tampilkanFormJadwal(BuildContext pageContext) { // ✅ terima pageContext dari build()
    final ambilController = TextEditingController();
    final kembaliController = TextEditingController();

    DateTime? tanggalAmbil;
    DateTime? tanggalKembali;

    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext sheetContext) { // ✅ context bottomsheet diberi nama berbeda
        return StatefulBuilder(
          builder: (BuildContext sheetContext, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Atur Jadwal Sewa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 24),
                  
                  // INPUT TANGGAL AMBIL (KALENDER)
                  TextField(
                    controller: ambilController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: sheetContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          tanggalAmbil = pickedDate;
                          ambilController.text =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Tanggal Ambil",
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),

                  // INPUT TANGGAL KEMBALI (KALENDER)
                  TextField(
  controller: kembaliController,
  readOnly: true,
  onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: sheetContext,
      initialDate: tanggalAmbil ?? DateTime.now(),
      firstDate: tanggalAmbil ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        tanggalKembali = pickedDate;
        kembaliController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  },
  decoration: InputDecoration(
    labelText: "Tanggal Kembali",
    prefixIcon: Icon(Icons.event_available, color: Colors.teal),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    filled: true,
    fillColor: Colors.grey[50],
  ),
),
                  SizedBox(height: 32),

                  // Tombol Konfirmasi Bayar
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: (tanggalAmbil != null && tanggalKembali != null)
                          ? () async {
                              final mulai =
                                  "${tanggalAmbil!.year}-${tanggalAmbil!.month.toString().padLeft(2,'0')}-${tanggalAmbil!.day.toString().padLeft(2,'0')}";
                              final selesai =
                                  "${tanggalKembali!.year}-${tanggalKembali!.month.toString().padLeft(2,'0')}-${tanggalKembali!.day.toString().padLeft(2,'0')}";

                              final result = await ApiService.createBooking(
                                mobilId: carData['id'],
                                tanggalMulai: mulai,
                                tanggalSelesai: selesai,
                              );

                              if (result['success']) {
                                Navigator.pop(sheetContext); // ✅ tutup bottomsheet pakai sheetContext
                                _tampilkanPopupBerhasil(pageContext); // ✅ tampilkan popup pakai pageContext halaman asli
                              } else {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(content: Text(result['message'])),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        "Konfirmasi & Bayar", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: (tanggalAmbil != null && tanggalKembali != null) ? Colors.white : Colors.grey[500])
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // 2. POP-UP BERHASIL
  void _tampilkanPopupBerhasil(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) { // ✅ context dialog diberi nama berbeda
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.teal, size: 80),
              SizedBox(height: 16),
              Text("Pemesanan Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 8),
              Text("Jadwal sewa $namaMobil Anda telah dikonfirmasi. Silakan cek menu Pesanan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], height: 1.4)),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    // ✅ Pakai dialogContext (context milik AlertDialog) untuk navigasi
                    Navigator.of(dialogContext, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => MainLayout(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Lihat Pesanan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  String _formatCurrency(dynamic value) {
    int harga = value is int ? value : int.tryParse(value.toString()) ?? 0;
    return harga.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (Match m) => '.');
  }
}