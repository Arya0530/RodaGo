@extends('layouts.admin')

@section('title', 'Dashboard - Admin RodaGo')

@section('content')

<header class="flex justify-between items-center mb-10">
    <div>
        <h1 class="text-2xl font-extrabold text-gray-900">Command Center Dashboard</h1>
        <p class="text-gray-400 font-medium">Monitoring sistem RodaGo secara real-time.</p>
    </div>
    <div class="flex items-center gap-3">
        {{-- Indikator live sync --}}
        <div id="sync-indicator" class="flex items-center gap-2 bg-white px-4 py-2 rounded-2xl shadow-sm border border-gray-100">
            <span id="sync-dot" class="w-2 h-2 rounded-full bg-gray-300"></span>
            <span id="sync-text" class="text-xs font-bold text-gray-400">Connecting...</span>
        </div>
        <div class="bg-white px-5 py-2.5 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-3">
            <div class="w-9 h-9 bg-emerald-500 rounded-xl flex items-center justify-center text-white text-sm font-bold shadow-lg shadow-emerald-200">A</div>
            <div>
                <p class="text-xs text-gray-400 font-bold leading-none">ADMINISTRATOR</p>
                <p class="text-sm font-extrabold text-gray-800 leading-tight">Super Admin</p>
            </div>
        </div>
    </div>
</header>

{{-- ============================================================ --}}
{{-- STATS CARDS — semua diisi via AJAX                          --}}
{{-- ============================================================ --}}
<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-10">

    {{-- Card 1: Total User --}}
    <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100 transition-all hover:shadow-md">
        <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Total User</p>
        <h3 id="stat-users" class="text-3xl font-black text-gray-900">
            {{ number_format($totalUsers) }}
        </h3>
        <div class="mt-2 text-emerald-500 text-xs font-bold">Terdaftar di Sistem</div>
    </div>

    {{-- Card 2: Total Rental --}}
    <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100 transition-all hover:shadow-md">
        <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Penyedia Rental</p>
        <h3 id="stat-rentals" class="text-3xl font-black text-gray-900">
            {{ number_format($totalRentals) }}
        </h3>
        <div class="mt-2 text-emerald-500 text-xs font-bold">Mitra Aktif</div>
    </div>

    {{-- Card 3: Live Monitor Mobil — sebelumnya "Syncing..." --}}
    <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100 transition-all hover:shadow-md">
        <div class="flex justify-between items-start">
            <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Live Monitor Mobil</p>
            <span class="w-2 h-2 rounded-full bg-blue-400 animate-pulse mt-1"></span>
        </div>
        <h3 id="stat-live-cars" class="text-3xl font-black text-blue-600">—</h3>
        <div class="mt-2 text-blue-400 text-xs font-bold">Mobil Tersedia</div>
    </div>

    {{-- Card 4: Pending Booking — sebelumnya "Syncing..." --}}
    <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100 transition-all hover:shadow-md">
        <div class="flex justify-between items-start">
            <p class="text-gray-400 text-xs font-bold uppercase tracking-wider mb-2">Pending Booking</p>
            <span class="w-2 h-2 rounded-full bg-yellow-400 animate-pulse mt-1"></span>
        </div>
        <h3 id="stat-pending" class="text-3xl font-black text-yellow-500">—</h3>
        <div class="mt-2 text-yellow-400 text-xs font-bold">Menunggu Konfirmasi Owner</div>
    </div>

</div>

{{-- ============================================================ --}}
{{-- ACTIVITY MONITOR — sebelumnya "Development Phase"           --}}
{{-- ============================================================ --}}
<div class="bg-white rounded-[2.5rem] p-10 shadow-sm border border-gray-100">
    <div class="flex justify-between items-center mb-8">
        <h3 class="text-xl font-black text-gray-800 italic uppercase">Aktivitas Transaksi</h3>
        <div class="flex items-center gap-2">
            <span id="activity-badge" class="bg-emerald-50 text-emerald-600 px-4 py-1 rounded-full text-xs font-bold border border-emerald-100">
                ● Live
            </span>
            <span class="text-gray-300 text-xs" id="last-updated">Memuat...</span>
        </div>
    </div>

    {{-- Loading skeleton saat pertama kali --}}
    <div id="activity-loading" class="space-y-3">
        @for ($i = 0; $i < 5; $i++)
        <div class="animate-pulse flex items-center gap-4 p-4 rounded-2xl bg-gray-50">
            <div class="w-10 h-10 bg-gray-200 rounded-xl"></div>
            <div class="flex-1 space-y-2">
                <div class="h-3 bg-gray-200 rounded w-1/3"></div>
                <div class="h-2 bg-gray-100 rounded w-1/2"></div>
            </div>
            <div class="h-3 bg-gray-100 rounded w-16"></div>
        </div>
        @endfor
    </div>

    {{-- Konten aktivitas diisi AJAX --}}
    <div id="activity-list" class="space-y-3 hidden"></div>

    {{-- State kalau belum ada data --}}
    <div id="activity-empty" class="hidden text-center py-16 border-2 border-dashed border-gray-100 rounded-[2rem] bg-gray-50/50">
        <div class="w-16 h-16 bg-white rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-sm border border-gray-100">
            <span class="text-2xl">📭</span>
        </div>
        <h4 class="text-gray-800 font-bold mb-2">Belum Ada Aktivitas</h4>
        <p class="text-gray-400 text-sm">Transaksi akan muncul di sini secara otomatis.</p>
    </div>
