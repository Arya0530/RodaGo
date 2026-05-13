{{-- LOKASI: resources/views/admin/kyc.blade.php --}}

@extends('layouts.admin')
@section('title', 'Verifikasi KYC - Admin RodaGo')

@section('content')

{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- HEADER                                                       --}}
{{-- ═══════════════════════════════════════════════════════════ --}}
<header class="flex justify-between items-center mb-10">
    <div>
        <h1 class="text-2xl font-extrabold text-gray-900">Verifikasi Identitas (KYC)</h1>
        <p class="text-gray-400 font-medium">Periksa KTP & SIM pengguna lalu setujui atau tolak.</p>
    </div>

    {{-- Statistik ringkas --}}
    <div class="flex gap-3">
        <div class="bg-yellow-50 border border-yellow-100 rounded-xl px-4 py-2 text-center">
            <div class="text-xs text-yellow-500 font-semibold">Pending</div>
            <div class="text-lg font-extrabold text-yellow-600">{{ $totalPending }}</div>
        </div>
        <div class="bg-green-50 border border-green-100 rounded-xl px-4 py-2 text-center">
            <div class="text-xs text-green-500 font-semibold">Verified</div>
            <div class="text-lg font-extrabold text-green-600">{{ $totalVerified }}</div>
        </div>
        <div class="bg-red-50 border border-red-100 rounded-xl px-4 py-2 text-center">
            <div class="text-xs text-red-400 font-semibold">Rejected</div>
            <div class="text-lg font-extrabold text-red-500">{{ $totalRejected }}</div>
        </div>
    </div>
</header>

{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- FLASH MESSAGE                                                --}}
{{-- ═══════════════════════════════════════════════════════════ --}}
@if(session('success'))
    <div class="mb-6 bg-green-50 border border-green-200 text-green-700 px-5 py-3 rounded-xl font-medium flex items-center gap-2">
        <svg class="w-5 h-5 text-green-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
        </svg>
        {{ session('success') }}
    </div>
@endif

{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- TABEL DATA KYC                                               --}}
{{-- ═══════════════════════════════════════════════════════════ --}}
<div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">

    <div class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
        <h3 class="font-bold text-gray-800">Data Pengajuan KYC</h3>
        <span class="text-xs text-gray-400">Total: {{ $kycs->count() }} pengajuan</span>
    </div>

    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">

            <thead>
                <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                    <th class="p-5 font-bold border-b border-gray-100">Pengguna</th>
                    <th class="p-5 font-bold border-b border-gray-100">Foto KTP</th>
                    <th class="p-5 font-bold border-b border-gray-100">Foto SIM</th>
                    <th class="p-5 font-bold border-b border-gray-100">Dikirim</th>
                    <th class="p-5 font-bold border-b border-gray-100">Status</th>
                    <th class="p-5 font-bold border-b border-gray-100 text-center">Aksi Admin</th>
                </tr>
            </thead>

            <tbody class="text-sm">
                @forelse($kycs as $kyc)
                <tr class="hover:bg-gray-50 transition border-b border-gray-50">

                    {{-- PENGGUNA --}}
                    <td class="p-5">
                        <div class="font-bold text-gray-800">{{ $kyc->user->name ?? '—' }}</div>
                        <div class="text-xs text-gray-400">{{ $kyc->user->email ?? '' }}</div>
                    </td>

                    {{-- FOTO KTP --}}
                    <td class="p-5">
                        @if($kyc->ktp_path)
                            <img
                                src="{{ url(Storage::url($kyc->ktp_path)) }}"
                                onclick="previewImage('{{ url(Storage::url($kyc->ktp_path)) }}', 'KTP — {{ $kyc->user->name ?? '' }}')"
                                class="w-28 h-20 object-cover rounded-xl cursor-pointer hover:scale-105 transition shadow border border-gray-100"
                                alt="KTP {{ $kyc->user->name ?? '' }}"
                            >
                        @else
                            <span class="text-red-400 text-xs font-semibold">Belum Upload</span>
                        @endif
                    </td>

                    {{-- FOTO SIM --}}
                    <td class="p-5">
                        @if($kyc->sim_path)
                            <img
                                src="{{ url(Storage::url($kyc->sim_path)) }}"
                                onclick="previewImage('{{ url(Storage::url($kyc->sim_path)) }}', 'SIM — {{ $kyc->user->name ?? '' }}')"
                                class="w-28 h-20 object-cover rounded-xl cursor-pointer hover:scale-105 transition shadow border border-gray-100"
                                alt="SIM {{ $kyc->user->name ?? '' }}"
                            >
                        @else
                            <span class="text-red-400 text-xs font-semibold">Belum Upload</span>
                        @endif
                    </td>

                    {{-- TANGGAL SUBMIT --}}
                    <td class="p-5 text-gray-500 text-xs">
                        @if($kyc->submitted_at)
                            {{ $kyc->submitted_at->format('d M Y') }}<br>
                            <span class="text-gray-300">{{ $kyc->submitted_at->format('H:i') }}</span>
                        @else
                            —
                        @endif
                    </td>

                    {{-- STATUS BADGE --}}
                    <td class="p-5">
                        @if($kyc->status === 'verified')
                            <span class="bg-green-50 text-green-600 px-3 py-1 rounded-full text-xs font-bold">
                                ✔ Verified
                            </span>
                            @if($kyc->verified_at)
                                <div class="text-[10px] text-gray-300 mt-1">{{ $kyc->verified_at->format('d M Y H:i') }}</div>
                            @endif

                        @elseif($kyc->status === 'rejected')
                            <span class="bg-red-50 text-red-500 px-3 py-1 rounded-full text-xs font-bold">
                                ✖ Rejected
                            </span>
                            @if($kyc->rejection_note)
                                <div class="text-[10px] text-red-400 mt-1 max-w-[140px]">{{ $kyc->rejection_note }}</div>
                            @endif

                        @else
                            <span class="bg-yellow-50 text-yellow-600 px-3 py-1 rounded-full text-xs font-bold">
                                ⏳ Pending
                            </span>
                        @endif
                    </td>

                    {{-- AKSI --}}
                    <td class="p-5 text-center">
                        @if($kyc->status === 'pending')
                            <div class="flex justify-center gap-2">
                                {{-- Tombol Approve --}}
                                <form method="POST" action="{{ route('admin.kyc.approve', $kyc->id) }}"
                                    onsubmit="return confirm('Setujui KYC milik {{ addslashes($kyc->user->name ?? 'user') }}?')">
                                    @csrf
                                    <button type="submit"
                                        class="bg-green-50 text-green-600 hover:bg-green-500 hover:text-white px-3 py-2 rounded-lg text-xs font-bold transition border border-green-100">
                                        ✔ Approve
                                    </button>
                                </form>

                                {{-- Tombol Reject — buka modal --}}
                                <button type="button"
                                    onclick="openRejectModal({{ $kyc->id }}, '{{ addslashes($kyc->user->name ?? '') }}')"
                                    class="bg-red-50 text-red-500 hover:bg-red-500 hover:text-white px-3 py-2 rounded-lg text-xs font-bold transition border border-red-100">
                                    ✖ Reject
                                </button>
                            </div>

                        @elseif($kyc->status === 'verified')
                            {{-- Tombol Cabut (kembalikan ke pending) jika diperlukan --}}
                            <span class="text-gray-300 text-xs italic">Sudah disetujui</span>

                        @else
                            {{-- Rejected → bisa approve ulang setelah user kirim ulang --}}
                            <form method="POST" action="{{ route('admin.kyc.approve', $kyc->id) }}"
                                onsubmit="return confirm('Setujui KYC ini?')">
                                @csrf
                                <button type="submit"
                                    class="bg-green-50 text-green-600 hover:bg-green-500 hover:text-white px-3 py-2 rounded-lg text-xs font-bold transition border border-green-100">
                                    ✔ Approve Ulang
                                </button>
                            </form>
                        @endif
                    </td>

                </tr>
                @empty
                <tr>
                    <td colspan="6" class="p-12 text-center text-gray-400">
                        <div class="text-4xl mb-3">🪪</div>
                        <div class="font-bold text-gray-600">Belum ada pengajuan KYC</div>
                        <div class="text-xs mt-1">Pengajuan dari pengguna akan muncul di sini.</div>
                    </td>
                </tr>
                @endforelse
            </tbody>

        </table>
    </div>
