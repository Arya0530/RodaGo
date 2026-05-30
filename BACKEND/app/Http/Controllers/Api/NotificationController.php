<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Notification;

// Simpan di: app/Http/Controllers/Api/NotificationController.php

class NotificationController extends Controller
{
    // =========================================================================
    // GET /api/notifications
    // Ambil semua notifikasi milik user yang login, terbaru dulu
    // =========================================================================
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->take(50)
            ->get()
            ->map(fn($n) => [
                'id'         => $n->id,
                'title'      => $n->title,
                'body'       => $n->body,
                'type'       => $n->type,
                'booking_id' => $n->booking_id,
                'is_read'    => $n->is_read,
                'created_at' => $n->created_at->diffForHumans(), // "5 menit yang lalu"
            ]);

        return response()->json(['success' => true, 'data' => $notifications]);
    }

    // =========================================================================
    // GET /api/notifications/unread-count
    // Hanya kembalikan jumlah notifikasi yang belum dibaca
    // Dipakai untuk badge di bottom navigation bar Flutter
    // =========================================================================
    public function unreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json(['success' => true, 'count' => $count]);
    }

    // =========================================================================
    // POST /api/notifications/{id}/read
    // Tandai satu notifikasi sebagai sudah dibaca
    // =========================================================================
    public function markRead(Request $request, $id)
    {
        $notif = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$notif) {
            return response()->json(['success' => false, 'message' => 'Notifikasi tidak ditemukan'], 404);
        }

        $notif->update(['is_read' => true]);

        return response()->json(['success' => true]);
    }

    // =========================================================================
    // POST /api/notifications/read-all
    // Tandai SEMUA notifikasi user sebagai sudah dibaca
    // =========================================================================
    public function markAllRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['success' => true, 'message' => 'Semua notifikasi telah dibaca']);
    }
}