import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/show_app_snack_bar.dart';



















mixin ProcessOperationWithErrorHandlerPageStateMixin<T extends StatefulWidget>
    on State<T> {
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  Future<void> process(Future<void> Function() operation) async {
    try {
      await operation();
    } on HealthConnectorException catch (e) {
      if (!mounted) {
        return;
      }

      showAppSnackBar(context, SnackBarType.error, e.message);
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        SnackBarType.error,
        '${AppTexts.errorPrefixColon} $e',
      );
    }
  }
}
