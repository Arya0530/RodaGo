<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],

    'allowed_methods' => ['*'],

    // Untuk development, pakai '*' agar semua origin boleh akses.
    // Nanti production ganti dengan domain Flutter web kamu.
    'allowed_origins' => ['*'],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    // Set false karena kamu pakai token-based auth (bukan cookie)
    'supports_credentials' => false,
];