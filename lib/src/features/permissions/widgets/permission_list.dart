import 'package:flutter/widgets.dart';
import 'package:health_connector/health_connector_internal.dart'
    show HealthDataPermission;
import 'package:ai_health/src/common/utils/extensions/display_name_extensions.dart';
import 'package:ai_health/src/features/permissions/permissions_change_notifier.dart';
import 'package:ai_health/src/features/permissions/widgets/permission_list_tile.dart';





@immutable
final class PermissionList extends StatelessWidget {
  const PermissionList({
    required this.notifier,
    required this.permissions,
    super.key,
  });

  
  final PermissionsChangeNotifier notifier;

  
  final List<HealthDataPermission> permissions;

  @override
  Widget build(BuildContext context) {
    // Sort permissions alphabetically by display name
    final sortedPermissions = permissions.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return Column(
      children: sortedPermissions.map((permission) {
        return PermissionListTile(
          title: Text(permission.displayName),
          isSelected: notifier.isPermissionSelected(permission),
          permissionStatus: notifier.getPermissionStatus(permission),
          onChanged: (bool value) => notifier.togglePermissionSelection(
            permission,
            isSelected: value,
          ),
        );
      }).toList(),
    );
  }
}
