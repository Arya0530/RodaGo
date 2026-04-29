<?php
// LOKASI FILE: app/Http/Controllers/CityController.php

namespace App\Http\Controllers;

use App\Models\City;
use Illuminate\Http\Request;

class CityController extends Controller
{
    public function index()
    {
        $cities = City::orderBy('name')->get();
        return view('admin.cities', compact('cities'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:100|unique:cities,name',
            'province' => 'required|string|max:100',
        ]);

        City::create([
            'name'     => $request->name,
            'province' => $request->province,
        ]);

        return redirect('/admin/cities')->with('success', 'Kota berhasil ditambahkan!');
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name'     => 'required|string|max:100|unique:cities,name,' . $id,
            'province' => 'required|string|max:100',
        ]);

        $city = City::findOrFail($id);
        $city->update([
            'name'     => $request->name,
            'province' => $request->province,
        ]);

        return redirect('/admin/cities')->with('success', 'Kota berhasil diupdate!');
    }

    public function destroy($id)
    {
        $city = City::findOrFail($id);
        $city->delete();

        return redirect('/admin/cities')->with('success', 'Kota berhasil dihapus!');
    }
}