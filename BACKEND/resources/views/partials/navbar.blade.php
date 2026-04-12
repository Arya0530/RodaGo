<nav class="bg-white border-b border-gray-100 sticky top-0 z-50 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-20 w-full">
            
            <div class="flex-1 flex justify-start items-center gap-3">
                <svg class="w-10 h-10" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="50" cy="50" r="45" stroke="#10b981" stroke-width="10" stroke-linecap="round"/>
                    <circle cx="50" cy="50" r="15" fill="#10b981"/>
                    <path d="M70 50L45 35V65L70 50Z" fill="#ffffff" stroke="#10b981" stroke-width="3" stroke-linejoin="round"/>
                </svg>
                <span class="font-extrabold text-2xl tracking-tight" style="color: #1e293b;">
                    Roda<span style="color: #10b981;">Go</span>
                </span>
            </div>
            
            <div class="hidden md:flex flex-1 justify-center space-x-8">
                <a href="/" class="{{ request()->is('/') ? 'text-emerald-500 border-b-2 border-emerald-500 pb-1 font-bold' : 'text-gray-500 hover:text-emerald-500 font-medium transition' }}">
                    Dashboard
                </a>
                <a href="/features" class="{{ request()->is('features') ? 'text-emerald-500 border-b-2 border-emerald-500 pb-1 font-bold' : 'text-gray-500 hover:text-emerald-500 font-medium transition' }}">
                    Fitur 
                </a>
                <a href="/about" class="{{ request()->is('about') ? 'text-emerald-500 border-b-2 border-emerald-500 pb-1 font-bold' : 'text-gray-500 hover:text-emerald-500 font-medium transition' }}">
                    Tentang Kami
                </a>
                <a href="/contact" class="{{ request()->is('contact') ? 'text-emerald-500 border-b-2 border-emerald-500 pb-1 font-bold' : 'text-gray-500 hover:text-emerald-500 font-medium transition' }}">
                    Kontak
                </a>
            </div>

            <div class="flex-1 flex justify-end">
                <a href="/login" class="inline-flex items-center gap-2 bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-2.5 rounded-full font-bold shadow-lg shadow-emerald-500/30 transition-all hover:-translate-y-0.5 active:translate-y-0">
                     Login
                </a>
            </div>

        </div>
    </div>
</nav>