import 'package:flutter/foundation.dart';

class ApiService {
  // Base URL untuk API Laravel
  // - Android Emulator: http://10.0.2.2:8000 (10.0.2.2 = host machine loopback)
  // - Web/Chrome: http://localhost:8000
  // - Physical device: http://<your-machine-ip>:8000
  
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String _localhostUrl = 'http://localhost:8000';
  
  static String get baseUrl {
    // Di development, gunakan localhost
    // Untuk production, sesuaikan dengan server URL
    return _localhostUrl;
  }
  
  // Alternative: jika ingin auto-detect platform
  static String get baseUrlAuto {
    if (kIsWeb) {
      // Web/Chrome
      return _localhostUrl;
    } else {
      // Android/iOS - gunakan 10.0.2.2 untuk Android emulator, atau bisa set IP device
      return _androidEmulatorUrl;
    }
  }
  
  // Untuk testing/development, bisa override base URL
  static String customBaseUrl = '';
  
  static String getApiUrl(String endpoint) {
    final base = customBaseUrl.isNotEmpty ? customBaseUrl : baseUrl;
    return '$base/api$endpoint';
  }
}
