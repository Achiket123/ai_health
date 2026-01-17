import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


abstract class DateFormatter {
  DateFormatter._();

  
  static final DateFormat ddMMyyyyHHmm = DateFormat('dd-MM-yyyy HH:mm');

  
  
  
  static String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  
  
  
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  
  
  
  static String formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  
  
  
  
  static DateTime? combine(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
