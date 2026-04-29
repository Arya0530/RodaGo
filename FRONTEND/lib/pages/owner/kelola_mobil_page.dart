import 'package:flutter/material.dart';
import '../../service/mobil_service.dart';
import '../auth/login_page.dart';
import '../../service/user_session.dart';
import 'tambah_mobil_page.dart';
import 'edit_mobil_page.dart';

class KelolaMobilPage extends StatefulWidget {
  @override
  _KelolaMobilPageState createState() => _KelolaMobilPageState();
}

class _KelolaMobilPageState extends State<KelolaMobilPage> {
  List<dynamic> _mobilList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMobil();
  }

  Future<void> _fetchMobil() async {
    try {
      final data = await MobilService.getMobil();
      setState(() {
        _mobilList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      final errorMessage = e.toString();

      if (errorMessage.contains('Unauthorized') ||
          errorMessage.contains('401')) {
        UserSession.hapus();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $errorMessage')),
        );
      }
    }
  }

  void _hapusMobil(int id, String nama) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Mobil?"),
        content: Text("Yakin mau menghapus $nama?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await MobilService.hapusMobil(id);
              _fetchMobil();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$nama dihapus")),
              );
            },
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Tidak pakai Scaffold/AppBar — sudah dihandle OwnerMainLayout
    return Stack(
      children: [
        Container(
          color: Colors.grey[50],
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _mobilList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 100),
                      itemCount: _mobilList.length,
                      itemBuilder: (context, index) {
                        return _buildCarItem(context, _mobilList[index]);
                      },
                    ),
        ),
        // FAB manual di pojok kanan bawah
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TambahMobilPage()),
              );
              _fetchMobil();
            },
            backgroundColor: Colors.teal,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Tambah Mobil",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildCarItem(BuildContext context, Map<String, dynamic> mobil) {
    int id = mobil['id'];
    String name = mobil['nama'];
    String price = "Rp ${_formatCurrency(mobil['harga'])} / hari";
    String imageUrl = mobil['gambar'] ?? '';

    final isAvailable = mobil['tersedia'] == true ||
        mobil['tersedia'] == 1 ||
        mobil['tersedia'].toString() == '1';

    String status = isAvailable ? "Tersedia" : "Disewa";
    Color statusColor = isAvailable ? Colors.green : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12)),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child:
                            Icon(Icons.directions_car, color: Colors.grey[400]),
                      ),
                    ),
                  )
                : Center(
                    child:
                        Icon(Icons.directions_car, color: Colors.grey[400])),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(price,
                    style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                SizedBox(height: 8),
                Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMobilPage(
                    mobilId: mobil['id'],
                    namaMobil: mobil['nama'],
                    hargaSewa: mobil['harga'].toString(),
                    tipe: mobil['tipe'] ?? 'Economy',
                    kursi: mobil['kursi'] ?? 4,
                    transmisi: mobil['transmisi'] ?? 'Otomatis',
                    bahan_bakar: mobil['bahan_bakar'] ?? 'Bensin',
                  ),
                ),
              );
              _fetchMobil();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _hapusMobil(id, name),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(dynamic value) {
    int harga =
        value is int ? value : int.tryParse(value.toString()) ?? 0;
    return harga
        .toString()
        .replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'), (Match m) => '.');
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 80, color: Colors.grey[300]),
          SizedBox(height: 24),
          Text('Belum Ada Armada',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          SizedBox(height: 8),
          Text(
            'Mulai tambahkan kendaraan Anda\nuntuk memulai bisnis rental',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}