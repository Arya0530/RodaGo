<?php

namespace App\Http\Controllers;

use App\Models\Mobil;
use Illuminate\Http\Request;

class MobilController extends Controller
{
    /*
     * ============================================================
     * DATA MOBIL — disimpan di sini sementara (sebelum ada tabel DB)
     * Nanti kalau sudah ada tabel 'cars' di database, data ini
     * cukup diganti dengan: $mobil = Car::where('slug', $slug)->firstOrFail();
     * ============================================================
     */
    private function getDaftarMobil(): array
    {
        return [
            [
                "slug"        => "toyota-avanza-veloz",
                "nama"        => "Toyota Avanza Veloz",
                "img"         => "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2",
                "harga"       => 400000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "fitur"       => "AC Dual",
                "tipe"        => "MPV",
                "deskripsi"   => "Toyota Avanza Veloz adalah pilihan keluarga yang nyaman dan tangguh. Dengan kapasitas 7 penumpang, transmisi otomatis, dan AC dual zone, perjalanan jauh terasa menyenangkan. Kondisi armada selalu diperiksa sebelum setiap penyewaan.",
            ],
            [
                "slug"        => "honda-brio-rs",
                "nama"        => "Honda Brio RS",
                "img"         => "https://images.unsplash.com/photo-1619682817481-e994891cd1f5",
                "harga"       => 300000,
                "kursi"       => 4,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "fitur"       => "AC",
                "tipe"        => "Economy",
                "deskripsi"   => "Honda Brio RS cocok untuk perjalanan kota dengan desain sporty dan konsumsi bahan bakar yang irit. Mudah dikendarai bahkan di jalanan sempit. Ideal untuk 2–4 penumpang.",
            ],
            [
                "slug"        => "bmw-320i-sport",
                "nama"        => "BMW 320i Sport",
                "img"         => "https://images.unsplash.com/photo-1555215695-3004980ad54e",
                "harga"       => 1500000,
                "kursi"       => 5,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "fitur"       => "Sunroof",
                "tipe"        => "Luxury",
                "deskripsi"   => "BMW 320i Sport menghadirkan pengalaman berkendara mewah dengan teknologi terkini. Dilengkapi sunroof, sistem audio premium, dan suspensi adaptif. Sempurna untuk acara bisnis atau perjalanan premium.",
            ],
            [
                "slug"        => "toyota-innova-reborn",
                "nama"        => "Toyota Innova Reborn",
                "img"         => "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf",
                "harga"       => 600000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Diesel",
                "fitur"       => "AC Dual",
                "tipe"        => "MPV",
                "deskripsi"   => "Toyota Innova Reborn Diesel terkenal dengan torsi besar dan efisiensi bahan bakar luar biasa. Kapasitas 7 kursi membuatnya ideal untuk perjalanan keluarga atau rombongan ke luar kota.",
            ],
            [
                "slug"        => "honda-hrv",
                "nama"        => "Honda HR-V",
                "img"         => "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7",
                "harga"       => 550000,
                "kursi"       => 5,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "fitur"       => "AC",
                "tipe"        => "SUV",
                "deskripsi"   => "Honda HR-V tampil stylish dengan ground clearance tinggi, cocok untuk berbagai medan. Kabin luas dan fitur keselamatan lengkap menjadikannya pilihan populer untuk keluarga muda.",
            ],
            [
                "slug"        => "suzuki-ertiga",
                "nama"        => "Suzuki Ertiga",
                "img"         => "https://images.unsplash.com/photo-1590362891991-f776e747a588",
                "harga"       => 380000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "fitur"       => "AC",
                "tipe"        => "MPV",
                "deskripsi"   => "Suzuki Ertiga adalah MPV hemat yang tidak kalah nyaman. Irit bahan bakar, kabin lapang, dan harga sewa terjangkau membuatnya jadi favorit untuk perjalanan keluarga maupun bisnis.",
            ],
            [
                "slug"        => "pajero-sport",
                "nama"        => "Pajero Sport",
                "img"         => "https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2",
                "harga"       => 1200000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Diesel",
                "fitur"       => "4WD",
                "tipe"        => "SUV",
                "deskripsi"   => "Mitsubishi Pajero Sport adalah SUV sejati dengan teknologi 4WD Super Select. Tangguh di berbagai medan, dari jalanan kota hingga jalan berbatu. Cocok untuk petualangan atau perjalanan off-road.",
            ],
            [
                "slug"        => "toyota-fortuner",
                "nama"        => "Toyota Fortuner",
                "img"         => "https://images.unsplash.com/photo-1606152421802-db97b9c7a11b",
                "harga"       => 1300000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Diesel",
                "fitur"       => "4x4",
                "tipe"        => "SUV",
                "deskripsi"   => "Toyota Fortuner adalah SUV premium yang menggabungkan kemewahan dan ketangguhan. Dengan mesin diesel bertenaga dan tampilan gagah, Fortuner cocok untuk perjalanan VIP maupun medan berat.",
            ],
            [
                "slug"        => "daihatsu-xenia",
                "nama"        => "Daihatsu Xenia",
                "img"         => "https://images.unsplash.com/photo-1626668893632-6f3a4466d22f",
                "harga"       => 350000,
                "kursi"       => 7,
                "transmisi"   => "Manual",
                "bahan_bakar" => "Bensin",
                "fitur"       => "AC",
                "tipe"        => "MPV",
                "deskripsi"   => "Daihatsu Xenia adalah solusi ekonomis untuk keluarga besar. Perawatan mudah, suku cadang terjangkau, dan kabin lega menjadikannya pilihan andalan para penyewa yang mengutamakan efisiensi biaya.",
            ],
            [
                "slug"        => "wuling-almaz",
                "nama"        => "Wuling Almaz",
                "img"         => "https://images.unsplash.com/photo-1503376780353-7e6692767b70",
                "harga"       => 500000,
                "kursi"       => 7,
                "transmisi"   => "Otomatis",
                "bahan_bakar" => "Bensin",
                "fitur"       => "Panoramic",
                "tipe"        => "SUV",
                "deskripsi"   => "Wuling Almaz hadir dengan tampilan modern dan fitur lengkap termasuk panoramic sunroof dan layar sentuh besar. Pilihan SUV stylish dengan harga sewa yang kompetitif.",
            ],
        ];
    }

    /*
     * ============================================================
     * METHOD: show()
     * Dipanggil saat user mengakses URL: /mobil/{slug}
     * Contoh: /mobil/toyota-avanza-veloz
     *
     * Cara kerja:
     *   1. Terima $slug dari URL
     *   2. Cari mobil yang slug-nya cocok dari array
     *   3. Kalau tidak ketemu → abort 404
     *   4. Kirim data ke view detail_mobil
     * ============================================================
     */
    public function show(string $slug)
    {
        // Cari mobil berdasarkan slug dari database Mobil model
        $mobil = Mobil::where('slug', $slug)->firstOrFail();

        // Kirim variabel $mobil ke view resources/views/mobil/detail.blade.php
        return view('mobil.detail', compact('mobil'));
    }
}