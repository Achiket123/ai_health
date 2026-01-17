import 'package:flutter/material.dart';
import 'package:ai_health/src/common/widgets/pickers/date_time_picker_row.dart';



mixin StartDateTimePickerPageStateMixin<T extends StatefulWidget> on State<T> {
  DateTime? _startDate;
  TimeOfDay? _startTime;

  
  DateTime? get startDate => _startDate;

  
  TimeOfDay? get startTime => _startTime;

  
  
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

  
  DateTime? get time => startDateTime;

  
  
  int? get zoneOffsetSeconds {
    final dt = startDateTime;
    if (dt == null) {
      return null;
    }
    return dt.timeZoneOffset.inSeconds;
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    setState(() {
      _startDate = DateTime.now();
      _startTime = TimeOfDay.now();
    });
  }

  
  void setDate(DateTime? date) {
    setState(() {
      _startDate = date;
    });
  }

  
  void setTime(TimeOfDay? time) {
    setState(() {
      _startTime = time;
    });
  }

  
  void resetDateTime() {
    setState(() {
      _startDate = null;
      _startTime = null;
    });
  }

  
  
  
  
  Widget buildDateTimePicker(BuildContext context) {
    return DateTimePickerRow(
      startDate: _startDate,
      startTime: _startTime,
      onDateChanged: setDate,
      onTimeChanged: setTime,
    );
  }
}
