import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

// Import UserSession untuk mendapatkan token
import '../pages/services/user_session.dart';

class MobilService {
  /// Helper function untuk mendapatkan headers dengan token
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${UserSession.token}',
    };
  }

  /// GET /api/mobil/public - Ambil daftar mobil publik untuk customer (NO AUTH)
  static Future<List<dynamic>> getMobilPublic() async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/mobil/public');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return data;
      } else {
        throw Exception('Gagal load mobil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error get mobil public: $e');
    }
  }

  /// GET /api/mobil - Ambil daftar mobil milik user yang login
  static Future<List<dynamic>> getMobil() async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/mobil');
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // API Laravel biasanya return array langsung atau wrapped dalam object
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Silahkan login kembali');
      } else {
        throw Exception('Gagal load mobil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error get mobil: $e');
    }
  }

  /// GET /api/mobil/{id} - Ambil detail mobil by ID
  static Future<Map<String, dynamic>> getMobilById(int id) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/mobil/$id');
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map ? data : data['data'];
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

  /// POST /api/mobil - Tambah mobil baru untuk user yang login
  static Future<Map<String, dynamic>> tambahMobil(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/mobil');
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      
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

  /// PUT /api/mobil/{id} - Update mobil (hanya owner yang bisa update mobilnya sendiri)
  static Future<Map<String, dynamic>> updateMobil(int id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/mobil/$id');
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      
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

  /// DELETE /api/mobil/{id} - Hapus mobil (hanya owner yang bisa hapus mobilnya sendiri)
  static Future<void> hapusMobil(int id) async {
    try {
      final url = Uri.parse('${ApiService.baseUrl}/api/mobil/$id');
      final response = await http.delete(
        url,
        headers: _getHeaders(),
      );
      
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