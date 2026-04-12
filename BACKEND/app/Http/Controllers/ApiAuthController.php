<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class ApiAuthController extends Controller
{
    // FUNGSI REGISTER KHUSUS FLUTTER
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string', // Sesuai desain UI lu
            'password' => 'required|string|min:8',
            'role' => 'required|in:user,owner' // Pilihan dari Flutter
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        // Bikin tiket masuk (Token Sanctum)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Berhasil mendaftar!',
            'user' => $user,
            'token' => $token
        ], 201);
    }

    // FUNGSI LOGIN KHUSUS FLUTTER
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek email ada nggak, dan passwordnya bener nggak
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Email atau Password salah!'], 401);
        }
        
        // Bikin tiket masuk (Token)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login sukses!',
            'user' => $user,
            'token' => $token
        ]);
    }

    // FUNGSI LOGOUT KHUSUS FLUTTER
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Berhasil logout dari HP']);
    }
}