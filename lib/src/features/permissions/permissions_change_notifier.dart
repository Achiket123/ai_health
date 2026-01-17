import 'dart:collection';
import 'dart:developer' show log;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector_internal.dart'
    show
        HealthConnectorException,
        HealthPlatformFeature,
        HealthPlatformFeatureStatus,
        Permission,
        PermissionStatus,
        HealthConnector;


sealed class PermissionLoadingState {
  const PermissionLoadingState();
}


final class Idle extends PermissionLoadingState {
  const Idle();
}


final class LoadingPage extends PermissionLoadingState {
  const LoadingPage();
}


final class LoadingRequest extends PermissionLoadingState {
  const LoadingRequest();
}






final class PermissionsChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;

  PermissionsChangeNotifier(this._healthConnector) {
    loadFeatureStatuses();
  }

  PermissionLoadingState _loadingState = const Idle();
  UnmodifiableListView<Permission> _grantedPermissions = UnmodifiableListView(
    [],
  );
  final Set<Permission> _selectedPermissions = {};
  Map<Permission, PermissionStatus> _permissionResults = {};
  Map<HealthPlatformFeature, HealthPlatformFeatureStatus> _featureStatuses = {};
  String? _errorMessage;

  
  PermissionLoadingState get loadingState => _loadingState;

  
  bool get isLoading =>
      _loadingState is LoadingRequest || _loadingState is LoadingPage;

  
  bool get isPageLoading => _loadingState is LoadingPage;

  
  List<Permission> get grantedPermissions => _grantedPermissions;

  
  Set<Permission> get selectedPermissions => _selectedPermissions;

  
  UnmodifiableMapView<Permission, PermissionStatus> get permissionResults =>
      UnmodifiableMapView(_permissionResults);

  
  UnmodifiableMapView<HealthPlatformFeature, HealthPlatformFeatureStatus>
  get featureStatuses => UnmodifiableMapView(_featureStatuses);

  
  String? get errorMessage => _errorMessage;

  
  bool isPermissionSelected(Permission permission) {
    return _selectedPermissions.contains(permission);
  }

  
  void togglePermissionSelection(
    Permission permission, {
    required bool isSelected,
  }) {
    _executeAndNotify(() {
      if (isSelected) {
        _selectedPermissions.add(permission);
      } else {
        _selectedPermissions.remove(permission);
      }
    });
  }

  
  PermissionStatus? getPermissionStatus(Permission permission) {
    return _permissionResults[permission];
  }

  
  
  
  
  Future<void> loadFeatureStatuses() async {
    log('Loading feature statuses');
    _executeAndNotify(() {
      _loadingState = const LoadingPage();
      _errorMessage = null;
    });

    try {
      // Load all feature statuses in parallel for better performance
      final featureStatusFutures = HealthPlatformFeature.values.map(
        (feature) async => MapEntry(
          feature,
          await _healthConnector.getFeatureStatus(feature),
        ),
      );

      final statuses = Map.fromEntries(await Future.wait(featureStatusFutures));

      _executeAndNotify(() {
        _featureStatuses = statuses;
        _loadingState = const Idle();
      });

      log('Loaded ${statuses.length} feature statuses');
    } on HealthConnectorException catch (e, stackTrace) {
      log('Failed to load feature statuses', error: e, stackTrace: stackTrace);
      _executeAndNotify(() {
        _errorMessage = 'Failed to load feature statuses: ${e.message}';
        _loadingState = const Idle();
      });
    } on Exception catch (e, stackTrace) {
      log('Error loading feature statuses', error: e, stackTrace: stackTrace);
      _executeAndNotify(() {
        _errorMessage = 'Error: $e';
        _loadingState = const Idle();
      });
    }
  }

  
  
  
  
  Future<void> requestPermissions(List<Permission> permissions) async {
    if (permissions.isEmpty) {
      return;
    }

    log('Requesting ${permissions.length} permissions');
    _executeAndNotify(() {
      _loadingState = const LoadingRequest();
      _errorMessage = null;
    });

    try {
      final results = await _healthConnector.requestPermissions(permissions);
      log('Received ${results.length} permission results');

      final resultsMap = <Permission, PermissionStatus>{};
      for (final result in results) {
        resultsMap[result.permission] = result.status;
      }

      _executeAndNotify(() {
        _permissionResults = {..._permissionResults, ...resultsMap};
        _selectedPermissions.clear();
        _loadingState = const Idle();
      });
    } on HealthConnectorException catch (e, stackTrace) {
      log('Failed to request permissions', error: e, stackTrace: stackTrace);
      _executeAndNotify(() {
        _errorMessage = 'Failed to request permissions: ${e.message}';
        _loadingState = const Idle();
      });
    } on Exception catch (e, stackTrace) {
      log('Error requesting permissions', error: e, stackTrace: stackTrace);
      _executeAndNotify(() {
        _errorMessage = 'Error: $e';
        _loadingState = const Idle();
      });
    }
  }

  
  
  
  Future<void> getGrantedPermissions() async {
    log('Getting granted permissions');
    _executeAndNotify(() {
      _loadingState = const LoadingRequest();
      _errorMessage = null;
    });

    try {
      final grantedPermissions = await _healthConnector.getGrantedPermissions();
      log('Retrieved ${grantedPermissions.length} granted permissions');

      _executeAndNotify(() {
        _grantedPermissions = UnmodifiableListView(grantedPermissions);
        _loadingState = const Idle();
      });
    } on HealthConnectorException catch (e, stackTrace) {
      log(
        'Failed to get granted permissions',
        error: e,
        stackTrace: stackTrace,
      );
      _executeAndNotify(() {
        _errorMessage = 'Failed to get granted permissions: ${e.message}';
        _loadingState = const Idle();
      });
    } on Exception catch (e, stackTrace) {
      log(
        'Error getting granted permissions',
        error: e,
        stackTrace: stackTrace,
      );
      _executeAndNotify(() {
        _errorMessage = 'Error: $e';
        _loadingState = const Idle();
      });
    }
  }

  
  
  
  Future<void> revokeAllPermissions() async {
    log('Revoking all permissions');
    _executeAndNotify(() {
      _loadingState = const LoadingRequest();
      _errorMessage = null;
    });

    try {
      await _healthConnector.revokeAllPermissions();
      log('Successfully revoked all permissions');

      _executeAndNotify(() {
        _grantedPermissions = UnmodifiableListView([]);
        _loadingState = const Idle();
      });
    } on HealthConnectorException catch (e, stackTrace) {
      log('Failed to revoke permissions', error: e, stackTrace: stackTrace);
      _executeAndNotify(() {
        _errorMessage = 'Failed to revoke permissions: ${e.message}';
        _loadingState = const Idle();
      });
    } on Exception catch (e, stackTrace) {
      log('Error revoking permissions', error: e, stackTrace: stackTrace);
      _executeAndNotify(() {
        _errorMessage = 'Error: $e';
        _loadingState = const Idle();
      });
    }
  }

  
  
  
  
  void _executeAndNotify(void Function() action) {
    action();
    notifyListeners();
  }
}
