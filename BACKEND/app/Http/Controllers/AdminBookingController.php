<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Http\Request;

// Simpan di: app/Http/Controllers/AdminBookingController.php

class AdminBookingController extends Controller
{
    // __construct() dihapus — Laravel 12 tidak support $this->middleware() di constructor.
    // Middleware 'auth' sudah ditangani di routes/web.php (group middleware ['auth'])

    // ===============================
    // TAMPILKAN SEMUA BOOKING
    // ===============================
    public function index()
    {
        $bookings = Booking::with(['user', 'mobil'])
            ->orderBy('created_at', 'desc')
            ->get();

        return view('admin.bookings', compact('bookings'));
    }

    // ===============================
    // FORCE CANCEL ADMIN
    // POST /admin/bookings/{id}/force-cancel
    // ===============================
    public function forceCancel(Request $request, $id)
    {
        $booking = Booking::with(['user', 'mobil'])->findOrFail($id);

        // ❌ Tidak boleh cancel kalau sudah selesai atau sudah dibatalkan
        if (in_array($booking->status, ['completed', 'cancelled'])) {
            $pesan = $booking->status === 'completed'
                ? 'Booking sudah selesai, tidak bisa dibatalkan.'
                : 'Booking sudah dibatalkan sebelumnya.';

            return back()->with('error', $pesan);
        }

        // ✅ Validasi alasan cancel (opsional, tapi disarankan)
        $request->validate([
            'cancel_reason' => 'nullable|string|max:255',
        ]);

        // ✅ Update status booking
        $booking->update([
            'status'        => 'cancelled',
            'cancelled_by'  => 'admin',   // bisa juga: auth()->id() untuk simpan ID admin
            'cancelled_at'  => now(),
            'cancel_reason' => $request->input('cancel_reason', 'Force cancel oleh admin'),
        ]);

        // ✅ Kembalikan mobil jadi tersedia lagi
        if ($booking->mobil) {
            $booking->mobil->update([
                'tersedia' => true,
            ]);
        }

        return back()->with('success', "Booking #{$booking->id} berhasil dibatalkan oleh admin.");
    }
}