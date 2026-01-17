import 'package:flutter/material.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/theme/app_theme_data.dart';
import 'package:ai_health/src/features/home/home_change_notifier.dart';
import 'package:ai_health/src/features/home/pages/home_page.dart';
import 'package:provider/provider.dart';





@immutable
final class HealthConnectorToolboxApp extends StatelessWidget {
  const HealthConnectorToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ChangeNotifierProvider(
        create: (_) => HomeChangeNotifier()..init(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppTexts.healthConnectorToolbox,
          theme: appThemeData,
          home: const HomePage(),
        ),
      ),
    );
  }
}
