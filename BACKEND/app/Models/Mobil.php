<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Mobil extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'nama', 'slug', 'tipe', 'harga', 'kursi', 'transmisi',
        'bahan_bakar', 'fitur', 'deskripsi', 'gambar', 'tersedia'
    ];

    /**
     * Get the user that owns the mobil.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}