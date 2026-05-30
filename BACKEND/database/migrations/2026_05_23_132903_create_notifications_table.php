<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// Simpan di: database/migrations/2026_05_01_000001_create_notifications_table.php

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();

            // Penerima notifikasi
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade');

            // Judul singkat, misal: "Pesanan Diterima!"
            $table->string('title');

            // Isi notifikasi
            $table->text('body');

            /**
             * Tipe notifikasi:
             *   booking_accepted  → user: pesanan diterima owner, harus bayar
             *   booking_paid      → owner: user sudah bayar
             *   booking_cancelled → user/owner: pesanan dibatalkan
             */
            $table->string('type');

            // ID booking terkait (opsional, untuk deep-link ke detail)
            $table->unsignedBigInteger('booking_id')->nullable();

            // Sudah dibaca atau belum
            $table->boolean('is_read')->default(false);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};