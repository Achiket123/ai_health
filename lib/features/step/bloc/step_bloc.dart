import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ai_health/main.dart';
import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import '../models/step_model.dart';
import 'dart:developer' as developer;

part 'step_event.dart';
part 'step_state.dart';

class StepBloc extends Bloc<StepEvent, StepState> {
  StepBloc() : super(StepInitial()) {
    on<LoadStepDataEvent>(_onLoadStepData);
  }

  Future<void> _onLoadStepData(
    LoadStepDataEvent event,
    Emitter<StepState> emit,
  ) async {
    emit(StepLoading());
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: event.days));

      final records = await healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.steps,
          startTime: startDate,
          endTime: now,
        ),
      );

      final Map<DateTime, int> dailySteps = {};

      for (var record in records.records) {
        final date = DateTime(
          record.startTime.year,
          record.startTime.month,
          record.startTime.day,
        );
        dailySteps[date] = (dailySteps[date] ?? 0) + record.count;
      }

      final stepData = dailySteps.entries.map((entry) {
        return StepModel(date: entry.key, steps: entry.value);
      }).toList();

      stepData.sort((a, b) => a.date.compareTo(b.date));

      developer.log('StepBloc: Loaded ${stepData.length} days of step data');
      emit(StepLoaded(stepData: stepData));
    } catch (e) {
      developer.log('StepBloc: Error loading step data: $e', error: e);
      emit(StepError(message: e.toString()));
    }
  }
}
