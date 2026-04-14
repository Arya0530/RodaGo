import 'package:flutter/material.dart';

class EditMobilPage extends StatefulWidget {
  final String namaMobil;
  final String hargaSewa;

  // Constructor buat nangkep data mobil yang mau diedit
  EditMobilPage({required this.namaMobil, required this.hargaSewa});

  @override
  _EditMobilPageState createState() => _EditMobilPageState();
}

class _EditMobilPageState extends State<EditMobilPage> {
  // Controller buat ngisi textfield otomatis
  late TextEditingController _namaController;
  late TextEditingController _hargaController;

  // State Dropdown (Defaultnya kita samain aja buat MVP)
  String _kategori = 'Economy';
  String _transmisi = 'Otomatis';
  String _kursi = '4 Kursi';
  String _bbmPolicy = 'Kembali Full';
  String _isHybrid = 'Non-Hybrid';

  @override
  void initState() {
    super.initState();
    // Isi otomatis textfield pake data yang dilempar
    _namaController = TextEditingController(text: widget.namaMobil);
    
    // Bersihin teks harga (misal "Rp 450.000 / hari" jadi "450000" doang)
    String hargaBersih = widget.hargaSewa.replaceAll(RegExp(r'[^0-9]'), '');
    _hargaController = TextEditingController(text: hargaBersih);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
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
            // KOTAK UPLOAD FOTO (Pura-puranya udah ada fotonya)
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal, width: 2), // Border teal tanda udah ada foto
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

            // FORM INPUT TEXT (Udah keisi otomatis!)
            _buildInputField("Nama Mobil", _namaController, isNumber: false),
            SizedBox(height: 16),
            _buildInputField("Harga Sewa per Hari (Rp)", _hargaController, isNumber: true),
            
            Divider(height: 48, thickness: 2, color: Colors.grey[100]),
            Text("Spesifikasi Mobil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16),

            // FORM DROPDOWN 👇
            _buildDropdownField("Kategori", ["Economy", "MPV", "Luxury"], _kategori, (val) => setState(() => _kategori = val!)),
            SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildDropdownField("Transmisi", ["Otomatis", "Manual"], _transmisi, (val) => setState(() => _transmisi = val!))),
                SizedBox(width: 16),
                Expanded(child: _buildDropdownField("Kapasitas", ["4 Kursi", "6 Kursi", "8 Kursi"], _kursi, (val) => setState(() => _kursi = val!))),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildDropdownField("Kebijakan BBM", ["Kembali Full", "Sesuai Pemakaian"], _bbmPolicy, (val) => setState(() => _bbmPolicy = val!))),
                SizedBox(width: 16),
                Expanded(child: _buildDropdownField("Jenis Mesin", ["Non-Hybrid", "Hybrid"], _isHybrid, (val) => setState(() => _isHybrid = val!))),
              ],
            ),
            SizedBox(height: 40),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Perubahan data mobil berhasil disimpan!"), backgroundColor: Colors.teal)
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("Simpan Perubahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // FUNGSI PEMBANTU BUAT TEXT FIELD (Pake Controller)
  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        SizedBox(height: 8),
        TextField(
          controller: controller, // <-- Nyambungin datanya di sini
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

  // FUNGSI PEMBANTU BUAT DROPDOWN
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