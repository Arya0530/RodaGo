<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ApiAuthController; // Manggil Controller API
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MobilController;



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
});