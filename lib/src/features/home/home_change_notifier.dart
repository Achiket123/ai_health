import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector_internal.dart';


final class HomeChangeNotifier extends ChangeNotifier {
  StreamSubscription<HealthConnectorLog>? _logEventSubscription;
  bool _isLoading = false;
  HealthConnector? _healthConnector;
  HealthConnectorException? _error;

  bool get isLoading => _isLoading;

  HealthConnector? get healthConnector => _healthConnector;

  HealthConnectorException? get error => _error;

  
  
  
  
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      const config = HealthConnectorConfig(
        loggerConfig: HealthConnectorLoggerConfig(
          enableNativeLogging: true,
          logProcessors: [
            DeveloperLogProcessor(),
          ],
        ),
      );
      final healthConnector = await HealthConnector.create(config);

      _healthConnector = healthConnector;
    } on HealthConnectorException catch (e) {
      _error = e;
      _healthConnector = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> launchHealthAppPageInAppStore() async {
    try {
      await HealthConnector.launchHealthAppPageInAppStore();
    } on HealthConnectorException {
      rethrow;
    }
  }

  @override
  void dispose() {
    _logEventSubscription?.cancel();
    _logEventSubscription = null;
    _healthConnector = null;

    super.dispose();
  }
}
