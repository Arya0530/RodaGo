<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Mobil;

class HomeController extends Controller
{
    public function index()
    {
        $mobilList = Mobil::all();
        return view('home', compact('mobilList'));
    }
}
