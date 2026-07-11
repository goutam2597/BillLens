import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FirebaseConfigService {
  FirebaseOptions? _options;
  bool _initialized = false;

  bool get isConfigured => _options != null;
  FirebaseOptions? get options => _options;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      const baseUrl = 'http://192.168.0.187/billlens/billlens_backend/public';
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse('$baseUrl/firebase-config'));
        final response = await request.close().timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode != 200) return;

        final body = await response.transform(utf8.decoder).join();
        final decoded = json.decode(body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;

        if (data == null || data['configured'] != true) return;

        final config = data['config'] as Map<String, dynamic>;
        final projectId = (config['projectId'] as String?) ?? '';
        final apiKey = (config['apiKey'] as String?) ?? '';

        if (projectId.isEmpty || apiKey.isEmpty) return;

        _options = FirebaseOptions(
          apiKey: apiKey,
          appId: (config['appId'] as String?) ?? '',
          messagingSenderId: (config['messagingSenderId'] as String?) ?? '',
          projectId: projectId,
          authDomain: (config['authDomain'] as String?) ?? '',
          storageBucket: (config['storageBucket'] as String?) ?? '',
          measurementId: (config['measurementId'] as String?) ?? '',
        );

        await Firebase.initializeApp(
          options: _options!,
        );

        _initialized = true;
      } finally {
        client.close();
      }
    } catch (_) {
      // Firebase init failure is non-fatal
    }
  }
}
