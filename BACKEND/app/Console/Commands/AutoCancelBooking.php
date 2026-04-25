<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Booking;
use Carbon\Carbon;

// Simpan di: app/Console/Commands/AutoCancelBooking.php

class AutoCancelBooking extends Command
{
    protected $signature   = 'booking:auto-cancel';
    protected $description = 'Otomatis batalkan pesanan unpaid yang sudah lebih dari 24 jam';

    public function handle()
    {
        $expired = Booking::where('status', 'unpaid')
            ->where('accepted_at', '<=', Carbon::now()->subHours(24))
            ->get();

        $jumlah = $expired->count();

        foreach ($expired as $booking) {
            $booking->update([
                'status'       => 'cancelled',
                'cancelled_by' => 'system',
            ]);
        }

        $this->info("Auto-cancel selesai: {$jumlah} pesanan dibatalkan.");

        return Command::SUCCESS;
    }
}