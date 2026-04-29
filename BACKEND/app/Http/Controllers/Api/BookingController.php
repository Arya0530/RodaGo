<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use App\Models\Mobil;
use Carbon\Carbon;

// Simpan di: app/Http/Controllers/Api/BookingController.php

class BookingController extends Controller
{
    // =========================================================================
    // GET /api/bookings
    // Ambil semua pesanan milik user yang sedang login SAJA
    // Dipanggil: pesanan_page.dart → _loadBookings()
    // =========================================================================
    public function index(Request $request)
    {
        $bookings = Booking::with('mobil')
            ->where('user_id', $request->user()->id) // ← hanya milik user ini
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($b) {
                return [
                    'id'             => $b->id,
                    'mobil_id'       => $b->mobil_id,
                    'nama_mobil'     => $b->mobil->nama ?? '-',
                    'gambar_mobil'   => $b->mobil->gambar ?? null,
                    'tanggal_mulai'  => $b->tanggal_mulai->format('d M Y'),
                    'tanggal_selesai'=> $b->tanggal_selesai->format('d M Y'),
                    'total_harga'    => $b->total_harga,
                    'status'         => $b->status,
                    'cancelled_by'   => $b->cancelled_by,
                    // deadline_bayar dihitung dari accepted_at + 24 jam
                    'deadline_bayar' => $b->status === 'unpaid' && $b->accepted_at
                        ? $b->accepted_at->addHours(24)->toIso8601String()
                        : null,
                ];
            });

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    // =========================================================================
    // POST /api/bookings
    // User buat pesanan baru → status otomatis: pending
    // Body: { mobil_id, tanggal_mulai, tanggal_selesai }
    // =========================================================================
    public function store(Request $request)
    {
        $request->validate([
            'mobil_id'        => 'required|exists:mobils,id',
            'tanggal_mulai'   => 'required|date|after_or_equal:today',
            'tanggal_selesai' => 'required|date|after:tanggal_mulai',
        ]);

        $mobil = Mobil::findOrFail($request->mobil_id);

        if (!$mobil->tersedia) {
            return response()->json([
                'success' => false,
                'message' => 'Maaf, mobil ini sedang tidak tersedia.',
            ], 422);
        }

        $mulai      = Carbon::parse($request->tanggal_mulai);
        $selesai    = Carbon::parse($request->tanggal_selesai);
        $jumlahHari = $mulai->diffInDays($selesai);
        $totalHarga = $jumlahHari * $mobil->harga; // kolom 'harga' sesuai tabel mobils

        // Cek bentrok jadwal di mobil yang sama
        $bentrok = Booking::where('mobil_id', $request->mobil_id)
            ->whereIn('status', ['pending', 'unpaid', 'active'])
            ->where(function ($q) use ($request) {
                $q->whereBetween('tanggal_mulai',    [$request->tanggal_mulai, $request->tanggal_selesai])
                  ->orWhereBetween('tanggal_selesai', [$request->tanggal_mulai, $request->tanggal_selesai]);
            })
            ->exists();

        if ($bentrok) {
            return response()->json([
                'success' => false,
                'message' => 'Mobil sudah dipesan di tanggal tersebut.',
            ], 422);
        }

        $booking = Booking::create([
            'user_id'         => $request->user()->id,
            'mobil_id'        => $request->mobil_id,
            'tanggal_mulai'   => $request->tanggal_mulai,
            'tanggal_selesai' => $request->tanggal_selesai,
            'total_harga'     => $totalHarga,
            'status'          => 'pending',
            'cancelled_by'    => null,
            'accepted_at'     => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil dibuat! Menunggu konfirmasi owner.',
            'data'    => $booking->load('mobil'),
        ], 201);
    }

    // =========================================================================
    // DELETE /api/bookings/{id}/cancel
    // User cancel pesanan — hanya boleh kalau status masih: pending
    // =========================================================================
    public function cancel(Request $request, $id)
    {
        $booking = Booking::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Pesanan tidak ditemukan.'], 404);
        }

        if ($booking->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak bisa dibatalkan. Status saat ini: ' . $booking->status,
            ], 422);
        }

        $booking->update([
            'status'       => 'cancelled',
            'cancelled_by' => 'user',
        ]);

        return response()->json(['success' => true, 'message' => 'Pesanan berhasil dibatalkan.']);
    }
   public function ownerBookings(Request $request)
{
    $ownerId = $request->user()->id;

    $bookings = Booking::with(['mobil', 'user'])
        ->whereHas('mobil', function ($q) use ($ownerId) {
            $q->where('user_id', $ownerId);
        })
        ->whereIn('status', ['pending', 'unpaid', 'active'])
        ->orderBy('created_at', 'desc')
        ->get()
        ->map(function ($b) {
            return [
                'id' => $b->id,

                'nama_penyewa' => $b->user->name ?? '-',
                'email_penyewa' => $b->user->email ?? '-',
                'phone_penyewa' => $b->user->phone ?? '-',

                'nama_mobil' => $b->mobil->nama ?? '-',

                'tanggal_mulai' => Carbon::parse($b->tanggal_mulai)->format('d M Y'),
                'tanggal_selesai' => Carbon::parse($b->tanggal_selesai)->format('d M Y'),

                'total_harga' => $b->total_harga,
                'status' => $b->status,
            ];
        });

    return response()->json([
        'success' => true,
        'data' => $bookings
    ]);
}
public function terima(Request $request, $id)
{
    $booking = Booking::find($id);

    if (!$booking) {
        return response()->json([
            'success' => false,
            'message' => 'Pesanan tidak ditemukan'
        ], 404);
    }

    $booking->update([
        'status' => 'unpaid',
        'accepted_at' => now(),
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Pesanan diterima'
    ]);
}
public function tolak(Request $request, $id)
{
    $booking = Booking::find($id);

    if (!$booking) {
        return response()->json([
            'success' => false,
            'message' => 'Pesanan tidak ditemukan'
        ], 404);
    }

    if ($booking->status !== 'pending') {
        return response()->json([
            'success' => false,
            'message' => 'Pesanan tidak bisa ditolak karena sudah diproses'
        ], 422);
    }

    $booking->update([
        'status' => 'cancelled',
        'cancelled_by' => 'owner',
    ]);

    return response()->json([
        'success' => true,
        'message' => 'Pesanan ditolak'
    ]);
}
public function pay(Request $request, $id)
{
    $booking = Booking::with('mobil')->find($id);

    if (!$booking) {
        return response()->json([
            'success' => false,
            'message' => 'Booking tidak ditemukan'
        ], 404);
    }

    if ($booking->status !== 'unpaid') {
        return response()->json([
            'success' => false,
            'message' => 'Booking belum siap dibayar atau sudah diproses'
        ], 422);
    }

    // ✅ Update status pesanan jadi completed
    $booking->update(['status' => 'completed']);

    // ✅ Update mobil jadi "Sedang Disewa" (tersedia = false)
    if ($booking->mobil) {
        $booking->mobil->update(['tersedia' => false]);
    }

    // ✅ Generate kode tiket unik dari booking ID
    $kodeTiket = 'RDG-' . strtoupper(str_pad($booking->id, 6, '0', STR_PAD_LEFT));

    return response()->json([
        'success'     => true,
        'message'     => 'Pembayaran berhasil!',
        'booking_id'  => $booking->id,
        'kode_tiket'  => $kodeTiket,
        'nama_mobil'  => $booking->mobil->nama ?? '-',
        'tanggal_mulai'   => $booking->tanggal_mulai->format('d M Y'),
        'tanggal_selesai' => $booking->tanggal_selesai->format('d M Y'),
    ]);
}
}