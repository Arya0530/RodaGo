<?php
// LOKASI: app/Http/Controllers/Api/KycController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\UserKyc;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class KycController extends Controller
{
    // =========================================================================
    // GET /api/kyc/status
    // Ambil status KYC user yang sedang login.
    //
    // Response:
    // {
    //   "success": true,
    //   "data": {
    //     "status": "unverified" | "pending" | "verified" | "rejected",
    //     "rejection_note": null | "Foto buram",
    //     "submitted_at": null | "2024-01-01T..."
    //   }
    // }
    // =========================================================================
    public function status(Request $request)
    {
        $user = $request->user();
        $kyc  = $user->kyc;

        return response()->json([
            'success' => true,
            'data'    => [
                'status'         => $kyc ? $kyc->status : 'unverified',
                'rejection_note' => $kyc ? $kyc->rejection_note : null,
                'submitted_at'   => $kyc ? $kyc->submitted_at : null,
            ],
        ]);
    }

    // =========================================================================
    // POST /api/kyc/upload
    // Upload dokumen KTP dan SIM.
    //
    // Request (multipart/form-data):
    //   ktp_file: file gambar KTP (jpg/png, max 2MB)
    //   sim_file: file gambar SIM (jpg/png, max 2MB)
    // =========================================================================
    public function upload(Request $request)
    {
        $request->validate([
            'ktp_file' => 'required|file|mimes:jpg,jpeg,png|max:2048',
            'sim_file' => 'required|file|mimes:jpg,jpeg,png|max:2048',
        ], [
            'ktp_file.required' => 'File KTP wajib diunggah.',
            'ktp_file.mimes'    => 'KTP harus berformat JPG atau PNG.',
            'ktp_file.max'      => 'Ukuran KTP maksimal 2MB.',
            'sim_file.required' => 'File SIM wajib diunggah.',
            'sim_file.mimes'    => 'SIM harus berformat JPG atau PNG.',
            'sim_file.max'      => 'Ukuran SIM maksimal 2MB.',
        ]);

        $user = $request->user();
        $kyc  = $user->kyc;

        // Hapus file lama dari storage jika ada
        if ($kyc) {
            if ($kyc->ktp_path) Storage::disk('public')->delete($kyc->ktp_path);
            if ($kyc->sim_path) Storage::disk('public')->delete($kyc->sim_path);
        }

        // Simpan file KTP ke storage/app/public/kyc/ktp/
        $ktpPath = $request->file('ktp_file')->store('kyc/ktp', 'public');

        // Simpan file SIM ke storage/app/public/kyc/sim/
        $simPath = $request->file('sim_file')->store('kyc/sim', 'public');

        // Simpan/update ke database
        $kyc = UserKyc::updateOrCreate(
            ['user_id' => $user->id],
            [
                'ktp_path'       => $ktpPath,
                'sim_path'       => $simPath,
                'status'         => 'pending',
                'rejection_note' => null,
                'submitted_at'   => now(),
                'verified_at'    => null,
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Dokumen berhasil dikirim. Sedang menunggu verifikasi.',
            'data'    => [
                'status'       => $kyc->status,
                'submitted_at' => $kyc->submitted_at,
            ],
        ], 200);
    }

    // =========================================================================
    // GET /api/kyc/booking/{bookingId}
    // Owner melihat dokumen KYC (KTP & SIM) milik penyewa.
    // Hanya owner yang mobilnya ada di booking tersebut yang boleh akses.
    //
    // Response:
    // {
    //   "success": true,
    //   "data": {
    //     "status": "verified",
    //     "ktp_url": "https://xxx.ngrok-free.app/storage/kyc/ktp/xxx.jpg",
    //     "sim_url": "https://xxx.ngrok-free.app/storage/kyc/sim/xxx.jpg"
    //   }
    // }
    // =========================================================================
    public function getByBookingId(Request $request, $bookingId)
    {
        $owner = $request->user();

        // Cek booking ada dan milik owner yang login
        $booking = Booking::with('mobil')->find($bookingId);

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Booking tidak ditemukan'], 404);
        }

        // Pastikan mobil di booking ini milik owner yang request
        if ($booking->mobil->user_id !== $owner->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // Ambil KYC penyewa (user yang booking)
        $kyc = UserKyc::where('user_id', $booking->user_id)->first();

        if (!$kyc) {
            return response()->json([
                'success' => true,
                'data'    => [
                    'status'  => 'unverified',
                    'ktp_url' => null,
                    'sim_url' => null,
                ],
            ]);
        }

        // Bangun URL lengkap (pakai url() agar pakai APP_URL dari .env)
        $ktpUrl = $kyc->ktp_path ? url(Storage::url($kyc->ktp_path)) : null;
        $simUrl = $kyc->sim_path ? url(Storage::url($kyc->sim_path)) : null;

        return response()->json([
            'success' => true,
            'data'    => [
                'status'  => $kyc->status,
                'ktp_url' => $ktpUrl,
                'sim_url' => $simUrl,
            ],
        ]);
    }
}