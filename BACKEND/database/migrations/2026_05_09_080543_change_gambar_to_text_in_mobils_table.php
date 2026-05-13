<?php
// CARA BUAT FILE INI:
// php artisan make:migration change_gambar_to_text_in_mobils_table
//
// LALU JALANKAN:
// php artisan migrate
//
// KENAPA PERLU?
// Kolom gambar lama bertipe string(255).
// URL storage Laravel bisa lebih panjang dari 255 karakter,
// jadi kita ubah ke TEXT supaya tidak terpotong.
//
// CATATAN: Butuh package doctrine/dbal untuk ->change() di Laravel.
// Jalankan dulu: composer require doctrine/dbal

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mobils', function (Blueprint $table) {
            $table->text('gambar')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('mobils', function (Blueprint $table) {
            $table->string('gambar', 255)->nullable()->change();
        });
    }
};