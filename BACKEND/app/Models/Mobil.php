<?php
// LOKASI: app/Models/Mobil.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mobil extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',      // ← owner / pemilik mobil
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
        'harga'    => 'integer',
        'kursi'    => 'integer',
    ];

    // Mobil punya banyak booking
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    // Mobil dimiliki satu owner (user)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}