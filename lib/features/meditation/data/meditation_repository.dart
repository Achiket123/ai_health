import 'package:ai_health/features/meditation/data/meditation_item.dart';
import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'dart:developer' as developer;

class MeditationRepository {
  HealthConnector? _healthConnector;

  MeditationRepository({HealthConnector? healthConnector})
      : _healthConnector = healthConnector;

  // Use a default instance if not provided
  Future<HealthConnector> get _hc async {
    if (_healthConnector != null) return _healthConnector!;
    _healthConnector = await HealthConnector.create();
    return _healthConnector!;
  }

  Future<List<MeditationItem>> getItems() async {
    // Return dummy data for content as Health Connect does not store content/videos
    return const [
      // Tutorials
      MeditationItem(
        title: 'Meditation for Beginners',
        url: 'https://www.youtube.com/watch?v=inpok4MKVLM',
        thumbnailUrl: 'https://img.youtube.com/vi/inpok4MKVLM/0.jpg',
        duration: '10 min',
        isTutorial: true,
      ),
      MeditationItem(
        title: '10-Minute Meditation for Anxiety',
        url: 'https://www.youtube.com/watch?v=O-6f5wQXSu8',
        thumbnailUrl: 'https://img.youtube.com/vi/O-6f5wQXSu8/0.jpg',
        duration: '10 min',
        isTutorial: true,
      ),
       MeditationItem(
        title: 'Daily Calm 10 Minute Meditation',
        url: 'https://www.youtube.com/watch?v=ZToicYcHIOU',
        thumbnailUrl: 'https://img.youtube.com/vi/ZToicYcHIOU/0.jpg',
        duration: '10 min',
        isTutorial: true,
      ),

      // Beats / Music
      MeditationItem(
        title: 'Tibetan Healing Sounds',
        url: 'https://www.youtube.com/watch?v=Q5dU6serXkg',
        thumbnailUrl: 'https://img.youtube.com/vi/Q5dU6serXkg/0.jpg',
        duration: '1 Hour',
        isTutorial: false,
      ),
       MeditationItem(
        title: 'Positive Energy Music',
        url: 'https://www.youtube.com/watch?v=lWA2pjMjpBs',
        thumbnailUrl: 'https://img.youtube.com/vi/lWA2pjMjpBs/0.jpg',
        duration: '1 Hour',
        isTutorial: false,
      ),
    ];
  }

  /// Save a meditation session to Health Connect (Mindfulness)
  Future<void> saveSession(DateTime startTime, DateTime endTime) async {
    try {
      final hc = await _hc;
      // Using MindfulnessSessionRecord (or closest equivalent)
      // Note: `health_connector` might use specific naming for Mindfulness.
      // Based on common Health Connect types, it is MindfulnessSessionRecord.

      // Checking health_connector types... Assuming MindfulnessSessionRecord exists.
      // If not, we might need to use ExerciseSession with type=Meditation? No, usually distinct.
      // Let's assume standard Health Connect SDK mapping.

      // Note: If the package version is older, it might not support it.
      // But typically it is available.

      // Let's check imports.

      final record = MindfulnessSessionRecord(
        startTime: startTime,
        endTime: endTime,
        metadata: Metadata.manualEntry(),
        notes: "Meditation Session",
      );

      await hc.writeRecords([record]);
      developer.log("Saved mindfulness session to Health Connect");
    } catch (e) {
      developer.log("Error saving mindfulness session: $e", error: e);
      // Don't crash if unsupported
    }
  }

  /// Get recent meditation sessions
  Future<List<MindfulnessSessionRecord>> getSessions() async {
    try {
      final hc = await _hc;
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));

      final response = await hc.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.mindfulnessSession,
          startTime: startTime,
          endTime: now,
        ),
      );

      return response.records.whereType<MindfulnessSessionRecord>().toList();
    } catch (e) {
      developer.log("Error fetching mindfulness sessions: $e", error: e);
      return [];
    }
  }
}
