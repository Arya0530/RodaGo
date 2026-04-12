@extends('layouts.admin')

@section('title', 'Penyedia Rental - Admin RodaGo')

@section('content')
    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Penyedia Rental (Mitra)</h1>
            <p class="text-gray-400 font-medium">Manajemen data pemilik mobil dan status operasional.</p>
        </div>
        <button onclick="document.getElementById('modalTambah').classList.remove('hidden')" class="bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2.5 rounded-xl font-bold shadow-sm transition-all flex items-center gap-2">
            <span>+</span> Tambah Mitra Manual
        </button>
    </header>

    @if(session('success'))
        <div class="bg-emerald-100 text-emerald-700 p-4 rounded-xl mb-6 font-bold">
            ✅ {{ session('success') }}
        </div>
    @endif

    <div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                        <th class="p-5 font-bold border-b border-gray-100">Nama Rental</th>
                        <th class="p-5 font-bold border-b border-gray-100">Pemilik</th>
                        <th class="p-5 font-bold border-b border-gray-100">Kota</th>
                        <th class="p-5 font-bold border-b border-gray-100">Status</th>
                        <th class="p-5 font-bold border-b border-gray-100 text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    @foreach($rentals as $rental)
                    <tr class="hover:bg-gray-50 transition border-b border-gray-50">
                        <td class="p-5 font-bold text-gray-800">{{ $rental->brand_name }}</td>
                        <td class="p-5 text-gray-500">{{ $rental->user->name ?? 'N/A' }}</td>
                        <td class="p-5 text-gray-500">{{ $rental->city }}</td>
                        <td class="p-5">
                            <span class="bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full text-xs font-bold uppercase">Aktif</span>
                        </td>
                        <td class="p-5 flex justify-center gap-2">
                            <button onclick="document.getElementById('modalEdit{{ $rental->id }}').classList.remove('hidden')" class="p-2 bg-gray-100 hover:bg-emerald-100 text-gray-600 hover:text-emerald-600 rounded-lg transition">✏️</button>
                            
                            <form action="/admin/rentals/{{ $rental->id }}" method="POST" onsubmit="return confirm('Hapus mitra ini?');">
                                @csrf @method('DELETE')
                                <button type="submit" class="p-2 bg-gray-100 hover:bg-red-100 text-gray-600 hover:text-red-600 rounded-lg transition">🗑️</button>
                            </form>

                            <div id="modalEdit{{ $rental->id }}" class="hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-50 flex items-center justify-center text-left">
                                <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl">
                                    <h2 class="text-2xl font-black text-gray-900 mb-6">Edit Mitra</h2>
                                    <form action="/admin/rentals/{{ $rental->id }}" method="POST" class="space-y-4">
                                        @csrf @method('PUT')
                                        <div>
                                            <label class="block text-sm font-bold text-gray-700 mb-1">Nama Brand</label>
                                            <input type="text" name="brand_name" value="{{ $rental->brand_name }}" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-bold text-gray-700 mb-1">Kota Operasional</label>
                                            <input type="text" name="city" value="{{ $rental->city }}" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                                        </div>
                                        <div class="flex gap-3 mt-6">
                                            <button type="button" onclick="document.getElementById('modalEdit{{ $rental->id }}').classList.add('hidden')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl">Batal</button>
                                            <button type="submit" class="flex-1 bg-emerald-500 text-white font-bold py-3 rounded-xl">Update</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <div id="modalTambah" class="hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-50 flex items-center justify-center">
        <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl text-left">
            <h2 class="text-2xl font-black text-gray-900 mb-6">Daftarkan Mitra Baru</h2>
            <form action="/admin/rentals" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Pilih Pemilik (Owner)</label>
                    <select name="user_id" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                        @foreach($owners as $owner)
                            <option value="{{ $owner->id }}">{{ $owner->name }} ({{ $owner->email }})</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Nama Brand Rental</label>
                    <input type="text" name="brand_name" placeholder="Contoh: Berkah Trans" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Kota</label>
                    <input type="text" name="city" placeholder="Surabaya / Jakarta" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                </div>
                <div class="flex gap-3 mt-6">
                    <button type="button" onclick="document.getElementById('modalTambah').classList.add('hidden')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl">Batal</button>
                    <button type="submit" class="flex-1 bg-emerald-500 text-white font-bold py-3 rounded-xl">Simpan</button>
                </div>
            </form>
        </div>
    </div>
@endsection