<?php
// LOKASI: app/Models/User.php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasApiTokens;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
        ];
    }

    // Relasi ke tabel mobils
    public function mobils()
    {
        return $this->hasMany(Mobil::class);
    }

    // ── TAMBAHAN: Relasi one-to-one ke UserKyc ─────────────────
    // Setiap user punya satu data KYC
    public function kyc()
    {
        return $this->hasOne(UserKyc::class);
    }
}