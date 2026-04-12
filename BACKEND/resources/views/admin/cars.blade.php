@extends('layouts.admin')
@section('title', 'Monitor Armada - Admin RodaGo')
@section('content')
    <header class="flex justify-between items-center mb-10">
        <div>
            <h1 class="text-2xl font-extrabold text-gray-900">Pusat Kendali Armada</h1>
            <p class="text-gray-400 font-medium">Lacak status dan simulasi koordinat mobil di sistem.</p>
        </div>
    </header>

    <div class="bg-white rounded-[2rem] shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead>
                    <tr class="bg-white text-gray-400 text-xs uppercase tracking-wider">
                        <th class="p-5 font-bold border-b border-gray-100">Plat Nomor</th>
                        <th class="p-5 font-bold border-b border-gray-100">Merek & Model</th>
                        <th class="p-5 font-bold border-b border-gray-100">Milik Rental</th>
                        <th class="p-5 font-bold border-b border-gray-100">Status Fisik</th>
                        <th class="p-5 font-bold border-b border-gray-100 text-center">GPS Tracker</th>
                    </tr>
                </thead>
                <tbody class="text-sm">
                    <tr class="hover:bg-gray-50 transition border-b border-gray-50">
                        <td class="p-5 font-black text-gray-800">L 1234 XX</td>
                        <td class="p-5 font-bold text-gray-800">Honda Brio RS</td>
                        <td class="p-5 text-gray-500">Berkah Jaya Trans</td>
                        <td class="p-5"><span class="bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full text-xs font-bold">Sedang Disewa</span></td>
                        <td class="p-5 flex justify-center gap-2">
                            <button onclick="document.getElementById('modalMap').classList.remove('hidden')" class="p-2 bg-emerald-50 text-emerald-600 hover:bg-emerald-500 hover:text-white rounded-lg transition font-bold text-xs flex items-center gap-1 shadow-sm">
                                <span>📍</span> Lacak Lokasi
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <div id="modalMap" class="hidden fixed inset-0 bg-gray-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl w-full max-w-3xl shadow-2xl overflow-hidden animate-fade-in-up">
            
            <div class="flex justify-between items-center p-6 border-b border-gray-100 bg-gray-50/50">
                <div>
                    <h2 class="text-xl font-black text-gray-900 flex items-center gap-2">
                        <span class="animate-pulse">🔴</span> Live Tracking Simulasi
                    </h2>
                    <p class="text-gray-500 text-sm mt-1">Honda Brio RS (L 1234 XX) - Koordinat Terakhir</p>
                </div>
                <button onclick="document.getElementById('modalMap').classList.add('hidden')" class="text-gray-400 hover:text-red-500 font-bold text-3xl leading-none">&times;</button>
            </div>
            
            <div class="w-full h-[400px] bg-gray-200">
                <iframe 
                    src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3957.6919770732565!2d112.79156707477382!3d-7.275847092731003!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2dd7fa10ea2ae883%3A0xbe22c55d60ef09c7!2sPoliteknik%20Elektronika%20Negeri%20Surabaya%20(PENS)!5e0!3m2!1sid!2sid!4v1712630000000!5m2!1sid!2sid" 
                    width="100%" 
                    height="100%" 
                    style="border:0;" 
                    allowfullscreen="" 
                    loading="lazy" 
                    referrerpolicy="no-referrer-when-downgrade">
                </iframe>
            </div>

            <div class="p-6 bg-yellow-50 border-t border-yellow-100">
                <p class="text-yellow-700 text-sm font-medium flex items-start gap-2">
                    <span>⚠️</span>
                    <span><strong>Status: Tahap Prototipe.</strong> Peta saat ini menggunakan data statis (Dummy Koordinat). Sinkronisasi GPS realtime dengan perangkat keras kendaraan akan dilakukan pada fase pengembangan selanjutnya.</span>
                </p>
            </div>

        </div>
    </div>
@endsection