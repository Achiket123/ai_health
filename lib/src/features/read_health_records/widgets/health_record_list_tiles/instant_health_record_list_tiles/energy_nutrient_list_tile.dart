import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show DietaryEnergyConsumedRecord, MealType;
import 'package:ai_health/src/common/constants/app_icons.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/date_formatter.dart';
import 'package:ai_health/src/common/utils/extensions/meal_type_extension.dart';
import 'package:ai_health/src/common/widgets/measurement_unit_display.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_detail_row.dart';
import 'package:ai_health/src/features/read_health_records/widgets/health_record_list_tiles/instant_health_record_list_tiles/instant_health_record_list_tile.dart';






final class EnergyNutrientListTile extends StatelessWidget {
  const EnergyNutrientListTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final DietaryEnergyConsumedRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InstantHealthRecordTile<DietaryEnergyConsumedRecord>(
      record: record,
      icon: AppIcons.localFireDepartment,
      title: _buildTitle(),
      subtitleBuilder: _buildSubtitle,
      detailRowsBuilder: _buildDetailRows,
      onDelete: onDelete,
    );
  }

  
  String _buildTitle() {
    return '${record.energy.inKilocalories.toStringAsFixed(2)} kcal '
        '(${record.energy.inCalories.toStringAsFixed(0)} cal)';
  }

  
  
  Widget _buildSubtitle(DietaryEnergyConsumedRecord rec, BuildContext ctx) {
    final foodName = rec.foodName;
    final mealType = rec.mealType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          '${AppTexts.time}: ${DateFormatter.formatDateTime(rec.time)}',
        ),
        if (foodName != null && foodName.isNotEmpty)
          Text(
            '${AppTexts.food}: $foodName',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
            ),
          ),
        if (mealType != MealType.unknown)
          Text(
            '${AppTexts.meal}: ${mealType.displayName}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
            ),
          ),
        Text(
          '${AppTexts.recording}: ${rec.metadata.recordingMethod.name}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(ctx).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  
  List<Widget> _buildDetailRows(
    DietaryEnergyConsumedRecord rec,
    BuildContext ctx,
  ) {
    final foodName = rec.foodName;
    final mealType = rec.mealType;

    return [
      const HealthRecordDetailRow(
        label: AppTexts.value,
        value: '',
      ),
      MeasurementUnitDisplay(unit: rec.energy),
      if (foodName != null && foodName.isNotEmpty)
        HealthRecordDetailRow(
          label: AppTexts.foodName,
          value: foodName,
        ),
      if (mealType != MealType.unknown)
        HealthRecordDetailRow(
          label: AppTexts.mealType,
          value: mealType.displayName,
        ),
    ];
  }
}
