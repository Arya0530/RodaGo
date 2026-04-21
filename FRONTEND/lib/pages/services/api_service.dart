// ============================================================
// FILE DIUPDATE: lib/services/api_service.dart
// ============================================================
// APA YANG BERUBAH DARI VERSI LAMA?
//
// Fungsi login() sekarang melakukan 2 hal setelah sukses:
//   1. Ambil data user (nama, email, phone, role) dari response API
//   2. Simpan data itu ke UserSession supaya bisa dipakai seluruh app
//
// Versi lama hanya return {'success': true, 'data': ...} tanpa
// menyimpan ke mana pun. Akibatnya halaman lain tidak bisa tahu
// siapa yang sedang login.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart'; // <-- TAMBAHAN BARU: import file session kita

class ApiService {
  // Base URL untuk API Laravel
  static const String baseUrl = 'http://localhost:8000/api'; 

  // ============================================================
  // FUNGSI LOGIN (DIUPDATE)
  // ============================================================
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("DATA API: $data");
  print("USER: ${data['user']}");
  print("ROLE: ${data['user']['role']}");
        final user = data['user'];
        final token = data['token'] ?? '';

        UserSession.simpan(
          nama: user['name'] ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          role: user['role'] ?? 'user',
          token: token,
        );
        // -------------------------------------------------------

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal konek ke server. Cek jaringan/Ngrok lu bro!'
      };
    }
  }

  // ============================================================
  // FUNGSI REGISTER (TIDAK ADA PERUBAHAN)
  // ============================================================
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message']
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Server error'};
    }
  }

  // --- NANTI FUNGSI LAIN DIBIKIN DI BAWAH SINI ---
}