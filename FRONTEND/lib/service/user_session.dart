import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  // ── Key konstanta ─────────────────────────────────────────────────────────
  static const _kToken = 'token';
  static const _kNama  = 'nama';
  static const _kEmail = 'email';
  static const _kPhone = 'phone';
  static const _kRole  = 'role';

  // ── Data in-memory (cepat diakses di seluruh app) ─────────────────────────
  static String token = '';
  static String nama  = '';
  static String email = '';
  static String phone = '';
  static String role  = '';

  // ── Simpan session ke SharedPreferences + memory ──────────────────────────
  // Dipanggil setelah login berhasil
  static Future<void> simpan({
    required String nama,
    required String email,
    required String phone,
    required String role,
    required String token,
  }) async {
    // Simpan ke memory dulu (untuk akses cepat tanpa async)
    UserSession.token = token;
    UserSession.nama  = nama;
    UserSession.email = email;
    UserSession.phone = phone;
    UserSession.role  = role;

    // Simpan ke SharedPreferences (persisten, tidak hilang saat app ditutup)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kNama,  nama);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kRole,  role);
  }

  // ── Muat session dari SharedPreferences saat app dibuka ───────────────────
  // Return true kalau ada sesi tersimpan, false kalau belum pernah login
  static Future<bool> muat() async {
    final prefs      = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_kToken) ?? '';

    if (savedToken.isEmpty) return false;

    // Isi memory dari storage
    token = savedToken;
    nama  = prefs.getString(_kNama)  ?? '';
    email = prefs.getString(_kEmail) ?? '';
    phone = prefs.getString(_kPhone) ?? '';
    role  = prefs.getString(_kRole)  ?? '';

    return true;
  }

  // ── Hapus semua session (dipanggil saat logout) ────────────────────────────
  static Future<void> hapus() async {
    token = '';
    nama  = '';
    email = '';
    phone = '';
    role  = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  static bool get isOwner    => role == 'owner';
  static bool get isLoggedIn => token.isNotEmpty;
}