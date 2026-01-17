import 'package:flutter/material.dart';
import 'package:health_connector/health_connector_internal.dart'
    show HealthRecord;


typedef RecordTitleBuilder<T extends HealthRecord> = String Function(T record);


typedef RecordIconBuilder<T extends HealthRecord> = IconData Function(T record);


typedef RecordSubtitleBuilder<T extends HealthRecord> =
    Widget Function(
      T record,
      BuildContext context,
    );


typedef RecordDetailRowsBuilder<T extends HealthRecord> =
    List<Widget> Function(
      T record,
      BuildContext context,
    );



typedef SeriesSamplesBuilder<T> =
    Widget? Function(
      T samples,
      BuildContext context,
    );
