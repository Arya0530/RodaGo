<?php
// LOKASI: routes/api.php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MobilController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\KycController;        // ← TAMBAHAN
use App\Http\Controllers\AdminBookingController;

// ── Publik (tanpa token) ──────────────────────────────────────────────────────

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

Route::get('/mobil/public', [MobilController::class, 'publicIndex']);
Route::get('/mobil/search', [MobilController::class, 'searchAvailable']);
Route::get('/cities',       [CityController::class, 'index']);

// ── Butuh Token (auth:sanctum) ────────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(Request $r) => $r->user());

    // ── KYC ───────────────────────────────────────────────────────────────────
    // GET  /api/kyc/status          → cek status KYC user yang login
    // POST /api/kyc/upload          → upload KTP + SIM (multipart/form-data)
    // GET  /api/kyc/booking/{id}    → owner lihat KYC penyewa di booking tertentu
    Route::get ('/kyc/status',          [KycController::class, 'status']);
    Route::post('/kyc/upload',          [KycController::class, 'upload']);
    Route::get ('/kyc/booking/{bookingId}', [KycController::class, 'getByBookingId']);

    // ── Mobil ─────────────────────────────────────────────────────────────────
    Route::apiResource('mobil', MobilController::class);
    Route::post('/mobil/{mobil}', [MobilController::class, 'update']); // method spoofing untuk multipart PUT

    // ── Booking — User ────────────────────────────────────────────────────────
    Route::get   ('/bookings',             [BookingController::class, 'index']);
    Route::post  ('/bookings',             [BookingController::class, 'store']);
    Route::delete('/bookings/{id}/cancel', [BookingController::class, 'cancel']);
    Route::post  ('/bookings/{id}/pay',    [BookingController::class, 'pay']);

    // ── Booking — Owner ───────────────────────────────────────────────────────
    Route::get ('/owner/bookings',                 [BookingController::class, 'ownerBookings']);
    Route::post('/owner/bookings/{id}/terima',     [BookingController::class, 'terima']);
    Route::post('/owner/bookings/{id}/tolak',      [BookingController::class, 'tolak']);
    Route::get ('/owner/dashboard',                [BookingController::class, 'ownerDashboard']);

    Route::get('/bookings/auto-complete', [BookingController::class, 'autoComplete']);

    // ── Admin ─────────────────────────────────────────────────────────────────
    Route::post('/admin/bookings/{id}/force-cancel', [AdminBookingController::class, 'forceCancel']);
});