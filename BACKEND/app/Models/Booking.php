<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

// Simpan di: app/Models/Booking.php

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'mobil_id',
        'tanggal_mulai',
        'tanggal_selesai',
        'total_harga',
        'status',
        'cancelled_by',
        'cancelled_at',      // ✅ TAMBAHAN
        'cancel_reason',     // ✅ TAMBAHAN
        'accepted_at',
    ];

    protected $casts = [
        'tanggal_mulai'   => 'date',
        'tanggal_selesai' => 'date',
        'accepted_at'     => 'datetime',
        'cancelled_at'    => 'datetime', // ✅ TAMBAHAN
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function mobil()
    {
        return $this->belongsTo(Mobil::class);
    }

    // ✅ Helper: Apakah booking ini bisa di-force cancel?
    public function canForceCancelled(): bool
    {
        return !in_array($this->status, ['completed', 'cancelled']);
    }

    // ✅ Helper: Label status dalam Bahasa Indonesia
    public function statusLabel(): string
    {
        return match($this->status) {
            'pending'   => 'Menunggu Konfirmasi',
            'unpaid'    => 'Belum Dibayar',
            'active'    => 'Sedang Berjalan',
            'completed' => 'Selesai',
            'cancelled' => 'Dibatalkan',
            default     => ucfirst($this->status),
        };
    }

    // ✅ Helper: Warna badge status
    public function statusColor(): string
    {
        return match($this->status) {
            'pending'   => 'yellow',
            'unpaid'    => 'orange',
            'active'    => 'blue',
            'completed' => 'green',
            'cancelled' => 'red',
            default     => 'gray',
        };
    }
    public function scopeCompleted($query)
{
    return $query->where('status', 'completed');
}
}