<?php
// LOKASI: database/migrations/2026_05_30_000001_fix_gambar_path_mobils_table.php
//
// TUJUAN: Ubah kolom gambar dari URL ngrok absolut → path relatif storage
//
// SEBELUM : "https://xxx.ngrok-free.app/storage/mobil/AbCd.jpg"
// SESUDAH : "mobil/AbCd.jpg"
//
// Setelah migration ini, MobilController.php yang baru akan mem-build
// URL absolut menggunakan APP_URL dari .env — sehingga gambar muncul
// baik di website maupun di Flutter.
//
// Cara jalankan:
//   php artisan migrate

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Ambil semua mobil yang punya gambar berupa URL absolut (http)
        $mobils = DB::table('mobils')
            ->whereNotNull('gambar')
            ->where('gambar', 'like', 'http%')
            ->get(['id', 'gambar']);

        foreach ($mobils as $mobil) {
            // Ekstrak path dari URL
            // "https://xxx.ngrok.../storage/mobil/AbCd.jpg" → "mobil/AbCd.jpg"
            $urlPath  = parse_url($mobil->gambar, PHP_URL_PATH);  // "/storage/mobil/AbCd.jpg"
            $cleaned  = ltrim($urlPath, '/');                     // "storage/mobil/AbCd.jpg"
            $path     = preg_replace('#^storage/#', '', $cleaned); // "mobil/AbCd.jpg"

            if ($path && $path !== $mobil->gambar) {
                DB::table('mobils')
                    ->where('id', $mobil->id)
                    ->update(['gambar' => $path]);
            }
        }
    }

    public function down(): void
    {
        // Tidak di-reverse karena URL ngrok lama sudah tidak valid
        // (ngrok URL berubah setiap restart)
    }
};