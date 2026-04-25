<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ApiAuthController; // Manggil Controller API
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MobilController;
use App\Http\Controllers\Api\BookingController;



// Rute publik (TIDAK perlu login)
Route::post('/register', [ApiAuthController::class, 'register']);
Route::post('/login', [ApiAuthController::class, 'login']);

// Endpoint publik untuk customer melihat daftar mobil
Route::get('/mobil/public', [MobilController::class, 'publicIndex']);

// Rute yang butuh Token (Harus udah login di HP)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [ApiAuthController::class, 'logout']);
    
    // Tarik data profil
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Mobil routes - Protected dengan auth:sanctum
    Route::apiResource('mobil', MobilController::class);

    Route::get('/bookings', [BookingController::class, 'index']);
Route::post('/bookings', [BookingController::class, 'store']);
Route::delete('/bookings/{id}/cancel', [BookingController::class, 'cancel']);

Route::get('/owner/bookings', [BookingController::class, 'ownerBookings']);
Route::post('/owner/bookings/{id}/terima', [BookingController::class, 'terima']);
Route::post('/owner/bookings/{id}/tolak', [BookingController::class, 'tolak']);

Route::post('/bookings/{id}/pay', [BookingController::class, 'pay']);
});