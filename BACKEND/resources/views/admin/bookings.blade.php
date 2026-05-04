@extends('layouts.admin')
@section('title', 'Monitor Transaksi - Admin RodaGo')
@section('content')

    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Monitor Transaksi (Booking)</h1>
            <p class="text-gray-400 font-medium">Pantau arus penyewaan mobil secara real-time.</p>
        </div>
        {{-- Statistik ringkas --}}
        <div class="flex gap-3">
            <div class="bg-blue-50 border border-blue-100 rounded-xl px-4 py-2 text-center">
                <div class="text-xs text-blue-400 font-semibold">Aktif</div>
                <div class="text-lg font-extrabold text-blue-600">
                    {{ $bookings->where('status', 'active')->count() }}
                </div>
            </div>
            <div class="bg-yellow-50 border border-yellow-100 rounded-xl px-4 py-2 text-center">
                <div class="text-xs text-yellow-400 font-semibold">Pending</div>
                <div class="text-lg font-extrabold text-yellow-600">
                    {{ $bookings->where('status', 'pending')->count() }}
                </div>
            </div>
            <div class="bg-red-50 border border-red-100 rounded-xl px-4 py-2 text-center">
                <div class="text-xs text-red-400 font-semibold">Dibatalkan</div>
                <div class="text-lg font-extrabold text-red-600">
                    {{ $bookings->where('status', 'cancelled')->count() }}
                </div>
            </div>
        </div>
    </header>

    {{-- Flash Message --}}
    @if (session('success'))
        <div class="mb-6 bg-green-50 border border-green-200 text-green-700 px-5 py-3 rounded-xl font-medium flex items-center gap-2">
            <svg class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
            {{ session('success') }}
        </div>
    @endif
    @if (session('error'))
        <div class="mb-6 bg-red-50 border border-red-200 text-red-700 px-5 py-3 rounded-xl font-medium flex items-center gap-2">
            <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M12 4a8 8 0 100 16A8 8 0 0012 4z"/>
            </svg>
            {{ session('error') }}
        </div>
    @endif

    <div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
            <h3 class="font-bold text-gray-800">Live Booking Data</h3>
            <span class="text-xs text-gray-400">Total: {{ $bookings->count() }} transaksi</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                        <th class="p-5 font-bold border-b border-gray-100">ID Transaksi</th>
                        <th class="p-5 font-bold border-b border-gray-100">Penyewa</th>
                        <th class="p-5 font-bold border-b border-gray-100">Armada</th>
                        <th class="p-5 font-bold border-b border-gray-100">Periode Sewa</th>
                        <th class="p-5 font-bold border-b border-gray-100">Total Harga</th>
                        <th class="p-5 font-bold border-b border-gray-100">Status</th>
                        <th class="p-5 font-bold border-b border-gray-100 text-center">Aksi Admin</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    @forelse ($bookings as $booking)
                        <tr class="hover:bg-gray-50 transition border-b border-gray-50">

                            {{-- ID Transaksi --}}
                            <td class="p-5 font-black text-emerald-500">
                                #TRX-{{ str_pad($booking->id, 5, '0', STR_PAD_LEFT) }}
                            </td>

                            {{-- Penyewa --}}
                            <td class="p-5">
                                <div class="font-bold text-gray-800">{{ $booking->user->name ?? '-' }}</div>
                                <div class="text-xs text-gray-400">{{ $booking->user->email ?? '' }}</div>
                            </td>

                            {{-- Armada --}}
                            <td class="p-5 text-gray-500">
                                {{ $booking->mobil->nama ?? '-' }}
                            </td>

                            {{-- Periode --}}
                            <td class="p-5 text-gray-500 text-xs">
                                {{ $booking->tanggal_mulai->format('d M Y') }}
                                <span class="text-gray-300 mx-1">→</span>
                                {{ $booking->tanggal_selesai->format('d M Y') }}
                            </td>

                            {{-- Total Harga --}}
                            <td class="p-5 font-bold text-gray-800">
                                Rp {{ number_format($booking->total_harga, 0, ',', '.') }}
                            </td>

                            {{-- Status Badge --}}
                            <td class="p-5">
                                @if ($booking->status === 'pending')
                                    <span class="bg-yellow-50 text-yellow-600 px-3 py-1 rounded-full text-xs font-bold">
                                        Menunggu Konfirmasi
                                    </span>
                                @elseif ($booking->status === 'unpaid')
                                    <span class="bg-orange-50 text-orange-600 px-3 py-1 rounded-full text-xs font-bold">
                                        Belum Dibayar
                                    </span>
                                @elseif ($booking->status === 'active')
                                    <span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-xs font-bold">
                                        Sedang Berjalan
                                    </span>
                                @elseif ($booking->status === 'completed')
                                    <span class="bg-green-50 text-green-600 px-3 py-1 rounded-full text-xs font-bold">
                                        Selesai
                                    </span>
                                @elseif ($booking->status === 'cancelled')
                                    <span class="bg-red-50 text-red-500 px-3 py-1 rounded-full text-xs font-bold">
                                        Dibatalkan
                                        @if($booking->cancelled_by)
                                            ({{ $booking->cancelled_by }})
                                        @endif
                                    </span>
                                @endif
                            </td>

                            {{-- Aksi --}}
                            <td class="p-5 text-center">
                                @if ($booking->canForceCancelled())
                                    {{-- Tombol trigger modal --}}
                                    <button
                                        onclick="openCancelModal({{ $booking->id }}, '{{ addslashes($booking->user->name ?? 'User') }}', '{{ addslashes($booking->mobil->nama ?? 'Kendaraan') }}')"
                                        class="p-2 px-3 bg-red-50 text-red-500 hover:bg-red-500 hover:text-white rounded-lg transition font-bold text-xs border border-red-100"
                                        title="Force Cancel oleh Admin">
                                        🚫 Batalkan Paksa
                                    </button>
                                @else
                                    <span class="text-gray-300 text-xs font-medium italic">
                                        @if($booking->status === 'completed') Selesai @else Sudah Batal @endif
                                    </span>
                                @endif
                            </td>

                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="p-10 text-center text-gray-400 font-medium">
                                Tidak ada data booking ditemukan.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    {{-- ====================== --}}
    {{-- MODAL KONFIRMASI CANCEL --}}
    {{-- ====================== --}}
    <div id="cancelModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md p-8 relative">
            {{-- Icon warning --}}
            <div class="flex justify-center mb-4">
                <div class="bg-red-100 rounded-full p-4">
                    <svg class="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
                    </svg>
                </div>
            </div>

            <h2 class="text-xl font-extrabold text-gray-900 text-center mb-1">Batalkan Transaksi?</h2>
            <p class="text-gray-400 text-center text-sm mb-6" id="modalDesc">
                Tindakan ini tidak bisa dibatalkan.
            </p>

            <form id="cancelForm" method="POST">
                @csrf
                @method('POST')

                <div class="mb-4">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        Alasan Pembatalan <span class="text-gray-400 font-normal">(opsional)</span>
                    </label>
                    <input
                        type="text"
                        name="cancel_reason"
                        placeholder="Contoh: Penipuan, kendaraan bermasalah..."
                        class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 focus:border-red-400 transition"
                    />
                </div>

                <div class="flex gap-3 mt-6">
                    <button
                        type="button"
                        onclick="closeCancelModal()"
                        class="flex-1 border border-gray-200 text-gray-600 hover:bg-gray-50 font-bold py-3 rounded-xl transition text-sm">
                        Batal
                    </button>
                    <button
                        type="submit"
                        class="flex-1 bg-red-500 hover:bg-red-600 text-white font-bold py-3 rounded-xl transition text-sm">
                        Ya, Batalkan Sekarang
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openCancelModal(bookingId, userName, mobilName) {
            document.getElementById('cancelModal').classList.remove('hidden');
            document.getElementById('cancelModal').classList.add('flex');
            document.getElementById('modalDesc').textContent =
                `Anda akan membatalkan paksa booking #${String(bookingId).padStart(5, '0')} atas nama ${userName} (${mobilName}).`;
            document.getElementById('cancelForm').action = `/admin/bookings/${bookingId}/force-cancel`;
        }

        function closeCancelModal() {
            document.getElementById('cancelModal').classList.add('hidden');
            document.getElementById('cancelModal').classList.remove('flex');
        }

        // Tutup modal kalau klik di luar
        document.getElementById('cancelModal').addEventListener('click', function (e) {
            if (e.target === this) closeCancelModal();
        });
    </script>

@endsection