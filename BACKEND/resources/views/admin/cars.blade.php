{{-- LOKASI: resources/views/admin/cars.blade.php --}}
{{--                                                              --}}
{{-- PERUBAHAN:                                                    --}}
{{--   1. Tambah kolom "Foto" di tabel                            --}}
{{--   2. Gambar support path relatif (data baru) DAN URL lama    --}}
{{--   3. Modal preview foto (klik gambar → zoom), sama seperti   --}}
{{--      kyc.blade.php                                           --}}
@extends('layouts.admin')
@section('title', 'Data Armada - Admin RodaGo')

@section('content')

{{-- Flash message --}}
@if(session('success'))
    <div class="mb-6 bg-emerald-50 border border-emerald-200 text-emerald-700 px-5 py-3 rounded-2xl flex items-center gap-2">
        <span>✅</span> {{ session('success') }}
    </div>
@endif
@if(session('error'))
    <div class="mb-6 bg-red-50 border border-red-200 text-red-700 px-5 py-3 rounded-2xl flex items-center gap-2">
        <span>⚠️</span> {{ session('error') }}
    </div>
@endif

{{-- Header + statistik --}}
<div class="flex flex-wrap justify-between items-start gap-4 mb-8">
    <div>
        <h1 class="text-2xl font-extrabold text-gray-900">Data Armada</h1>
        <p class="text-gray-400 text-sm mt-1">Seluruh mobil yang terdaftar di sistem RodaGo.</p>
    </div>
    <div class="flex gap-3 flex-wrap">
        <div class="bg-white border border-gray-100 rounded-2xl px-5 py-3 text-center shadow-sm">
            <p class="text-2xl font-black text-gray-800">{{ $stats['total'] }}</p>
            <p class="text-xs text-gray-400 font-semibold mt-0.5">Total Mobil</p>
        </div>
        <div class="bg-emerald-50 border border-emerald-100 rounded-2xl px-5 py-3 text-center">
            <p class="text-2xl font-black text-emerald-600">{{ $stats['tersedia'] }}</p>
            <p class="text-xs text-emerald-500 font-semibold mt-0.5">Tersedia</p>
        </div>
        <div class="bg-amber-50 border border-amber-100 rounded-2xl px-5 py-3 text-center">
            <p class="text-2xl font-black text-amber-600">{{ $stats['disewa'] }}</p>
            <p class="text-xs text-amber-500 font-semibold mt-0.5">Sedang Disewa</p>
        </div>
    </div>
</div>

