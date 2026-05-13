<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Booking;

class AdminBookingController extends Controller
{
    // GET /admin/bookings
    public function index()
    {
        $bookings = Booking::with(['user', 'mobil'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return view('admin.bookings', compact('bookings'));
    }

    // GET /admin/bookings/{id}
    public function show($id)
    {
        $booking = Booking::with(['user', 'mobil'])->findOrFail($id);
        return view('admin.booking-detail', compact('booking'));
    }

    // PUT /admin/bookings/{id}  — ubah status manual
    public function update(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);

        $request->validate([
            'status' => 'required|in:pending,unpaid,active,completed,cancelled',
        ]);

        $booking->status = $request->status;

        if ($request->status === 'active' && !$booking->accepted_at) {
            $booking->accepted_at = now();
        }

        $booking->save();

        return back()->with('success', 'Status booking berhasil diperbarui!');
    }

    // DELETE /admin/bookings/{id}
    public function destroy($id)
    {
        Booking::findOrFail($id)->delete();
        return back()->with('success', 'Booking berhasil dihapus!');
    }

    // POST /admin/bookings/{id}/force-cancel
    public function forceCancel(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);

        if (!$booking->canForceCancelled()) {
            return back()->with('error', 'Booking ini tidak bisa dibatalkan (sudah selesai/dibatalkan).');
        }

        $booking->update([
            'status'       => 'cancelled',
            'cancelled_by' => 'admin',
            'cancelled_at' => now(),
            'cancel_reason' => $request->input('reason', 'Dibatalkan oleh Admin'),
        ]);

        return back()->with('success', 'Booking berhasil di-force cancel!');
    }
}