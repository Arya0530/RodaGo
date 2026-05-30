// LOKASI: lib/pages/notifikasi/notifikasi_page.dart
// Halaman daftar notifikasi.
// Dipanggil dari ikon lonceng di AppBar MainLayout dan OwnerMainLayout.

import 'package:flutter/material.dart';
import '../../service/api_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<dynamic> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ApiService.getNotifications();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _notifs  = result['success'] == true ? (result['data'] as List) : [];
    });
  }

  Future<void> _bacaSemua() async {
    await ApiService.markAllNotificationsRead();
    // Update semua item lokal supaya UI langsung berubah tanpa reload
    setState(() {
      _notifs = _notifs.map((n) => {...n as Map, 'is_read': true}).toList();
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking_accepted': return Icons.check_circle_outline;
      case 'booking_paid':     return Icons.payments_outlined;
      case 'booking_cancelled': return Icons.cancel_outlined;
      default:                 return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'booking_accepted': return Colors.teal;
      case 'booking_paid':     return Colors.green;
      case 'booking_cancelled': return Colors.red;
      default:                 return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifs.where((n) => n['is_read'] == false).length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _bacaSemua,
              child: const Text('Baca Semua', style: TextStyle(color: Colors.teal, fontSize: 13)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _notifs.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: Colors.teal,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                    itemBuilder: (context, i) {
                      final n       = _notifs[i] as Map;
                      final isRead  = n['is_read'] == true;
                      final type    = n['type']?.toString() ?? '';
                      final color   = _colorForType(type);

                      return InkWell(
                        onTap: () async {
                          if (!isRead) {
                            await ApiService.markNotificationRead(n['id'] as int);
                            setState(() {
                              _notifs[i] = {...n, 'is_read': true};
                            });
                          }
                        },
                        child: Container(
                          color: isRead ? Colors.white : Colors.teal.withOpacity(0.04),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ikon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_iconForType(type), color: color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              // Konten
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            n['title']?.toString() ?? '',
                                            style: TextStyle(
                                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.teal,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body']?.toString() ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n['created_at']?.toString() ?? '',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi pesanan akan muncul di sini',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}