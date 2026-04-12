<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Rental;
use App\Models\User; 
use App\Models\City;

class AdminController extends Controller
{
    public function dashboard() { 
        // Ngitung jumlah asli dari database
        $totalUsers = \App\Models\User::count();
        $totalRentals = \App\Models\Rental::count();
        
        // Buat mobil & booking karena lu belum bikin tabelnya, kita kasih dummy statis dulu
        $liveCars = 18; 
        $pendingBookings = 7;

        return view('admin.dashboard', compact('totalUsers', 'totalRentals', 'liveCars', 'pendingBookings')); 
    }

    public function users() {
        $users = User::orderBy('created_at', 'desc')->get();
        return view('admin.users', compact('users'));
    }

    // FUNGSI CREATE (TAMBAH USER)
    public function storeUser(Request $request) {
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6',
            'role' => 'required|in:admin,owner,user'
        ]);

        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password), // Password wajib dienkripsi
            'role' => $request->role,
        ]);

        return back()->with('success', 'User berhasil ditambahkan!');
    }

    // FUNGSI UPDATE (EDIT USER)
    public function updateUser(Request $request, $id) {
        $user = User::find($id);
        
        // Kita cuma update Nama, Email, dan Role (Password biarin aja kalau dikosongin)
        $user->name = $request->name;
        $user->email = $request->email;
        $user->role = $request->role;
        
        // Kalau admin mau ngubah password orangnya sekalian
        if($request->filled('password')) {
            $user->password = bcrypt($request->password);
        }
        
        $user->save();

        return back()->with('success', 'Data user berhasil diperbarui!');
    }

    // FUNGSI DELETE (HAPUS USER)
    public function destroyUser($id) {
        User::find($id)->delete();
        return back()->with('success', 'User berhasil dihapus/suspend!');
    }

    // FUNGSI TAB RENTALS
    public function rentals() {
        $rentals = Rental::with('user')->orderBy('created_at', 'desc')->get(); // Narik data beserta nama pemiliknya
        $owners = User::where('role', 'owner')->get(); // Buat pilihan siapa pemilik rentalnya di form
        return view('admin.rentals', compact('rentals', 'owners'));
    }

    public function storeRental(Request $request) {
        $request->validate([
            'brand_name' => 'required',
            'user_id' => 'required',
            'city' => 'required',
        ]);

        Rental::create($request->all());
        return back()->with('success', 'Mitra Rental baru berhasil didaftarkan!');
    }

    public function updateRental(Request $request, $id) {
        $rental = Rental::find($id);
        $rental->update($request->all());
        return back()->with('success', 'Data mitra berhasil diperbarui!');
    }

    public function destroyRental($id) {
        Rental::find($id)->delete();
        return back()->with('success', 'Mitra berhasil dihapus dari sistem!');
    }

    public function cities() {
        $cities = City::orderBy('name', 'asc')->get();
        return view('admin.cities', compact('cities'));
    }

    public function storeCity(Request $request) {
        City::create($request->validate(['name' => 'required', 'province' => 'required']));
        return back()->with('success', 'Area operasional baru berhasil dibuka!');
    }

    public function updateCity(Request $request, $id) {
        City::find($id)->update($request->validate(['name' => 'required', 'province' => 'required']));
        return back()->with('success', 'Data kota diperbarui!');
    }

    public function destroyCity($id) {
        City::find($id)->delete();
        return back()->with('success', 'Area operasional ditutup!');
    }
    public function cars() { return view('admin.cars'); }
    public function bookings() { return view('admin.bookings'); }

}