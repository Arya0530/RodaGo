<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();

            // Siapa yang pesan (user/penyewa)
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade');

            // Mobil apa yang dipesan
            $table->foreignId('mobil_id')
                  ->constrained('mobils')
                  ->onDelete('cascade');

            // Tanggal mulai & selesai sewa
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');

            // Total harga (dihitung otomatis: harga/hari × jumlah hari)
            $table->integer('total_harga');

            /**
             * STATUS ALUR PESANAN:
             * pending   → Baru dipesan, nunggu owner approve
             * unpaid    → Owner sudah terima, tinggal user bayar
             * active    → Sudah dibayar, sewa sedang berjalan
             * completed → Sewa selesai
             * cancelled → Dibatalkan (oleh user, owner tolak, atau auto-cancel 24 jam)
             */
            $table->enum('status', ['pending', 'unpaid', 'active', 'completed', 'cancelled'])
                  ->default('pending');

            // Siapa yang batalkan (biar kita tau alasannya)
            // 'user', 'owner', 'system' (auto-cancel)
            $table->string('cancelled_by')->nullable();

            // Kapan owner menerima pesanan (untuk hitung deadline 24 jam bayar)
            $table->timestamp('accepted_at')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};