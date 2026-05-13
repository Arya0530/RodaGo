<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Rental;
use App\Models\User;
use App\Models\City;
use App\Models\Mobil;
use App\Models\Booking;

class AdminController extends Controller
{
    public function dashboard()
    {
        $totalUsers   = User::count();
        $totalRentals = Rental::count();

        return view('admin.dashboard', compact('totalUsers', 'totalRentals'));
    }

    // =====================================================
    // ✅ LIVE STATS API — dipanggil AJAX tiap 5 detik
    // GET /admin/api/live-stats
    // =====================================================
    public function liveStats()
    {
        // Mobil yang tersedia / siap dipesan (tersedia = true)
        $availableCars = Mobil::where('tersedia', true)->count();

        // Booking yang sedang pending (nunggu konfirmasi owner)
       $pendingBookings = Booking::whereIn('status', [
            'pending',
            'unpaid'
        ])->count();

        // Total user & rental (supaya kartu atas juga live)
        $totalUsers   = User::count();
        $totalRentals = Rental::count();

        return response()->json([
            'live_cars' => $availableCars,
            'pending_bookings' => $pendingBookings,
            'total_users'      => $totalUsers,
            'total_rentals'    => $totalRentals,
        ]);
    }

    // =====================================================
    // ✅ RECENT ACTIVITY API — dipanggil AJAX tiap 10 detik
    // GET /admin/api/recent-activity
    // =====================================================
    public function recentActivity()
    {
        $bookings = Booking::with(['user', 'mobil'])
            ->orderBy('updated_at', 'desc')
            ->limit(10)
            ->get();

        $activities = $bookings->map(function ($b) {
            $icon  = '📋';
            $label = 'Booking dibuat';
            $color = 'yellow';
            $time  = $b->created_at;

            if ($b->status === 'unpaid') {
                $icon  = '⏳';
                $label = 'Menunggu Pembayaran';
                $color = 'orange';
                $time  = $b->accepted_at ?? $b->updated_at;
            } elseif ($b->status === 'active') {
                $icon  = '🚗';
                $label = 'Sewa Aktif / Mobil Diambil';
                $color = 'blue';
                $time  = $b->accepted_at ?? $b->updated_at;
            } elseif ($b->status === 'completed') {
                $icon  = '✅';
                $label = 'Transaksi Selesai';
                $color = 'green';
                $time  = $b->updated_at;
            } elseif ($b->status === 'cancelled') {
                $icon  = '❌';
                $label = 'Dibatalkan';
                $color = 'red';
                $time  = $b->cancelled_at ?? $b->updated_at;
            }

            return [
                'id'    => $b->id,
                'icon'  => $icon,
                'label' => $label,
                'color' => $color,
                'user'  => $b->user?->name ?? 'Unknown',
                'mobil' => $b->mobil?->nama ?? 'Unknown',
                'total' => number_format($b->total_harga, 0, ',', '.'),
                'time'  => $time?->diffForHumans() ?? '-',
            ];
        });

        return response()->json(['activities' => $activities]);
    }

    // =====================================================
    // Sisanya tidak berubah
    // =====================================================

    public function users()
    {
        $users = User::orderBy('created_at', 'desc')->get();
        return view('admin.users', compact('users'));
    }

    public function storeUser(Request $request)
    {
        $request->validate([
            'name'     => 'required',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:6',
            'role'     => 'required|in:admin,owner,user',
        ]);

        User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'phone'    => $request->phone,
            'password' => bcrypt($request->password),
            'role'     => $request->role,
        ]);

        return back()->with('success', 'User berhasil ditambahkan!');
    }

    public function updateUser(Request $request, $id)
    {
        $user        = User::find($id);
        $user->name  = $request->name;
        $user->email = $request->email;
        $user->role  = $request->role;

        if ($request->filled('password')) {
            $user->password = bcrypt($request->password);
        }

        $user->save();
        return back()->with('success', 'Data user berhasil diperbarui!');
    }

    public function destroyUser($id)
    {
        User::find($id)->delete();
        return back()->with('success', 'User berhasil dihapus/suspend!');
    }

    public function rentals()
    {
        $rentals = Rental::with('user')->orderBy('created_at', 'desc')->get();
        $owners  = User::where('role', 'owner')->get();
        $cities  = City::orderBy('name')->get();
        return view('admin.rentals', compact('rentals', 'owners', 'cities'));
    }

    public function storeRental(Request $request)
    {
        $request->validate([
            'brand_name' => 'required',
            'user_id'    => 'required',
            'city'       => 'required',
        ]);

        Rental::create($request->all());
        return back()->with('success', 'Mitra Rental baru berhasil didaftarkan!');
    }

    public function updateRental(Request $request, $id)
    {
        Rental::find($id)->update($request->all());
        return back()->with('success', 'Data mitra berhasil diperbarui!');
    }

    public function destroyRental($id)
    {
        Rental::find($id)->delete();
        return back()->with('success', 'Mitra berhasil dihapus dari sistem!');
    }

    public function cities()
    {
        $cities = City::orderBy('name', 'asc')->get();
        return view('admin.cities', compact('cities'));
    }

    public function storeCity(Request $request)
    {
        City::create($request->validate(['name' => 'required', 'province' => 'required']));
        return back()->with('success', 'Area operasional baru berhasil dibuka!');
    }

    public function updateCity(Request $request, $id)
    {
        City::find($id)->update($request->validate(['name' => 'required', 'province' => 'required']));
        return back()->with('success', 'Data kota diperbarui!');
    }

    public function destroyCity($id)
    {
        City::find($id)->delete();
        return back()->with('success', 'Area operasional ditutup!');
    }

    public function cars()     { return view('admin.cars'); }
    public function bookings() { return view('admin.bookings'); }
}