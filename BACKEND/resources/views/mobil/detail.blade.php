@extends('layouts.app')

@section('content')
<style>
    @keyframes fade-in-up {
        0% { opacity: 0; transform: translateY(24px); }
        100% { opacity: 1; transform: translateY(0); }
    }
    .animate-fade-in-up { animation: fade-in-up 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards; }

    @keyframes slide-up {
        0% { opacity: 0; transform: translateY(40px); }
        100% { opacity: 1; transform: translateY(0); }
    }
    .animate-slide-up { animation: slide-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }

    /* Modal backdrop blur */
    #modal-jadwal.active { display: flex !important; }
    #modal-sukses.active { display: flex !important; }

    /* Custom date input style */
    input[type="date"]::-webkit-calendar-picker-indicator {
        opacity: 0;
        position: absolute;
        right: 0;
        width: 100%;
        height: 100%;
        cursor: pointer;
    }
</style>

<div class="max-w-3xl mx-auto animate-fade-in-up px-4 pb-32">

    {{-- TOMBOL KEMBALI --}}
    <div class="mb-6">
        <a href="/" class="inline-flex items-center gap-2 text-gray-500 hover:text-gray-800 font-medium transition-colors group">
            <svg class="w-5 h-5 group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
            </svg>
            Kembali
        </a>
    </div>

    {{-- JUDUL HALAMAN --}}
    <h1 class="text-2xl font-bold text-gray-800 mb-6 text-center">Detail Mobil</h1>

    {{-- GAMBAR MOBIL --}}
    <div class="w-full h-56 md:h-72 bg-gray-100 rounded-2xl overflow-hidden mb-8 shadow-sm">
        <img 
            src="{{ $mobil['img'] }}?q=80&w=800&auto=format&fit=crop" 
            alt="{{ $mobil['nama'] }}"
            class="w-full h-full object-cover"
            onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
        >
        {{-- Fallback kalau gambar gagal load --}}
        <div class="w-full h-full hidden items-center justify-center bg-gray-100">
            <svg class="w-24 h-24 text-gray-300" fill="currentColor" viewBox="0 0 24 24">
                <path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.85 7h10.29l1.08 3.11H5.77L6.85 7zM19 17H5v-5h14v5zm-8 0z"/>
                <circle cx="7.5" cy="14.5" r="1.5"/>
                <circle cx="16.5" cy="14.5" r="1.5"/>
            </svg>
        </div>
    </div>

    {{-- NAMA & HARGA --}}
    <div class="mb-8">
        <h2 class="text-2xl md:text-3xl font-extrabold text-gray-800 mb-2">{{ $mobil['nama'] }}</h2>
        <p class="text-2xl font-extrabold text-emerald-500">
            Rp {{ number_format($mobil['harga'], 0, ',', '.') }}
            <span class="text-base font-normal text-gray-400">/ hari</span>
        </p>
    </div>

    {{-- SPESIFIKASI --}}
    <div class="grid grid-cols-4 gap-3 mb-10">
        @php
            $specs = [
                ['icon' => 'seat',   'label' => $mobil['kursi'] . ' Kursi'],
                ['icon' => 'gear',   'label' => $mobil['transmisi']],
                ['icon' => 'fuel',   'label' => $mobil['bahan_bakar']],
                ['icon' => 'ac',     'label' => $mobil['fitur']],
            ];
        @endphp

        @foreach ($specs as $spec)
        <div class="flex flex-col items-center gap-2">
            <div class="w-14 h-14 bg-emerald-50 rounded-xl flex items-center justify-center">
                @if ($spec['icon'] === 'seat')
                    <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                @elseif ($spec['icon'] === 'gear')
                    <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                    </svg>
                @elseif ($spec['icon'] === 'fuel')
                    <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h1l1-4h10l1 4h1a1 1 0 011 1v7a1 1 0 01-1 1H3a1 1 0 01-1-1v-7a1 1 0 011-1z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 10V6M16 10V6"/>
                    </svg>
                @else
                    <svg class="w-6 h-6 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                    </svg>
                @endif
            </div>
            <span class="text-xs font-bold text-gray-500 text-center leading-tight">{{ $spec['label'] }}</span>
        </div>
        @endforeach
    </div>

    {{-- DESKRIPSI --}}
    <div class="mb-6">
        <h3 class="text-lg font-extrabold text-gray-800 mb-3">Deskripsi</h3>
        <p class="text-gray-500 leading-relaxed">{{ $mobil['deskripsi'] }}</p>
    </div>

    {{-- INFO TAMBAHAN --}}
    <div class="bg-emerald-50 border border-emerald-100 rounded-2xl p-5 mb-4">
        <div class="flex items-start gap-3">
            <svg class="w-5 h-5 text-emerald-500 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            <p class="text-emerald-700 text-sm leading-relaxed">
                Syarat penyewaan: KTP & SIM A aktif. Pembayaran dilakukan secara online. Mobil tersedia untuk sewa lepas kunci maupun dengan sopir.
            </p>
        </div>
    </div>

