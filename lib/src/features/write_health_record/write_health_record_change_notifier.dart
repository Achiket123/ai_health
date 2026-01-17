import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector_internal.dart'
    show HealthRecord, HealthRecordId, HealthPlatform, HealthConnector;


final class WriteHealthRecordChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;

  WriteHealthRecordChangeNotifier(this._healthConnector);

  bool _isLoading = false;

  HealthPlatform get healthPlatform => _healthConnector.healthPlatform;

  bool get isLoading => _isLoading;

  
  Future<HealthRecordId> writeHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _healthConnector.writeRecord(record);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
