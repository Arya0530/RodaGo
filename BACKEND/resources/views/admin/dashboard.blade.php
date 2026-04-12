@extends('layouts.admin')

@section('title', 'Dashboard - Admin RodaGo')

@section('content')
    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Command Center Dashboard</h1>
            <p class="text-gray-400 font-medium">Monitoring sistem RodaGo secara real-time.</p>
        </div>
        <div class="bg-white px-5 py-2.5 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-3">
            <div class="w-9 h-9 bg-emerald-500 rounded-xl flex items-center justify-center text-white text-sm font-bold shadow-lg shadow-emerald-200">A</div>
            <div>
                <p class="text-xs text-gray-400 font-bold leading-none">ADMINISTRATOR</p>
                <p class="text-sm font-extrabold text-gray-800 leading-tight">Super Admin</p>
            </div>
        </div>
    </header>

<!-- STATS CARDS -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-10">
        <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100 transition-all hover:shadow-md">
            <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Total User</p>
            <h3 class="text-3xl font-black text-gray-900">{{ number_format($totalUsers) }}</h3>
            <div class="mt-2 text-emerald-500 text-xs font-bold">Terdaftar di Sistem</div>
        </div>
        <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100 transition-all hover:shadow-md">
            <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Penyedia Rental</p>
            <h3 class="text-3xl font-black text-gray-900">{{ number_format($totalRentals) }}</h3>
            <div class="mt-2 text-emerald-500 text-xs font-bold">Mitra Aktif</div>
        </div>
        
        <!-- DIBIKIN SEOLAH-OLAH NUNGGU DATA FLUTTER -->
        <div class="bg-gray-50 p-6 rounded-[2rem] shadow-sm border border-dashed border-gray-200 opacity-80">
            <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Live Monitor Mobil</p>
            <h3 class="text-2xl font-black text-gray-400">Syncing...</h3>
            <div class="mt-2 text-gray-400 text-xs font-bold">Menunggu API Mobile</div>
        </div>
        <div class="bg-gray-50 p-6 rounded-[2rem] shadow-sm border border-dashed border-gray-200 opacity-80">
            <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Pending Booking</p>
            <h3 class="text-2xl font-black text-gray-400">Syncing...</h3>
            <div class="mt-2 text-gray-400 text-xs font-bold">Menunggu API Mobile</div>
        </div>
    </div>

    <!-- ACTIVITY MONITOR (DIBIKIN JADI TAHAP INTEGRASI) -->
    <div class="bg-white rounded-[2.5rem] p-10 shadow-sm border border-gray-100">
        <div class="flex justify-between items-center mb-8">
            <h3 class="text-xl font-black text-gray-800 italic uppercase">Aktivitas Transaksi</h3>
            <span class="bg-orange-50 text-orange-500 px-4 py-1 rounded-full text-xs font-bold border border-orange-100">Development Phase</span>
        </div>
        <div class="text-center py-20 border-2 border-dashed border-gray-100 rounded-[2rem] bg-gray-50/50">
            <div class="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-sm border border-gray-100">
                <span class="text-2xl animate-pulse">📱</span>
            </div>
            <h4 class="text-gray-800 font-bold mb-2">Integrasi API Flutter Sedang Disiapkan</h4>
            <p class="text-gray-400 text-sm max-w-md mx-auto">
                Live stream transaksi akan berjalan otomatis setelah endpoint API terhubung dengan aplikasi mobile RodaGo di tahap pengembangan selanjutnya.
            </p>
        </div>
    </div>
@endsection