@extends('layouts.app')

@section('title', 'Kontak Kami - RodaGo')

@section('content')
<div class="max-w-6xl mx-auto animate-fade-in-up">
    
    <div class="text-center mb-16 mt-8">
        <h1 class="text-4xl md:text-5xl font-extrabold text-gray-900 mb-4 tracking-tight">Hubungi <span class="text-appteal">Tim Kami</span></h1>
        <p class="text-lg text-gray-500 max-w-xl mx-auto">Punya pertanyaan soal layanan sewa lepas kunci atau butuh bantuan darurat di jalan? Kami siap membantu 24/7.</p>
    </div>

    <div class="bg-white rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] overflow-hidden">
        <div class="grid grid-cols-1 lg:grid-cols-5">
            
            <div class="lg:col-span-2 bg-appteal text-white p-10 md:p-12 flex flex-col justify-between relative overflow-hidden">
                <div class="absolute -bottom-24 -right-24 w-64 h-64 bg-white opacity-10 rounded-full blur-2xl"></div>
                
                <div class="relative z-10">
                    <h3 class="text-3xl font-extrabold mb-8">Informasi Kontak</h3>
                    
                    <div class="space-y-6">
                        <div class="flex items-start gap-4">
                            <span class="text-2xl mt-1">📍</span>
                            <div>
                                <p class="font-bold text-lg">Kantor Pusat RodaGo</p>    
                                <p class="text-emerald-50">Jl.Veteran - Lamongan No. 123<br>Jawa Timur, Indonesia</p>
                            </div>
                        </div>
                        <div class="flex items-start gap-4">
                            <span class="text-2xl mt-1">📞</span>
                            <div>
                                <p class="font-bold text-lg">Layanan Pelanggan</p>
                                <p class="text-emerald-50">+62 812 3456 7890 (WA Available)</p>
                            </div>
                        </div>
                        <div class="flex items-start gap-4">
                            <span class="text-2xl mt-1">✉️</span>
                            <div>
                                <p class="font-bold text-lg">Email Resmi</p>
                                <p class="text-emerald-50">hello@rodago.id</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="lg:col-span-3 p-10 md:p-12">
                <h3 class="text-2xl font-extrabold text-gray-900 mb-8">Kirim Pesan Langsung</h3>
                
                <form class="space-y-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Nama Lengkap</label>
                            <input type="text" placeholder="Cth: Budi Santoso" class="w-full bg-gray-50 border border-gray-200 text-gray-900 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-appteal focus:border-transparent transition">
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Nomor Telepon / WA</label>
                            <input type="tel" placeholder="0812..." class="w-full bg-gray-50 border border-gray-200 text-gray-900 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-appteal focus:border-transparent transition">
                        </div>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2">Pesan atau Pertanyaan</label>
                        <textarea rows="4" placeholder="Tuliskan detail pertanyaan Anda di sini..." class="w-full bg-gray-50 border border-gray-200 text-gray-900 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-appteal focus:border-transparent transition"></textarea>
                    </div>
                    
                    <button type="button" class="bg-gray-900 hover:bg-gray-800 text-white font-bold px-8 py-3.5 rounded-xl transition shadow-md w-full md:w-auto">
                        Kirim Pesan Sekarang
                    </button>
                </form>
            </div>
            
        </div>
    </div>
</div>

<style>
    @keyframes fade-in-up { 0% { opacity: 0; transform: translateY(20px); } 100% { opacity: 1; transform: translateY(0); } }
    .animate-fade-in-up { animation: fade-in-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
</style>
@endsection