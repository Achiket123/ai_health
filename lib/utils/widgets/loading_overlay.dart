import 'package:flutter/material.dart';

import 'package:ai_health/utils/widgets/loading_indicator.dart';




@immutable
final class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  
  final bool isLoading;

  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      child: Stack(
        children: [
          child,
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                child: ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: const LoadingIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
