import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ai_health/features/step/repo/step_repository.dart';
import 'dart:developer' as developer;

part 'step_event.dart';
part 'step_state.dart';

class StepBloc extends Bloc<StepEvent, StepState> {
  final StepRepository _repository;

  StepBloc({required StepRepository repository})
    : _repository = repository,
      super(StepInitial()) {
    on<LoadStepDataEvent>(_onLoadStepData);
  }

  Future<void> _onLoadStepData(
    LoadStepDataEvent event,
    Emitter<StepState> emit,
  ) async {
    emit(StepLoading());
    try {
      final steps = await _repository.getDailySteps(event.days);
      emit(StepLoaded(stepData: steps));
    } catch (e) {
      developer.log('StepBloc: Error loading step data: $e', error: e);
      emit(StepError(message: e.toString()));
    }
  }
}
