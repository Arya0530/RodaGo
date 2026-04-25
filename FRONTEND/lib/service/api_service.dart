import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  // ─── Header tanpa token (untuk login & register) ──────────────────────────
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── Header dengan token (untuk semua request yang butuh login) ───────────
  static Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };

  // ============================================================
  // AUTH
  // ============================================================

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("DATA API: $data");
        print("USER: ${data['user']}");
        print("ROLE: ${data['user']['role']}");

        final user  = data['user'];
        final token = data['token'] ?? '';

        UserSession.simpan(
          nama:  user['name']  ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          role:  user['role']  ?? 'user',
          token: token,
        );

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

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name, 'email': email, 'phone': phone,
          'password': password, 'role': role,
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

  // ============================================================
  // BOOKING — USER
  // ============================================================

  // GET /api/bookings
  // Ambil semua pesanan milik user yang sedang login
  static Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/bookings'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal mengambil pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server!'};
    }
  }

  // POST /api/bookings
  // Buat pesanan baru → status otomatis "pending"
  static Future<Map<String, dynamic>> createBooking({
    required int mobilId,
    required String tanggalMulai,   // format: YYYY-MM-DD
    required String tanggalSelesai, // format: YYYY-MM-DD
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/bookings'),
            headers: _authHeaders,
            body: jsonEncode({
              'mobil_id'        : mobilId,
              'tanggal_mulai'   : tanggalMulai,
              'tanggal_selesai' : tanggalSelesai,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server!'};
    }
  }

  // DELETE /api/bookings/{id}/cancel
  // User batalkan pesanan (hanya boleh saat status masih "pending")
  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/bookings/$bookingId/cancel'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membatalkan pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server!'};
    }
  }

  // ============================================================
  // BOOKING — OWNER
  // ============================================================

  // GET /api/owner/bookings
  // Owner lihat pesanan pending yang masuk ke mobil-mobilnya
  static Future<Map<String, dynamic>> getOwnerBookings() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/owner/bookings'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal mengambil pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server!'};
    }
  }

  // POST /api/owner/bookings/{id}/terima
  // Owner terima pesanan → status jadi "unpaid", timer 24 jam mulai
  static Future<Map<String, dynamic>> terimaBooking(int bookingId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/owner/bookings/$bookingId/terima'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': body['message']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menerima pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server!'};
    }
  }

  // POST /api/owner/bookings/{id}/tolak
  // Owner tolak pesanan → status jadi "cancelled"
  static Future<Map<String, dynamic>> tolakBooking(int bookingId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/owner/bookings/$bookingId/tolak'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal menolak pesanan'
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server!'};
    }
  }
}