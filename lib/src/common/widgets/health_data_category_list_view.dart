import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show HealthDataTypeCategory;
import 'package:ai_health/src/common/utils/extensions/display_name_extensions.dart';









class HealthDataCategoryListView<T> extends StatelessWidget {
  const HealthDataCategoryListView({
    required this.groupedItems,
    required this.itemBuilder,
    super.key,
    this.itemSorter,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
  });

  
  final Map<HealthDataTypeCategory, List<T>> groupedItems;

  
  final Widget Function(BuildContext context, T item) itemBuilder;

  
  final int Function(T a, T b)? itemSorter;

  
  final ScrollPhysics? physics;

  
  final bool shrinkWrap;

  
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    // Sort categories by display name
    final sortedCategories = groupedItems.keys.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return ListView.builder(
      padding: padding ?? EdgeInsets.zero,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final items = groupedItems[category]!;

        // Sort items if a sorter is provided
        if (itemSorter != null) {
          items.sort(itemSorter);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryHeader(context, category),
            const SizedBox(height: 8),
            ...items.map((item) => itemBuilder(context, item)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(
    BuildContext context,
    HealthDataTypeCategory category,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Icon(category.icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            category.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
