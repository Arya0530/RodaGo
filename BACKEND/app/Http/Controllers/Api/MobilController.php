<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Mobil;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class MobilController extends Controller
{
    // GET /api/mobil/public - Get all available mobils for customers (PUBLIC - NO AUTH REQUIRED)
    public function publicIndex()
    {
        return response()->json(Mobil::where('tersedia', true)->with('user')->get());
    }

    // GET /api/mobil - Get all mobils for authenticated user
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Jika user adalah owner/admin, ambil mobil mereka saja
        if ($user) {
            return response()->json(Mobil::where('user_id', $user->id)->get());
        }
        
        // Jika tidak ada user, return empty array
        return response()->json([]);
    }

    // POST /api/mobil - Create new mobil for authenticated user
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama' => 'required|string|max:255',
            'tipe' => 'required|string',
            'harga' => 'required|integer',
            'kursi' => 'required|integer',
            'transmisi' => 'required|string',
            'bahan_bakar' => 'required|string',
            'fitur' => 'nullable|string',
            'deskripsi' => 'nullable|string',
            'gambar' => 'nullable|string',
            'tersedia' => 'boolean',
        ]);

        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $validated['user_id'] = $user->id;
        $validated['slug'] = Str::slug($validated['nama']) . '-' . Str::random(4);

        $mobil = Mobil::create($validated);
        return response()->json($mobil, 201);
    }

    // GET /api/mobil/{id} - Get specific mobil (only owner can view their own)
    public function show(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        
        // Check ownership
        $user = $request->user();
        if ($user && $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        return response()->json($mobil);
    }

    // PUT/PATCH /api/mobil/{id} - Update mobil (only owner can update)
    public function update(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        
        // Check ownership
        $user = $request->user();
        if (!$user || $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        $validated = $request->validate([
            'nama' => 'sometimes|string|max:255',
            'tipe' => 'sometimes|string',
            'harga' => 'sometimes|integer',
            'kursi' => 'sometimes|integer',
            'transmisi' => 'sometimes|string',
            'bahan_bakar' => 'sometimes|string',
            'fitur' => 'nullable|string',
            'deskripsi' => 'nullable|string',
            'gambar' => 'nullable|string',
            'tersedia' => 'boolean',
        ]);

        if (isset($validated['nama'])) {
            $validated['slug'] = Str::slug($validated['nama']) . '-' . Str::random(4);
        }

        $mobil->update($validated);
        return response()->json($mobil);
    }

    // DELETE /api/mobil/{id} - Delete mobil (only owner can delete)
    public function destroy(Request $request, $id)
    {
        $mobil = Mobil::findOrFail($id);
        
        // Check ownership
        $user = $request->user();
        if (!$user || $mobil->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        $mobil->delete();
        return response()->json(['message' => 'Mobil dihapus']);
    }
}