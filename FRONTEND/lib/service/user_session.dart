import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  // ── Key konstanta ─────────────────────────────────────────────
  static const _kId    = 'id';
  static const _kToken = 'token';
  static const _kNama  = 'nama';
  static const _kEmail = 'email';
  static const _kPhone = 'phone';
  static const _kRole  = 'role';

  // ── Data in-memory ────────────────────────────────────────────
  static int id = 0;
  static String token = '';
  static String nama = '';
  static String email = '';
  static String phone = '';
  static String role = '';

  // ── Simpan session ────────────────────────────────────────────
  static Future<void> simpan({
    required int id,
    required String nama,
    required String email,
    required String phone,
    required String role,
    required String token,
  }) async {
    UserSession.id = id;
    UserSession.token = token;
    UserSession.nama = nama;
    UserSession.email = email;
    UserSession.phone = phone;
    UserSession.role = role;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_kId, id);
    await prefs.setString(_kToken, token);
    await prefs.setString(_kNama, nama);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kRole, role);
  }

  // ── Muat session ──────────────────────────────────────────────
  static Future<bool> muat() async {
    final prefs = await SharedPreferences.getInstance();

    final savedToken = prefs.getString(_kToken) ?? '';

    if (savedToken.isEmpty) return false;

    id = prefs.getInt(_kId) ?? 0;
    token = savedToken;
    nama = prefs.getString(_kNama) ?? '';
    email = prefs.getString(_kEmail) ?? '';
    phone = prefs.getString(_kPhone) ?? '';
    role = prefs.getString(_kRole) ?? '';

    return true;
  }

  // ── Hapus session ─────────────────────────────────────────────
  static Future<void> hapus() async {
    id = 0;
    token = '';
    nama = '';
    email = '';
    phone = '';
    role = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Helper ────────────────────────────────────────────────────
  static bool get isOwner => role == 'owner';
  static bool get isLoggedIn => token.isNotEmpty;
}