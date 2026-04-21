import 'dart:convert';
import 'package:http/http.dart' as http;

class MobilService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<List<dynamic>> getMobil() async {
    final response = await http.get(Uri.parse('$baseUrl/mobil'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load mobil');
    }
  }

  static Future<Map<String, dynamic>> createMobil({
    required String nama,
    required int harga,
    required String tipe,
    required int kursi,
    required String transmisi,
    required String bahan_bakar,
    required String fitur,
    String? deskripsi,
    String? gambar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mobil'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama': nama,
        'harga': harga,
        'tipe': tipe,
        'kursi': kursi,
        'transmisi': transmisi,
        'bahan_bakar': bahan_bakar,
        'fitur': fitur,
        'deskripsi': deskripsi ?? '',
        'gambar': gambar ?? '',
        'tersedia': true,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create mobil');
    }
  }

  static Future<Map<String, dynamic>> updateMobil({
    required int id,
    required String nama,
    required int harga,
    required String tipe,
    required int kursi,
    required String transmisi,
    required String bahan_bakar,
    required String fitur,
    String? deskripsi,
    String? gambar,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mobil/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nama': nama,
        'harga': harga,
        'tipe': tipe,
        'kursi': kursi,
        'transmisi': transmisi,
        'bahan_bakar': bahan_bakar,
        'fitur': fitur,
        'deskripsi': deskripsi ?? '',
        'gambar': gambar ?? '',
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update mobil');
    }
  }

  static Future<Map<String, dynamic>> getMobilById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/mobil/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load mobil detail');
    }
  }

  static Future<void> hapusMobil(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/mobil/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete mobil');
    }
  }
}