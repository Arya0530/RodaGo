<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\City;
use App\Models\Rental;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. BIKIN USER DUMMY
        $admin = User::create([
            'name' => 'Super Admin',
            'email' => 'admin@rodago.id',
            'phone' => '08123456789',
            'password' => bcrypt('password'),
            'role' => 'admin'
            
        ]);

        $owner1 = User::create([
            'name' => 'Budi Sudarsono',
            'email' => 'budi@gmail.com',
            'phone' => '08123456789',
            'password' => bcrypt('password'),
            'role' => 'owner'
        ]);

        $owner2 = User::create([
            'name' => 'Arya Nugraha',
            'email' => 'arya@gmail.com',
            'phone' => '08123456789',
            'password' => bcrypt('password'),
            'role' => 'owner'
        ]);

        User::create([
            'name' => 'Naufal Penyewa',
            'email' => 'naufal@gmail.com',
            'phone' => '08123456789',
            'password' => bcrypt('password'),
            'role' => 'user'
        ]);

        // 2. BIKIN KOTA DUMMY
        City::create(['name' => 'Surabaya', 'province' => 'Jawa Timur']);
        City::create(['name' => 'Jakarta Selatan', 'province' => 'DKI Jakarta']);
        City::create(['name' => 'Bandung', 'province' => 'Jawa Barat']);
        City::create(['name' => 'Malang', 'province' => 'Jawa Timur']);

        // 3. BIKIN RENTAL DUMMY
        Rental::create([
            'user_id' => $owner1->id,
            'brand_name' => 'Berkah Jaya Trans',
            'city' => 'Surabaya'
        ]);

        Rental::create([
            'user_id' => $owner2->id,
            'brand_name' => 'Auto Sultan Rent',
            'city' => 'Jakarta Selatan'
        ]);

        // 4. BIKIN MOBIL DUMMY
        $this->call(MobilSeeder::class);
    }
}