{{-- Tabel --}}
<div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-left">
            <thead>
                <tr class="bg-gray-50 text-gray-400 text-xs uppercase tracking-wider border-b border-gray-100">
                    <th class="px-5 py-4 font-bold">Foto</th>
                    <th class="px-5 py-4 font-bold">Nama Mobil</th>
                    <th class="px-5 py-4 font-bold">Tipe</th>
                    <th class="px-5 py-4 font-bold">Pemilik Rental</th>
                    <th class="px-5 py-4 font-bold">Harga / Hari</th>
                    <th class="px-5 py-4 font-bold text-center">Kursi</th>
                    <th class="px-5 py-4 font-bold text-center">Status</th>
                    <th class="px-5 py-4 font-bold text-center">Aksi</th>
                </tr>
            </thead>
            <tbody>
                @forelse($mobils as $mobil)
                    @php
                        // ── Gambar URL ───────────────────────────────────────
                        // Support dua format kolom gambar:
                        //   1. Path relatif baru  : "mobil/AbCd.jpg"
                        //   2. URL absolut lama   : "https://xxx.ngrok.../storage/mobil/AbCd.jpg"
                        $gambarUrl = null;
                        if (!empty($mobil->gambar)) {
                            if (str_starts_with($mobil->gambar, 'http')) {
                                // Data lama → pakai URL apa adanya
                                // (akan tetap muncul selama ngrok masih aktif,
                                //  setelah owner edit+simpan ulang otomatis pakai path baru)
                                $gambarUrl = $mobil->gambar;
                            } else {
                                // Data baru → bangun URL dari storage
                                $gambarUrl = url(Storage::url($mobil->gambar));
                            }
                        }

                        // ── Status badge ────────────────────────────────────
                        $sedangDisewa = in_array($mobil->id, $activeBookingIds);
                        if (!$mobil->tersedia) {
                            $badgeClass = 'bg-red-50 text-red-500';
                            $badgeText  = 'Nonaktif';
                        } elseif ($sedangDisewa) {
                            $badgeClass = 'bg-amber-50 text-amber-600';
                            $badgeText  = 'Sedang Disewa';
                        } else {
                            $badgeClass = 'bg-emerald-50 text-emerald-600';
                            $badgeText  = 'Tersedia';
                        }
                    @endphp

                    <tr class="border-b border-gray-50 hover:bg-gray-50 transition">

                        {{-- ── FOTO ──────────────────────────────────────────── --}}
                        <td class="px-5 py-4">
                            @if($gambarUrl)
                                <img
                                    src="{{ $gambarUrl }}"
                                    alt="{{ $mobil->nama }}"
                                    onclick="previewImage('{{ $gambarUrl }}', '{{ addslashes($mobil->nama) }}')"
                                    class="w-20 h-14 object-cover rounded-xl cursor-pointer hover:scale-105 transition shadow border border-gray-100"
                                    onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                                >
                                {{-- Fallback jika gambar gagal load (URL ngrok expired) --}}
                                <div class="w-20 h-14 rounded-xl bg-gray-100 items-center justify-center hidden text-gray-300 text-xs text-center p-1" style="flex-direction:column;">
                                    <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                    </svg>
                                    No foto
                                </div>
                            @else
                                {{-- Belum ada foto --}}
                                <div class="w-20 h-14 rounded-xl bg-gray-100 flex flex-col items-center justify-center text-gray-300">
                                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                                    </svg>
                                    <span class="text-[10px] mt-1">No foto</span>
                                </div>
                            @endif
                        </td>

                        {{-- Nama --}}
                        <td class="px-5 py-4">
                            <p class="font-bold text-gray-800 text-sm">{{ $mobil->nama }}</p>
                            <p class="text-xs text-gray-400 mt-0.5">{{ $mobil->transmisi }} · {{ $mobil->bahan_bakar }}</p>
                        </td>

                        {{-- Tipe --}}
                        <td class="px-5 py-4">
                            <span class="bg-gray-100 text-gray-600 text-xs px-3 py-1 rounded-full font-semibold">
                                {{ $mobil->tipe }}
                            </span>
                        </td>

                        {{-- Pemilik --}}
                        <td class="px-5 py-4">
                            <p class="text-sm text-gray-700 font-medium">{{ $mobil->nama_rental ?? '—' }}</p>
                            @if($mobil->kota_rental)
                                <p class="text-xs text-gray-400">{{ $mobil->kota_rental }}</p>
                            @endif
                        </td>

                        {{-- Harga --}}
                        <td class="px-5 py-4 font-bold text-gray-800 text-sm whitespace-nowrap">
                            Rp {{ number_format($mobil->harga, 0, ',', '.') }}
                        </td>

                        {{-- Kursi --}}
                        <td class="px-5 py-4 text-center text-sm font-semibold text-gray-700">
                            {{ $mobil->kursi }}
                        </td>

                        {{-- Status --}}
                        <td class="px-5 py-4 text-center">
                            <span class="text-xs font-bold px-3 py-1 rounded-full {{ $badgeClass }}">
                                {{ $badgeText }}
                            </span>
                        </td>

                        {{-- Aksi toggle --}}
                        <td class="px-5 py-4 text-center">
                            <form
                                action="{{ url('/admin/cars/' . $mobil->id . '/toggle') }}"
                                method="POST"
                                onsubmit="return confirm('{{ $mobil->tersedia ? 'Nonaktifkan' : 'Aktifkan' }} mobil ini?')"
                            >
                                @csrf
                                <button type="submit"
                                    class="text-xs font-bold px-3 py-1.5 rounded-lg transition
                                    {{ $mobil->tersedia
                                        ? 'bg-red-50 text-red-500 hover:bg-red-500 hover:text-white'
                                        : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-500 hover:text-white' }}">
                                    {{ $mobil->tersedia ? 'Nonaktifkan' : 'Aktifkan' }}
                                </button>
                            </form>
                        </td>

                    </tr>
                @empty
                    <tr>
                        <td colspan="8" class="px-5 py-16 text-center">
                            <div class="text-5xl mb-3">🚗</div>
                            <p class="text-gray-400 font-semibold">Belum ada mobil terdaftar.</p>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    @if($mobils->hasPages())
        <div class="px-5 py-4 border-t border-gray-100">
            {{ $mobils->links() }}
        </div>
    @endif
</div>


{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- MODAL PREVIEW GAMBAR (sama seperti kyc.blade.php)           --}}
{{-- ═══════════════════════════════════════════════════════════ --}}
<div id="imageModal"
    class="fixed inset-0 bg-black/70 backdrop-blur-sm hidden items-center justify-center z-50 p-4"
    onclick="closeImageModal()">
    <div class="relative max-w-2xl w-full" onclick="event.stopPropagation()">
        <div class="flex justify-between items-center mb-3 px-1">
            <p id="imageModalTitle" class="text-white font-bold text-sm"></p>
            <button onclick="closeImageModal()" class="text-white/70 hover:text-white text-2xl leading-none">&times;</button>
        </div>
        <img id="previewImg"
            class="w-full rounded-2xl shadow-2xl max-h-[80vh] object-contain bg-gray-900">
    </div>
</div>

<script>
    function previewImage(src, title) {
        document.getElementById('imageModal').classList.remove('hidden');
        document.getElementById('imageModal').classList.add('flex');
        document.getElementById('previewImg').src = src;
        document.getElementById('imageModalTitle').textContent = title || '';
    }

    function closeImageModal() {
        document.getElementById('imageModal').classList.add('hidden');
        document.getElementById('imageModal').classList.remove('flex');
    }
</script>

@endsection