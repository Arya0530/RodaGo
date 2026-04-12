<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'RodaGo - Sewa Mobil Mudah')</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        appbg: '#ffffff',
                        appcard: '#f8fafc',
                        appteal: '#10b981',
                        apptealhover: '#059669',
                    },
                    fontFamily: {
                        sans: ['Inter', 'ui-sans-serif', 'system-ui', 'sans-serif'],
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-appbg text-gray-800 font-sans min-h-screen flex flex-col selection:bg-appteal selection:text-white">

    @include('partials.navbar')

    <main class="flex-grow w-full pt-8 pb-12 px-4 sm:px-6 lg:px-8 bg-gray-50/30">
        @yield('content')
    </main>

    @include('partials.footer')

</body>
</html> 