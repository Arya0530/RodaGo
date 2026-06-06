<?php
// LOKASI: database/seeders/MobilSeeder.php
//
// FIX: Tambah user_id → seeder sekarang attach ke owner pertama
// yang ada di tabel users dengan role 'owner'.
// Jika belum ada owner, seeder buat dulu satu user owner dummy.

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Mobil;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class MobilSeeder extends Seeder
{
    public function run(): void
    {
        // Cari owner yang sudah ada, atau buat baru kalau belum ada
        $owner = User::where('role', 'owner')->first();

        if (!$owner) {
            $owner = User::create([
                'name'     => 'Demo Rental',
                'email'    => 'owner@demo.com',
                'password' => Hash::make('password'),
                'role'     => 'owner',
                'phone'    => '08123456789',
            ]);
        }

        $mobilList = [
            [
                'user_id'     => $owner->id,
                'slug'        => 'toyota-avanza-veloz',
                'nama'        => 'Toyota Avanza Veloz',
                'harga'       => 400000,
                'kursi'       => 7,
                'transmisi'   => 'Otomatis',
                'bahan_bakar' => 'Bensin',
                'tipe'        => 'MPV',
                'deskripsi'   => 'Toyota Avanza Veloz adalah pilihan keluarga yang nyaman dan tangguh. Dengan kapasitas 7 penumpang, transmisi otomatis, dan AC dual zone, perjalanan jauh terasa menyenangkan.',
                // URL Unsplash disimpan apa adanya — MobilController & home.blade
                // sudah bisa handle URL eksternal ini dengan benar
                'gambar'      => 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2',
                'tersedia'    => true,
            ],
            [
                'user_id'     => $owner->id,
                'slug'        => 'honda-brio-rs',
                'nama'        => 'Honda Brio RS',
                'harga'       => 300000,
                'kursi'       => 4,
                'transmisi'   => 'Otomatis',
                'bahan_bakar' => 'Bensin',
                'tipe'        => 'Economy',
                'deskripsi'   => 'Honda Brio RS cocok untuk perjalanan kota dengan desain sporty dan konsumsi bahan bakar yang irit. Mudah dikendarai bahkan di jalanan sempit.',
                'gambar'      => 'https://images.unsplash.com/photo-1619682817481-e994891cd1f5',
                'tersedia'    => true,
            ],
            [
                'user_id'     => $owner->id,
                'slug'        => 'bmw-320i-sport',
                'nama'        => 'BMW 320i Sport',
                'harga'       => 1500000,
                'kursi'       => 5,
                'transmisi'   => 'Otomatis',
                'bahan_bakar' => 'Bensin',
                'tipe'        => 'Luxury',
                'deskripsi'   => 'BMW 320i Sport menghadirkan pengalaman berkendara mewah dengan teknologi terkini. Dilengkapi sunroof, sistem audio premium, dan suspensi adaptif.',
                'gambar'      => 'https://images.unsplash.com/photo-1555215695-3004980ad54e',
                'tersedia'    => true,
            ],
            [
                'user_id'     => $owner->id,
                'slug'        => 'toyota-innova-reborn',
                'nama'        => 'Toyota Innova Reborn',
                'harga'       => 600000,
                'kursi'       => 7,
                'transmisi'   => 'Otomatis',
                'bahan_bakar' => 'Diesel',
                'tipe'        => 'MPV',
                'deskripsi'   => 'Toyota Innova Reborn menawarkan kenyamanan maksimal untuk perjalanan jauh. Mesin diesel efisien, kapasitas 7 penumpang, dan fitur keselamatan lengkap.',
                'gambar'      => 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf',
                'tersedia'    => true,
            ],
        ];

        foreach ($mobilList as $data) {
            // updateOrCreate berdasarkan slug agar aman dijalankan ulang
            Mobil::updateOrCreate(
                ['slug' => $data['slug']],
                $data
            );
        }
    }
}