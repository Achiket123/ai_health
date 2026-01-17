import 'package:flutter/material.dart';
import 'package:ai_health/src/features/write_health_record/widgets/write_forms/interval_health_record_write_form.dart';


@immutable
abstract class SeriesHealthRecordWriteForm<TSample>
    extends IntervalHealthRecordWriteForm {
  const SeriesHealthRecordWriteForm({
    required super.healthPlatform,
    required super.onSubmit,
    super.key,
  });

  @override
  SeriesHealthRecordFormState<TSample, SeriesHealthRecordWriteForm<TSample>>
  createState();
}


abstract class SeriesHealthRecordFormState<
  TSample,
  T extends SeriesHealthRecordWriteForm<TSample>
>
    extends IntervalHealthRecordFormState<T> {
  
  List<TSample> samples = [];

  @override
  bool validate() {
    if (!super.validate()) {
      return false;
    }

    // Validate minimum sample count
    if (samples.isEmpty) {
      return false;
    }

    return true;
  }

  
  
  
  
  List<Widget> buildSeriesFields(BuildContext context);

  @override
  List<Widget> buildFields(BuildContext context) {
    return [
      // Get fields from the parent interval write form
      ...super.buildFields(context),

      const SizedBox(height: 16),
      ...buildSeriesFields(context),
    ];
  }
}
