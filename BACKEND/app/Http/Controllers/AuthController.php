<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // Nampilin halaman form login
    public function showLogin()
    {
        return view('auth.login');
    }

    // Proses cek email & password
    public function authenticate(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            // Cek kalau yang login itu admin, lempar ke dashboard admin!
            if (Auth::user()->role === 'admin') {
                return redirect()->intended('/admin/dashboard');
            }

            // Kalau bukan admin, tendang balik ke halaman depan
            return redirect('/');
        }

        // Kalau password salah
        return back()->withErrors([
            'email' => 'Email atau password salah!',
        ])->onlyInput('email');
    }

    // Proses Logout
    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }
}