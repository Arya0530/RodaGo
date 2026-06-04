<?php
// ============================================================
// LOKASI FILE: routes/api.php
// ============================================================
// PERUBAHAN dari versi lama:
//   - Tambah 1 baris route: POST /forgot-password
//   - Tambah 1 baris use:   use App\Http\Controllers\Api\PasswordResetController;
//   - SEMUA yang lain TIDAK DIUBAH
// ============================================================

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MobilController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\KycController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PasswordResetController; // ← TAMBAHAN BARU
use App\Http\Controllers\AdminBookingController;
use App\Http\Controllers\ChatController;

// ── Publik (tanpa token) ──────────────────────────────────────────────────────

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

Route::post('/forgot-password', [PasswordResetController::class, 'reset']); // ← TAMBAHAN BARU
Route::post('/chat/send', [ChatController::class, 'sendToAI']);

Route::get('/mobil/public', [MobilController::class, 'publicIndex']);
Route::get('/mobil/search', [MobilController::class, 'searchAvailable']);
Route::get('/mobil/{id}/booked-dates', [MobilController::class, 'getBookedDates']); // ← TAMBAHAN
Route::get('/cities',       [CityController::class, 'index']);

// ── Butuh Token (auth:sanctum) ────────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(Request $r) => $r->user());

    Route::put('/user/profile', [AuthController::class, 'updateProfile']);

    // ── KYC ───────────────────────────────────────────────────────────────────
    Route::get ('/kyc/status',              [KycController::class, 'status']);
    Route::post('/kyc/upload',              [KycController::class, 'upload']);
    Route::get ('/kyc/booking/{bookingId}', [KycController::class, 'getByBookingId']);

    // ── Mobil ─────────────────────────────────────────────────────────────────
    Route::apiResource('mobil', MobilController::class);
    Route::post('/mobil/{mobil}', [MobilController::class, 'update']);

    // ── Booking — User ────────────────────────────────────────────────────────
    Route::get   ('/bookings',             [BookingController::class, 'index']);
    Route::post  ('/bookings',             [BookingController::class, 'store']);
    Route::delete('/bookings/{id}/cancel', [BookingController::class, 'cancel']);
    Route::post  ('/bookings/{id}/pay',    [BookingController::class, 'pay']);

    // ── Booking — Owner ───────────────────────────────────────────────────────
    Route::get ('/owner/bookings',             [BookingController::class, 'ownerBookings']);
    Route::post('/owner/bookings/{id}/terima', [BookingController::class, 'terima']);
    Route::post('/owner/bookings/{id}/tolak',  [BookingController::class, 'tolak']);
    Route::get ('/owner/dashboard',            [BookingController::class, 'ownerDashboard']);

    Route::get('/bookings/auto-complete', [BookingController::class, 'autoComplete']);

    // ── Notifikasi ────────────────────────────────────────────────────────────
    Route::get ('/notifications',               [NotificationController::class, 'index']);
    Route::get ('/notifications/unread-count',  [NotificationController::class, 'unreadCount']);
    Route::post('/notifications/{id}/read',     [NotificationController::class, 'markRead']);
    Route::post('/notifications/read-all',      [NotificationController::class, 'markAllRead']);

    // ── Admin ─────────────────────────────────────────────────────────────────
    Route::post('/admin/bookings/{id}/force-cancel', [AdminBookingController::class, 'forceCancel']);   
});