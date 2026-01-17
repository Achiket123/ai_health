import 'package:health_connector/health_connector_internal.dart'
    show HealthDataPermission;
import 'package:ai_health/src/common/utils/extensions/health_data_permission_access_type_ui_extension.dart';
import 'package:ai_health/src/common/utils/extensions/health_data_type_ui_extension.dart';


extension HealthDataPermissionUI on HealthDataPermission {
  
  
  
  String get displayName {
    return '${dataType.displayName} - ${accessType.displayName}';
  }
}