</div>

{{-- TOMBOL PESAN (FIXED DI BAWAH, PERSIS SEPERTI FLUTTER) --}}
<div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 shadow-[0_-4px_20px_rgba(0,0,0,0.06)] p-5 z-40">
    <div class="max-w-3xl mx-auto">
        <button 
            onclick="bukaModalJadwal()"
            class="w-full bg-emerald-500 hover:bg-emerald-600 active:bg-emerald-700 text-white font-bold text-lg py-4 rounded-2xl transition-all hover:scale-[1.01] active:scale-[0.99] shadow-md shadow-emerald-500/30"
        >
            Pesan Sekarang
        </button>
    </div>
</div>


{{-- ============================================================ --}}
{{-- MODAL: FORM JADWAL (sama seperti ModalBottomSheet di Flutter) --}}
{{-- ============================================================ --}}
<div id="modal-jadwal" 
     class="fixed inset-0 z-50 hidden items-end justify-center bg-black/40 backdrop-blur-sm"
     onclick="tutupModalJadwal(event)">
    <div class="bg-white w-full max-w-3xl rounded-t-3xl p-7 animate-slide-up" onclick="event.stopPropagation()">
        
        <div class="w-12 h-1 bg-gray-200 rounded-full mx-auto mb-6"></div>
        
        <h3 class="text-xl font-extrabold text-gray-800 mb-6">Atur Jadwal Sewa</h3>

        {{-- INPUT TANGGAL AMBIL --}}
        <div class="mb-4">
            <label class="block text-sm font-bold text-gray-700 mb-2">Tanggal Ambil</label>
            <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none">
                    <svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                    </svg>
                </span>
                <input 
                    type="date" 
                    id="tanggal-ambil"
                    class="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-200 rounded-xl font-medium text-gray-700 focus:outline-none focus:ring-2 focus:ring-emerald-400 focus:border-transparent transition cursor-pointer"
                    onchange="updateMinKembali()"
                >
            </div>
        </div>

        {{-- INPUT TANGGAL KEMBALI --}}
        <div class="mb-8">
            <label class="block text-sm font-bold text-gray-700 mb-2">Tanggal Kembali</label>
            <div class="relative">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 pointer-events-none">
                    <svg class="w-5 h-5 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                </span>
                <input 
                    type="date" 
                    id="tanggal-kembali"
                    class="w-full pl-12 pr-4 py-4 bg-gray-50 border border-gray-200 rounded-xl font-medium text-gray-700 focus:outline-none focus:ring-2 focus:ring-emerald-400 focus:border-transparent transition cursor-pointer"
                    disabled
                >
            </div>
        </div>

        {{-- RINGKASAN HARGA --}}
        <div id="ringkasan-harga" class="hidden bg-emerald-50 border border-emerald-100 rounded-xl p-4 mb-6">
            <div class="flex justify-between items-center">
                <span class="text-gray-600 font-medium text-sm">Durasi Sewa</span>
                <span id="durasi-text" class="font-bold text-gray-800">-</span>
            </div>
            <div class="flex justify-between items-center mt-2">
                <span class="text-gray-600 font-medium text-sm">Total Estimasi</span>
                <span id="total-text" class="font-extrabold text-emerald-600">-</span>
            </div>
        </div>

        {{-- TOMBOL KONFIRMASI --}}
        <button 
            id="btn-konfirmasi"
            onclick="konfirmasi()"
            disabled
            class="w-full bg-emerald-500 text-white font-bold text-base py-4 rounded-2xl transition-all disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed enabled:hover:bg-emerald-600 enabled:hover:scale-[1.01] shadow-md shadow-emerald-500/20 disabled:shadow-none"
        >
            Konfirmasi &amp; Bayar
        </button>
    </div>
