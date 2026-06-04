// LOKASI: lib/pages/chatbot/chatbot_page.dart

import 'package:flutter/material.dart';
import '../../service/api_service.dart'; // WAJIB DI-IMPORT BIAR BISA NEMBAK API

class ChatbotPage extends StatefulWidget {
  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // List ini bakal nyimpen history chat biar dinamis
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // FUNGSI INTI BUAT NGIRIM KE LARAVEL -> FLASK
  void _kirimPesan() async {
    String pesanUser = _textController.text.trim();
    if (pesanUser.isEmpty) return;

    // 1. Munculin pesan user ke layar
    setState(() {
      _messages.add({'isMe': true, 'text': pesanUser});
      _isLoading = true; // Munculin indikator loading
    });
    
    _textController.clear();
    _scrollToBottom();

    // 2. Tembak API
    String balasanBot = await ApiService.sendMessageToAI(pesanUser);

    // 3. Munculin jawaban IndoBERT ke layar
    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add({'isMe': false, 'text': balasanBot});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
          // AREA LIST CHAT DINAMIS
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildBubble(isMe: msg['isMe'], text: msg['text']);
              },
            ),
          ),
          
          // INDIKATOR LOADING AI
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI sedang mengetik...', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ),

          // AREA INPUT
          _buildInputChat(),
        ],
      ),
    );
  }

  // Desain Gelembung Chat (Persis buatan lo)
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

  // Kolom Ketik Pesan (Dimodif biar nyambung ke fungsi _kirimPesan)
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
              controller: _textController, // SAMBUNGIN CONTROLLER
              onSubmitted: (_) => _kirimPesan(), // ENTER LANGSUNG KIRIM
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
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20), 
              onPressed: _kirimPesan, // TOMBOL SEND PANGGIL FUNGSI API
            ),
          )
        ],
      ),
    );
  }
}