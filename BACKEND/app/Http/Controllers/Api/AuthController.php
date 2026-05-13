<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    // =========================================================================
    // POST /api/register
    // =========================================================================
    public function register(Request $request)
    {
        try {
            $validated = $request->validate([
                'name'     => 'required|string|max:255',
                'email'    => 'required|string|email|max:255|unique:users',
                'phone'    => 'required|string|max:20',
                'password' => [
                    'required',
                    'string',
                    'min:8',
                    'regex:/[a-z]/',
                    'regex:/[A-Z]/',
                    'regex:/[0-9]/',
                ],
                'role' => 'required|in:user,owner',
            ], [
                'name.required'      => 'Nama lengkap wajib diisi.',
                'email.required'     => 'Email wajib diisi.',
                'email.email'        => 'Format email tidak valid.',
                'email.unique'       => 'Email sudah terdaftar, gunakan email lain.',
                'phone.required'     => 'Nomor HP wajib diisi.',
                'password.required'  => 'Password wajib diisi.',
                'password.min'       => 'Password minimal 8 karakter.',
                'password.regex'     => 'Password harus mengandung huruf besar, huruf kecil, dan angka.',
                'role.required'      => 'Pilih jenis akun.',
                'role.in'            => 'Jenis akun tidak valid.',
            ]);

            $user = User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'phone'    => $validated['phone'],
                'password' => Hash::make($validated['password']),
                'role'     => $validated['role'],
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Registrasi berhasil! Silakan login.',
                'user'    => $user,
            ], 201);

        } catch (ValidationException $e) {
            $pesanPertama = collect($e->errors())->flatten()->first();
            return response()->json([
                'success' => false,
                'message' => $pesanPertama,
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan server. Coba lagi.',
            ], 500);
        }
    }

    // =========================================================================
    // POST /api/login
    // =========================================================================
    public function login(Request $request)
    {
        try {
            $request->validate([
                'email'    => 'required|string|email',
                'password' => 'required|string',
            ], [
                'email.required'    => 'Email wajib diisi.',
                'email.email'       => 'Format email tidak valid.',
                'password.required' => 'Password wajib diisi.',
            ]);
        } catch (ValidationException $e) {
            $pesanPertama = collect($e->errors())->flatten()->first();
            return response()->json([
                'success' => false,
                'message' => $pesanPertama,
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email atau password salah.',
            ], 401);
        }

        // Hapus token lama biar tidak numpuk
        $user->tokens()->delete();

        // Generate token baru
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil!',
            'token'   => $token,
            'user'    => [
                'id'    => $user->id,
                'name'  => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role'  => $user->role,
            ],
        ], 200);
    }

    // =========================================================================
    // POST /api/logout
    // =========================================================================
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.',
        ]);
    }
}