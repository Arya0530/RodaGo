<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up()
{
    Schema::create('mobils', function (Blueprint $table) {
        $table->id();
        $table->string('nama');
        $table->string('slug')->unique();
        $table->string('tipe'); // Economy, MPV, SUV, Luxury
        $table->integer('harga'); // per hari
        $table->integer('kursi');
        $table->string('transmisi');
        $table->string('bahan_bakar');
        $table->text('deskripsi')->nullable();
        $table->string('gambar')->nullable(); // URL gambar
        $table->boolean('tersedia')->default(true);
        $table->timestamps();
    });
}
};
