import 'package:flutter/material.dart';
import 'package:ai_health/src/common/constants/app_texts.dart';
import 'package:ai_health/src/common/utils/mixins/start_date_time_picker_page_state_mixin.dart';



mixin StartDateTimePickerWithDurationPageStateMixin<T extends StatefulWidget>
    on StartDateTimePickerPageStateMixin<T> {
  TimeOfDay? _duration;

  
  TimeOfDay? get duration => _duration;

  
  
  
  DateTime? get endDateTime {
    final start = startDateTime;
    if (start == null || _duration == null) {
      return null;
    }

    // Convert duration (TimeOfDay) to Duration
    final durationMinutes = _duration!.hour * 60 + _duration!.minute;
    if (durationMinutes == 0) {
      return null;
    }

    return start.add(Duration(minutes: durationMinutes));
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    // Set start date/time to now - 30 minutes
    final nowMinus30Min = DateTime.now().subtract(const Duration(minutes: 30));
    setDate(
      DateTime(
        nowMinus30Min.year,
        nowMinus30Min.month,
        nowMinus30Min.day,
      ),
    );
    setTime(
      TimeOfDay(
        hour: nowMinus30Min.hour,
        minute: nowMinus30Min.minute,
      ),
    );
    // Set duration to 30 minutes
    _duration = const TimeOfDay(hour: 0, minute: 30);
  }

  
  void setDuration(TimeOfDay? duration) {
    setState(() {
      _duration = duration;
    });
  }

  
  void resetDuration() {
    setState(() {
      _duration = null;
    });
  }

  
  @override
  void resetDateTime() {
    super.resetDateTime();
    resetDuration();
  }

  
  
  
  
  
  
  String? Function(TimeOfDay?) get durationValidator {
    return (TimeOfDay? value) {
      if (value == null) {
        return '${AppTexts.pleaseSelect} Duration';
      }
      final durationMinutes = value.hour * 60 + value.minute;
      if (durationMinutes == 0) {
        return 'Duration must be greater than 0';
      }
      if (startDateTime == null) {
        return AppTexts.pleaseSelectDateTime;
      }
      // Verify endDateTime can be calculated
      final end = endDateTime;
      if (end == null) {
        return 'Failed to calculate end time';
      }
      return null;
    };
  }
}
