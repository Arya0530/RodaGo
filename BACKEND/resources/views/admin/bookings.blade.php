@extends('layouts.admin')
@section('title', 'Monitor Transaksi - Admin RodaGo')
@section('content')
    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Monitor Transaksi (Booking)</h1>
            <p class="text-gray-400 font-medium">Pantau arus penyewaan mobil secara real-time.</p>
        </div>
    </header>

    <div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
        <div class="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
            <h3 class="font-bold text-gray-800">Live Booking Data</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                        <th class="p-5 font-bold border-b border-gray-100">ID Transaksi</th>
                        <th class="p-5 font-bold border-b border-gray-100">Penyewa</th>
                        <th class="p-5 font-bold border-b border-gray-100">Armada</th>
                        <th class="p-5 font-bold border-b border-gray-100">Total Harga</th>
                        <th class="p-5 font-bold border-b border-gray-100">Status</th>
                        <th class="p-5 font-bold border-b border-gray-100 text-center">Emergency</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    <tr class="hover:bg-gray-50 transition border-b border-gray-50">
                        <td class="p-5 font-black text-emerald-500">#TRX-00192</td>
                        <td class="p-5 font-bold text-gray-800">Naufal</td>
                        <td class="p-5 text-gray-500">Toyota Innova Reborn</td>
                        <td class="p-5 font-bold text-gray-800">Rp 1.200.000</td>
                        <td class="p-5"><span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-full text-xs font-bold">Sedang Berjalan</span></td>
                        <td class="p-5 flex justify-center gap-2">
                            <button class="p-2 bg-red-50 text-red-500 hover:bg-red-500 hover:text-white rounded-lg transition font-bold text-xs" title="Hentikan Paksa">Batalkan Sepihak</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
@endsection