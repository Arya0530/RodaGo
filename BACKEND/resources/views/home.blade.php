@extends('layouts.app')

@section('content')
<style>
    .hide-scrollbar::-webkit-scrollbar { display: none; }
    .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

    @keyframes fade-in-up { 
        0% { opacity: 0; transform: translateY(20px); } 
        100% { opacity: 1; transform: translateY(0); } 
    }
    .animate-fade-in-up { animation: fade-in-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
</style>

<div class="max-w-7xl mx-auto animate-fade-in-up">

    <!-- HERO (TIDAK BERUBAH) -->
    <div class="bg-gradient-to-r from-emerald-400 to-emerald-500 rounded-[2rem] p-10 md:p-16 text-center text-white mb-16 shadow-lg shadow-emerald-500/20">
        <h1 class="text-4xl md:text-5xl font-extrabold mb-4 tracking-tight">
            Sewa Mobil Mudah & Cepat
        </h1>
        <p class="text-emerald-50 text-lg md:text-xl max-w-2xl mx-auto mb-8 font-medium">
            Pilih dari puluhan armada terbaik kami. Perjalanan bisnis, liburan keluarga, atau mudik jadi lebih nyaman dengan RodaGo.
        </p>
        <button class="bg-white text-emerald-600 px-8 py-3.5 rounded-full font-bold text-lg hover:bg-gray-50 hover:scale-105 transition-all shadow-md">
            Mulai Sewa Sekarang
        </button>
    </div>

    <!-- ARMADA PILIHAN -->
    <div class="mb-16">
        <div class="flex justify-between items-end mb-6 px-2">
            <div>
                <h2 class="text-2xl font-extrabold text-gray-800">Armada Pilihan Kami</h2>
                <p class="text-gray-500"></p>
            </div>
            <button class="text-emerald-500 font-bold hover:text-emerald-600"></button>
        </div>

        <div id="slider-mobil" class="flex overflow-x-auto gap-6 pb-8 hide-scrollbar px-2 scroll-smooth">
            @foreach ($mobilList as $mobil)
            <a 
                href="/mobil/{{ $mobil->slug }}" 
                class="min-w-[280px] md:min-w-[320px] bg-white border border-gray-100 rounded-2xl p-4 snap-center shadow-sm hover:shadow-md transition-shadow group block no-underline"
            >
                <img src="{{ $mobil->gambar }}?q=80&w=600&auto=format&fit=crop" 
                     alt="{{ $mobil->nama }}" 
                     class="w-full h-40 object-cover rounded-xl mb-4 group-hover:scale-[1.02] transition-transform">
                
                <span class="bg-emerald-100 text-emerald-700 text-xs font-bold px-2.5 py-1 rounded-md">{{ $mobil->tersedia ? 'Tersedia' : 'Disewa' }}</span>
                <h3 class="font-bold text-lg text-gray-800 mt-2">{{ $mobil->nama }}</h3>
                <p class="text-gray-500 text-sm mb-3">{{ $mobil->transmisi }} • {{ $mobil->kursi }} Kursi • {{ $mobil->bahan_bakar }}</p>

                <div class="flex justify-between items-center mt-4">
                    <p class="font-extrabold text-emerald-600">
                        Rp {{ number_format($mobil->harga / 1000, 0) }}k
                        <span class="text-sm text-gray-400">/hari</span>
                    </p>
                    {{-- 
                        Tombol Sewa: pakai onclick + stopPropagation biar klik tombol
                        tidak trigger dua kali (karena sudah ada <a> di parent)
                    --}}
                    <button 
                        onclick="event.preventDefault(); window.location.href='/mobil/{{ $mobil->slug }}'"
                        class="bg-emerald-500 text-white px-4 py-2 rounded-lg text-sm font-bold hover:bg-emerald-600 transition"
                    >
                        Lihat
                    </button>
                </div>
            </a>
            @endforeach
        </div>
    </div>

    <!-- MENGAPA MEMILIH RODAGO (TIDAK BERUBAH) -->
    <div class="bg-white border border-gray-100 rounded-[2rem] p-10 md:p-14 shadow-sm mb-10">
        <h2 class="text-3xl font-extrabold text-center text-gray-800 mb-10">Mengapa Memilih RodaGo?</h2>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-10 items-center">
            <div class="space-y-4">
                <div class="flex items-center gap-3">
                    <div class="w-6 h-6 rounded-full bg-emerald-500 text-white flex items-center justify-center text-sm">✓</div>
                    <p class="text-gray-700 font-medium">Kondisi Armada Selalu Prima & Bersih</p>
                </div>
                <div class="flex items-center gap-3">
                    <div class="w-6 h-6 rounded-full bg-emerald-500 text-white flex items-center justify-center text-sm">✓</div>
                    <p class="text-gray-700 font-medium">Harga Transparan Tanpa Biaya Tersembunyi</p>
                </div>
                <div class="flex items-center gap-3">
                    <div class="w-6 h-6 rounded-full bg-emerald-500 text-white flex items-center justify-center text-sm">✓</div>
                    <p class="text-gray-700 font-medium">Bisa Lepas Kunci</p>
                </div>
                <div class="flex items-center gap-3">
                    <div class="w-6 h-6 rounded-full bg-emerald-500 text-white flex items-center justify-center text-sm">✓</div>
                    <p class="text-gray-700 font-medium">Dukungan Darurat Bantuan 24/7</p>
                </div>
            </div>

            <div class="bg-emerald-50 p-8 rounded-2xl border border-emerald-100">
                <p class="text-emerald-800 leading-relaxed font-medium">
                    "Kami tidak hanya menyewakan mobil, kami memastikan setiap perjalanan Anda aman, nyaman, dan sampai tujuan dengan senyuman. Kepuasan pelanggan adalah prioritas utama kami."
                </p>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const slider = document.getElementById('slider-mobil');
    let autoScroll;

    function startAutoScroll() {
        autoScroll = setInterval(() => {
            if (slider.scrollLeft + slider.clientWidth >= slider.scrollWidth - 5) {
                slider.scrollTo({ left: 0, behavior: 'smooth' });
            } else {
                slider.scrollBy({ left: 344, behavior: 'smooth' });
            }
        }, 1500);
    }

    startAutoScroll();

    slider.addEventListener('mouseenter', () => clearInterval(autoScroll));
    slider.addEventListener('mouseleave', startAutoScroll);
});
</script>
@endsection