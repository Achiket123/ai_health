import 'dart:collection';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector_internal.dart';






final class ReadHealthRecordsChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;

  ReadHealthRecordsChangeNotifier(this._healthConnector);

  bool _isLoading = false;
  ReadRecordsInTimeRangeRequest? _nextPageRequest;
  UnmodifiableListView<HealthRecord> _healthRecords = UnmodifiableListView([]);
  bool _hasQueriedRecords = false;

  UnmodifiableListView<HealthRecord> get healthRecords => _healthRecords;

  bool get isLoading => _isLoading;

  ReadRecordsInTimeRangeRequest? get nextPageRequest => _nextPageRequest;

  bool get hasQueriedRecords => _hasQueriedRecords;

  
  
  
  
  
  Future<void> readHealthRecords<R extends HealthRecord>({
    required HealthDataType<R, MeasurementUnit> dataType,
    required DateTime startTime,
    required DateTime endTime,
    int pageSize = 100,
    String? pageToken,
    List<DataOrigin> dataOrigins = const [],
    SortDescriptor sortDescriptor = SortDescriptor.timeDescending,
  }) async {
    notify(() {
      _isLoading = true;
      _healthRecords = UnmodifiableListView([]);
      _nextPageRequest = null;
      _hasQueriedRecords = false;
    });

    try {
      final request = ReadRecordsInTimeRangeRequest(
        dataType: dataType,
        startTime: startTime,
        endTime: endTime,
        pageSize: pageSize,
        pageToken: pageToken,
        dataOrigins: dataOrigins,
        sortDescriptor: sortDescriptor,
      );

      final response = await _healthConnector.readRecords(request);

      notify(() {
        _healthRecords = UnmodifiableListView(response.records);
        _nextPageRequest = response.nextPageRequest;
        _hasQueriedRecords = true;
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  
  
  
  
  
  Future<void> loadNextPage() async {
    final nextPageRequest = _nextPageRequest;
    if (nextPageRequest == null) {
      return;
    }

    notify(() {
      _isLoading = true;
    });

    try {
      final nextResponse = await _healthConnector.readRecords(nextPageRequest);

      notify(() {
        final updatedHealthRecords = [
          ..._healthRecords,
          ...nextResponse.records,
        ];
        _healthRecords = UnmodifiableListView(updatedHealthRecords);
        _nextPageRequest = nextResponse.nextPageRequest;
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  
  
  
  
  Future<void> deleteRecord(
    HealthRecord record,
    HealthDataType<HealthRecord, MeasurementUnit> dataType,
  ) async {
    notify(() {
      _isLoading = true;
    });

    try {
      final request = DeleteRecordsByIdsRequest(
        dataType: dataType,
        recordIds: [record.id],
      );

      await _healthConnector.deleteRecords(request);

      notify(() {
        final updatedHealthRecords = _healthRecords
            .where((r) => r.id != record.id)
            .toList();
        _healthRecords = UnmodifiableListView(updatedHealthRecords);
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  
  void reset() {
    notify(() {
      _healthRecords = UnmodifiableListView([]);
      _nextPageRequest = null;
      _hasQueriedRecords = false;
    });
  }

  void notify(void Function() fn) {
    fn();
    notifyListeners();
  }
}
