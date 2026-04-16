<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\MobilController; // <-- TAMBAHAN BARU

// ============================================================
// PUBLIC PAGES (TIDAK BERUBAH)
// ============================================================
Route::get('/', fn() => view('home'));
Route::get('/features', fn() => view('features'));
Route::get('/about', fn() => view('about'));
Route::get('/contact', fn() => view('contact'));

// ============================================================
// ROUTE DETAIL MOBIL (TAMBAHAN BARU)
// URL: /mobil/toyota-avanza-veloz → MobilController@show
// {slug} adalah bagian dinamis yang otomatis dikirim ke method show()
// ============================================================
Route::get('/mobil/{slug}', [MobilController::class, 'show'])->name('mobil.detail');

// ============================================================
// AUTH (TIDAK BERUBAH)
// ============================================================
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'authenticate']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// ============================================================
// ADMIN ROUTES (TIDAK BERUBAH)
// ============================================================
Route::middleware(['auth'])->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);
    Route::get('/admin/users', [AdminController::class, 'users']);
    Route::post('/admin/users', [AdminController::class, 'storeUser']);
    Route::delete('/admin/users/{id}', [AdminController::class, 'destroyUser']);
    Route::put('/admin/users/{id}', [AdminController::class, 'updateUser']);
    Route::get('/admin/rentals', [AdminController::class, 'rentals']);
    Route::get('/admin/cars', [AdminController::class, 'cars']);
    Route::get('/admin/bookings', [AdminController::class, 'bookings']);
    Route::get('/admin/cities', [AdminController::class, 'cities']);
    Route::post('/admin/rentals', [AdminController::class, 'storeRental']);
    Route::put('/admin/rentals/{id}', [AdminController::class, 'updateRental']);
    Route::delete('/admin/rentals/{id}', [AdminController::class, 'destroyRental']);
    Route::post('/admin/cities', [AdminController::class, 'storeCity']);
    Route::put('/admin/cities/{id}', [AdminController::class, 'updateCity']);
    Route::delete('/admin/cities/{id}', [AdminController::class, 'destroyCity']);
});