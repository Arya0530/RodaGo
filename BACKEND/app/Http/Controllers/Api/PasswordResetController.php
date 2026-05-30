<?php
// ============================================================
// LOKASI FILE: app/Http/Controllers/Api/PasswordResetController.php
// ============================================================
// TIDAK ADA tabel baru / migration yang dibutuhkan.
// Reset password langsung update kolom 'password' di tabel 'users'
// yang sudah ada sejak awal.
// ============================================================

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class PasswordResetController extends Controller
{
    // ============================================================
    // POST /api/forgot-password
    //
    // Request body (JSON):
    //   {
    //     "email"                     : "user@email.com",
    //     "new_password"              : "Password123",
    //     "new_password_confirmation" : "Password123"
    //   }
    //
    // Response sukses (200):
    //   { "success": true, "message": "Password berhasil diubah." }
    //
    // Response gagal (404):
    //   { "success": false, "message": "Email tidak terdaftar." }
    //
    // Response validasi gagal (422):
    //   { "success": false, "message": "pesan error pertama" }
    // ============================================================

    public function reset(Request $request)
    {
        // ── Validasi input ─────────────────────────────────────────
        try {
            $request->validate([
                'email'        => 'required|email',
                'new_password' => [
                    'required',
                    'string',
                    'min:8',
                    'regex:/[a-z]/',      // harus ada huruf kecil
                    'regex:/[A-Z]/',      // harus ada huruf kapital
                    'regex:/[0-9]/',      // harus ada angka
                    'confirmed',          // harus ada field new_password_confirmation
                ],
            ], [
                'email.required'         => 'Email wajib diisi.',
                'email.email'            => 'Format email tidak valid.',
                'new_password.required'  => 'Password baru wajib diisi.',
                'new_password.min'       => 'Password minimal 8 karakter.',
                'new_password.regex'     => 'Password harus mengandung huruf besar, huruf kecil, dan angka.',
                'new_password.confirmed' => 'Konfirmasi password tidak cocok.',
            ]);
        } catch (ValidationException $e) {
            // Kembalikan hanya pesan error pertama (sesuai pola AuthController)
            return response()->json([
                'success' => false,
                'message' => collect($e->errors())->flatten()->first(),
            ], 422);
        }

        // ── Cari user berdasarkan email ────────────────────────────
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar.',
            ], 404);
        }

        // ── Ganti password ─────────────────────────────────────────
        $user->password = Hash::make($request->new_password);
        $user->save();

        // Hapus semua token Sanctum lama → user wajib login ulang
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah. Silakan login dengan password baru.',
        ], 200);
    }
}