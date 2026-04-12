<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rental extends Model
{
    use HasFactory;

    // 1. Izin biar kolom-kolom ini boleh diisi form (Biar gak error Mass Assignment)
    protected $fillable = [
        'user_id',
        'brand_name',
        'city',
    ];

    // 2. Relasi ke tabel User (Karena 1 Rental punya 1 User/Owner)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}