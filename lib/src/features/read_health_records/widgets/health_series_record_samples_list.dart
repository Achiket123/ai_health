import 'package:flutter/material.dart';



















@immutable
final class HealthSeriesRecordSampleList<T> extends StatelessWidget {
  const HealthSeriesRecordSampleList({
    required this.title,
    required this.samples,
    required this.itemBuilder,
    super.key,
    this.emptyMessage = 'No samples available',
  });

  
  final String title;

  
  final List<T> samples;

  
  
  
  final Widget Function(T sample, int index) itemBuilder;

  
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...samples.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  '${entry.key + 1}.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: itemBuilder(entry.value, entry.key)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
