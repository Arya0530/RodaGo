<?php
// LOKASI: app/Http/Controllers/Api/CityController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\City;

class CityController extends Controller
{
    // =========================================================================
    // GET /api/cities
    //
    // Ambil SEMUA kota dari tabel `cities`.
    // Tidak ada filter — semua kota yang ada di database ditampilkan di dropdown.
    //
    // Kenapa tidak difilter?
    //   Karena tabel cities adalah master data yang diisi admin.
    //   Kalau difilter hanya yang punya rental/mobil, kota seperti Surabaya,
    //   Jakarta, Bandung tidak akan muncul jika datanya dari seeder lama
    //   yang user_id-nya NULL dan tidak terhubung ke tabel rentals.
    //
    // Format response:
    //   [
    //     {"id": 1, "name": "Surabaya",       "province": "Jawa Timur"},
    //     {"id": 2, "name": "Jakarta Selatan", "province": "DKI Jakarta"},
    //     {"id": 3, "name": "Bandung",         "province": "Jawa Barat"},
    //     {"id": 4, "name": "Malang",          "province": "Jawa Timur"},
    //     {"id": 5, "name": "Blitar",          "province": "jawa timur"},
    //   ]
    // =========================================================================
    public function index()
    {
        $cities = City::orderBy('name')->get(['id', 'name', 'province']);
        return response()->json($cities, 200);
    }
}