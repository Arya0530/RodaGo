<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Mobil;

class MobilSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $mobilList = [
            [
                "slug"        => "toyota-avanza-veloz",
                "nama"        => "Toyota Avanza Veloz",
                "harga"       => 400000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "tipe"        => "MPV",
                "deskripsi"   => "Toyota Avanza Veloz adalah pilihan keluarga yang nyaman dan tangguh. Dengan kapasitas 7 penumpang, transmisi otomatis, dan AC dual zone, perjalanan jauh terasa menyenangkan. Kondisi armada selalu diperiksa sebelum setiap penyewaan.",
                "gambar"      => "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2",
                "tersedia"    => 1,
            ],
            [
                "slug"        => "honda-brio-rs",
                "nama"        => "Honda Brio RS",
                "harga"       => 300000,
                "kursi"       => 4,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "tipe"        => "Economy",
                "deskripsi"   => "Honda Brio RS cocok untuk perjalanan kota dengan desain sporty dan konsumsi bahan bakar yang irit. Mudah dikendarai bahkan di jalanan sempit. Ideal untuk 2–4 penumpang.",
                "gambar"      => "https://images.unsplash.com/photo-1619682817481-e994891cd1f5",
                "tersedia"    => 1,
            ],
            [
                "slug"        => "bmw-320i-sport",
                "nama"        => "BMW 320i Sport",
                "harga"       => 1500000,
                "kursi"       => 5,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "tipe"        => "Luxury",
                "deskripsi"   => "BMW 320i Sport menghadirkan pengalaman berkendara mewah dengan teknologi terkini. Dilengkapi sunroof, sistem audio premium, dan suspensi adaptif. Sempurna untuk acara bisnis atau perjalanan premium.",
                "gambar"      => "https://images.unsplash.com/photo-1555215695-3004980ad54e",
                "tersedia"    => 1,
            ],
            [
                "slug"        => "toyota-innova-reborn",
                "nama"        => "Toyota Innova Reborn",
                "harga"       => 600000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Diesel",
                "tipe"        => "MPV",
                "deskripsi"   => "Toyota Innova Reborn menawarkan kenyamanan maksimal untuk perjalanan jauh. Dengan mesin diesel efisien, kapasitas 7 penumpang, dan fitur keselamatan lengkap, cocok untuk keluarga besar atau rombongan.",
                "gambar"      => "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf",
                "tersedia"    => 1,
            ],
        ];

        foreach ($mobilList as $mobil) {
            Mobil::create($mobil);
        }
    }
}
