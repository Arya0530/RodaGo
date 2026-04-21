import 'package:flutter/material.dart';
import '../../service/mobil_service.dart';
import '../auth/login_page.dart';
import '../services/user_session.dart';

class EditMobilPage extends StatefulWidget {
  final String namaMobil;
  final String hargaSewa;
  final int mobilId;
  final String tipe;
  final int kursi;
  final String transmisi;
  final String bahan_bakar;

  EditMobilPage({
    required this.mobilId,
    required this.namaMobil,
    required this.hargaSewa,
    required this.tipe,
    required this.kursi,
    required this.transmisi,
    required this.bahan_bakar,
  });

  @override
  _EditMobilPageState createState() => _EditMobilPageState();
}

class _EditMobilPageState extends State<EditMobilPage> {
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;

  late String _tipe;
  late String _transmisi;
  late String _kursi;
  late String _bahan_bakar;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.namaMobil);
    String hargaBersih = widget.hargaSewa.replaceAll(RegExp(r'[^0-9]'), '');
    _hargaController = TextEditingController(text: hargaBersih);
    _deskripsiController = TextEditingController();

    _tipe = widget.tipe;
    _transmisi = widget.transmisi;
    _kursi = widget.kursi.toString();
    _bahan_bakar = widget.bahan_bakar;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama dan harga harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await MobilService.updateMobil(
        widget.mobilId,
        {
          'nama': _namaController.text,
          'harga': int.parse(_hargaController.text),
          'tipe': _tipe,
          'kursi': int.parse(_kursi),
          'transmisi': _transmisi,
          'bahan_bakar': _bahan_bakar,
          'deskripsi': _deskripsiController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobil berhasil diperbarui!'), backgroundColor: Colors.teal),
      );
      Navigator.pop(context);
    } catch (e) {
      final errorMessage = e.toString();
      
      // Handle authentication errors
      if (errorMessage.contains('Unauthorized') || errorMessage.contains('401')) {
        UserSession.hapus();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      } else if (errorMessage.contains('Anda tidak memiliki akses') || errorMessage.contains('403')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anda tidak memiliki akses untuk mengubah mobil ini'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
        title: Text("Edit Mobil", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.directions_car, size: 80, color: Colors.teal[100]),
                  Positioned(
                    bottom: 12, right: 12,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: Icon(Icons.edit, color: Colors.teal, size: 20),
                    )
                  )
                ],
              ),
            ),
            SizedBox(height: 32),

            _buildInputField("Nama Mobil", _namaController, isNumber: false),
            SizedBox(height: 16),
            _buildInputField("Harga Sewa per Hari (Rp)", _hargaController, isNumber: true),
            
            Divider(height: 48, thickness: 2, color: Colors.grey[100]),
            Text("Spesifikasi Mobil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16),

            _buildDropdownField("Kategori", ["Economy", "MPV", "Luxury", "SUV"], _tipe, (val) => setState(() => _tipe = val!)),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildDropdownField("Transmisi", ["Otomatis", "Manual"], _transmisi, (val) => setState(() => _transmisi = val!))),
                SizedBox(width: 16),
                Expanded(child: _buildDropdownField("Kapasitas", ["4", "5", "6", "7", "8"], _kursi, (val) => setState(() => _kursi = val!))),
              ],
            ),
            SizedBox(height: 16),

            _buildDropdownField("Bahan Bakar", ["Bensin", "Diesel", "Hybrid"], _bahan_bakar, (val) => setState(() => _bahan_bakar = val!)),
            SizedBox(height: 24),

            Text("Deskripsi Mobil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 8),
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tuliskan deskripsi atau catatan...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            
            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.teal),
              items: items.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: Colors.black87, fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
