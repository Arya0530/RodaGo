<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// LOKASI FILE: database/migrations/2026_04_28_000001_add_city_id_to_mobils_table.php
// Jalankan: php artisan migrate

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mobils', function (Blueprint $table) {
            // Tambah kolom city_id setelah kolom 'id'
            // nullable() supaya data mobil lama tidak error
            $table->foreignId('city_id')
                  ->nullable()
                  ->after('id')
                  ->constrained('cities')
                  ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('mobils', function (Blueprint $table) {
            $table->dropForeign(['city_id']);
            $table->dropColumn('city_id');
        });
    }
};