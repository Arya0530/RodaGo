import 'package:flutter/material.dart';
import '../../service/mobil_service.dart';
import '../auth/login_page.dart';
import '../../service/user_session.dart';

class TambahMobilPage extends StatefulWidget {
  @override
  _TambahMobilPageState createState() => _TambahMobilPageState();
}

class _TambahMobilPageState extends State<TambahMobilPage> {
  // Text Controllers
  late TextEditingController _namaController;
  late TextEditingController _nomorPolisiController;
  late TextEditingController _hargaController;
  late TextEditingController _deskripsiController;

  // Dropdown values
  String _tipe = 'Economy';
  String _transmisi = 'Otomatis';
  String _kursi = '4';
  String _bahan_bakar = 'Bensin';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _nomorPolisiController = TextEditingController();
    _hargaController = TextEditingController();
    _deskripsiController = TextEditingController();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorPolisiController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _simpanMobil() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama dan harga harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await MobilService.tambahMobil({
        'nama': _namaController.text,
        'harga': int.parse(_hargaController.text),
        'tipe': _tipe,
        'kursi': int.parse(_kursi),
        'transmisi': _transmisi,
        'bahan_bakar': _bahan_bakar,
        'deskripsi': _deskripsiController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mobil berhasil ditambahkan!'), backgroundColor: Colors.teal),
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
        title: Text("Tambah Mobil Baru", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
                  SizedBox(height: 12),
                  Text("Upload Foto Mobil", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Format JPG/PNG, maks 2MB", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            SizedBox(height: 32),

            _buildInputField("Nama Mobil", "Contoh: Honda Civic RS", _namaController),
            SizedBox(height: 16),
            _buildInputField("Nomor Polisi", "Contoh: N 1234 ABC", _nomorPolisiController),
            SizedBox(height: 16),
            _buildInputField("Harga Sewa per Hari (Rp)", "Contoh: 500000", _hargaController, isNumber: true),
            
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
                hintText: "Tuliskan deskripsi kondisi mobil, syarat khusus, atau informasi lainnya...",
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
                onPressed: _isLoading ? null : _simpanMobil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Simpan Mobil", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
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
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.black87, fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
