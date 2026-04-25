<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AlterBookingsAddColumns extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {

            if (!Schema::hasColumn('bookings', 'cancelled_by')) {
                $table->string('cancelled_by')->nullable()->after('status');
            }

            if (!Schema::hasColumn('bookings', 'cancelled_at')) {
                $table->timestamp('cancelled_at')->nullable();
            }

            if (!Schema::hasColumn('bookings', 'cancel_reason')) {
                $table->text('cancel_reason')->nullable();
            }

        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn([
                'cancelled_by',
                'cancelled_at',
                'cancel_reason'
            ]);
        });
    }
}