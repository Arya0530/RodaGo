@extends('layouts.app')

@section('title', 'Tentang Kami - RodaGo')

@section('content')
<div class="max-w-6xl mx-auto animate-fade-in-up">
    
    <div class="bg-white rounded-[3rem] p-10 md:p-20 shadow-sm text-center mb-16 relative overflow-hidden">
        <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-emerald-400 to-teal-500"></div>
        <div class="absolute -top-24 -right-24 w-48 h-48 bg-emerald-50 rounded-full blur-3xl"></div>
        
        <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-6 relative z-10">Mengubah Cara Anda<br><span class="text-appteal">Menyewa Kendaraan</span></h1>
        <p class="text-xl text-gray-500 max-w-3xl mx-auto leading-relaxed relative z-10">
            RodaGo lahir dari sebuah ide sederhana: menyewa mobil harusnya semudah memesan makanan. Kami menggabungkan teknologi modern dengan pelayanan sepenuh hati.
        </p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 mb-16">
        <div class="space-y-8">
            <div>
                <div class="w-12 h-12 bg-emerald-100 rounded-2xl flex items-center justify-center mb-4 text-2xl">🌱</div>
                <h3 class="text-2xl font-extrabold text-gray-900 mb-2">Visi Kami</h3>
                <p class="text-gray-600 leading-relaxed">Menjadi platform digital mobility nomor satu di Indonesia yang mengutamakan transparansi harga, keamanan unit, dan kenyamanan pengguna dalam setiap perjalanan.</p>
            </div>
            <div>
                <div class="w-12 h-12 bg-blue-100 rounded-2xl flex items-center justify-center mb-4 text-2xl">🤝</div>
                <h3 class="text-2xl font-extrabold text-gray-900 mb-2">Komitmen Kami</h3>
                <p class="text-gray-600 leading-relaxed">Tidak ada biaya tersembunyi. Semua armada kami diservis rutin di bengkel resmi. Keselamatan dan kenyamanan Anda adalah metrik kesuksesan utama kami.</p>
            </div>
        </div>

        <div class="bg-white p-8 md:p-10 rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 flex flex-col justify-center">
            <h3 class="text-sm font-bold text-appteal uppercase tracking-widest mb-8">Dikembangkan Oleh</h3>
            
            <div class="flex items-center gap-6 mb-8">
                <img src="https://ui-avatars.com/api/?name=Arya+Nugraha&background=10b981&color=fff&size=128" alt="Arya" class="w-24 h-24 rounded-full shadow-md">
                <div>
                    <h2 class="text-2xl font-extrabold text-gray-900">Arya Nugraha</h2>
                    <p class="text-gray-500 font-medium">Mahasiswa / System Engineer</p>
                    <div class="mt-2 inline-block bg-gray-100 text-gray-600 px-3 py-1 rounded-lg text-sm font-bold">
                        NRP: 3124521043
                    </div>
                </div>
            </div>
            
            <p class="text-gray-600 italic">"Sistem RodaGo ini dibangun menggunakan framework Laravel dan Tailwind CSS sebagai Proyek Akhir untuk mendemonstrasikan integrasi sistem informasi manajemen rental yang responsif dan modern."</p>
        </div>
    </div>
</div>

<style>
    @keyframes fade-in-up { 0% { opacity: 0; transform: translateY(20px); } 100% { opacity: 1; transform: translateY(0); } }
    .animate-fade-in-up { animation: fade-in-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
</style>
@endsection