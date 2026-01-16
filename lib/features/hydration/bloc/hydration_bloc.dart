import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ai_health/main.dart';
import 'package:ai_health/features/hydration/repo/hydration_repository.dart';
import '../models/hydration_model.dart';
import 'dart:developer' as developer;

part 'hydration_event.dart';
part 'hydration_state.dart';

class HydrationBloc extends Bloc<HydrationEvent, HydrationState> {
  final HydrationRepository _hydrationRepository;

  HydrationBloc()
    : _hydrationRepository = HydrationRepository(
        healthConnector: healthConnector,
      ),
      super(const HydrationInitial()) {
    on<InitializeHydrationEvent>(_onInitialize);
    on<AddGlassEvent>(_onAddGlass);
    on<SetupRemindersEvent>(_onSetupReminders);
    on<UpdateRemindersEvent>(_onUpdateReminders);
  }

  Future<void> _onInitialize(
    InitializeHydrationEvent event,
    Emitter<HydrationState> emit,
  ) async {
    emit(const HydrationLoading());
    try {
      final now = DateTime.now();
      // Fetch for 0 days ago (today)
      final history = await _hydrationRepository.getHydrationHistory(0);

      int glasses = 0;
      if (history.isNotEmpty) {
        glasses = history.first.glasses;
      }

      final hydration = HydrationModel(
        id: DateTime.now().millisecondsSinceEpoch,
        reminderTimes: [],
        date: now,
        glassesConsumed: glasses,
        glassesTarget: 8,
      );

      developer.log('HydrationBloc: Initialized hydration tracking for today');
      emit(HydrationLoaded(hydration: hydration));
    } catch (e) {
      developer.log('HydrationBloc: Initialization error: $e', error: e);
      emit(HydrationError(message: e.toString()));
    }
  }

  Future<void> _onAddGlass(
    AddGlassEvent event,
    Emitter<HydrationState> emit,
  ) async {
    if (state is HydrationLoaded) {
      final currentState = state as HydrationLoaded;
      final updatedHydration = currentState.hydration.copyWith(
        glassesConsumed: currentState.hydration.glassesConsumed + 1,
      );

      // Write to Health Connect
      try {
        await _hydrationRepository.logGlass();
        print('Total glasses today: ${updatedHydration.glassesConsumed}');
      } catch (e) {
        print('HydrationBloc: Health Connect Write Error: $e');
      }

      emit(HydrationLoaded(hydration: updatedHydration));
    }
  }

  Future<void> _onSetupReminders(
    SetupRemindersEvent event,
    Emitter<HydrationState> emit,
  ) async {
    if (state is HydrationLoaded) {
      final currentState = state as HydrationLoaded;
      final reminderTimes = _generateReminderTimes(event.intervalMinutes);
      final updatedHydration = currentState.hydration.copyWith(
        reminderTimes: reminderTimes,
      );
      print(
        'HydrationBloc: Setup reminders every ${event.intervalMinutes} minutes. ',
      );
      emit(HydrationLoaded(hydration: updatedHydration));
    }
  }

  Future<void> _onUpdateReminders(
    UpdateRemindersEvent event,
    Emitter<HydrationState> emit,
  ) async {
    if (state is HydrationLoaded) {
      final currentState = state as HydrationLoaded;
      final remainingTimes = currentState.hydration.reminderTimes
          .where((time) => time.isAfter(DateTime.now()))
          .toList();
      final updatedHydration = currentState.hydration.copyWith(
        reminderTimes: remainingTimes,
      );
      developer.log(
        'HydrationBloc: Updated reminders. '
        '${remainingTimes.length} reminders remaining for today',
      );
      emit(HydrationLoaded(hydration: updatedHydration));
    }
  }

  /// Generate reminder times for the day at specified intervals
  /// Starts from now + interval and continues until 11:59 PM
  List<DateTime> _generateReminderTimes(int intervalMinutes) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
    final times = <DateTime>[];
    var currentTime = now.add(Duration(minutes: intervalMinutes));

    while (currentTime.isBefore(endOfDay)) {
      times.add(currentTime);
      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
    }

    return times;
  }
}
