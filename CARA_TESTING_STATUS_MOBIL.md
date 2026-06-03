# Cara Testing Status Mobil Owner

## 🎯 Tujuan Testing
Memastikan status mobil di halaman "Kelola Mobil" owner berubah sesuai dengan tanggal hari ini.

---

## ✅ Yang Harus Dites

### 1. Status "Tersedia"
Status ini muncul ketika:
- Mobil tidak memiliki booking sama sekali
- Mobil memiliki booking di masa depan (tanggal booking belum dimulai)
- Mobil memiliki booking yang sudah selesai (tanggal booking sudah lewat)

### 2. Status "Disewa"
Status ini muncul ketika:
- Mobil memiliki booking AKTIF HARI INI
- Tanggal hari ini berada di antara tanggal_mulai dan tanggal_selesai booking
- Status booking adalah `unpaid` atau `completed`

---

## 🔍 Langkah-langkah Testing

### Persiapan Data Test
1. Login sebagai owner
2. Pastikan Anda memiliki minimal 1 mobil
3. Catat ID mobil tersebut

### Skenario 1: Booking di Masa Depan
**Tujuan:** Status harus tetap "Tersedia"

**Langkah:**
1. Buat booking untuk mobil owner dengan tanggal masa depan
   - Misalnya hari ini: 3 Juni 2026
   - Booking: 10 Juni - 12 Juni 2026
   - Status booking: `unpaid` atau `completed`

2. Buka halaman "Kelola Mobil" di aplikasi owner
3. **Expected:** Status mobil = **"Tersedia"** (warna hijau)

**Penjelasan:** Karena tanggal booking belum dimulai (10 Juni > 3 Juni)

---

### Skenario 2: Booking Sedang Berjalan
**Tujuan:** Status harus "Disewa"

**Langkah:**
1. Buat booking untuk mobil owner dengan tanggal yang mencakup hari ini
   - Misalnya hari ini: 3 Juni 2026
   - Booking: 1 Juni - 5 Juni 2026
   - Status booking: `unpaid` atau `completed`

2. Buka halaman "Kelola Mobil" di aplikasi owner
3. **Expected:** Status mobil = **"Disewa"** (warna orange)

**Penjelasan:** Karena tanggal hari ini (3 Juni) berada di antara 1 Juni - 5 Juni

---

### Skenario 3: Booking Sudah Selesai
**Tujuan:** Status harus kembali "Tersedia"

**Langkah:**
1. Buat booking untuk mobil owner dengan tanggal yang sudah lewat
   - Misalnya hari ini: 3 Juni 2026
   - Booking: 1 Juni - 2 Juni 2026 (sudah lewat)
   - Status booking: `completed`

2. Buka halaman "Kelola Mobil" di aplikasi owner
3. **Expected:** Status mobil = **"Tersedia"** (warna hijau)

**Penjelasan:** Karena tanggal booking sudah selesai (2 Juni < 3 Juni)

---

### Skenario 4: Multiple Bookings
**Tujuan:** Status berdasarkan booking yang aktif hari ini saja

**Langkah:**
1. Buat 3 booking untuk 1 mobil:
   - Booking 1: 1 Juni - 2 Juni (sudah lewat)
   - Booking 2: 10 Juni - 12 Juni (masa depan)
   - Booking 3: 15 Juni - 17 Juni (masa depan)
   - Hari ini: 3 Juni 2026

2. Buka halaman "Kelola Mobil" di aplikasi owner
3. **Expected:** Status mobil = **"Tersedia"** (warna hijau)

**Penjelasan:** Tidak ada booking yang mencakup tanggal hari ini (3 Juni)

---

## 🔧 Cara Membuat Data Test di Database

### Option 1: Menggunakan API (Recommended)
```bash
# Login sebagai user biasa (bukan owner)
POST /api/login
{
  "email": "user@test.com",
  "password": "password"
}

# Booking mobil milik owner
POST /api/bookings
{
  "mobil_id": 1,
  "tanggal_mulai": "2026-06-01",
  "tanggal_selesai": "2026-06-05"
}

# Owner terima booking
POST /api/owner/bookings/{id}/terima

# User bayar booking
POST /api/bookings/{id}/pay
```

### Option 2: Langsung ke Database
```sql
-- Insert booking langsung (untuk testing cepat)
INSERT INTO bookings (user_id, mobil_id, tanggal_mulai, tanggal_selesai, total_harga, status, created_at, updated_at)
VALUES (2, 1, '2026-06-01', '2026-06-05', 2000000, 'completed', NOW(), NOW());
```

