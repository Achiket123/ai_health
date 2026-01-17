import 'package:flutter/material.dart';



@immutable
final class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  
  final String? message;

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).progressIndicatorTheme.color ??
        Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color),
          if (message != null) ...[
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
              ),
              child: Text(
                message!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
