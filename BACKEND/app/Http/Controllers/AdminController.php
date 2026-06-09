<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Rental;
use App\Models\User;
use App\Models\City;
use App\Models\Mobil;
use App\Models\Booking;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth; // Tambahan biar auth()->id() gak error di VS Code

class AdminController extends Controller
{
    public function store(Request $request)
    {
        // Ambil data mobil
        $mobil = Mobil::findOrFail($request->mobil_id);

        // Tambahkan pengecekan ini: (Gembok Owner)
        if ($mobil->user_id == Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak bisa menyewa mobil milik sendiri!'
            ], 403);
        }

        // Lanjutkan proses simpan booking...
        $booking = Booking::create([
            'user_id' => Auth::id(),
            'mobil_id' => $request->mobil_id,
            'tanggal_mulai' => $request->tanggal_mulai ?? now(),
            'tanggal_selesai' => $request->tanggal_selesai ?? now()->addDays(1),
            'total_harga' => $request->total_harga ?? 0,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking berhasil dibuat',
            'data' => $booking
        ], 201);
    }

    public function dashboard()
    {
        $totalUsers   = User::count();
        $totalRentals = Rental::count();
        return view('admin.dashboard', compact('totalUsers', 'totalRentals'));
    }

    // GET /admin/api/live-stats
    public function liveStats()
    {
        return response()->json([
            'live_cars'        => Mobil::where('tersedia', true)->count(),
            'pending_bookings' => Booking::whereIn('status', ['pending', 'unpaid'])->count(),
            'total_users'      => User::count(),
            'total_rentals'    => Rental::count(),
        ]);
    }

    // GET /admin/api/recent-activity
    public function recentActivity()
    {
        $bookings   = Booking::with(['user', 'mobil'])->orderBy('updated_at', 'desc')->limit(10)->get();
        $activities = $bookings->map(function ($b) {
            $icon  = '📋'; $label = 'Booking dibuat'; $color = 'yellow'; $time = $b->created_at;
            if ($b->status === 'unpaid')        { $icon = '⏳'; $label = 'Menunggu Pembayaran'; $color = 'orange'; $time = $b->accepted_at  ?? $b->updated_at; }
            elseif ($b->status === 'active')    { $icon = '🚗'; $label = 'Sewa Aktif';          $color = 'blue';   $time = $b->accepted_at  ?? $b->updated_at; }
            elseif ($b->status === 'completed') { $icon = '✅'; $label = 'Transaksi Selesai';   $color = 'green';  $time = $b->updated_at; }
            elseif ($b->status === 'cancelled') { $icon = '❌'; $label = 'Dibatalkan';          $color = 'red';    $time = $b->cancelled_at ?? $b->updated_at; }
            return [
                'id'    => $b->id,   'icon'  => $icon,  'label' => $label, 'color' => $color,
                'user'  => $b->user?->name  ?? 'Unknown',
                'mobil' => $b->mobil?->nama ?? 'Unknown',
                'total' => number_format($b->total_harga, 0, ',', '.'),
                'time'  => $time?->diffForHumans() ?? '-',
            ];
        });
        return response()->json(['activities' => $activities]);
    }

    // =========================================================
    // USERS
    // =========================================================
    public function users()
    {
        $users = User::orderBy('created_at', 'desc')->get();
        return view('admin.users', compact('users'));
    }

    public function storeUser(Request $request)
    {
        $request->validate(['name' => 'required', 'email' => 'required|email|unique:users', 'password' => 'required|min:6', 'role' => 'required|in:admin,owner,user']);
        User::create(['name' => $request->name, 'email' => $request->email, 'phone' => $request->phone, 'password' => bcrypt($request->password), 'role' => $request->role]);
        return back()->with('success', 'User berhasil ditambahkan!');
    }

    public function updateUser(Request $request, string $id)
    {
        $user = User::find($id);
        $user->name = $request->name; $user->email = $request->email; $user->role = $request->role;
        if ($request->filled('password')) $user->password = bcrypt($request->password);
        $user->save();
        return back()->with('success', 'Data user berhasil diperbarui!');
    }

    public function destroyUser(string $id)
    {
        User::find($id)->delete();
        return back()->with('success', 'User berhasil dihapus!');
    }

    // =========================================================
    // RENTALS
    // =========================================================
    public function rentals()
    {
        $rentals = Rental::with('user')->orderBy('created_at', 'desc')->get();
        $owners  = User::where('role', 'owner')->get();
        $cities  = City::orderBy('name')->get();
        return view('admin.rentals', compact('rentals', 'owners', 'cities'));
    }

    public function storeRental(Request $request)
    {
        $request->validate(['brand_name' => 'required', 'user_id' => 'required', 'city' => 'required']);
        Rental::create($request->all());
        return back()->with('success', 'Mitra Rental baru berhasil didaftarkan!');
    }

    public function updateRental(Request $request, string $id)
    {
        Rental::find($id)->update($request->all());
        return back()->with('success', 'Data mitra berhasil diperbarui!');
    }

    public function destroyRental(string $id)
    {
        Rental::find($id)->delete();
        return back()->with('success', 'Mitra berhasil dihapus!');
    }

    // =========================================================
    // CITIES
    // =========================================================
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

    public function updateCity(Request $request, string $id)
    {
        City::find($id)->update($request->validate(['name' => 'required', 'province' => 'required']));
        return back()->with('success', 'Data kota diperbarui!');
    }

    public function destroyCity(string $id)
    {
        City::find($id)->delete();
        return back()->with('success', 'Area operasional ditutup!');
    }

    // =========================================================
    // CARS — query DB, tampilkan di view blade (tanpa AJAX)
    // REVISI: Status "Sedang Disewa" hanya untuk booking aktif HARI INI
    // =========================================================
    public function cars()
    {
        // Ambil semua mobil + nama rental pemiliknya
        $mobils = DB::table('mobils')
            ->leftJoin('users',   'users.id',        '=', 'mobils.user_id')
            ->leftJoin('rentals', 'rentals.user_id', '=', 'users.id')
            ->select(
                'mobils.id',
                'mobils.nama',
                'mobils.tipe',
                'mobils.harga',
                'mobils.kursi',
                'mobils.transmisi',
                'mobils.bahan_bakar',
                'mobils.deskripsi',
                'mobils.gambar',
                'mobils.tersedia',
                'rentals.brand_name as nama_rental',
                'rentals.city       as kota_rental'
            )
            ->orderBy('mobils.nama')
            ->paginate(15);

        // REVISI: Hitung mobil yang SEDANG DISEWA HARI INI saja
        // (bukan semua booking pending/unpaid)
        $today = \Carbon\Carbon::today();
        $mobilDisewaHariIni = DB::table('bookings')
            ->whereIn('status', ['unpaid', 'completed'])
            ->whereDate('tanggal_mulai', '<=', $today)
            ->whereDate('tanggal_selesai', '>=', $today)
            ->pluck('mobil_id')
            ->unique()
            ->count();

        // Statistik untuk header
        $stats = [
            'total'    => DB::table('mobils')->count(),
            'tersedia' => DB::table('mobils')->where('tersedia', true)->count(),
            'disewa'   => $mobilDisewaHariIni, // ← PERUBAHAN: hanya yang aktif hari ini
        ];

        // Tidak perlu kirim activeBookingIds lagi ke view
        // karena view akan query sendiri untuk setiap mobil
        return view('admin.cars', compact('mobils', 'stats'));
    }

    // POST /admin/cars/{id}/toggle
    // Aktifkan atau nonaktifkan ketersediaan mobil
    public function carToggle(string $id)
    {
        $mobil = Mobil::findOrFail($id);

        // Cegah nonaktifkan kalau masih ada booking aktif
        if ($mobil->tersedia) {
            $ada = DB::table('bookings')
                ->where('mobil_id', $id)
                ->whereIn('status', ['pending', 'unpaid', 'active'])
                ->exists();

            if ($ada) {
                return back()->with('error', "Tidak bisa dinonaktifkan — \"{$mobil->nama}\" masih memiliki booking aktif.");
            }
        }

        $mobil->update(['tersedia' => !$mobil->tersedia]);
        $aksi = $mobil->tersedia ? 'diaktifkan' : 'dinonaktifkan';
        return back()->with('success', "Mobil \"{$mobil->nama}\" berhasil {$aksi}.");
    }

    // =========================================================
    // BOOKINGS
    // =========================================================
    public function bookings()
    {
        return view('admin.bookings');
    }
}