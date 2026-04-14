import 'package:flutter/material.dart';

class PesananPage extends StatefulWidget {
  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  // BIKIN DATA DUMMY BIAR BISA DIUBAH-UBAH STATUSNYA
  List<Map<String, dynamic>> _daftarPesanan = [
    {
      "mobil": "Toyota Camry Hybrid",
      "tanggal": "15 Apr - 18 Apr 2026",
      "harga": "Rp 4.500.000",
      "status": "pending", // Nunggu di acc owner
    },
    {
      "mobil": "Mitsubishi Xpander",
      "tanggal": "20 Apr - 22 Apr 2026",
      "harga": "Rp 900.000",
      "status": "unpaid", // Udah di acc, tinggal bayar
    },
    {
      "mobil": "Honda Brio",
      "tanggal": "10 Apr - 12 Apr 2026",
      "harga": "Rp 600.000",
      "status": "active", // Udah lunas, siap dipake
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text("Pesanan Saya", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: ACTIVE (Kita looping dari data di atas)
            ListView.builder(
              padding: EdgeInsets.all(24),
              itemCount: _daftarPesanan.length,
              itemBuilder: (context, index) {
                var pesanan = _daftarPesanan[index];
                return _buildOrderCard(
                  index: index, // Kirim index biar tau mana yang diklik
                  context: context,
                  mobil: pesanan['mobil'],
                  tanggal: pesanan['tanggal'],
                  harga: pesanan['harga'],
                  status: pesanan['status'],
                );
              },
            ),

            // TAB 2: COMPLETED
            Center(child: Text("Belum ada pesanan selesai", style: TextStyle(color: Colors.grey))),

            // TAB 3: CANCELLED
            Center(child: Text("Belum ada pesanan dibatalkan", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  // FUNGSI DESAIN KOTAK PESANAN
  Widget _buildOrderCard({
    required int index,
    required BuildContext context,
    required String mobil,
    required String tanggal,
    required String harga,
    required String status,
  }) {
    Color statusColor = Colors.grey;
    String statusText = "";
    IconData statusIcon = Icons.info;

    if (status == "pending") {
      statusColor = Colors.orange;
      statusText = "Menunggu Konfirmasi";
      statusIcon = Icons.access_time_filled;
    } else if (status == "unpaid") {
      statusColor = Colors.red;
      statusText = "Belum Dibayar";
      statusIcon = Icons.warning_rounded;
    } else if (status == "active") {
      statusColor = Colors.teal;
      statusText = "Disewa (Lunas)";
      statusIcon = Icons.check_circle;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mobil, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    SizedBox(width: 4),
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              SizedBox(width: 8),
              Text(tanggal, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey[500]),
              SizedBox(width: 8),
              Text(harga, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          
          Divider(height: 24, color: Colors.grey[100], thickness: 2),

          // --- LOGIKA TOMBOL INTERAKTIF ---
          
          if (status == "pending") 
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pesanan dibatalkan."), backgroundColor: Colors.grey));
                },
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.red[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text("Batalkan Pesanan", style: TextStyle(color: Colors.red)),
              ),
            ),
            
          if (status == "unpaid")
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // MANGGIL FUNGSI PURA-PURA BAYAR 👇
                  _prosesPembayaran(index);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),

          if (status == "active")
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _tampilkanTiketQR(context);
                },
                icon: Icon(Icons.qr_code, color: Colors.teal, size: 18),
                label: Text("Lihat Tiket", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.teal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
        ],
      ),
    );
  }

  // FUNGSI ANIMASI PURA-PURA BAYAR (MVP MAGIC ✨)
  void _prosesPembayaran(int index) {
    // 1. Munculin loading muter-muter
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(color: Colors.teal)),
    );

    // 2. Tunggu 2 detik, seolah-olah lagi ngecek saldo Gopay/M-Banking
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Tutup loadingnya
      
      // 3. Ubah status data dari "unpaid" jadi "active"
      setState(() {
        _daftarPesanan[index]['status'] = 'active'; 
      });

      // 4. Munculin notif berhasil!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pembayaran Berhasil! Tiket diterbitkan."), backgroundColor: Colors.teal)
      );
    });
  }

  void _tampilkanTiketQR(BuildContext context) {
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
              ),
              SizedBox(height: 24),
              Text("Booking ID: #RDG-0812", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Tutup", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
          ],
        );
      },
    );
  }
}