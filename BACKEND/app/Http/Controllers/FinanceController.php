namespace App\Http\Controllers;

use App\Models\Booking;
use Illuminate\Support\Facades\Auth;

class FinanceController extends Controller
{
    public function getSummary()
    {
        $userId = Auth::id(); // Owner ID

        // Hitung total pendapatan dari mobil milik owner yang statusnya 'completed'
        $totalPendapatan = Booking::whereHas('mobil', function($query) use ($userId) {
            $query->where('user_id', $userId);
        })
        ->where('status', 'completed')
        ->sum('total_harga'); // Pastikan ada kolom total_harga di tabel bookings

        return response()->json([
            'total_pendapatan' => $totalPendapatan,
            'currency' => 'IDR'
        ]);
    }
}