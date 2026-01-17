import 'package:equatable/equatable.dart';
import 'package:ai_health/features/streak/models/streak_day.dart';

abstract class StreakEvent extends Equatable {
  const StreakEvent();

  @override
  List<Object?> get props => [];
}


class FetchStreakDataEvent extends StreakEvent {
  final String userId;

  const FetchStreakDataEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}


class AddPhotoToDayEvent extends StreakEvent {
  final String userId;
  final DateTime date;
  final String photoPath;

  const AddPhotoToDayEvent({
    required this.userId,
    required this.date,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [userId, date, photoPath];
}


class RemovePhotoFromDayEvent extends StreakEvent {
  final String userId;
  final DateTime date;
  final String photoPath;

  const RemovePhotoFromDayEvent({
    required this.userId,
    required this.date,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [userId, date, photoPath];
}


class UpdateDayPhotosEvent extends StreakEvent {
  final String userId;
  final StreakDay day;

  const UpdateDayPhotosEvent({required this.userId, required this.day});

  @override
  List<Object?> get props => [userId, day];
}


class FetchMonthDataEvent extends StreakEvent {
  final String userId;
  final DateTime month;

  const FetchMonthDataEvent({required this.userId, required this.month});

  @override
  List<Object?> get props => [userId, month];
}


class DeleteStreakDataEvent extends StreakEvent {
  final String userId;

  const DeleteStreakDataEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
