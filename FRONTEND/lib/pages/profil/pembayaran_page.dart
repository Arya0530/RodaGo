import 'package:flutter/material.dart';

class PembayaranPage extends StatelessWidget {
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
        title: Text("Metode Pembayaran", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          Text("Transfer Bank (Virtual Account)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 12),
          _buildPaymentOption(Icons.account_balance, "BCA Virtual Account", "Dicek otomatis"),
          _buildPaymentOption(Icons.account_balance, "Mandiri Virtual Account", "Dicek otomatis"),
          _buildPaymentOption(Icons.account_balance, "BNI Virtual Account", "Dicek otomatis"),
          
          SizedBox(height: 32),
          
          Text("E-Wallet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 12),
          _buildPaymentOption(Icons.wallet, "GoPay", "Gratis biaya admin"),
          _buildPaymentOption(Icons.wallet, "OVO", "Gratis biaya admin"),
          _buildPaymentOption(Icons.wallet, "ShopeePay", "Gratis biaya admin"),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.teal),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.grey[300]), // Pura-puranya tombol pilih
        ],
      ),
    );
  }
}