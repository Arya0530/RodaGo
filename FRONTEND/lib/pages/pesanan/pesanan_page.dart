import 'package:flutter/material.dart';


class PesananPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // DefaultTabController ini yang bikin lu bisa geser-geser tab Active, Completed, Cancelled
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Pesanan Saya", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.teal, // Warna teks tab yang dipilih
            unselectedLabelColor: Colors.grey, // Warna teks tab yang nggak dipilih
            indicatorColor: Colors.teal, // Garis bawah warna hijau
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. ISI TAB ACTIVE (Di sini tempat tombol lacaknya)
            _buildActiveTab(context),
            
            // 2. ISI TAB COMPLETED (Masih kosong dummy dulu)
            Center(child: Text("Belum ada riwayat pesanan selesai", style: TextStyle(color: Colors.grey))),
            
            // 3. ISI TAB CANCELLED (Masih kosong dummy dulu)
            Center(child: Text("Tidak ada pesanan yang dibatalkan", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  // FUNGSI BUAT NAMPILIN KOTAK PESANAN DI TAB "ACTIVE"
  Widget _buildActiveTab(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        // Kotak Card Pesanan
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card (ID Booking & Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Booking #RDG-0812", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Active", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              Divider(height: 24, color: Colors.grey[100]),

              // Isi Data Mobil
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Mobil Bohongan
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(width: 16),
                  
                  // Teks Keterangan Mobil
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Toyota Camry Hybrid", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text("15 Apr - 18 Apr 2026", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text("Surabaya Pusat", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text("Rp 1.500.000", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15)),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),

             // TOMBOL TIKET PENGAMBILAN MOBIL
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // INI KODINGAN BUAT MUNCULIN POP-UP TIKET
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              contentPadding: EdgeInsets.all(24),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Tiket Pengambilan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text("Tunjukkan QR Code ini ke pihak rental", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                  SizedBox(height: 24),
                                  // Gambar QR Code bohongan pakai Icon
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
                                  ),
                                  SizedBox(height: 24),
                                  Text("Booking ID: #RDG-0812", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Tutup", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                )
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.confirmation_number_outlined, color: Colors.teal, size: 18),
                      label: Text("Lihat Tiket", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}