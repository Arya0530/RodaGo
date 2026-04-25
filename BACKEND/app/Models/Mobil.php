<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

// Simpan di: app/Models/Mobil.php

class Mobil extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',       // ← WAJIB: supaya MobilController bisa filter & simpan
        'nama',
        'slug',
        'tipe',
        'harga',
        'kursi',
        'transmisi',
        'bahan_bakar',
        'deskripsi',
        'gambar',
        'tersedia',
    ];

    protected $casts = [
        'tersedia' => 'boolean',
    ];

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    // Relasi ke user (owner pemilik mobil ini)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}