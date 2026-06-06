<?php
// ============================================================
// LOKASI FILE: app/Http/Controllers/ImageProxyController.php
// ============================================================
// Controller baru — hanya 1 method.
// Tugasnya: fetch gambar dari URL (termasuk ngrok) server-side
// dengan header ngrok-skip-browser-warning, lalu teruskan ke browser.
// Ini menyelesaikan masalah ngrok warning page di browser web admin.
// ============================================================

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ImageProxyController extends Controller
{
    // GET /admin/gambar?url=https://...
    public function show(Request $request)
    {
        $url = $request->query('url');

        if (!$url) {
            abort(400, 'URL tidak diberikan');
        }

        // Hanya izinkan URL dari domain yang dikenal (keamanan dasar)
        $parsed = parse_url($url);
        $host   = $parsed['host'] ?? '';

        $allowedPatterns = [
            'ngrok-free.app',
            'ngrok-free.dev',
            'ngrok.io',
            'localhost',
            '127.0.0.1',
            parse_url(config('app.url'), PHP_URL_HOST), // domain APP_URL sendiri
        ];

        $diizinkan = false;
        foreach ($allowedPatterns as $pattern) {
            if ($pattern && str_contains($host, $pattern)) {
                $diizinkan = true;
                break;
            }
        }

        if (!$diizinkan) {
            abort(403, 'Domain tidak diizinkan');
        }

        try {
            // Fetch gambar server-side dengan header ngrok-skip-browser-warning
            $response = Http::withHeaders([
                'ngrok-skip-browser-warning' => 'true',
                'User-Agent'                 => 'RodaGoAdmin/1.0',
            ])->timeout(10)->get($url);

            if (!$response->successful()) {
                abort(404, 'Gambar tidak ditemukan');
            }

            $contentType = $response->header('Content-Type') ?? 'image/jpeg';

            // Pastikan response adalah gambar
            if (!str_starts_with($contentType, 'image/')) {
                abort(422, 'Bukan file gambar');
            }

            return response($response->body(), 200)
                ->header('Content-Type', $contentType)
                ->header('Cache-Control', 'public, max-age=3600'); // cache 1 jam

        } catch (\Exception $e) {
            abort(500, 'Gagal memuat gambar');
        }
    }
}