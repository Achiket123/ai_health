import 'package:flutter/material.dart';
import 'package:ai_health/src/common/widgets/pickers/date_time_range_picker_column.dart';



mixin DateTimeRangePickerPageStateMixin<T extends StatefulWidget> on State<T> {
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  
  DateTime? get startDate => _startDate;

  
  TimeOfDay? get startTime => _startTime;

  
  DateTime? get endDate => _endDate;

  
  TimeOfDay? get endTime => _endTime;

  
  
  DateTime? get startDateTime {
    if (_startDate == null || _startTime == null) {
      return null;
    }
    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  
  
  DateTime? get endDateTime {
    if (_endDate == null || _endTime == null) {
      return null;
    }
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  
  
  int? get startZoneOffsetSeconds {
    final dt = startDateTime;
    if (dt == null) {
      return null;
    }
    return dt.timeZoneOffset.inSeconds;
  }

  
  
  int? get endZoneOffsetSeconds {
    final dt = endDateTime;
    if (dt == null) {
      return null;
    }
    return dt.timeZoneOffset.inSeconds;
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    _initializeDefaultRange();
  }

  
  void setStartDate(DateTime? date) {
    setState(() {
      _startDate = date;
    });
  }

  
  void setStartTime(TimeOfDay? time) {
    setState(() {
      _startTime = time;
    });
  }

  
  void setEndDate(DateTime? date) {
    setState(() {
      _endDate = date;
    });
  }

  
  void setEndTime(TimeOfDay? time) {
    setState(() {
      _endTime = time;
    });
  }

  
  void resetDateTimeRange() {
    setState(() {
      _startDate = null;
      _startTime = null;
      _endDate = null;
      _endTime = null;
    });
  }

  
  
  
  void _initializeDefaultRange() {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(
      const Duration(days: 30),
    );

    setState(() {
      // Set end date/time to now
      _endDate = DateTime(now.year, now.month, now.day);
      _endTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Set start date/time to 1 month ago
      _startDate = DateTime(
        oneMonthAgo.year,
        oneMonthAgo.month,
        oneMonthAgo.day,
      );
      _startTime = TimeOfDay(
        hour: oneMonthAgo.hour,
        minute: oneMonthAgo.minute,
      );
    });
  }

  
  
  
  
  Widget buildDateTimeRangePicker(BuildContext context) {
    return DateTimeRangePickerColumn(
      startDate: _startDate,
      startTime: _startTime,
      endDate: _endDate,
      endTime: _endTime,
      onStartDateChanged: setStartDate,
      onStartTimeChanged: setStartTime,
      onEndDateChanged: setEndDate,
      onEndTimeChanged: setEndTime,
    );
  }
}
