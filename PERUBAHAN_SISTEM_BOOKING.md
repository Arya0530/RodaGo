# Dokumentasi Perubahan Sistem Booking - RodaGo

## Tanggal: 3 Juni 2026
## Versi: 2.0 (Revisi sesuai permintaan dosen)

---

## 📋 RINGKASAN PERUBAHAN

Sistem booking telah direvisi sesuai dengan ketentuan dosen:

### ✅ Yang Berubah:

1. **Mobil yang sudah dibooking TETAP TAMPIL di dashboard**
   - Semua mobil ditampilkan tanpa filter
   - User dapat melihat dan memilih mobil tersebut

2. **Validasi tanggal booking**
   - User harus memilih tanggal mulai dan tanggal selesai terlebih dahulu
   - Sistem memeriksa apakah rentang tanggal bertabrakan dengan booking yang sudah ada
   - Jika bertabrakan → tampilkan pesan error
   - Jika tidak bertabrakan → pemesanan dapat dilakukan

3. **Date picker di frontend disable tanggal yang sudah dibooking**
   - Tanggal yang sudah dibooking tidak dapat dipilih
   - User tidak perlu trial-error untuk menemukan tanggal yang tersedia

4. **Status mobil di dashboard owner/admin hanya dua: Tersedia dan Disewa**
   - Status "Disewa" hanya muncul jika tanggal HARI INI berada di antara tanggal mulai dan selesai rental yang aktif
   - Jika ada booking di masa depan tetapi tanggal sewanya belum dimulai, status tetap "Tersedia"
   - Contoh:
     - Hari ini: 3 Juni
     - Booking: 10-12 Juni
     - Status: **Tersedia**
     - Pada tanggal 10-12 Juni: **Disewa**
     - Setelah 12 Juni: **Tersedia**

---

## 🔧 PERUBAHAN TEKNIS DETAIL

### 1. BACKEND

#### A. Routes (api.php)
**File:** `e:\RodaGo\BACKEND\routes\api.php`

**Perubahan:**
```php
// TAMBAHAN: Endpoint untuk mengambil tanggal yang sudah dibooking
Route::get('/mobil/{id}/booked-dates', [MobilController::class, 'getBookedDates']);
```

#### B. MobilController.php
**File:** `e:\RodaGo\BACKEND\app\Http\Controllers\Api\MobilController.php`

**Perubahan:**
1. **Tambah method baru `getBookedDates()`**
   ```php
   public function getBookedDates($id)
   {
       $bookedRanges = DB::table('bookings')
           ->where('mobil_id', $id)
           ->whereIn('status', ['pending', 'unpaid', 'completed'])
           ->select('tanggal_mulai', 'tanggal_selesai')
           ->get()
           ->map(function ($booking) {
               return [
                   'start' => $booking->tanggal_mulai,
                   'end'   => $booking->tanggal_selesai,
               ];
           });

       return response()->json([
           'success' => true,
           'data'    => $bookedRanges,
       ]);
   }
   ```

2. **publicIndex()** - Sudah sesuai (tampilkan semua mobil)
3. **searchAvailable()** - Sudah sesuai (exclude hanya mobil yang bentrok tanggal)
4. **index()** - Sudah sesuai (tambah field status_hari_ini)

#### C. BookingController.php
**File:** `e:\RodaGo\BACKEND\app\Http\Controllers\Api\BookingController.php`

**Status:** Sudah sesuai dengan revisi dosen
- `store()` - Validasi bentrok tanggal sudah ada
- `pay()` - Sudah tidak mengubah flag tersedia

#### D. AdminController.php
**File:** `e:\RodaGo\BACKEND\app\Http\Controllers\AdminController.php`

**Perubahan:**
```php
public function cars()
{
    // ... query mobil ...

    // REVISI: Hitung mobil yang SEDANG DISEWA HARI INI saja
    $today = \Carbon\Carbon::today();
    $mobilDisewaHariIni = DB::table('bookings')
        ->whereIn('status', ['unpaid', 'completed'])
        ->whereDate('tanggal_mulai', '<=', $today)
        ->whereDate('tanggal_selesai', '>=', $today)
        ->pluck('mobil_id')
        ->unique()
        ->count();

    $stats = [
        'total'    => DB::table('mobils')->count(),
        'tersedia' => DB::table('mobils')->where('tersedia', true)->count(),
        'disewa'   => $mobilDisewaHariIni, // ← PERUBAHAN
    ];

    return view('admin.cars', compact('mobils', 'stats'));
}
```

#### E. cars.blade.php
**File:** `e:\RodaGo\BACKEND\resources\views\admin\cars.blade.php`

