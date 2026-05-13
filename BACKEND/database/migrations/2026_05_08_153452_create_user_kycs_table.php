<?php
// LOKASI: database/migrations/2024_01_01_000001_create_user_kycs_table.php
// CARA BUAT: php artisan make:migration create_user_kycs_table
// CARA JALANKAN: php artisan migrate

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_kycs', function (Blueprint $table) {
            $table->id();

            // Relasi ke tabel users (one-to-one)
            // onDelete cascade = kalau user dihapus, data KYC ikut terhapus
            $table->foreignId('user_id')
                  ->unique()           // Satu user hanya punya 1 data KYC
                  ->constrained('users')
                  ->onDelete('cascade');

            // Path file KTP di storage (contoh: kyc/ktp/abc123.jpg)
            $table->string('ktp_path')->nullable();

            // Path file SIM di storage
            $table->string('sim_path')->nullable();

            // Status verifikasi:
            // - unverified : belum upload sama sekali
            // - pending    : sudah upload, menunggu admin review
            // - verified   : sudah diverifikasi admin, boleh pesan
            // - rejected   : ditolak admin, harus upload ulang
            $table->enum('status', ['unverified', 'pending', 'verified', 'rejected'])
                  ->default('unverified');

            // Catatan dari admin jika ditolak (opsional)
            $table->text('rejection_note')->nullable();

            // Kapan dokumen di-submit user
            $table->timestamp('submitted_at')->nullable();

            // Kapan admin memverifikasi
            $table->timestamp('verified_at')->nullable();

            $table->timestamps(); // created_at & updated_at otomatis
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_kycs');
    }
};