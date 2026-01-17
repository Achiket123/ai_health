import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:health_connector/health_connector.dart';
import 'package:ai_health/src/features/incremental_data_sync/services/sync_token_storage_service.dart';





final class IncrementalDataSyncChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;
  final SyncTokenStorageService _storageService;

  // State variables
  bool _isLoading = false;
  HealthDataSyncToken? _syncToken;
  List<HealthDataType> _selectedDataTypes = [];

  // Sync results
  List<HealthRecord> _upsertedRecords = [];
  List<HealthRecordId> _deletedRecordIds = [];
  bool _hasMore = false;

  // Console logs
  final List<String> _logs = [];
  static const int _maxLogLines = 100;

  // Getters
  bool get isLoading => _isLoading;

  HealthDataSyncToken? get syncToken => _syncToken;

  List<HealthDataType> get selectedDataTypes => _selectedDataTypes;

  UnmodifiableListView<HealthRecord> get upsertedRecords =>
      UnmodifiableListView(_upsertedRecords);

  UnmodifiableListView<HealthRecordId> get deletedRecordIds =>
      UnmodifiableListView(_deletedRecordIds);

  bool get hasMore => _hasMore;

  UnmodifiableListView<String> get logs => UnmodifiableListView(_logs);

  IncrementalDataSyncChangeNotifier(
    this._healthConnector,
    this._storageService,
  );

  
  
  Future<void> initialize() async {
    notify(() => _isLoading = true);
    try {
      final token = await _storageService.loadToken();
      notify(() {
        _syncToken = token;
        if (token != null) {
          _selectedDataTypes = List.from(token.dataTypes);
        }
      });
      _addLog(
        'Initialized: '
        '${token != null ? "Token loaded" : "No token found"}',
      );
    } finally {
      notify(() => _isLoading = false);
    }
  }

  
  
  
  Future<void> synchronize() async {
    if (_selectedDataTypes.isEmpty) {
      throw ArgumentError('Please select at least one data type');
    }

    notify(() => _isLoading = true);
    _addLog(
      'Starting synchronization for '
      '${_selectedDataTypes.length} data type(s)...',
    );

    try {
      final result = await _healthConnector.synchronize(
        dataTypes: _selectedDataTypes,
        syncToken: _syncToken,
      );

      // Append results
      notify(() {
        _upsertedRecords.addAll(result.upsertedRecords);
        _deletedRecordIds.addAll(result.deletedRecordIds);
        _hasMore = result.hasMore;
        _syncToken = result.nextSyncToken;
      });

      // Save token
      await _storageService.saveToken(_syncToken);

      _addLog(
        'Sync complete: ${result.upsertedRecords.length} upsert(s), '
        '${result.deletedRecordIds.length} deletion(s), '
        'hasMore: ${result.hasMore}',
      );
    } finally {
      notify(() => _isLoading = false);
    }
  }

  
  Future<void> loadMore() async {
    if (!_hasMore || _syncToken == null) {
      return;
    }
    await synchronize();
  }

  
  Future<void> clearToken() async {
    notify(() => _isLoading = true);
    try {
      await _storageService.clearToken();
      notify(() {
        _syncToken = null;
        _upsertedRecords = [];
        _deletedRecordIds = [];
        _hasMore = false;
      });
      _addLog('Token cleared');
    } finally {
      notify(() => _isLoading = false);
    }
  }

  
  void clearResults() {
    notify(() {
      _upsertedRecords = [];
      _deletedRecordIds = [];
      _hasMore = false;
    });
    _addLog('Results cleared');
  }

  
  void updateSelectedDataTypes(
    List<HealthDataType> dataTypes,
  ) {
    notify(() {
      _selectedDataTypes = dataTypes;
    });
  }

  
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _logs.add('[$timestamp] $message');
    if (_logs.length > _maxLogLines) {
      _logs.removeAt(0);
    }
    notifyListeners();
  }

  
  void notify(void Function() fn) {
    fn();
    notifyListeners();
  }
}
