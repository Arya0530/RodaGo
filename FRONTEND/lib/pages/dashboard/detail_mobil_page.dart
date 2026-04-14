import 'package:flutter/material.dart';

class DetailMobilPage extends StatelessWidget {
  final String namaMobil;

  DetailMobilPage({required this.namaMobil});

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
              child: Icon(Icons.directions_car, size: 100, color: Colors.grey[400]),
            ),
            SizedBox(height: 24),

            // NAMA & HARGA
            Text(namaMobil, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            Text("Rp 1.500.000 / hari", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
            SizedBox(height: 24),

            // SPESIFIKASI
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                _buildSpecItem(Icons.event_seat, "4 Kursi"),
                _buildSpecItem(Icons.settings, "Otomatis"),
                _buildSpecItem(Icons.local_gas_station, "BBM Full"), // Teks bensin lebih pendek
                _buildSpecItem(Icons.bolt, "Hybrid"), // Pengganti AC, pake icon petir/listrik
              ],
            ),
            SizedBox(height: 32),

            // DESKRIPSI
            Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 12),
            Text(
                "Mobil $namaMobil ini merupakan varian mesin Hybrid yang sangat irit bahan bakar. "
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
              // ALURNYA KITA UBAH! Sekarang buka Form Tanggal dulu, bukan langsung sukses 👇
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

  // 1. FORM PILIH JADWAL (MUNCUL DARI BAWAH)
 // 1. FORM PILIH JADWAL (DENGAN FITUR KALENDER / DATE PICKER)
  void _tampilkanFormJadwal(BuildContext context) {
    // Bikin variabel buat nyimpen tanggal yang dipilih
    DateTime? tanggalAmbil;
    DateTime? tanggalKembali;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        // Pake StatefulBuilder biar formnya bisa ngerubah teks pas kalender diklik
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Atur Jadwal Sewa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 24),
                  
                  // INPUT TANGGAL AMBIL (KALENDER) 👇
                  TextField(
                    readOnly: true, // Biar keyboard nggak muncul pas diklik
                    onTap: () async {
                      // Munculin Kalender Bawaan Flutter
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(), // Nggak bisa pilih tanggal kemarin
                        lastDate: DateTime(2030),
                      );
                      
                      // Kalau user milih tanggal, simpen datanya
                      if (pickedDate != null) {
                        setState(() {
                          tanggalAmbil = pickedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Tanggal Ambil",
                      // Ngecek kalau udah milih tanggal, tampilin. Kalau belum, tampilin hint.
                      hintText: tanggalAmbil != null 
                          ? "${tanggalAmbil!.day}/${tanggalAmbil!.month}/${tanggalAmbil!.year}" 
                          : "Pilih Tanggal di Kalender",
                      hintStyle: TextStyle(color: tanggalAmbil != null ? Colors.black87 : Colors.grey[400], fontWeight: tanggalAmbil != null ? FontWeight.bold : FontWeight.normal),
                      prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),

                  // INPUT TANGGAL KEMBALI (KALENDER) 👇
                  TextField(
                    readOnly: true, 
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: tanggalAmbil ?? DateTime.now(), // Mulainya dari tanggal ambil
                        firstDate: tanggalAmbil ?? DateTime.now(), // Nggak bisa balikin sebelum tanggal ambil
                        lastDate: DateTime(2030),
                      );
                      
                      if (pickedDate != null) {
                        setState(() {
                          tanggalKembali = pickedDate;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Tanggal Kembali",
                      hintText: tanggalKembali != null 
                          ? "${tanggalKembali!.day}/${tanggalKembali!.month}/${tanggalKembali!.year}" 
                          : "Pilih Tanggal di Kalender",
                      hintStyle: TextStyle(color: tanggalKembali != null ? Colors.black87 : Colors.grey[400], fontWeight: tanggalKembali != null ? FontWeight.bold : FontWeight.normal),
                      prefixIcon: Icon(Icons.event_available, color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Tombol Konfirmasi Bayar
                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      // Validasi: Tombol baru bisa diklik kalau kedua tanggal udah diisi
                      onPressed: (tanggalAmbil != null && tanggalKembali != null) ? () {
                        Navigator.pop(context); // Tutup Form
                        _tampilkanPopupBerhasil(context); // Buka Popup
                      } : null,
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
      builder: (BuildContext context) {
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
                    Navigator.pop(context); // Tutup Popup
                    Navigator.pop(context); // Balik ke Beranda
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
}