**Perubahan:**
```php
@php
    // Status berdasarkan apakah ada booking aktif HARI INI
    $today = \Carbon\Carbon::today();
    $sedangDisewaHariIni = \App\Models\Booking::where('mobil_id', $mobil->id)
        ->whereIn('status', ['unpaid', 'completed'])
        ->whereDate('tanggal_mulai', '<=', $today)
        ->whereDate('tanggal_selesai', '>=', $today)
        ->exists();

    if (!$mobil->tersedia) {
        $badgeClass = 'bg-red-50 text-red-500';
        $badgeText  = 'Nonaktif';
    } elseif ($sedangDisewaHariIni) {
        $badgeClass = 'bg-amber-50 text-amber-600';
        $badgeText  = 'Sedang Disewa';
    } else {
        $badgeClass = 'bg-emerald-50 text-emerald-600';
        $badgeText  = 'Tersedia';
    }
@endphp
```

---

### 2. FRONTEND

#### A. ApiService.dart
**File:** `e:\RodaGo\FRONTEND\lib\service\api_service.dart`

**Perubahan:**
```dart
/// GET /api/mobil/{id}/booked-dates
/// Ambil semua rentang tanggal yang sudah dibooking untuk mobil tertentu
static Future<List<dynamic>> getBookedDates(int mobilId) async {
  try {
    final res = await http
        .get(Uri.parse('$baseUrl/api/mobil/$mobilId/booked-dates'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (body['data'] ?? []) as List<dynamic>;
    }
    return [];
  } catch (e) {
    debugPrint('getBookedDates error: $e');
    return [];
  }
}
```

#### B. detail_mobil_page.dart
**File:** `e:\RodaGo\FRONTEND\lib\pages\dashboard\detail_mobil_page.dart`

**Perubahan Besar:**
1. **Ambil data tanggal yang sudah dibooking**
   ```dart
   void _tampilkanFormJadwal(BuildContext pageContext) async {
     // Ambil daftar tanggal yang sudah dibooking
     final bookedDates = await ApiService.getBookedDates(carData['id']);
     
     // Parse booking ranges menjadi set tanggal yang tidak bisa dipilih
     Set<DateTime> disabledDates = {};
     for (var booking in bookedDates) {
       final start = DateTime.parse(booking['start'].toString());
       final end = DateTime.parse(booking['end'].toString());
       
       // Tambahkan semua tanggal dalam rentang booking
       for (var date = start; date.isBefore(end.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
         disabledDates.add(DateTime(date.year, date.month, date.day));
       }
     }
     // ...
   }
   ```

2. **Date picker dengan selectableDayPredicate**
   ```dart
   DateTime? pickedDate = await showDatePicker(
     context: sheetContext,
     initialDate: DateTime.now(),
     firstDate: DateTime.now(),
     lastDate: DateTime(2030),
     selectableDayPredicate: (DateTime date) {
       // Disable tanggal yang sudah dibooking
       final normalizedDate = DateTime(date.year, date.month, date.day);
       return !disabledDates.contains(normalizedDate);
     },
     // ...
   );
   ```

3. **Validasi untuk tanggal kembali**
   - Cek apakah ada tanggal yang dibooking di antara tanggal ambil dan tanggal kembali
   - Disable tanggal kembali jika ada booking yang menghalangi

4. **Tambah info banner**
   ```dart
   Container(
     padding: EdgeInsets.all(12),
     decoration: BoxDecoration(
       color: Colors.orange[50],
       borderRadius: BorderRadius.circular(12),
       border: Border.all(color: Colors.orange[200]!),
     ),
     child: Row(
       children: [
         Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
         SizedBox(width: 8),
         Expanded(
           child: Text(
             'Tanggal yang sudah dibooking tidak dapat dipilih',
             style: TextStyle(
               fontSize: 12,
               color: Colors.orange[700],
               fontWeight: FontWeight.w500,
             ),
           ),
         ),
       ],
     ),
   )
   ```

---

## 🎯 CARA KERJA SISTEM BARU

### Skenario 1: User Melihat Mobil
1. User membuka halaman beranda
2. **SEMUA mobil ditampilkan** (termasuk yang sedang dibooking)
3. User melihat detail mobil → klik "Pesan Sekarang"

### Skenario 2: User Memilih Tanggal
1. System mengambil data tanggal yang sudah dibooking untuk mobil tersebut
2. Date picker menampilkan kalender
3. **Tanggal yang sudah dibooking tidak dapat dipilih** (disabled)
4. User hanya dapat memilih tanggal yang masih tersedia

### Skenario 3: User Booking Mobil
1. User memilih tanggal yang tersedia
2. Klik "Konfirmasi & Bayar"
3. Backend melakukan validasi final:
   - Cek apakah ada bentrok tanggal
   - Jika ya → tolak dengan pesan error
   - Jika tidak → buat booking baru

### Skenario 4: Owner/Admin Melihat Status
1. Owner/admin membuka dashboard
2. Melihat tabel mobil dengan status:
   - **Tersedia**: Tidak ada booking aktif hari ini
   - **Sedang Disewa**: Ada booking aktif hari ini (tanggal_mulai <= today <= tanggal_selesai)
   - **Nonaktif**: Mobil dinonaktifkan manual oleh owner/admin

