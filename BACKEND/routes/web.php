<?php
// LOKASI: routes/web.php
// PERUBAHAN dari versi lama:
//   - Tambah 1 route: GET /admin/gambar → ImageProxyController
//   - Tambah 1 use:   use App\Http\Controllers\ImageProxyController;
//   - Duplikat Route::get('/admin/cars') dihapus (ada 2 sebelumnya)
//   - SEMUA yang lain TIDAK DIUBAH

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\MobilController;
use App\Http\Controllers\CityController;
use App\Http\Controllers\AdminBookingController;
use App\Http\Controllers\KycAdminController;
use App\Http\Controllers\ImageProxyController; // ← TAMBAHAN BARU

// ============================================================
// PUBLIC PAGES
// ============================================================
Route::get('/', [HomeController::class, 'index']);
Route::get('/features', fn() => view('features'));
Route::get('/about', fn() => view('about'));
Route::get('/contact', fn() => view('contact'));

// ============================================================
// ROUTE DETAIL MOBIL
// ============================================================
Route::get('/mobil/{slug}', [MobilController::class, 'show'])->name('mobil.detail');

// ============================================================
// AUTH
// ============================================================
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'authenticate']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// ============================================================
// ADMIN ROUTES
// ============================================================
Route::middleware(['auth'])->group(function () {

    // --- Dashboard ---
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);

    Route::get('/admin/api/live-stats',      [AdminController::class, 'liveStats']);
    Route::get('/admin/api/recent-activity', [AdminController::class, 'recentActivity']);

    // ✅ TAMBAHAN BARU: Proxy gambar ngrok → atasi ngrok warning di browser
    Route::get('/admin/gambar', [ImageProxyController::class, 'show']);

    // --- Users ---
    Route::get('/admin/users',         [AdminController::class, 'users']);
    Route::post('/admin/users',        [AdminController::class, 'storeUser']);
    Route::put('/admin/users/{id}',    [AdminController::class, 'updateUser']);
    Route::delete('/admin/users/{id}', [AdminController::class, 'destroyUser']);

    // --- Rentals ---
    Route::get('/admin/rentals',         [AdminController::class, 'rentals']);
    Route::post('/admin/rentals',        [AdminController::class, 'storeRental']);
    Route::put('/admin/rentals/{id}',    [AdminController::class, 'updateRental']);
    Route::delete('/admin/rentals/{id}', [AdminController::class, 'destroyRental']);

    // --- Cars ---
    Route::get('/admin/cars',                  [AdminController::class, 'cars']);
    Route::post('/admin/cars/{id}/toggle',     [AdminController::class, 'carToggle']);

    // --- Bookings ---
    Route::get('/admin/bookings',                    [AdminBookingController::class, 'index']);
    Route::get('/admin/bookings/{id}',               [AdminBookingController::class, 'show']);
    Route::put('/admin/bookings/{id}',               [AdminBookingController::class, 'update']);
    Route::delete('/admin/bookings/{id}',            [AdminBookingController::class, 'destroy']);
    Route::post('/admin/bookings/{id}/force-cancel', [AdminBookingController::class, 'forceCancel']);

    // --- Cities ---
    Route::get('/admin/cities',          [AdminController::class, 'cities']);
    Route::post('/admin/cities',         [AdminController::class, 'storeCity']);
    Route::put('/admin/cities/{id}',     [AdminController::class, 'updateCity']);
    Route::delete('/admin/cities/{id}',  [AdminController::class, 'destroyCity']);

    // --- KYC ---
    Route::get('/admin/kyc',                   [KycAdminController::class, 'index'])  ->name('admin.kyc');
    Route::post('/admin/kyc/{id}/approve',     [KycAdminController::class, 'approve'])->name('admin.kyc.approve');
    Route::post('/admin/kyc/{id}/reject',      [KycAdminController::class, 'reject']) ->name('admin.kyc.reject');
});