<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Mobil;
use Illuminate\Support\Facades\Storage;

class HomeController extends Controller
{
    public function index()
    {
        // Ambil 10 mobil TERBARU yang tersedia
        // Diurutkan created_at DESC → mobil terlama otomatis tergeser keluar
        $mobilList = Mobil::where('tersedia', true)
                          ->latest()
                          ->take(10)
                          ->get()
                          ->map(function ($mobil) {
                              // Build URL gambar — sama persis dengan logika di Api/MobilController
                              $mobil->gambar = $this->buildGambarUrl($mobil->gambar);
                              return $mobil;
                          });

        return view('home', compact('mobilList'));
    }

    /**
     * Bangun URL gambar yang benar untuk ditampilkan.
     * Tiga tipe kolom gambar yang didukung:
     *
     *   1. URL EKSTERNAL (Unsplash, CDN lain)
     *      contoh : "https://images.unsplash.com/photo-xxx"
     *      ciri   : URL http tapi TIDAK mengandung "/storage/"
     *      aksi   : kembalikan apa adanya
     *
     *   2. URL NGROK LAMA
     *      contoh : "https://xxx.ngrok-free.app/storage/mobil/AbCd.jpg"
     *      ciri   : URL http DAN mengandung "/storage/"
     *      aksi   : ekstrak path relatif → rebuild pakai APP_URL
     *
     *   3. PATH RELATIF BARU (dari Flutter upload)
     *      contoh : "mobil/AbCd.jpg"
     *      ciri   : tidak diawali http
     *      aksi   : rebuild pakai APP_URL via Storage::url()
     */
    private function buildGambarUrl(?string $gambar): ?string
    {
        if (empty($gambar)) return null;

        // Path relatif baru (dari Flutter) → bangun full URL
        if (!str_starts_with($gambar, 'http')) {
            return url(Storage::url($gambar));
        }

        // URL http: cek apakah ada "/storage/" (URL ngrok lama)
        $urlPath = parse_url($gambar, PHP_URL_PATH) ?? '';
        if (!str_contains($urlPath, '/storage/')) {
            // URL eksternal (Unsplash, dll) → kembalikan apa adanya
            return $gambar;
        }

        // URL ngrok lama → ekstrak path relatif → rebuild pakai APP_URL
        $cleaned = ltrim($urlPath, '/');                      // "storage/mobil/AbCd.jpg"
        $path    = preg_replace('#^storage/#', '', $cleaned); // "mobil/AbCd.jpg"
        return $path ? url(Storage::url($path)) : $gambar;
    }
}