<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Rental; // Panggil model Rental lu

class RentalController extends Controller
{
    // READ: Nampilin semua data rental
    public function index()
    {
        // Ambil semua data rental, kalau lu ada relasi ke tabel User/City bisa ditambahin ->with('user', 'city')
        $rentals = Rental::all(); 
        return response()->json($rentals);
    }

    // CREATE: Nyimpen data rental baru
    public function store(Request $request)
    {
        $rental = Rental::create($request->all());
        return response()->json([
            'success' => true,
            'message' => 'Data rental berhasil ditambah via API',
            'data'    => $rental
        ], 201);
    }

    // READ: Nampilin 1 data rental spesifik buat di-edit
    public function show($id)
    {
        $rental = Rental::findOrFail($id);
        return response()->json($rental);
    }

    // UPDATE: Nyimpen perubahan data rental
    public function update(Request $request, $id)
    {
        $rental = Rental::findOrFail($id);
        $rental->update($request->all());
        
        return response()->json([
            'success' => true,
            'message' => 'Data rental berhasil diupdate via API',
            'data'    => $rental
        ]);
    }

    // DELETE: Hapus data rental
    public function destroy($id)
    {
        $rental = Rental::findOrFail($id);
        $rental->delete();

        return response()->json([
            'success' => true,
            'message' => 'Data rental berhasil dihapus via API'
        ]);
    }
}