<?php
// LOKASI: app/Models/UserKyc.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserKyc extends Model
{
    use HasFactory;

    protected $table = 'user_kycs';

    protected $fillable = [
        'user_id',
        'ktp_path',
        'sim_path',
        'status',
        'rejection_note',
        'submitted_at',
        'verified_at',
    ];

    protected $casts = [
        'submitted_at' => 'datetime',
        'verified_at'  => 'datetime',
    ];

    // ── Relasi: KYC dimiliki satu User ────────────────────────
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // ── Helper: apakah sudah terverifikasi? ───────────────────
    public function isVerified(): bool
    {
        return $this->status === 'verified';
    }

    // ── Helper: apakah sedang menunggu review? ────────────────
    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    // CATATAN: method kyc() yang ada di versi lama SALAH TEMPAT.
    // kyc() adalah relasi di model User, bukan di UserKyc.
    // Sudah dipindah ke app/Models/User.php
}