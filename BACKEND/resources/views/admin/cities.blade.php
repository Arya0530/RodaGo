@extends('layouts.admin')

@section('title', 'Kelola Kota - Admin RodaGo')

@section('content')
    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Area Operasional (Kota)</h1>
            <p class="text-gray-400 font-medium">Atur wilayah jangkauan aplikasi RodaGo.</p>
        </div>
        <button onclick="document.getElementById('modalTambah').classList.remove('hidden')" class="bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2.5 rounded-xl font-bold shadow-sm transition-all flex items-center gap-2">
            <span>+</span> Buka Wilayah Baru
        </button>
    </header>

    @if(session('success'))
        <div class="bg-emerald-100 text-emerald-700 p-4 rounded-xl mb-6 font-bold">
            ✅ {{ session('success') }}
        </div>
    @endif

    <!-- TABEL KOTA -->
    <div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                        <th class="p-5 font-bold border-b border-gray-100">Nama Kota</th>
                        <th class="p-5 font-bold border-b border-gray-100">Provinsi</th>
                        <th class="p-5 font-bold border-b border-gray-100 text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    @foreach($cities as $city)
                    <tr class="hover:bg-gray-50 transition border-b border-gray-50">
                        <td class="p-5 font-black text-gray-800">{{ $city->name }}</td>
                        <td class="p-5 text-gray-500">{{ $city->province }}</td>
                        <td class="p-5 flex justify-center gap-2">
                            <!-- Tombol Edit -->
                            <button onclick="document.getElementById('modalEdit{{ $city->id }}').classList.remove('hidden')" class="p-2 bg-gray-100 hover:bg-emerald-100 text-gray-600 hover:text-emerald-600 rounded-lg transition" title="Edit">✏️</button>
                            
                            <!-- Tombol Delete -->
                            <form action="/admin/cities/{{ $city->id }}" method="POST" onsubmit="return confirm('Yakin mau menutup area ini?');">
                                @csrf @method('DELETE')
                                <button type="submit" class="p-2 bg-gray-100 hover:bg-red-100 text-gray-600 hover:text-red-600 rounded-lg transition" title="Tutup Wilayah">🗑️</button>
                            </form>
                        </td>
                    </tr>

                    <!-- MODAL EDIT (Nempel di masing-masing kota) -->
                    <div id="modalEdit{{ $city->id }}" class="hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-50 flex items-center justify-center text-left">
                        <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl">
                            <h2 class="text-2xl font-black text-gray-900 mb-6">Edit Area Operasional</h2>
                            <form action="/admin/cities/{{ $city->id }}" method="POST" class="space-y-4">
                                @csrf @method('PUT')
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-1">Nama Kota</label>
                                    <input type="text" name="name" value="{{ $city->name }}" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                                </div>
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-1">Provinsi</label>
                                    <input type="text" name="province" value="{{ $city->province }}" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                                </div>
                                <div class="flex gap-3 mt-6">
                                    <button type="button" onclick="document.getElementById('modalEdit{{ $city->id }}').classList.add('hidden')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl">Batal</button>
                                    <button type="submit" class="flex-1 bg-emerald-500 text-white font-bold py-3 rounded-xl">Update</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <!-- MODAL TAMBAH KOTA -->
    <div id="modalTambah" class="hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-50 flex items-center justify-center text-left">
        <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl">
            <h2 class="text-2xl font-black text-gray-900 mb-6">Buka Area Baru</h2>
            <form action="/admin/cities" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Nama Kota</label>
                    <input type="text" name="name" placeholder="Contoh: Surabaya" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Provinsi</label>
                    <input type="text" name="province" placeholder="Contoh: Jawa Timur" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl outline-none focus:ring-2 focus:ring-emerald-500">
                </div>
                <div class="flex gap-3 mt-6">
                    <button type="button" onclick="document.getElementById('modalTambah').classList.add('hidden')" class="flex-1 bg-gray-100 text-gray-600 font-bold py-3 rounded-xl">Batal</button>
                    <button type="submit" class="flex-1 bg-emerald-500 text-white font-bold py-3 rounded-xl">Simpan</button>
                </div>
            </form>
        </div>
    </div>
@endsection