---

## 🐛 Troubleshooting

### Masalah 1: Status Tidak Berubah Sama Sekali
**Kemungkinan Penyebab:**
1. Frontend belum di-reload setelah perubahan
2. Backend belum mengirim field `status_hari_ini`
3. Cache browser/aplikasi

**Solusi:**
1. Hot restart aplikasi Flutter (bukan hot reload)
2. Cek response API di network tab atau Postman:
   ```
   GET /api/mobil
   Authorization: Bearer <token>
   ```
   Response harus ada field: `"status_hari_ini": "Tersedia"` atau `"status_hari_ini": "Disewa"`

### Masalah 2: Status Selalu "Tersedia" Padahal Ada Booking Hari Ini
**Kemungkinan Penyebab:**
1. Status booking bukan `unpaid` atau `completed` (misalnya masih `pending`)
2. Tanggal booking tidak mencakup hari ini
3. Zona waktu server berbeda

**Solusi:**
1. Cek status booking di database:
   ```sql
   SELECT id, mobil_id, tanggal_mulai, tanggal_selesai, status 
   FROM bookings 
   WHERE mobil_id = 1 
   AND status IN ('unpaid', 'completed')
   AND tanggal_mulai <= CURDATE() 
   AND tanggal_selesai >= CURDATE();
   ```
2. Jika query di atas return empty → tidak ada booking aktif hari ini
3. Jika ada hasil → cek apakah backend query yang sama di `MobilController@index()`

### Masalah 3: Status Selalu "Disewa" Padahal Booking Sudah Selesai
**Kemungkinan Penyebab:**
1. Tanggal server salah (masih tertinggal)
2. Frontend masih menggunakan field `tersedia` lama

**Solusi:**
1. Cek tanggal server: `SELECT CURDATE();` di database
2. Cek kode frontend di `kelola_mobil_page.dart` baris ~134:
   ```dart
   final String statusHariIni = mobil['status_hari_ini'] ?? 'Tersedia';
   ```
   Pastikan menggunakan `status_hari_ini` bukan `tersedia`

---

## 📊 Cara Verifikasi Response API

### Menggunakan Flutter DevTools
1. Buka Flutter DevTools
2. Pergi ke tab "Network"
3. Trigger `_fetchMobil()` di aplikasi
4. Lihat request ke `/api/mobil`
5. Periksa response body, harus ada:
   ```json
   [
     {
       "id": 1,
       "nama": "Toyota Avanza",
       "gambar": "...",
       "tersedia": true,
       "status_hari_ini": "Tersedia"  // ← Field ini HARUS ada
     }
   ]
   ```

### Menggunakan Postman
1. Buat request baru: `GET {{baseUrl}}/api/mobil`
2. Tambah header:
   - `Authorization: Bearer <token_owner>`
   - `Accept: application/json`
3. Kirim request
4. Periksa response body seperti di atas

---

## ✅ Checklist Testing

- [ ] Status "Tersedia" untuk mobil tanpa booking
- [ ] Status "Tersedia" untuk mobil dengan booking masa depan
- [ ] Status "Disewa" untuk mobil dengan booking hari ini
- [ ] Status "Tersedia" untuk mobil dengan booking yang sudah selesai
- [ ] Status berubah otomatis ketika tanggal berganti (test manual: ubah tanggal server)
- [ ] Pull to refresh di halaman kelola mobil berfungsi
- [ ] Status di admin panel juga selaras (untuk cross-check)

---

## 📞 Jika Masih Bermasalah

Jika setelah mengikuti semua langkah di atas masalah masih ada, cek:

1. **File yang harus sudah diubah:**
   - ✅ `BACKEND/app/Http/Controllers/Api/MobilController.php`
   - ✅ `FRONTEND/lib/pages/owner/kelola_mobil_page.dart`

2. **Restart yang diperlukan:**
   - Backend: Tidak perlu restart (PHP langsung reload)
   - Frontend: **Hot restart** (bukan hot reload)

3. **Database check:**
   ```sql
   -- Cek booking aktif hari ini untuk mobil ID 1
   SELECT * FROM bookings 
   WHERE mobil_id = 1 
   AND status IN ('unpaid', 'completed')
   AND DATE(tanggal_mulai) <= CURDATE()
   AND DATE(tanggal_selesai) >= CURDATE();
   ```

4. **Backend log check:**
   Tambahkan log di `MobilController@index()` untuk debug:
   ```php
   \Log::info('Mobil disewa hari ini:', $mobilDisewaHariIni);
   ```

---

**Good luck testing!** 🚀
