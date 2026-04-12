@extends('layouts.admin')

@section('title', 'Kelola User - Admin RodaGo')

@section('content')
    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Kelola Pengguna</h1>
            <p class="text-gray-400 font-medium">Manajemen data User dan Owner (Penyedia).</p>
        </div>
        <!-- Tambah atribut onclick buat buka modal -->
        <button onclick="document.getElementById('modalTambah').classList.remove('hidden')" class="bg-emerald-500 hover:bg-emerald-600 text-white px-5 py-2.5 rounded-xl font-bold shadow-sm transition-all flex items-center gap-2">
            <span>+</span> Tambah User Manual
        </button>
    </header>

    <!-- Notifikasi kalau sukses -->
    @if(session('success'))
        <div class="bg-emerald-100 text-emerald-700 p-4 rounded-xl mb-6 font-bold">
            ✅ {{ session('success') }}
        </div>
    @endif

    <!-- TABLE CRUD -->
    <div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
            <h3 class="font-bold text-gray-800">Daftar Pengguna Terdaftar</h3>
        </div>
        
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                        <th class="p-5 font-bold border-b border-gray-100">Nama Lengkap</th>
                        <th class="p-5 font-bold border-b border-gray-100">Email</th>
                        <th class="p-5 font-bold border-b border-gray-100">Role</th>
                        <th class="p-5 font-bold border-b border-gray-100 text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    @foreach($users as $user)
                    <tr class="hover:bg-gray-50 transition border-b border-gray-50">
                        <td class="p-5 font-bold text-gray-800">{{ $user->name }}</td>
                        <td class="p-5 text-gray-500">{{ $user->email }}</td>
                        <td class="p-5">
                            @if($user->role == 'admin')
                                <span class="bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full text-xs font-bold"> (Admin)</span>
                            @elseif($user->role == 'owner')
                                <span class="bg-purple-50 text-purple-600 px-3 py-1 rounded-full text-xs font-bold">Owner Rental</span>
                            @else
                                <span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-xs font-bold">User Biasa</span>
                            @endif
                        </td>
                        <td class="p-5 flex justify-center gap-2">
    <!-- Kalau dia admin, jangan ditampilin tombolnya biar aman -->
    @if($user->role != 'admin')
    
    <!-- TOMBOL EDIT -->
    <button onclick="document.getElementById('modalEdit{{ $user->id }}').classList.remove('hidden')" class="p-2 bg-gray-100 hover:bg-emerald-100 text-gray-600 hover:text-emerald-600 rounded-lg transition" title="Edit Data">✏️</button>

    <!-- TOMBOL DELETE -->
    <form action="/admin/users/{{ $user->id }}" method="POST" onsubmit="return confirm('Yakin mau suspend/hapus user ini?');">
        @csrf
        @method('DELETE')
        <button type="submit" class="p-2 bg-gray-100 hover:bg-red-100 text-gray-600 hover:text-red-600 rounded-lg transition" title="Suspend/Ban">🛑</button>
    </form>

    <!-- MODAL POPUP EDIT (Nempel di masing-masing user) -->
    <div id="modalEdit{{ $user->id }}" class="hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-50 flex items-center justify-center text-left">
        <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-2xl font-black text-gray-900">Edit Data Pengguna</h2>
                <button type="button" onclick="document.getElementById('modalEdit{{ $user->id }}').classList.add('hidden')" class="text-gray-400 hover:text-red-500 font-bold text-xl">&times;</button>
            </div>
            
            <form action="/admin/users/{{ $user->id }}" method="POST" class="space-y-4">
                @csrf
                @method('PUT') <!-- Wajib ada ini buat Edit di Laravel -->
                
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Nama Lengkap</label>
                    <input type="text" name="name" value="{{ $user->name }}" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Email</label>
                    <input type="email" name="email" value="{{ $user->email }}" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Password Baru (Opsional)</label>
                    <input type="password" name="password" placeholder="Kosongkan jika tidak ingin ganti" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Role/Peran</label>
                    <select name="role" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-gray-700">
                        <option value="user" {{ $user->role == 'user' ? 'selected' : '' }}>User Biasa (Penyewa)</option>
                        <option value="owner" {{ $user->role == 'owner' ? 'selected' : '' }}>Owner (Penyedia Rental)</option>
                    </select>
                </div>
                <button type="submit" class="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-3 rounded-xl mt-4 transition">
                    Update Data
                    </button>
                </form>
            </div>
        </div>
        
        @endif
    </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <!-- MODAL POPUP TAMBAH USER -->
    <div id="modalTambah" class="hidden fixed inset-0 bg-gray-900/50 backdrop-blur-sm z-50 flex items-center justify-center">
        <div class="bg-white rounded-3xl p-8 w-full max-w-md shadow-2xl">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-2xl font-black text-gray-900">Tambah Akun Baru</h2>
                <button onclick="document.getElementById('modalTambah').classList.add('hidden')" class="text-gray-400 hover:text-red-500 font-bold text-xl">&times;</button>
            </div>
            
            <form action="/admin/users" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Nama Lengkap</label>
                    <input type="text" name="name" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Email</label>
                    <input type="email" name="email" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Password</label>
                    <input type="password" name="password" required class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Role/Peran</label>
                    <select name="role" class="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-emerald-500 outline-none font-bold text-gray-700">
                        <option value="user">User Biasa (Penyewa)</option>
                        <option value="owner">Owner (Penyedia Rental)</option>
                        <option value="admin">Admin </option>
                    </select>
                </div>
                <button type="submit" class="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-3 rounded-xl mt-4 transition">
                    Simpan Data
                </button>
            </form>
        </div>
    </div>
@endsection