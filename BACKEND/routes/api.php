<?php
// LOKASI: routes/api.php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MobilController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\CityController;

// ── Publik (tanpa token) ──────────────────────────────────────────────────────

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Semua mobil tersedia — tampilan awal beranda sebelum user pilih kota
// GET /api/mobil/public
Route::get('/mobil/public', [MobilController::class, 'publicIndex']);

// Cari mobil berdasarkan kota + filter tanggal booking
// GET /api/mobil/search?city_name=Surabaya&tanggal_mulai=2026-05-10&tanggal_selesai=2026-05-12
// city_name opsional → jika tidak dikirim, tampilkan semua kota (hanya filter tanggal)
Route::get('/mobil/search', [MobilController::class, 'searchAvailable']);

// Daftar kota dari tabel cities yang ada rental aktif + mobil tersedia
// GET /api/cities
// Format: [{"id":1,"name":"Surabaya","province":"Jawa Timur"}, ...]
Route::get('/cities', [CityController::class, 'index']);

// ── Butuh Token (auth:sanctum) ────────────────────────────────────────────────

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(Request $r) => $r->user());

    // PENTING: /mobil/public dan /mobil/search HARUS di luar middleware
    // karena apiResource akan override GET /mobil dengan index() yang butuh token.
    // Urutan route di atas sudah benar.

    // Mobil — owner kelola mobil miliknya
    Route::apiResource('mobil', MobilController::class);

    // Booking — User
    Route::get   ('/bookings',             [BookingController::class, 'index']);
    Route::post  ('/bookings',             [BookingController::class, 'store']);
    Route::delete('/bookings/{id}/cancel', [BookingController::class, 'cancel']);
    Route::post  ('/bookings/{id}/pay',    [BookingController::class, 'pay']);

    // Booking — Owner
    Route::get ('/owner/bookings',                [BookingController::class, 'ownerBookings']);
    Route::post('/owner/bookings/{id}/terima',    [BookingController::class, 'terima']);
    Route::post('/owner/bookings/{id}/tolak',     [BookingController::class, 'tolak']);
});