</div>


{{-- ============================================================ --}}
{{-- MODAL: POPUP BERHASIL (sama seperti AlertDialog di Flutter) --}}
{{-- ============================================================ --}}
<div id="modal-sukses" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40 backdrop-blur-sm px-6">
    <div class="bg-white w-full max-w-sm rounded-3xl p-8 text-center shadow-2xl animate-fade-in-up">
        
        {{-- Icon centang bulat --}}
        <div class="w-24 h-24 bg-emerald-50 rounded-full flex items-center justify-center mx-auto mb-5">
            <svg class="w-14 h-14 text-emerald-500" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 14.5l-4-4 1.41-1.41L10 13.67l6.59-6.59L18 8.5l-8 8z"/>
            </svg>
        </div>

        <h3 class="text-xl font-extrabold text-gray-800 mb-2">Pemesanan Berhasil!</h3>
        <p class="text-gray-500 leading-relaxed text-sm mb-7">
            Jadwal sewa <strong>{{ $mobil['nama'] }}</strong> Anda telah dikonfirmasi. Silakan cek menu Pesanan.
        </p>

        <button 
            onclick="tutupSukses()"
            class="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-3.5 rounded-xl transition-all"
        >
            Lihat Pesanan
        </button>
    </div>
</div>


<script>
    // Harga mobil dari PHP (dalam rupiah)
    const hargaPerHari = {{ $mobil['harga'] }};

    // Set tanggal minimum = hari ini
    const today = new Date().toISOString().split('T')[0];
    document.getElementById('tanggal-ambil').min = today;

    // === BUKA/TUTUP MODAL JADWAL ===
    function bukaModalJadwal() {
        document.getElementById('modal-jadwal').classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function tutupModalJadwal(e) {
        // Hanya tutup kalau klik backdrop (bukan kontennya)
        if (e && e.currentTarget === e.target) {
            document.getElementById('modal-jadwal').classList.remove('active');
            document.body.style.overflow = '';
        }
    }

    // === UPDATE MIN TANGGAL KEMBALI (sama seperti logika firstDate di Flutter) ===
    function updateMinKembali() {
        const ambil = document.getElementById('tanggal-ambil').value;
        const kembaliInput = document.getElementById('tanggal-kembali');
        
        if (ambil) {
            kembaliInput.min = ambil;
            kembaliInput.disabled = false;
            kembaliInput.value = ''; // Reset nilai kembali
            document.getElementById('ringkasan-harga').classList.add('hidden');
            document.getElementById('btn-konfirmasi').disabled = true;
        }
    }

    // === HITUNG DURASI & TOTAL HARGA ===
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('tanggal-kembali').addEventListener('change', function() {
            const ambil = new Date(document.getElementById('tanggal-ambil').value);
            const kembali = new Date(this.value);

            if (ambil && kembali && kembali >= ambil) {
                const selisihMs = kembali - ambil;
                const durasi = Math.ceil(selisihMs / (1000 * 60 * 60 * 24));
                const total = durasi * hargaPerHari;

                document.getElementById('durasi-text').textContent = durasi + ' Hari';
                document.getElementById('total-text').textContent = 'Rp ' + total.toLocaleString('id-ID');
                document.getElementById('ringkasan-harga').classList.remove('hidden');
                document.getElementById('btn-konfirmasi').disabled = false;
            }
        });
    });

    // === KONFIRMASI → TUTUP MODAL JADWAL → BUKA POPUP SUKSES ===
    function konfirmasi() {
        document.getElementById('modal-jadwal').classList.remove('active');
        setTimeout(() => {
            document.getElementById('modal-sukses').classList.add('active');
        }, 200);
    }

    // === TUTUP POPUP SUKSES → BALIK KE HOME ===
    function tutupSukses() {
        document.getElementById('modal-sukses').classList.remove('active');
        document.body.style.overflow = '';
        window.location.href = '/';
    }
</script>
@endsection