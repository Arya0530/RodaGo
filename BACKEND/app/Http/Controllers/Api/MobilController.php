<?php
// LOKASI: app/Http/Controllers/Api/MobilController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mobil;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class MobilController extends Controller
{
    // ── GET /api/mobil/public ─────────────────────────────────────────────────
    public function publicIndex()
    {
        $mobils = DB::table('mobils')
            ->leftJoin('users',   'users.id',        '=', 'mobils.user_id')
            ->leftJoin('rentals', 'rentals.user_id', '=', 'users.id')
            ->where('mobils.tersedia', true)
            ->select(
                'mobils.id', 'mobils.nama', 'mobils.slug', 'mobils.tipe',
                'mobils.harga', 'mobils.kursi', 'mobils.transmisi',
                'mobils.bahan_bakar', 'mobils.deskripsi', 'mobils.gambar',
                'mobils.tersedia', 'mobils.user_id',
                'rentals.brand_name as nama_rental',
                'rentals.city       as kota_rental'
            )
            ->get();

        return response()->json($mobils, 200);
    }

    // ── GET /api/mobil/search ─────────────────────────────────────────────────
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

        $mobilDipesan = DB::table('bookings')
            ->whereIn('status', ['pending', 'unpaid', 'active'])
            ->where('tanggal_mulai',   '<=', $tanggalSelesai)
            ->where('tanggal_selesai', '>=', $tanggalMulai)
            ->pluck('mobil_id')
            ->toArray();

        $query = DB::table('mobils')
            ->leftJoin('users',   'users.id',        '=', 'mobils.user_id')
            ->leftJoin('rentals', 'rentals.user_id', '=', 'users.id')
            ->where('mobils.tersedia', true)
            ->whereNotIn('mobils.id', $mobilDipesan)
            ->select(
                'mobils.id', 'mobils.nama', 'mobils.slug', 'mobils.tipe',
                'mobils.harga', 'mobils.kursi', 'mobils.transmisi',
                'mobils.bahan_bakar', 'mobils.deskripsi', 'mobils.gambar',
                'mobils.tersedia', 'mobils.user_id',
                'rentals.brand_name as nama_rental',
                'rentals.city       as kota_rental'
            );

        if (!empty($cityName)) {
            $query->where('rentals.city', $cityName);
        }

        return response()->json([
            'success' => true,
            'data'    => $query->orderBy('mobils.nama')->get(),
        ], 200);
    }

    // ── GET /api/mobil ────────────────────────────────────────────────────────
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user) {
            return response()->json(Mobil::where('user_id', $user->id)->get());
        }
        return response()->json([]);
    }

    // ── POST /api/mobil ───────────────────────────────────────────────────────
    // Terima multipart/form-data (nama, harga, dll + gambar_file opsional)
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
            'gambar_file' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Proses file gambar jika dikirim
        $gambarUrl = null;
        if ($request->hasFile('gambar_file') && $request->file('gambar_file')->isValid()) {
            $path      = $request->file('gambar_file')->store('mobil', 'public');
            $gambarUrl = url(Storage::url($path));
        }

        $mobil = Mobil::create([
            'user_id'     => $user->id,
            'nama'        => $validated['nama'],
            'slug'        => Str::slug($validated['nama']) . '-' . Str::random(4),
            'tipe'        => $validated['tipe'],
            'harga'       => $validated['harga'],
            'kursi'       => $validated['kursi'],
            'transmisi'   => $validated['transmisi'],
            'bahan_bakar' => $validated['bahan_bakar'],
            'deskripsi'   => $validated['deskripsi'] ?? null,
            'gambar'      => $gambarUrl,
            'tersedia'    => true,
        ]);

        return response()->json($mobil, 201);
    }

    // ── GET /api/mobil/{id} ───────────────────────────────────────────────────
    public function show(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        $user  = $request->user();
        if ($user && $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        return response()->json($mobil);
    }

    // ── PUT /api/mobil/{id} ───────────────────────────────────────────────────
    // Support dua cara:
    //   1. PUT biasa (JSON)             → untuk update tanpa ganti gambar
    //   2. POST + _method=PUT (multipart) → untuk update sekaligus ganti gambar
    //
    // Laravel otomatis mendeteksi method spoofing via field _method.
    // Pastikan di routes/api.php terdapat Route::post untuk endpoint ini
    // ATAU cukup Route::match(['put','post'], ...) — pilih salah satu.
    //
    // Cara paling mudah: biarkan Route::apiResource (sudah include PUT),
    // tambahkan satu route POST spoofing di bawahnya.
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
            'gambar_file' => 'nullable|file|mimes:jpg,jpeg,png,webp|max:5120',
            'tersedia'    => 'boolean',
        ]);

        if (isset($validated['nama'])) {
            $validated['slug'] = Str::slug($validated['nama']) . '-' . Str::random(4);
        }

        // Proses ganti gambar jika ada file baru
        if ($request->hasFile('gambar_file') && $request->file('gambar_file')->isValid()) {
            // Hapus gambar lama dari storage
            if ($mobil->gambar) {
                $oldPath = ltrim(parse_url($mobil->gambar, PHP_URL_PATH), '/');
                $oldPath = preg_replace('#^storage/#', '', $oldPath);
                Storage::disk('public')->delete($oldPath);
            }
            $path                  = $request->file('gambar_file')->store('mobil', 'public');
            $validated['gambar']   = url(Storage::url($path));
        }

        unset($validated['gambar_file']);
        $mobil->update($validated);
        return response()->json($mobil);
    }

    // ── DELETE /api/mobil/{id} ────────────────────────────────────────────────
    public function destroy(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        $user  = $request->user();
        if (!$user || $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Hapus file gambar dari storage
        if ($mobil->gambar) {
            $oldPath = ltrim(parse_url($mobil->gambar, PHP_URL_PATH), '/');
            $oldPath = preg_replace('#^storage/#', '', $oldPath);
            Storage::disk('public')->delete($oldPath);
        }

        $mobil->delete();
        return response()->json(['message' => 'Mobil dihapus']);
    }
}