---

## 🔍 CONTOH KASUS

### Kasus 1: Booking di Masa Depan
- **Hari ini:** 3 Juni 2026
- **Booking existing:** 10 Juni - 12 Juni 2026
- **Status di dashboard:** **Tersedia** ✅
- **User dapat booking?** Ya, untuk tanggal 3-9 Juni atau 13 Juni ke atas
- **User tidak dapat booking?** 10-12 Juni (disabled di date picker)

### Kasus 2: Booking Sedang Berjalan
- **Hari ini:** 10 Juni 2026
- **Booking existing:** 10 Juni - 12 Juni 2026
- **Status di dashboard:** **Disewa** 🚗
- **User dapat booking?** Ya, untuk tanggal 13 Juni ke atas
- **User tidak dapat booking?** 10-12 Juni (disabled di date picker)

### Kasus 3: Booking Sudah Selesai
- **Hari ini:** 13 Juni 2026
- **Booking existing:** 10 Juni - 12 Juni 2026 (completed)
- **Status di dashboard:** **Tersedia** ✅
- **User dapat booking?** Ya, semua tanggal mulai dari 13 Juni

### Kasus 4: Multiple Booking
- **Hari ini:** 3 Juni 2026
- **Booking 1:** 5 Juni - 7 Juni
- **Booking 2:** 10 Juni - 12 Juni
- **Status di dashboard:** **Tersedia** ✅
- **Tanggal yang disabled:** 5-7 Juni dan 10-12 Juni
- **Tanggal yang tersedia:** 3-4 Juni, 8-9 Juni, 13 Juni ke atas

---

## ✅ CHECKLIST IMPLEMENTASI

- [x] Backend: Tambah endpoint `/api/mobil/{id}/booked-dates`
- [x] Backend: Method `getBookedDates()` di MobilController
- [x] Backend: Sesuaikan logika status di AdminController
- [x] Backend: Update view `cars.blade.php` dengan logika status baru
- [x] Frontend: Tambah method `getBookedDates()` di ApiService
- [x] Frontend: Implementasi date picker dengan `selectableDayPredicate`
- [x] Frontend: Validasi tanggal kembali agar tidak melewati booking
- [x] Frontend: Tambah info banner tentang tanggal yang tidak tersedia
- [x] Testing: Validasi bentrok tanggal di backend tetap berfungsi
- [x] Testing: Status mobil sesuai dengan tanggal hari ini

---

## 🚀 CARA TESTING

### Test 1: Lihat Semua Mobil
1. Buka aplikasi Flutter
2. Lihat dashboard → **semua mobil harus tampil**

### Test 2: Date Picker Disable Tanggal Booked
1. Pilih mobil yang sudah ada bookingnya
2. Klik "Pesan Sekarang"
3. Pilih tanggal ambil → **tanggal yang sudah dibooking tidak dapat dipilih**

### Test 3: Validasi Backend Tetap Berfungsi
1. Coba booking dengan tanggal yang bentrok (pakai API langsung atau manipulasi)
2. Backend harus menolak dengan pesan error

### Test 4: Status di Dashboard Admin
1. Login sebagai admin
2. Buka halaman "Data Armada"
3. Periksa status mobil:
   - Mobil dengan booking hari ini → **Disewa**
   - Mobil dengan booking masa depan → **Tersedia**
   - Mobil dengan booking sudah lewat → **Tersedia**

---

## 📝 CATATAN PENTING

1. **Validasi ganda:** Frontend disable tanggal + Backend validasi bentrok = keamanan maksimal
2. **Real-time status:** Status mobil dihitung berdasarkan tanggal hari ini, bukan flag statis
3. **Backward compatible:** Sistem lama masih berfungsi, hanya ditambahkan fitur baru
4. **User experience:** User tidak perlu trial-error untuk menemukan tanggal yang tersedia

---

## 🐛 POTENSI MASALAH & SOLUSI

### Masalah 1: Tanggal yang seharusnya disabled masih bisa dipilih
**Solusi:** Pastikan endpoint `/api/mobil/{id}/booked-dates` mengembalikan data yang benar

### Masalah 2: Status "Disewa" tidak muncul padahal ada booking hari ini
**Solusi:** Cek apakah status booking adalah `unpaid` atau `completed` (bukan `pending`)

### Masalah 3: User masih bisa booking tanggal yang sudah dibooking
**Solusi:** Validasi backend di `BookingController@store()` sudah ada, pastikan tidak di-comment

---

## 📞 KONTAK DEVELOPER

Jika ada pertanyaan atau masalah, hubungi:
- **Developer:** AI Assistant (Kiro)
- **Tanggal:** 3 Juni 2026

---

**SELESAI** ✅
