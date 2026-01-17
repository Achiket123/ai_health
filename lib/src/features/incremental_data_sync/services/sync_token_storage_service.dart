import 'dart:convert';

import 'package:health_connector/health_connector.dart';
import 'package:shared_preferences/shared_preferences.dart';





final class SyncTokenStorageService {
  static const String _syncTokenKey = 'health_sync_token';

  final SharedPreferences _prefs;

  SyncTokenStorageService(this._prefs);

  
  
  
  Future<void> saveToken(HealthDataSyncToken? token) async {
    if (token == null) {
      await _prefs.remove(_syncTokenKey);
    } else {
      final json = jsonEncode(token.toJson());
      await _prefs.setString(_syncTokenKey, json);
    }
  }

  
  
  
  Future<HealthDataSyncToken?> loadToken() async {
    final json = _prefs.getString(_syncTokenKey);
    if (json == null) {
      return null;
    }

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return HealthDataSyncToken.fromJson(map);
    } on Exception {
      // Token format changed or corrupted, clear it
      await clearToken();
      return null;
    }
  }

  
  Future<void> clearToken() async {
    await _prefs.remove(_syncTokenKey);
  }
}
