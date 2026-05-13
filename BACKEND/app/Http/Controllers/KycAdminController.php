<?php
// LOKASI: app/Http/Controllers/KycAdminController.php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\UserKyc;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KycAdminController extends Controller
{
    // =========================================================
    // GET /admin/kyc
    // Tampilkan semua pengajuan KYC beserta data user & URL foto
    // =========================================================
    public function index()
    {
        // Ambil semua data KYC beserta relasi user
        // Urutkan: pending dulu (yang perlu ditindak), lalu sisanya
        $kycs = UserKyc::with('user')
            ->orderByRaw("FIELD(status, 'pending', 'rejected', 'verified')")
            ->latest('submitted_at')
            ->get();

        // Hitung statistik untuk header
        $totalPending  = $kycs->where('status', 'pending')->count();
        $totalVerified = $kycs->where('status', 'verified')->count();
        $totalRejected = $kycs->where('status', 'rejected')->count();

        return view('admin.kyc', compact('kycs', 'totalPending', 'totalVerified', 'totalRejected'));
    }

    // =========================================================
    // POST /admin/kyc/{id}/approve
    // Admin menyetujui KYC → status jadi 'verified'
    // =========================================================
    public function approve($id)
    {
        $kyc = UserKyc::findOrFail($id);

        $kyc->update([
            'status'         => 'verified',
            'rejection_note' => null,
            'verified_at'    => now(),
        ]);

        return back()->with('success', 'KYC pengguna ' . ($kyc->user->name ?? '') . ' berhasil disetujui!');
    }

    // =========================================================
    // POST /admin/kyc/{id}/reject
    // Admin menolak KYC → status jadi 'rejected' + catatan alasan
    // =========================================================
    public function reject(Request $request, $id)
    {
        $kyc = UserKyc::findOrFail($id);

        $request->validate([
            'rejection_note' => 'nullable|string|max:500',
        ]);

        $kyc->update([
            'status'         => 'rejected',
            'rejection_note' => $request->input('rejection_note', 'Dokumen tidak sesuai atau tidak terbaca.'),
            'verified_at'    => null,
        ]);

        return back()->with('success', 'KYC pengguna ' . ($kyc->user->name ?? '') . ' telah ditolak.');
    }
}