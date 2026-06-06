<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use App\Models\Mobil;
use App\Models\Notification;
use Carbon\Carbon;

// Simpan di: app/Http/Controllers/Api/BookingController.php
//
// PERUBAHAN (revisi dosen):
//   - pay() → HAPUS baris $booking->mobil->update(['tersedia' => false])
//             Status ketersediaan mobil kini murni berdasarkan jadwal booking,
//             bukan flag tersedia di tabel mobils.
//   - Validasi bentrok tanggal di store() TETAP ADA (tidak berubah).
//   - Semua fungsi lain TIDAK BERUBAH.

class BookingController extends Controller
{
    // =========================================================================
    // GET /api/bookings
    // =========================================================================
    public function index(Request $request)
    {
        $bookings = Booking::with('mobil')
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($b) {
                return [
                    'id'              => $b->id,
                    'mobil_id'        => $b->mobil_id,
                    'nama_mobil'      => $b->mobil->nama ?? '-',
                    'gambar_mobil'    => $b->mobil->gambar ?? null,
                    'tanggal_mulai'   => $b->tanggal_mulai->format('d M Y'),
                    'tanggal_selesai' => $b->tanggal_selesai->format('d M Y'),
                    'total_harga'     => $b->total_harga,
                    'status'          => $b->status,
                    'cancelled_by'    => $b->cancelled_by,
                    'cancelled_at'    => $b->cancelled_at?->toIso8601String(),
                    'cancel_reason'   => $b->cancel_reason,
                    'deadline_bayar'  => $b->status === 'unpaid' && $b->accepted_at
                        ? $b->accepted_at->addHours(24)->toIso8601String()
                        : null,
                ];
            });

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    // =========================================================================
    // POST /api/bookings
    // Validasi bentrok tanggal TETAP ADA sesuai revisi dosen poin 4–6.
    // =========================================================================
    public function store(Request $request)
    {
        $request->validate([
            'mobil_id'        => 'required|exists:mobils,id',
            'tanggal_mulai'   => 'required|date|after_or_equal:today',
            'tanggal_selesai' => 'required|date|after:tanggal_mulai',
        ]);

        $mobil = Mobil::findOrFail($request->mobil_id);

        $mulai      = Carbon::parse($request->tanggal_mulai);
        $selesai    = Carbon::parse($request->tanggal_selesai);
        $jumlahHari = $mulai->diffInDays($selesai);
        $totalHarga = $jumlahHari * $mobil->harga;

        // Cek bentrok tanggal dengan booking yang sudah ada
        // (pending, unpaid, completed = booking aktif yang sudah/sedang berjalan)
        $bentrok = Booking::where('mobil_id', $request->mobil_id)
            ->whereIn('status', ['pending', 'unpaid', 'completed'])
            ->where('tanggal_mulai',   '<=', $request->tanggal_selesai)
            ->where('tanggal_selesai', '>=', $request->tanggal_mulai)
            ->exists();

        if ($bentrok) {
            return response()->json([
                'success' => false,
                'message' => 'Mobil tidak tersedia pada tanggal yang dipilih. Silakan pilih tanggal lain.',
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
    // User cancel → notifikasi ke OWNER
    // =========================================================================
    public function cancel(Request $request, $id)
    {
        $booking = Booking::with('mobil')->where('id', $id)
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
            'cancelled_at' => now(),
        ]);

        // Notifikasi: beritahu owner bahwa user cancel
        if ($booking->mobil && $booking->mobil->user_id) {
            $namaMobil   = $booking->mobil->nama ?? 'mobil';
            $namaPenyewa = $request->user()->name ?? 'Penyewa';

            Notification::create([
                'user_id'    => $booking->mobil->user_id,
                'title'      => 'Pesanan Dibatalkan',
                'body'       => "$namaPenyewa membatalkan pesanan {$namaMobil}.",
                'type'       => 'booking_cancelled',
                'booking_id' => $booking->id,
            ]);
        }

        return response()->json(['success' => true, 'message' => 'Pesanan berhasil dibatalkan.']);
    }

    // =========================================================================
    // GET /api/owner/bookings — hanya pending
    // =========================================================================
    public function ownerBookings(Request $request)
    {
        $ownerId = $request->user()->id;

        $bookings = Booking::with(['mobil', 'user'])
            ->whereHas('mobil', function ($q) use ($ownerId) {
                $q->where('user_id', $ownerId);
            })
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($b) {
                return [
                    'id'              => $b->id,
                    'nama_penyewa'    => $b->user->name   ?? '-',
                    'email_penyewa'   => $b->user->email  ?? '-',
                    'phone_penyewa'   => $b->user->phone  ?? '-',
                    'nama_mobil'      => $b->mobil->nama  ?? '-',
                    'tanggal_mulai'   => Carbon::parse($b->tanggal_mulai)->format('d M Y'),
                    'tanggal_selesai' => Carbon::parse($b->tanggal_selesai)->format('d M Y'),
                    'total_harga'     => $b->total_harga,
                    'status'          => $b->status,
                ];
            });

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    // =========================================================================
    // POST /api/owner/bookings/{id}/terima
    // Owner terima → notifikasi ke USER
    // =========================================================================
    public function terima(Request $request, $id)
    {
        $booking = Booking::with('mobil')->find($id);

        if (!$booking || $booking->status !== 'pending') {
            return response()->json(['success' => false, 'message' => 'Pesanan tidak ditemukan atau sudah diproses.'], 404);
        }

        $now = Carbon::now();

        $booking->update([
            'status'      => 'unpaid',
            'accepted_at' => $now,
        ]);

        // Notifikasi: beritahu user bahwa pesanannya diterima
        $namaMobil    = $booking->mobil->nama ?? 'mobil';
        $deadlineStr  = $now->copy()->addHours(24)->format('d M Y H:i');

        Notification::create([
            'user_id'    => $booking->user_id,
            'title'      => '🎉 Pesanan Diterima!',
            'body'       => "Pesanan {$namaMobil} Anda diterima oleh owner. Segera selesaikan pembayaran sebelum {$deadlineStr}.",
            'type'       => 'booking_accepted',
            'booking_id' => $booking->id,
        ]);

        return response()->json(['success' => true, 'message' => 'Pesanan diterima! User punya 24 jam untuk membayar.']);
    }

    // =========================================================================
    // POST /api/owner/bookings/{id}/tolak
    // Owner tolak → notifikasi ke USER
    // =========================================================================
    public function tolak(Request $request, $id)
    {
        $booking = Booking::with('mobil')->find($id);

        if (!$booking || $booking->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak bisa ditolak karena sudah diproses',
            ], 422);
        }

        $booking->update([
            'status'       => 'cancelled',
            'cancelled_by' => 'owner',
            'cancelled_at' => now(),
        ]);

        // Notifikasi: beritahu user bahwa pesanannya ditolak
        $namaMobil = $booking->mobil->nama ?? 'mobil';

        Notification::create([
            'user_id'    => $booking->user_id,
            'title'      => 'Pesanan Ditolak',
            'body'       => "Maaf, pesanan {$namaMobil} Anda ditolak oleh owner.",
            'type'       => 'booking_cancelled',
            'booking_id' => $booking->id,
        ]);

        return response()->json(['success' => true, 'message' => 'Pesanan ditolak']);
    }

