<?php
// LOKASI: app/Http/Controllers/Api/MobilController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mobil;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class MobilController extends Controller
{
    // =========================================================================
    // GET /api/mobil/public
    //
    // Tampilkan SEMUA mobil yang tersedia = true.
    // Tidak peduli apakah mobilnya punya user_id atau tidak,
    // tidak peduli apakah ownernya sudah punya rental atau belum.
    //
    // Pakai LEFT JOIN ke users dan rentals supaya:
    //   - Mobil dengan user_id NULL  → tetap muncul (nama_rental = null)
    //   - Mobil dengan owner yang belum punya rental → tetap muncul
    //   - Mobil dengan owner yang sudah punya rental → muncul + ada nama_rental
    // =========================================================================
    public function publicIndex()
    {
        $mobils = DB::table('mobils')
            ->leftJoin('users',   'users.id',         '=', 'mobils.user_id')
            ->leftJoin('rentals', 'rentals.user_id',   '=', 'users.id')
            ->where('mobils.tersedia', true)
            ->select(
                'mobils.id',
                'mobils.nama',
                'mobils.slug',
                'mobils.tipe',
                'mobils.harga',
                'mobils.kursi',
                'mobils.transmisi',
                'mobils.bahan_bakar',
                'mobils.deskripsi',
                'mobils.gambar',
                'mobils.tersedia',
                'mobils.user_id',
                'rentals.brand_name as nama_rental',
                'rentals.city       as kota_rental'
            )
            ->get();

        return response()->json($mobils, 200);
    }

    // =========================================================================
    // GET /api/mobil/search
    //   ?city_name=Surabaya        ← nama kota (dari rentals.city)
    //   &tanggal_mulai=2026-05-10
    //   &tanggal_selesai=2026-05-12
    //
    // LOGIKA FILTER:
    //
    // 1. Filter Kota (hanya jika city_name dikirim):
    //    - Pakai LEFT JOIN ke rentals
    //    - Jika city_name ada → filter WHERE rentals.city = city_name
    //    - Jika city_name kosong → tampilkan semua (tidak filter kota)
    //
    // 2. Filter Tanggal:
    //    - Exclude mobil yang punya booking AKTIF (pending/unpaid/active)
    //      yang tanggalnya OVERLAP dengan rentang dicari.
    //    - Overlap: booking.mulai <= selesaiCari AND booking.selesai >= mulaiCari
    //
    // 3. Mobil tersedia = false selalu dikecualikan.
    // =========================================================================
    public function searchAvailable(Request $request)
    {
        $request->validate([
            'city_name'       => 'nullable|string|max:100',
            'tanggal_mulai'   => 'required|date',
            'tanggal_selesai' => 'required|date|after:tanggal_mulai',
        ]);

        $cityName       = $request->city_name;
        $tanggalMulai   = $request->tanggal_mulai;
        $tanggalSelesai = $request->tanggal_selesai;

        // Step 1: Ambil ID mobil yang sudah ada booking aktif di rentang ini
        $mobilDipesan = DB::table('bookings')
            ->whereIn('status', ['pending', 'unpaid', 'active'])
            ->where('tanggal_mulai',   '<=', $tanggalSelesai)
            ->where('tanggal_selesai', '>=', $tanggalMulai)
            ->pluck('mobil_id')
            ->toArray();

        // Step 2: Query utama dengan LEFT JOIN
        // LEFT JOIN supaya mobil tanpa owner/rental tetap bisa muncul
        // (relevan untuk data seeder / data lama)
        $query = DB::table('mobils')
            ->leftJoin('users',   'users.id',        '=', 'mobils.user_id')
            ->leftJoin('rentals', 'rentals.user_id', '=', 'users.id')
            ->where('mobils.tersedia', true)
            ->whereNotIn('mobils.id', $mobilDipesan)
            ->select(
                'mobils.id',
                'mobils.nama',
                'mobils.slug',
                'mobils.tipe',
                'mobils.harga',
                'mobils.kursi',
                'mobils.transmisi',
                'mobils.bahan_bakar',
                'mobils.deskripsi',
                'mobils.gambar',
                'mobils.tersedia',
                'mobils.user_id',
                'rentals.brand_name as nama_rental',
                'rentals.city       as kota_rental'
            );

        // Step 3: Filter kota — hanya jika city_name dikirim
        // Ini filter berdasarkan rentals.city milik owner si mobil
        if (!empty($cityName)) {
            $query->where('rentals.city', $cityName);
        }

        $mobils = $query->orderBy('mobils.nama')->get();

        return response()->json([
            'success' => true,
            'data'    => $mobils,
        ], 200);
    }

    // =========================================================================
    // GET /api/mobil — daftar mobil milik owner yang login
    // =========================================================================
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user) {
            return response()->json(Mobil::where('user_id', $user->id)->get());
        }
        return response()->json([]);
    }

    // =========================================================================
    // POST /api/mobil — owner tambah mobil baru
    // =========================================================================
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama'        => 'required|string|max:255',
            'tipe'        => 'required|string',
            'harga'       => 'required|integer',
            'kursi'       => 'required|integer',
            'transmisi'   => 'required|string',
            'bahan_bakar' => 'required|string',
            'deskripsi'   => 'nullable|string',
            'gambar'      => 'nullable|string',
            'tersedia'    => 'boolean',
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $validated['user_id']  = $user->id;
        $validated['slug']     = Str::slug($validated['nama']) . '-' . Str::random(4);
        $validated['tersedia'] = true;

        $mobil = Mobil::create($validated);
        return response()->json($mobil, 201);
    }

    // =========================================================================
    // GET /api/mobil/{id}
    // =========================================================================
    public function show(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        $user  = $request->user();
        if ($user && $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        return response()->json($mobil);
    }

    // =========================================================================
    // PUT /api/mobil/{id}
    // =========================================================================
    public function update(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        $user  = $request->user();
        if (!$user || $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'nama'        => 'sometimes|string|max:255',
            'tipe'        => 'sometimes|string',
            'harga'       => 'sometimes|integer',
            'kursi'       => 'sometimes|integer',
            'transmisi'   => 'sometimes|string',
            'bahan_bakar' => 'sometimes|string',
            'deskripsi'   => 'nullable|string',
            'gambar'      => 'nullable|string',
            'tersedia'    => 'boolean',
        ]);

        if (isset($validated['nama'])) {
            $validated['slug'] = Str::slug($validated['nama']) . '-' . Str::random(4);
        }

        $mobil->update($validated);
        return response()->json($mobil);
    }

    // =========================================================================
    // DELETE /api/mobil/{id}
    // =========================================================================
    public function destroy(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        $user  = $request->user();
        if (!$user || $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        $mobil->delete();
        return response()->json(['message' => 'Mobil dihapus']);
    }
}