<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatController extends Controller
{
    public function sendToAI(Request $request)
    {
        // 1. Ambil pesan dari Flutter
        $userMessage = $request->input('message');

        try {
            // 2. Teruskan pesan ke Python Flask (AI_SERVICE) di port 5000
            // Pastikan Python app.py sedang menyala!
            $response = Http::post('http://127.0.0.1:5000/predict', [
                'message' => $userMessage
            ]);

            // 3. Ambil balasan dari Python
            $botReply = $response->json()['reply'] ?? 'Maaf, AI sedang gangguan.';

            // 5. Kembalikan balasan JSON ke Flutter
            return response()->json([
                'status' => 'success',
                'reply' => $botReply
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'reply' => 'Gagal terhubung ke AI Service Python.'
            ], 500);
        }
    }
}