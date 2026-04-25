<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Booking;
use App\Models\Mobil;
use Carbon\Carbon;

// Simpan di: app/Http/Controllers/Api/OwnerBookingController.php

class OwnerBookingController extends Controller
{
    // =========================================================================
    // GET /api/owner/bookings
    // Tampilkan pesanan PENDING yang masuk ke mobil milik owner ini
    // Dipanggil: owner_dashboard_page.dart → _loadPesanan()
    //
    // PENTING: Setelah migration alter_mobils_add_user_id sudah dijalankan,
    // pastikan data mobil lama sudah di-set user_id-nya (lihat instruksi di bawah)
    // =========================================================================
    public function index(Request $request)
    {
        // Ambil ID semua mobil milik owner yang sedang login
        $mobilIds = Mobil::where('user_id', $request->user()->id)
                         ->pluck('id');

        $bookings = Booking::with(['mobil', 'user'])
            ->whereIn('mobil_id', $mobilIds)
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn($b) => $this->format($b));

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    // =========================================================================
    // GET /api/owner/bookings/semua
    // Tampilkan SEMUA pesanan untuk mobil milik owner (semua status)
    // =========================================================================
    public function semua(Request $request)
    {
        $mobilIds = Mobil::where('user_id', $request->user()->id)
                         ->pluck('id');

        $bookings = Booking::with(['mobil', 'user'])
            ->whereIn('mobil_id', $mobilIds)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(fn($b) => $this->format($b));

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    // =========================================================================
    // POST /api/owner/bookings/{id}/terima
    // Terima pesanan → status: pending → unpaid, mulai hitung 24 jam
    // Dipanggil: detail_pesanan_masuk_page.dart → _handleTerima()
    // =========================================================================
    public function terima(Request $request, $id)
    {
        $booking = Booking::with('mobil')->find($id);

        if (!$booking || $booking->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak ditemukan atau sudah diproses.',
            ], 404);
        }

        // Pastikan mobil ini memang milik owner yang sedang login
        if ($booking->mobil && $booking->mobil->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak berhak memproses pesanan ini.',
            ], 403);
        }

        $now = Carbon::now();

        $booking->update([
            'status'      => 'unpaid',
            'accepted_at' => $now,
        ]);

        return response()->json([
            'success'        => true,
            'message'        => 'Pesanan diterima! User punya 24 jam untuk membayar.',
            'deadline_bayar' => $now->addHours(24)->toIso8601String(),
        ]);
    }

    // =========================================================================
    // POST /api/owner/bookings/{id}/tolak
    // Tolak pesanan → status: pending → cancelled
    // Dipanggil: detail_pesanan_masuk_page.dart → _handleTolak()
    // =========================================================================
    public function tolak(Request $request, $id)
    {
        $booking = Booking::with('mobil')->find($id);

        if (!$booking || $booking->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak ditemukan atau sudah diproses.',
            ], 404);
        }

        // Pastikan mobil ini memang milik owner yang sedang login
        if ($booking->mobil && $booking->mobil->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak berhak memproses pesanan ini.',
            ], 403);
        }

        $booking->update([
            'status'       => 'cancelled',
            'cancelled_by' => 'owner',
        ]);

        return response()->json(['success' => true, 'message' => 'Pesanan berhasil ditolak.']);
    }

    // =========================================================================
    // Helper: format booking konsisten untuk semua response
    // =========================================================================
    private function format(Booking $b): array
    {
        return [
            'id'              => $b->id,
            'nama_mobil'      => $b->mobil->nama    ?? '-',
            'nama_penyewa'    => $b->user->name     ?? '-',
            'email_penyewa'   => $b->user->email    ?? '-',
            'phone_penyewa'   => $b->user->phone    ?? '-',
            'tanggal_mulai'   => $b->tanggal_mulai->format('d M Y'),
            'tanggal_selesai' => $b->tanggal_selesai->format('d M Y'),
            'total_harga'     => $b->total_harga,
            'status'          => $b->status,
            'cancelled_by'    => $b->cancelled_by,
            'created_at'      => $b->created_at->format('d M Y H:i'),
        ];
    }
}