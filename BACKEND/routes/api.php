<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ApiAuthController; // Manggil Controller API

// Rute buat HP (Flutter)
Route::post('/register', [ApiAuthController::class, 'register']);
Route::post('/login', [ApiAuthController::class, 'login']);

// Rute yang butuh Token (Harus udah login di HP)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [ApiAuthController::class, 'logout']);
    
    // Tarik data profil
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});