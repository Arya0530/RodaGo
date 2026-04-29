// LOKASI: lib/service/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  // ⚠️ Ganti sesuai kondisimu:
  //   Emulator Android  → 'http://10.0.2.2:8000'
  //   HP fisik (WiFi)   → 'http://192.168.x.x:8000'
  //   Ngrok             → 'https://xxxx.ngrok-free.app'
  static const String baseUrl = 'http://localhost:8000';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept'      : 'application/json',
      };

  static Map<String, String> get _authHeaders => {
        'Content-Type' : 'application/json',
        'Accept'       : 'application/json',
        'Authorization': 'Bearer ${UserSession.token}',
      };

  // ════════════════════════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data  = jsonDecode(res.body);
        final user  = data['user'];
        final token = data['token'] ?? '';
        UserSession.simpan(
          nama : user['name']  ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          role : user['role']  ?? 'user',
          token: token,
        );
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': jsonDecode(res.body)['message'] ?? 'Login gagal',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String phone,
      String password, String role) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name, 'email': email, 'phone': phone,
              'password': password, 'role': role,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {
        'success': false,
        'message': jsonDecode(res.body)['message'] ?? 'Register gagal',
      };
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ════════════════════════════════════════════════════════════
  // CITIES
  //
  // GET /api/cities
  // Ambil kota dari tabel cities yang benar-benar punya rental aktif
  // dan minimal 1 mobil tersedia.
  //
  // Format response dari server:
  //   [ {"id": 1, "name": "Surabaya", "province": "Jawa Timur"}, ... ]
  // ════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getCities() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/cities'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('getCities error: $e');
      return [];
    }
  }

  // ════════════════════════════════════════════════════════════
  // MOBIL PUBLIC
  //
  // GET /api/mobil/public
  // Semua mobil tersedia — ditampilkan di beranda SEBELUM user pilih kota.
  // Response sudah include: nama_rental, kota_rental
  // ════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getMobilPublic() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/mobil/public'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        // Server return langsung array
        if (body is List) return body;
        // Atau dibungkus {data: [...]}
        if (body is Map && body['data'] != null) {
          return body['data'] as List<dynamic>;
        }
        return [];
      }
      return [];
    } catch (e) {
      print('getMobilPublic error: $e');
      return [];
    }
  }

  // ════════════════════════════════════════════════════════════
  // SEARCH MOBIL
  //
  // GET /api/mobil/search?city_name=...&tanggal_mulai=...&tanggal_selesai=...
  //
  // cityName      : nama kota (dari field 'name' di getCities).
  //                 Kosongkan ("") untuk tampilkan semua kota.
  // tanggalMulai  : format YYYY-MM-DD
  // tanggalSelesai: format YYYY-MM-DD
  //
  // Server hanya mengembalikan mobil yang:
  //   1. tersedia = true
  //   2. Tidak ada booking aktif (pending/unpaid/active) di rentang tanggal itu
  //   3. rentals.city = cityName (jika cityName tidak kosong)
  // ════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> searchMobil({
    required String cityName,       // kosong = semua kota
    required String tanggalMulai,   // YYYY-MM-DD
    required String tanggalSelesai, // YYYY-MM-DD
  }) async {
    try {
      final params = <String, String>{
        'tanggal_mulai'  : tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
      };

      // Hanya kirim city_name jika tidak kosong
      if (cityName.isNotEmpty) {
        params['city_name'] = cityName;
      }

      final uri = Uri.parse('$baseUrl/api/mobil/search')
          .replace(queryParameters: params);

      final res = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return {'success': true, 'data': body['data'] ?? []};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal mencari mobil',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server: $e'};
    }
  }

  // ════════════════════════════════════════════════════════════
  // BOOKING — USER
  // ════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/bookings'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required int    mobilId,
    required String tanggalMulai,
    required String tanggalSelesai,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/bookings'),
            headers: _authHeaders,
            body: jsonEncode({
              'mobil_id'       : mobilId,
              'tanggal_mulai'  : tanggalMulai,
              'tanggal_selesai': tanggalSelesai,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 201) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Gagal pesan'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/api/bookings/$bookingId/cancel'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true};
      return {'success': false, 'message': body['message'] ?? 'Gagal cancel'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> payBooking(int bookingId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/bookings/$bookingId/pay'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return {
          'success'        : true,
          'kode_tiket'     : body['kode_tiket'],
          'booking_id'     : body['booking_id'],
          'nama_mobil'     : body['nama_mobil'],
          'tanggal_mulai'  : body['tanggal_mulai'],
          'tanggal_selesai': body['tanggal_selesai'],
        };
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal bayar'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  // ════════════════════════════════════════════════════════════
  // BOOKING — OWNER
  // ════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getOwnerBookings() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/owner/bookings'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> terimaBooking(int bookingId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/owner/bookings/$bookingId/terima'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return {'success': true, 'message': body['message']};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal terima'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> tolakBooking(int bookingId) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/owner/bookings/$bookingId/tolak'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true};
      return {'success': false, 'message': body['message'] ?? 'Gagal tolak'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }
}