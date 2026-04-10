import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Nanti kalau Ngrok mati terus URL-nya ganti, lu CUKUP GANTI DI SINI AJA, nggak usah nyari-nyari di file lain.
  static const String baseUrl = 'https://afflictively-subsensuous-ingrid.ngrok-free.dev/api';

  // --- CONTOH FUNGSI LOGIN ---
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Kalau sukses (Status 200)
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        // Kalau password salah (Status 401 dll)
        return {'success': false, 'message': jsonDecode(response.body)['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server. Cek jaringan/Ngrok lu bro!'};
    }
  }

  // --- NANTI FUNGSI REGISTER, AMBIL DATA MOBIL, DLL DIBIKIN DI BAWAH SINI ---
}