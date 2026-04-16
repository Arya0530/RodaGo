// ============================================================
// FILE BARU: lib/services/user_session.dart
// ============================================================
// PENJELASAN:
// File ini adalah "memori sementara" aplikasi kita.
// Setelah login berhasil, data user (nama, email, role, token)
// disimpan di sini sebagai variabel statis.
// Karena statis, data ini bisa diakses dari MANA SAJA di seluruh
// aplikasi tanpa perlu kirim parameter bolak-balik.
//
// ANALOGI: Bayangkan ini seperti "kartu nama" yang lu pegang
// setelah login. Di mana pun lu berada dalam app, lu tinggal
// lihat kartu nama itu untuk tahu siapa lu.
// ============================================================

class UserSession {
  // Variabel statis = disimpan di "level kelas", bukan di objek.
  // Artinya bisa diakses kapan saja pakai UserSession.nama
  static String nama = '';
  static String email = '';
  static String phone = '';
  static String role = ''; // Isinya: 'user' atau 'owner'
  static String token = '';

  // Fungsi untuk mengisi semua data sekaligus setelah login berhasil
  static void simpan({
    required String nama,
    required String email,
    required String phone,
    required String role,
    required String token,
  }) {
    UserSession.nama = nama;
    UserSession.email = email;
    UserSession.phone = phone;
    UserSession.role = role;
    UserSession.token = token;
  }

  // Fungsi untuk menghapus semua data saat logout
  static void hapus() {
    nama = '';
    email = '';
    phone = '';
    role = '';
    token = '';
  }

  // Fungsi helper: cek apakah user yang login adalah owner
  static bool get isOwner => role == 'owner';
}