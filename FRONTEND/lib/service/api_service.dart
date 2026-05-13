// LOKASI: lib/service/api_service.dart
//
// ══════════════════════════════════════════════════════════════
// CARA PAKAI NGROK:
//   1. Buka terminal baru
//   2. Jalankan: ngrok http 8000
//   3. Copy URL yang muncul, contoh: https://abc123.ngrok-free.app
//   4. Ganti nilai baseUrl di bawah ini
//   5. Hot restart Flutter (bukan hot reload)
//   CATATAN: Setiap ngrok dijalankan ulang, URL berubah
// ══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  // ══════════════════════════════════════════════════════════════
  // GANTI URL INI DENGAN URL NGROK KAMU — tanpa slash di akhir
  // ══════════════════════════════════════════════════════════════
  static const String baseUrl = 'https://yi-unplayful-undevastatingly.ngrok-free.dev';

  // ── Headers ────────────────────────────────────────────────────
  static Map<String, String> get _headers => {
        'Content-Type'              : 'application/json',
        'Accept'                    : 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  static Map<String, String> get _authHeaders => {
        'Content-Type'              : 'application/json',
        'Accept'                    : 'application/json',
        'Authorization'             : 'Bearer ${UserSession.token}',
        'ngrok-skip-browser-warning': 'true',
      };

  // ══════════════════════════════════════════════════════════════
  // HELPER: perbaiki URL gambar yang tersimpan sebagai localhost
  // ══════════════════════════════════════════════════════════════
  static String perbaikiUrlGambar(String? url) {
    if (url == null || url.isEmpty) return '';
    if (!url.contains('localhost') && !url.contains('127.0.0.1')) return url;
    return url
        .replaceAll(RegExp(r'http://localhost:\d+'), baseUrl)
        .replaceAll(RegExp(r'http://127\.0\.0\.1:\d+'), baseUrl)
        .replaceAll('http://localhost', baseUrl)
        .replaceAll('http://127.0.0.1', baseUrl);
  }

  // ══════════════════════════════════════════════════════════════
  // KYC
  // ══════════════════════════════════════════════════════════════

  /// GET /api/kyc/status
  /// Ambil status KYC user yang sedang login.
  /// Response data: { status, rejection_note, submitted_at }
  /// status: 'unverified' | 'pending' | 'verified' | 'rejected'
  static Future<Map<String, dynamic>> getKycStatus() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/kyc/status'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Gagal cek KYC'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  /// POST /api/kyc/upload (multipart/form-data)
  /// Upload KTP dan SIM user.
  /// ktpBytes + ktpName : file KTP
  /// simBytes + simName : file SIM
  static Future<Map<String, dynamic>> uploadKyc({
    required List<int> ktpBytes,
    required String    ktpName,
    required List<int> simBytes,
    required String    simName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/kyc/upload'),
      );

      request.headers.addAll({
        'Accept'                    : 'application/json',
        'Authorization'             : 'Bearer ${UserSession.token}',
        'ngrok-skip-browser-warning': 'true',
      });

      request.files.add(http.MultipartFile.fromBytes(
        'ktp_file', ktpBytes, filename: ktpName,
      ));
      request.files.add(http.MultipartFile.fromBytes(
        'sim_file', simBytes, filename: simName,
      ));

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res      = await http.Response.fromStream(streamed);
      final body     = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200) {
        return {'success': true, 'data': body['data'], 'message': body['message']};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal upload KYC'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  /// GET /api/kyc/booking/{bookingId}
  /// Owner melihat dokumen KTP & SIM penyewa di booking tertentu.
  /// Response data: { status, ktp_url, sim_url }
  static Future<Map<String, dynamic>> getKycByBooking(int bookingId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/api/kyc/booking/$bookingId'),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        // Perbaiki URL gambar KYC yang masih localhost → ngrok
        final data = body['data'] as Map<String, dynamic>;
        if (data['ktp_url'] != null) {
          data['ktp_url'] = perbaikiUrlGambar(data['ktp_url'].toString());
        }
        if (data['sim_url'] != null) {
          data['sim_url'] = perbaikiUrlGambar(data['sim_url'].toString());
        }
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal ambil KYC'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // TAMBAH MOBIL DENGAN GAMBAR
  // POST /api/mobil  (multipart/form-data)
  // ══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> tambahMobilDenganGambar({
    required Map<String, dynamic> data,
    List<int>? gambarBytes,
    String?    gambarName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/mobil'),
      );
      request.headers.addAll({
        'Accept'                    : 'application/json',
        'Authorization'             : 'Bearer ${UserSession.token}',
        'ngrok-skip-browser-warning': 'true',
      });
      data.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });
      if (gambarBytes != null && gambarName != null && gambarBytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          'gambar_file', gambarBytes, filename: gambarName,
        ));
      }
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res      = await http.Response.fromStream(streamed);
      final body     = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        return {'success': true, 'data': body};
      }
      return {
        'success': false,
        'message': (body is Map ? body['message'] : null) ?? 'Gagal tambah mobil',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // UPDATE MOBIL DENGAN GAMBAR
  // POST /api/mobil/{id}?_method=PUT  (multipart + method spoofing)
  // ══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> updateMobilDenganGambar({
    required int mobilId,
    required Map<String, dynamic> data,
    List<int>? gambarBytes,
    String?    gambarName,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/mobil/$mobilId?_method=PUT'),
      );
      request.headers.addAll({
        'Accept'                    : 'application/json',
        'Authorization'             : 'Bearer ${UserSession.token}',
        'ngrok-skip-browser-warning': 'true',
      });
      request.fields['_method'] = 'PUT';
      data.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });
      if (gambarBytes != null && gambarName != null && gambarBytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(
          'gambar_file', gambarBytes, filename: gambarName,
        ));
      }
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res      = await http.Response.fromStream(streamed);
      final body     = jsonDecode(res.body);
      if (res.statusCode == 200) return {'success': true, 'data': body};
      return {
        'success': false,
        'message': (body is Map ? body['message'] : null) ?? 'Gagal update mobil',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/login'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = data['user'];
        UserSession.simpan(
          nama : user['name']  ?? '',
          email: user['email'] ?? '',
          phone: user['phone'] ?? '',
          role : user['role']  ?? 'user',
          token: data['token'] ?? '',
        );
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': jsonDecode(res.body)['message'] ?? 'Login gagal'};
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
      if (res.statusCode == 201) return {'success': true, 'data': jsonDecode(res.body)};
      return {'success': false, 'message': jsonDecode(res.body)['message'] ?? 'Register gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Server error: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // CITIES
  // ══════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getCities() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/cities'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
      return [];
    } catch (e) {
      debugPrint('getCities error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MOBIL PUBLIC
  // ══════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getMobilPublic() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/mobil/public'), headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        List<dynamic> list = body is List
            ? body
            : (body is Map && body['data'] != null ? body['data'] as List : []);
        return list.map((item) {
          if (item is Map && item['gambar'] != null) {
            item['gambar'] = perbaikiUrlGambar(item['gambar'].toString());
          }
          return item;
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('getMobilPublic error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SEARCH MOBIL
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> searchMobil({
    required String cityName,
    required String tanggalMulai,
    required String tanggalSelesai,
  }) async {
    try {
      final params = <String, String>{
        'tanggal_mulai'  : tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
      };
      if (cityName.isNotEmpty) params['city_name'] = cityName;
      final uri  = Uri.parse('$baseUrl/api/mobil/search').replace(queryParameters: params);
      final res  = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        final List<dynamic> data = ((body['data'] ?? []) as List).map((item) {
          if (item is Map && item['gambar'] != null) {
            item['gambar'] = perbaikiUrlGambar(item['gambar'].toString());
          }
          return item;
        }).toList();
        return {'success': true, 'data': data};
      }
      return {'success': false, 'message': body['message'] ?? 'Gagal mencari mobil'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek ke server: $e'};
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BOOKING — USER
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getMyBookings() async {
    try {
      final res  = await http.get(Uri.parse('$baseUrl/api/bookings'), headers: _authHeaders)
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
          .delete(Uri.parse('$baseUrl/api/bookings/$bookingId/cancel'), headers: _authHeaders)
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
          .post(Uri.parse('$baseUrl/api/bookings/$bookingId/pay'), headers: _authHeaders)
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

  // ══════════════════════════════════════════════════════════════
  // BOOKING — OWNER
  // ══════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getOwnerBookings() async {
    try {
      final res  = await http.get(Uri.parse('$baseUrl/api/owner/bookings'), headers: _authHeaders)
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
          .post(Uri.parse('$baseUrl/api/owner/bookings/$bookingId/terima'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'message': body['message']};
      return {'success': false, 'message': body['message'] ?? 'Gagal terima'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> tolakBooking(int bookingId) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl/api/owner/bookings/$bookingId/tolak'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true};
      return {'success': false, 'message': body['message'] ?? 'Gagal tolak'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }

  static Future<Map<String, dynamic>> getOwnerDashboard() async {
    try {
      final res  = await http.get(Uri.parse('$baseUrl/api/owner/dashboard'), headers: _authHeaders)
          .timeout(const Duration(seconds: 15));
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200) return {'success': true, 'data': body['data']};
      return {'success': false, 'message': body['message'] ?? 'Gagal load dashboard'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal konek: $e'};
    }
  }
}