@extends('layouts.app')

@section('title', 'Fitur Monitor - RodaGo')

@section('content')
<div class="max-w-7xl mx-auto animate-fade-in-up">
    
    <div class="text-center mb-16">
        <span class="text-emerald-500 font-bold tracking-widest text-sm uppercase mb-3 block">RodaGo Command Center</span>
        <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-6 tracking-tight">Kendali Penuh di <span class="text-emerald-500">Tangan Anda</span></h1>
        <p class="text-lg text-gray-500 max-w-2xl mx-auto">Website ini bertindak sebagai pusat monitoring untuk aplikasi mobile RodaGo. Pantau semua aktivitas, amankan transaksi, dan kelola ekosistem dalam satu layar.</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-16">
        
        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group">
            <div class="w-14 h-14 bg-blue-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-blue-100 transition-colors">
                <span class="text-2xl">👀</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">Live Monitoring</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Pantau seluruh aktivitas sewa secara real-time. Lihat detail pesanan masuk, status pembayaran, hingga waktu pengembalian secara transparan.</p>
        </div>

        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group">
            <div class="w-14 h-14 bg-red-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-red-100 transition-colors">
                <span class="text-2xl">🚫</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">User & Owner Suspend</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Hak akses penuh untuk melakukan blokir (suspend) sementara atau permanen kepada akun penyewa maupun pemilik mobil yang melanggar aturan.</p>
        </div>

        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group">
            <div class="w-14 h-14 bg-orange-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-orange-100 transition-colors">
                <span class="text-2xl">🛑</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">Emergency Halt</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Tindak cepat saat terjadi masalah di lapangan. Admin dapat membatalkan atau membekukan transaksi yang sedang berlangsung secara sepihak.</p>
        </div>

        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group">
            <div class="w-14 h-14 bg-emerald-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-emerald-100 transition-colors">
                <span class="text-2xl">📍</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">Live GPS Tracking</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Lacak koordinat pasti setiap armada yang sedang disewa untuk mencegah penggelapan dan memastikan keamanan aset kendaraan.</p>
        </div>

        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group">
            <div class="w-14 h-14 bg-purple-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-purple-100 transition-colors">
                <span class="text-2xl">🛡️</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">Verifikasi Berkas (KYC)</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Otoritas penuh untuk menyetujui (approve) atau menolak dokumen KTP dan SIM pengguna baru untuk mencegah penipuan identitas.</p>
        </div>

        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group">
            <div class="w-14 h-14 bg-green-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-green-100 transition-colors">
                <span class="text-2xl">💸</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">Manajemen Pencairan</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Atur potongan komisi platform dan proses pencairan dana (withdrawal) hasil sewa langsung ke rekening para Owner mobil.</p>
        </div>

        <div class="bg-white rounded-[2rem] p-8 shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all hover:-translate-y-1 border border-gray-50 group lg:col-start-2">
            <div class="w-14 h-14 bg-slate-50 rounded-2xl flex items-center justify-center mb-6 group-hover:bg-slate-100 transition-colors">
                <span class="text-2xl">⚙️</span>
            </div>
            <h3 class="text-xl font-extrabold text-gray-900 mb-3">Master Data Control</h3>
            <p class="text-gray-500 text-sm leading-relaxed">Pusat data. Tambah kategori mobil, ubah harga, update promo, hingga atur syarat dan ketentuan aplikasi secara dinamis.</p>
        </div>

    </div>
</div>

<style>
    @keyframes fade-in-up { 0% { opacity: 0; transform: translateY(20px); } 100% { opacity: 1; transform: translateY(0); } }
    .animate-fade-in-up { animation: fade-in-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
</style>
@endsection