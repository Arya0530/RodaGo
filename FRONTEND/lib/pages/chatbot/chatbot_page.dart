import 'package:flutter/material.dart';

class ChatbotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 10),
            Text("RodaGo Assistant", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildBubble(isMe: false, text: "Halo! Saya asisten AI RodaGo. Ada yang bisa saya bantu terkait penyewaan mobil hari ini?"),
                _buildBubble(isMe: true, text: "Syarat lepas kunci apa aja min?"),
                _buildBubble(isMe: false, text: "Sangat mudah! Anda hanya perlu menyiapkan E-KTP asli, SIM A aktif, dan melakukan verifikasi akun (KYC) di halaman Profil. Pembayaran langsung dilakukan di dalam aplikasi."),
              ],
            ),
          ),
          _buildInputChat(),
        ],
      ),
    );
  }

  // Desain Gelembung Chat
  Widget _buildBubble({required bool isMe, required String text}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
          ),
        ),
        child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, height: 1.4)),
      ),
    );
  }

  // Kolom Ketik Pesan
  Widget _buildInputChat() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Ketik pesan...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal,
            child: IconButton(icon: Icon(Icons.send, color: Colors.white, size: 20), onPressed: () {}),
          )
        ],
      ),
    );
  }
}