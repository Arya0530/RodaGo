import 'package:flutter/material.dart';
import 'instruksi_pembayaran_page.dart';

class ProsesPembayaranPage extends StatefulWidget {
  final String namaMobil;
  final String totalHarga;
  final int bookingId; // ✅ TAMBAHAN

  ProsesPembayaranPage({
    required this.namaMobil,
    required this.totalHarga,
    required this.bookingId, // ✅ TAMBAHAN
  });

  @override
  _ProsesPembayaranPageState createState() => _ProsesPembayaranPageState();
}

class _ProsesPembayaranPageState extends State<ProsesPembayaranPage> {
  String _metodeTerpilih = "BCA Virtual Account";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text("Pilih Pembayaran",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Tagihan", style: TextStyle(color: Colors.grey[600])),
                Text(widget.totalHarga,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
          ),
          SizedBox(height: 32),
          Text("Transfer Virtual Account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 16),
          _buildMetodeBayar("BCA Virtual Account", Icons.account_balance),
          _buildMetodeBayar("Mandiri Virtual Account", Icons.account_balance),
          _buildMetodeBayar("BNI Virtual Account", Icons.account_balance),
          SizedBox(height: 24),
          Text("E-Wallet",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 16),
          _buildMetodeBayar("GoPay", Icons.wallet),
          _buildMetodeBayar("OVO", Icons.wallet),
          _buildMetodeBayar("ShopeePay", Icons.wallet),
          SizedBox(height: 100),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () async {
              bool? lunas = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InstruksiPembayaranPage(
                    metode: _metodeTerpilih,
                    total: widget.totalHarga,
                    bookingId: widget.bookingId, // ✅ TERUSKAN bookingId
                  ),
                ),
              );
              if (lunas == true) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: Text("Lanjutkan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildMetodeBayar(String nama, IconData icon) {
    bool isSelected = _metodeTerpilih == nama;
    return GestureDetector(
      onTap: () => setState(() => _metodeTerpilih = nama),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? Colors.teal : Colors.grey[200]!,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.teal : Colors.grey[400]),
            SizedBox(width: 16),
            Text(nama, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: Colors.teal),
          ],
        ),
      ),
    );
  }
}