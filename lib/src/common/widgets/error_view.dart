import 'package:flutter/material.dart';
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';





@immutable
final class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    super.key,
    this.title,
    this.icon = AppIcons.error,
    this.onRetry,
  });

  
  final String? title;

  
  final String message;

  
  final IconData icon;

  
  
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.errorContainer,
            ),
            const SizedBox(height: 24),
            Text(
              title ?? AppTexts.errorOccurred,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(AppIcons.refresh),
                label: const Text(AppTexts.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