</div>


{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- MODAL PREVIEW GAMBAR                                         --}}
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


{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- MODAL REJECT + ALASAN                                        --}}
{{-- ═══════════════════════════════════════════════════════════ --}}
<div id="rejectModal"
    class="fixed inset-0 bg-black/50 backdrop-blur-sm hidden items-center justify-center z-50 p-4">
    <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md p-8 relative">

        {{-- Icon --}}
        <div class="flex justify-center mb-4">
            <div class="bg-red-100 rounded-full p-4">
                <svg class="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                </svg>
            </div>
        </div>

        <h2 class="text-xl font-extrabold text-gray-900 text-center mb-1">Tolak KYC?</h2>
        <p class="text-gray-400 text-center text-sm mb-6" id="rejectModalDesc">
            Berikan alasan agar pengguna tahu apa yang perlu diperbaiki.
        </p>

        <form id="rejectForm" method="POST">
            @csrf

            <div class="mb-4">
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                    Alasan Penolakan
                    <span class="text-gray-400 font-normal">(wajib diisi agar user tahu)</span>
                </label>
                <textarea
                    name="rejection_note"
                    rows="3"
                    placeholder="Contoh: Foto KTP buram, wajah tidak terlihat jelas. Mohon upload ulang dengan pencahayaan yang lebih baik."
                    class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 focus:border-red-400 transition resize-none"
                ></textarea>
            </div>

            <div class="flex gap-3 mt-6">
                <button type="button" onclick="closeRejectModal()"
                    class="flex-1 border border-gray-200 text-gray-600 hover:bg-gray-50 font-bold py-3 rounded-xl transition text-sm">
                    Batal
                </button>
                <button type="submit"
                    class="flex-1 bg-red-500 hover:bg-red-600 text-white font-bold py-3 rounded-xl transition text-sm">
                    Ya, Tolak
                </button>
            </div>
        </form>
    </div>
</div>


{{-- ═══════════════════════════════════════════════════════════ --}}
{{-- JAVASCRIPT                                                    --}}
{{-- ═══════════════════════════════════════════════════════════ --}}
<script>
    // ── Preview gambar ────────────────────────────────────────────
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

    // ── Modal reject ──────────────────────────────────────────────
    function openRejectModal(kycId, userName) {
        document.getElementById('rejectModal').classList.remove('hidden');
        document.getElementById('rejectModal').classList.add('flex');
        document.getElementById('rejectModalDesc').textContent =
            'Berikan alasan penolakan untuk ' + userName + ' agar mereka tahu apa yang perlu diperbaiki.';
        document.getElementById('rejectForm').action = '/admin/kyc/' + kycId + '/reject';
    }

    function closeRejectModal() {
        document.getElementById('rejectModal').classList.add('hidden');
        document.getElementById('rejectModal').classList.remove('flex');
    }

    // Klik di luar modal reject → tutup
    document.getElementById('rejectModal').addEventListener('click', function(e) {
        if (e.target === this) closeRejectModal();
    });
</script>

@endsection