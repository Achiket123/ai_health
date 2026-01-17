import 'package:ai_health/utils/constants/app_status_color.dart';
import 'package:flutter/material.dart';


enum SnackBarType {
  
  info,

  
  warning,

  
  error,

  
  success,
}








void showAppSnackBar(
  BuildContext context,
  SnackBarType type,
  String message, {
  Duration? duration,
  SnackBarAction? action,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: _getBackgroundColor(context, type),
    behavior: SnackBarBehavior.floating,
    duration: duration ?? const Duration(seconds: 4),
    showCloseIcon: true,
    action: action,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


Color _getBackgroundColor(BuildContext context, SnackBarType type) {
  final statusColors = Theme.of(context).extension<AppStatusColors>()!;
  return switch (type) {
    SnackBarType.info => statusColors.info,
    SnackBarType.warning => statusColors.warning,
    SnackBarType.error => Theme.of(context).colorScheme.error,
    SnackBarType.success => statusColors.success,
  };
}
