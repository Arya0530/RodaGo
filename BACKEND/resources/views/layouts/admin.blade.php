<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin Command Center - RodaGo')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style> body { font-family: 'Inter', sans-serif; } </style>
</head>
<body class="bg-gray-50 flex min-h-screen">

    <!-- SIDEBAR (CUKUP DITULIS SEKALI DI SINI) -->
    <aside class="w-72 bg-white border-r border-gray-100 flex flex-col p-6 sticky top-0 h-screen">
        <div class="flex items-center gap-3 mb-10 px-2">
            <svg class="w-8 h-8" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="50" cy="50" r="45" stroke="#10b981" stroke-width="10"/>
                <circle cx="50" cy="50" r="15" fill="#10b981"/>
            </svg>
            <span class="text-xl font-black text-gray-800 tracking-tight">Roda<span class="text-emerald-500">Go</span></span>
        </div>

        <nav class="flex-grow space-y-1">
            <a href="/admin/dashboard" class="flex items-center gap-4 p-4 rounded-2xl font-bold transition {{ request()->is('admin/dashboard') ? 'bg-emerald-50 text-emerald-600' : 'text-gray-500 hover:text-emerald-500 hover:bg-gray-50' }}">
                <span>📊</span> Dashboard
            </a>
            <a href="/admin/rentals" class="flex items-center gap-4 p-4 rounded-2xl font-semibold transition {{ request()->is('admin/rentals') ? 'bg-emerald-50 text-emerald-600' : 'text-gray-500 hover:text-emerald-500 hover:bg-gray-50' }}">
                <span>🏢</span> Penyedia Rental
            </a>
            <a href="/admin/users" class="flex items-center gap-4 p-4 rounded-2xl font-semibold transition {{ request()->is('admin/users') ? 'bg-emerald-50 text-emerald-600' : 'text-gray-500 hover:text-emerald-500 hover:bg-gray-50' }}">
                <span>👥</span> Kelola User
            </a>
            <a href="/admin/cars" class="flex items-center gap-4 p-4 rounded-2xl font-semibold transition {{ request()->is('admin/cars') ? 'bg-emerald-50 text-emerald-600' : 'text-gray-500 hover:text-emerald-500 hover:bg-gray-50' }}">
                <span>🚓</span> Monitor Mobil
            </a>
            <a href="/admin/bookings" class="flex items-center gap-4 p-4 rounded-2xl font-semibold transition {{ request()->is('admin/bookings') ? 'bg-emerald-50 text-emerald-600' : 'text-gray-500 hover:text-emerald-500 hover:bg-gray-50' }}">
                <span>📋</span> Monitor Booking
            </a>
            <a href="/admin/cities" class="flex items-center gap-4 p-4 rounded-2xl font-semibold transition {{ request()->is('admin/cities') ? 'bg-emerald-50 text-emerald-600' : 'text-gray-500 hover:text-emerald-500 hover:bg-gray-50' }}">
                <span>📍</span> Kelola Kota
            </a>
        </nav>

        <form action="{{ route('logout') }}" method="POST" class="mt-auto border-t border-gray-100 pt-4">
            @csrf
            <button type="submit" class="w-full flex items-center gap-4 p-4 text-gray-400 hover:text-red-500 font-bold transition">
                <span>🚪</span> Keluar Sistem
            </button>
        </form>
    </aside>

    <!-- AREA UNTUK ISI KONTEN DI TENGAH LAYAR -->
    <main class="flex-grow p-10 overflow-y-auto">
        @yield('content')
    </main>

</body>
</html>