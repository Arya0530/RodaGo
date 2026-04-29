<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

// LOKASI: app/Models/Rental.php

class Rental extends Model
{
    protected $fillable = [
        'user_id',
        'brand_name',
        'city',
    ];

    // Rental dimiliki oleh seorang owner (user)
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}