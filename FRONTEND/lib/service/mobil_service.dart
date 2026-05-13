// LOKASI: lib/service/mobil_service.dart
//
// FIX: Tambah header 'ngrok-skip-browser-warning': 'true' di SEMUA request.
// Tanpa header ini, ngrok menampilkan halaman HTML interstitial sebagai
// respons, bukan JSON → dart crash saat jsonDecode → "Failed to fetch".

import 'dart:convert';
import 'package:http/http.dart' as http;

import './api_service.dart';
import './user_session.dart';

class MobilService {
  // ── Header JSON + token + ngrok bypass ──────────────────────────
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type'              : 'application/json',
      'Accept'                    : 'application/json',
      'Authorization'             : 'Bearer ${UserSession.token}',
      'ngrok-skip-browser-warning': 'true',   // ← WAJIB untuk ngrok
    };
  }

  // Header tanpa auth (untuk endpoint publik)
  static Map<String, String> _getPublicHeaders() {
    return {
      'Accept'                    : 'application/json',
      'ngrok-skip-browser-warning': 'true',   // ← WAJIB untuk ngrok
    };
  }

  // ══════════════════════════════════════════════════════════════
  // GET /api/mobil/public — daftar mobil publik (tanpa auth)
  // ══════════════════════════════════════════════════════════════
  static Future<List<dynamic>> getMobilPublic() async {
    try {
      final url      = Uri.parse('${ApiService.baseUrl}/api/mobil/public');
      final response = await http
          .get(url, headers: _getPublicHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = data is List
            ? data
            : (data is Map && data.containsKey('data')
                ? data['data'] as List<dynamic>
                : []);

        return list.map((item) {
          if (item is Map<String, dynamic> && item['gambar'] != null) {
            item['gambar'] = ApiService.perbaikiUrlGambar(item['gambar'].toString());
          }
          return item;
        }).toList();
      } else {
        throw Exception('Gagal load mobil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error get mobil public: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GET /api/mobil — daftar mobil milik owner yang login
  // ══════════════════════════════════════════════════════════════
  static Future<List<dynamic>> getMobil() async {
    try {
      final url      = Uri.parse('${ApiService.baseUrl}/api/mobil');
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = data is List
            ? data
            : (data is Map && data.containsKey('data')
                ? data['data'] as List<dynamic>
                : []);

        return list.map((item) {
          if (item is Map<String, dynamic> && item['gambar'] != null) {
            item['gambar'] = ApiService.perbaikiUrlGambar(item['gambar'].toString());
          }
          return item;
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Silahkan login kembali');
      } else {
        throw Exception('Gagal load mobil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error get mobil: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // GET /api/mobil/{id} — detail mobil by ID
  // ══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> getMobilById(int id) async {
    try {
      final url      = Uri.parse('${ApiService.baseUrl}/api/mobil/$id');
      final response = await http
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> item =
            data is Map ? Map<String, dynamic>.from(data) : data['data'];
        if (item['gambar'] != null) {
          item['gambar'] = ApiService.perbaikiUrlGambar(item['gambar'].toString());
        }
        return item;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Silahkan login kembali');
      } else if (response.statusCode == 403) {
        throw Exception('Anda tidak memiliki akses ke mobil ini');
      } else {
        throw Exception('Gagal load detail mobil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error get mobil by id: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // POST /api/mobil — tambah mobil (JSON tanpa gambar)
  // ══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> tambahMobil(Map<String, dynamic> data) async {
    try {
      final url      = Uri.parse('${ApiService.baseUrl}/api/mobil');
      final response = await http
          .post(url, headers: _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Silahkan login kembali');
      } else {
        throw Exception('Gagal tambah mobil: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error tambah mobil: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // UPDATE MOBIL DENGAN GAMBAR (multipart/form-data)
  // gambarBytes null = tidak ganti gambar
  // ══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> updateMobilDenganGambar({
    required int mobilId,
    required Map<String, dynamic> data,
    List<int>? gambarBytes,
    String?    gambarName,
  }) async {
    final result = await ApiService.updateMobilDenganGambar(
      mobilId    : mobilId,
      data       : data,
      gambarBytes: gambarBytes,
      gambarName : gambarName,
    );
    if (result['success'] == true) {
      return result['data'] as Map<String, dynamic>;
    }
    throw Exception(result['message'] ?? 'Gagal update mobil');
  }

  // ══════════════════════════════════════════════════════════════
  // PUT /api/mobil/{id} — update mobil tanpa ganti gambar (JSON)
  // ══════════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>> updateMobil(int id, Map<String, dynamic> data) async {
    try {
      final url      = Uri.parse('${ApiService.baseUrl}/api/mobil/$id');
      final response = await http
          .put(url, headers: _getHeaders(), body: jsonEncode(data))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Silahkan login kembali');
      } else if (response.statusCode == 403) {
        throw Exception('Anda tidak memiliki akses untuk mengubah mobil ini');
      } else {
        throw Exception('Gagal update mobil: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error update mobil: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // DELETE /api/mobil/{id} — hapus mobil
  // ══════════════════════════════════════════════════════════════
  static Future<void> hapusMobil(int id) async {
    try {
      final url      = Uri.parse('${ApiService.baseUrl}/api/mobil/$id');
      final response = await http
          .delete(url, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 401) {
          throw Exception('Unauthorized - Silahkan login kembali');
        } else if (response.statusCode == 403) {
          throw Exception('Anda tidak memiliki akses untuk menghapus mobil ini');
        } else {
          throw Exception('Gagal hapus mobil: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error hapus mobil: $e');
    }
  }
}