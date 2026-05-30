<?php
// LOKASI: app/Http/Controllers/Api/MobilController.php
//
// FIX v2:
//   1. buildGambarUrl() sekarang deteksi 3 tipe gambar:
//      a. URL eksternal (Unsplash, dll) → kembalikan apa adanya
//      b. URL ngrok lama (/storage/ ada di path) → ekstrak path, rebuild pakai APP_URL
//      c. Path relatif baru ("mobil/xxx.jpg") → rebuild pakai APP_URL

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

        $mobils = $mobils->map(function ($mobil) {
            $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
            return $mobil;
        });

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

        $results = $query->orderBy('mobils.nama')->get()->map(function ($mobil) {
            $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
            return $mobil;
        });

        return response()->json([
            'success' => true,
            'data'    => $results,
        ], 200);
    }

    // ── GET /api/mobil ────────────────────────────────────────────────────────
    public function index(Request $request)
    {
        $user = $request->user();
        if ($user) {
            $mobils = Mobil::where('user_id', $user->id)->get()->map(function ($mobil) {
                $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
                return $mobil;
            });
            return response()->json($mobils);
        }
        return response()->json([]);
    }

    // ── POST /api/mobil ───────────────────────────────────────────────────────
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

        // Simpan PATH RELATIF (bukan URL ngrok absolut)
        $gambarPath = null;
        if ($request->hasFile('gambar_file') && $request->file('gambar_file')->isValid()) {
            $gambarPath = $request->file('gambar_file')->store('mobil', 'public');
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
            'gambar'      => $gambarPath,
            'tersedia'    => true,
        ]);

        $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
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
        $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
        return response()->json($mobil);
    }

    // ── PUT /api/mobil/{id} ───────────────────────────────────────────────────
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

        if ($request->hasFile('gambar_file') && $request->file('gambar_file')->isValid()) {
            // Hapus gambar lama (hanya jika tersimpan di storage lokal, bukan URL eksternal)
            if ($mobil->gambar && !$this->isExternalUrl($mobil->gambar)) {
                $oldPath = $this->extractStoragePath($mobil->gambar);
                if ($oldPath) Storage::disk('public')->delete($oldPath);
            }
            $validated['gambar'] = $request->file('gambar_file')->store('mobil', 'public');
        }

        unset($validated['gambar_file']);
        $mobil->update($validated);
        $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
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

        // Hapus file storage (hanya jika bukan URL eksternal seperti Unsplash)
        if ($mobil->gambar && !$this->isExternalUrl($mobil->gambar)) {
            $oldPath = $this->extractStoragePath($mobil->gambar);
            if ($oldPath) Storage::disk('public')->delete($oldPath);
        }

        $mobil->delete();
        return response()->json(['message' => 'Mobil dihapus']);
    }

    // ═════════════════════════════════════════════════════════════
    // HELPER PRIVATE
    // ═════════════════════════════════════════════════════════════

    /**
     * Bangun URL gambar yang benar untuk ditampilkan.
     *
     * Tiga tipe kolom gambar yang didukung:
     *
     *   1. URL EKSTERNAL (Unsplash, CDN lain)
     *      contoh : "https://images.unsplash.com/photo-xxx"
     *      ciri   : URL http tapi TIDAK mengandung "/storage/"
     *      aksi   : kembalikan apa adanya — jangan diubah
     *
     *   2. URL NGROK LAMA (data sebelum fix)
     *      contoh : "https://xxx.ngrok-free.app/storage/mobil/AbCd.jpg"
     *      ciri   : URL http DAN mengandung "/storage/"
     *      aksi   : ekstrak path relatif → rebuild pakai APP_URL
     *
     *   3. PATH RELATIF BARU (data setelah fix)
     *      contoh : "mobil/AbCd.jpg"
     *      ciri   : tidak diawali http
     *      aksi   : rebuild pakai APP_URL via Storage::url()
     */
    private function buildGambarUrl(?string $gambar): ?string
    {
        if (empty($gambar)) return null;

        // Bukan URL http → path relatif baru
        if (!str_starts_with($gambar, 'http')) {
            return url(Storage::url($gambar));
        }

        // URL http: cek apakah ada "/storage/" di path-nya
        $urlPath = parse_url($gambar, PHP_URL_PATH) ?? '';
        if (!str_contains($urlPath, '/storage/')) {
            // URL eksternal (Unsplash, dll) → kembalikan apa adanya
            return $gambar;
        }

        // URL ngrok lama → ekstrak path relatif → rebuild pakai APP_URL
        $path = $this->extractStoragePath($gambar);
        return $path ? url(Storage::url($path)) : $gambar;
    }

    /**
     * Cek apakah URL adalah URL eksternal (bukan storage lokal).
     * URL lokal selalu mengandung "/storage/" di path-nya.
     */
    private function isExternalUrl(?string $gambar): bool
    {
        if (empty($gambar) || !str_starts_with($gambar, 'http')) return false;
        $urlPath = parse_url($gambar, PHP_URL_PATH) ?? '';
        return !str_contains($urlPath, '/storage/');
    }

    /**
     * Ekstrak path storage relatif dari URL ngrok atau path absolut.
     *
     * "https://xxx/storage/mobil/AbCd.jpg" → "mobil/AbCd.jpg"
     * "/storage/mobil/AbCd.jpg"            → "mobil/AbCd.jpg"
     * "mobil/AbCd.jpg"                     → "mobil/AbCd.jpg"
     */
    private function extractStoragePath(?string $gambar): ?string
    {
        if (empty($gambar)) return null;
        if (!str_starts_with($gambar, 'http') && !str_starts_with($gambar, '/')) {
            return $gambar; // sudah path relatif
        }
        $urlPath = str_starts_with($gambar, 'http')
            ? (parse_url($gambar, PHP_URL_PATH) ?? '')
            : $gambar;
        $path = preg_replace('#^/?storage/#', '', ltrim($urlPath, '/'));
        return $path ?: null;
    }
}