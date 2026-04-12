@extends('layouts.app')

@section('title', 'Login Admin - RodaGo')

@section('content')
<div class="min-h-[70vh] flex items-center justify-center">
    <div class="bg-white p-10 rounded-[2.5rem] shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-gray-50 w-full max-w-md animate-fade-in-up">
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-emerald-50 rounded-2xl mb-4">
                <svg class="w-8 h-8 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
            </div>
            <h2 class="text-3xl font-extrabold text-gray-900">Admin Login</h2>
            <p class="text-gray-500 mt-2 text-sm">Gunakan akun otoritas RodaGo Anda</p>
        </div>

        <form action="/login" method="POST" class="space-y-6">
            @csrf
            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">Email Address</label>
                <input type="email" name="email" value="{{ old('email') }}" required class="w-full px-5 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-emerald-500 focus:bg-white outline-none transition-all" placeholder="admin@rodago.id">
                @error('email') <span class="text-red-500 text-xs mt-2 block">{{ $message }}</span> @enderror
            </div>

            <div>
                <label class="block text-sm font-bold text-gray-700 mb-2">Password</label>
                <input type="password" name="password" required class="w-full px-5 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-emerald-500 focus:bg-white outline-none transition-all" placeholder="••••••••">
            </div>

            <button type="submit" class="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-4 rounded-2xl shadow-lg shadow-emerald-500/30 transition-all transform hover:-translate-y-1 active:scale-[0.98]">
                Masuk ke Command Center
            </button>
        </form>
    </div>
</div>
@endsection