</div>

{{-- ============================================================ --}}
{{-- JAVASCRIPT — AJAX Polling                                    --}}
{{-- ============================================================ --}}
<script>
(function () {
    // ── Helpers ──────────────────────────────────────────────────
    const el = id => document.getElementById(id);

    function animateNumber(element, newValue) {
        const current = parseInt(element.textContent.replace(/\D/g, '')) || 0;
        if (current === newValue) return;
        element.classList.add('transition-all', 'duration-500');
        element.textContent = newValue.toLocaleString('id-ID');
        element.style.transform = 'scale(1.08)';
        setTimeout(() => element.style.transform = 'scale(1)', 300);
    }

    const colorMap = {
        yellow : 'bg-yellow-50 border-yellow-100',
        orange : 'bg-orange-50 border-orange-100',
        blue   : 'bg-blue-50 border-blue-100',
        green  : 'bg-emerald-50 border-emerald-100',
        red    : 'bg-red-50 border-red-100',
        gray   : 'bg-gray-50 border-gray-100',
    };

    function renderActivities(activities) {
        const list  = el('activity-list');
        const empty = el('activity-empty');

        if (!activities || activities.length === 0) {
            list.classList.add('hidden');
            empty.classList.remove('hidden');
            return;
        }

        empty.classList.add('hidden');
        list.classList.remove('hidden');

        list.innerHTML = activities.map(a => {
            const color = colorMap[a.color] || colorMap.gray;
            return `
            <div class="flex items-center gap-4 p-4 rounded-2xl border ${color} transition-all hover:shadow-sm">
                <div class="w-10 h-10 flex items-center justify-center text-xl bg-white rounded-xl shadow-sm border border-white/80 flex-shrink-0">
                    ${a.icon}
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-sm font-bold text-gray-800 leading-tight truncate">${a.label}</p>
                    <p class="text-xs text-gray-400 truncate mt-0.5">
                        <span class="font-semibold text-gray-600">${a.user}</span>
                        &nbsp;·&nbsp; ${a.mobil}
                        &nbsp;·&nbsp; Rp ${a.total}
                    </p>
                </div>
                <div class="text-right flex-shrink-0">
                    <p class="text-xs font-bold text-gray-500">${a.time}</p>
                    <p class="text-[10px] text-gray-300 mt-0.5">#${a.id}</p>
                </div>
            </div>`;
        }).join('');
    }

    // ── Set Sync Indicator ────────────────────────────────────────
    function setSyncStatus(status) {
        const dot  = el('sync-dot');
        const text = el('sync-text');
        if (status === 'live') {
            dot.className  = 'w-2 h-2 rounded-full bg-emerald-400 animate-pulse';
            text.className = 'text-xs font-bold text-emerald-500';
            text.textContent = 'Live';
        } else if (status === 'error') {
            dot.className  = 'w-2 h-2 rounded-full bg-red-400';
            text.className = 'text-xs font-bold text-red-400';
            text.textContent = 'Reconnecting...';
        } else {
            dot.className  = 'w-2 h-2 rounded-full bg-gray-300 animate-pulse';
            text.className = 'text-xs font-bold text-gray-400';
            text.textContent = 'Connecting...';
        }
    }

    // ── Fetch Live Stats (tiap 5 detik) ──────────────────────────
    async function fetchLiveStats() {
        try {
            const res  = await fetch('/admin/api/live-stats');
            const data = await res.json();

            animateNumber(el('stat-users'),    data.total_users);
            animateNumber(el('stat-rentals'),  data.total_rentals);
            animateNumber(el('stat-live-cars'), data.live_cars);
            animateNumber(el('stat-pending'),   data.pending_bookings);

            setSyncStatus('live');
        } catch (e) {
            setSyncStatus('error');
            console.error('Live stats error:', e);
        }
    }

    // ── Fetch Recent Activity (tiap 10 detik) ────────────────────
    async function fetchActivity() {
        try {
            const res  = await fetch('/admin/api/recent-activity');
            const data = await res.json();

            el('activity-loading').classList.add('hidden');
            renderActivities(data.activities);

            const now = new Date().toLocaleTimeString('id-ID');
            el('last-updated').textContent = 'Update: ' + now;
        } catch (e) {
            console.error('Activity error:', e);
        }
    }

    // ── Bootstrap ─────────────────────────────────────────────────
    // Langsung fetch saat halaman terbuka
    fetchLiveStats();
    fetchActivity();

    // Polling interval
    setInterval(fetchLiveStats, 5000);   // tiap 5 detik
    setInterval(fetchActivity,  10000);  // tiap 10 detik

})();
</script>

@endsection