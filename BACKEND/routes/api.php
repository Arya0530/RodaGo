<?php
// LOKASI: routes/api.php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MobilController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\AdminBookingController; // ✅ TAMBAHAN — untuk admin force-cancel via API

// ── Publik (tanpa token) ──────────────────────────────────────────────────────

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

Route::get('/mobil/public',  [MobilController::class, 'publicIndex']);
Route::get('/mobil/search',  [MobilController::class, 'searchAvailable']);
Route::get('/cities',        [CityController::class, 'index']);

// ── Butuh Token (auth:sanctum) ────────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(Request $r) => $r->user());

    // Mobil — owner kelola mobil miliknya
    Route::apiResource('mobil', MobilController::class);

    // Booking — User
    Route::get   ('/bookings',             [BookingController::class, 'index']);
    Route::post  ('/bookings',             [BookingController::class, 'store']);
    Route::delete('/bookings/{id}/cancel', [BookingController::class, 'cancel']);
    Route::post  ('/bookings/{id}/pay',    [BookingController::class, 'pay']);

    // Booking — Owner
    Route::get ('/owner/bookings',                  [BookingController::class, 'ownerBookings']);
    Route::post('/owner/bookings/{id}/terima',      [BookingController::class, 'terima']);
    Route::post('/owner/bookings/{id}/tolak',       [BookingController::class, 'tolak']);
    Route::get ('/owner/dashboard',                 [BookingController::class, 'ownerDashboard']);

    // ✅ TAMBAHAN — Admin force-cancel via API (untuk sinkronisasi Flutter)
    // POST /api/admin/bookings/{id}/force-cancel
    // Header: Authorization: Bearer <admin_token>
    // Body (opsional): { "cancel_reason": "..." }
    Route::post('/admin/bookings/{id}/force-cancel', [AdminBookingController::class, 'forceCancel']);

});