    // =========================================================================
    // GET /api/owner/dashboard
    // =========================================================================
    public function ownerDashboard(Request $request)
    {
        $ownerId = $request->user()->id;

        $totalPendapatan = Booking::whereHas('mobil', function ($q) use ($ownerId) {
                $q->where('user_id', $ownerId);
            })
            ->where('status', 'completed')
            ->sum('total_harga');

        $jumlahPesananMasuk = Booking::whereHas('mobil', function ($q) use ($ownerId) {
                $q->where('user_id', $ownerId);
            })
            ->where('status', 'pending')
            ->count();

        return response()->json([
            'success' => true,
            'data'    => [
                'total_pendapatan'     => $totalPendapatan,
                'jumlah_pesanan_masuk' => $jumlahPesananMasuk,
            ],
        ]);
    }

    // =========================================================================
    // POST /api/bookings/{id}/pay
    // REVISI: HAPUS update tersedia=false — status mobil kini dari jadwal booking
    // User bayar → notifikasi ke OWNER
    // =========================================================================
    public function pay(Request $request, $id)
    {
        $booking = Booking::with('mobil')->find($id);

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Booking tidak ditemukan'], 404);
        }

        if ($booking->status !== 'unpaid') {
            return response()->json([
                'success' => false,
                'message' => 'Booking belum siap dibayar atau sudah diproses',
            ], 422);
        }

        $booking->update(['status' => 'completed']);

        // REVISI: Baris berikut DIHAPUS karena status mobil kini murni dari jadwal booking.
        // if ($booking->mobil) {
        //     $booking->mobil->update(['tersedia' => false]);
        // }

        // Notifikasi: beritahu owner bahwa user sudah bayar
        if ($booking->mobil && $booking->mobil->user_id) {
            $namaMobil   = $booking->mobil->nama ?? 'mobil';
            $namaPenyewa = $request->user()->name ?? 'Penyewa';
            $totalFmt    = 'Rp ' . number_format($booking->total_harga, 0, ',', '.');

            Notification::create([
                'user_id'    => $booking->mobil->user_id,
                'title'      => '💰 Pembayaran Berhasil!',
                'body'       => "{$namaPenyewa} telah membayar sewa {$namaMobil} senilai {$totalFmt}.",
                'type'       => 'booking_paid',
                'booking_id' => $booking->id,
            ]);
        }

        $kodeTiket = 'RDG-' . strtoupper(str_pad($booking->id, 6, '0', STR_PAD_LEFT));

        return response()->json([
            'success'         => true,
            'message'         => 'Pembayaran berhasil!',
            'booking_id'      => $booking->id,
            'kode_tiket'      => $kodeTiket,
            'nama_mobil'      => $booking->mobil->nama ?? '-',
            'tanggal_mulai'   => $booking->tanggal_mulai->format('d M Y'),
            'tanggal_selesai' => $booking->tanggal_selesai->format('d M Y'),
        ]);
    }

    // =========================================================================
    // GET /api/bookings/auto-complete
    // =========================================================================
    public function autoComplete()
    {
        // REVISI: Tidak perlu ubah tersedia lagi karena status dari jadwal.
        // Fungsi ini tetap ada untuk kompatibilitas route yang sudah ada.
        return response()->json([
            'success' => true,
            'message' => 'Auto complete dijalankan (status mobil kini berbasis jadwal booking).',
        ]);
    }
}