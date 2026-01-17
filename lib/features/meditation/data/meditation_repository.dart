import 'package:health_connector/health_connector.dart';
import 'package:health_connector/health_connector_internal.dart';
import 'package:ai_health/features/meditation/data/meditation_item.dart';

class MeditationRepository {
  final HealthConnector _healthConnector;

  MeditationRepository({required HealthConnector healthConnector})
    : _healthConnector = healthConnector;

  Future<List<MeditationItem>> getItems() async {
    // Return dummy data for content
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

  Future<void> saveMeditationSession(
    DateTime startTime,
    DateTime endTime,
    String title,
    MindfulnessSessionType sessionType,
  ) async {
    try {
      final record = MindfulnessSessionRecord(
        sessionType: sessionType,
        startTime: startTime,
        endTime: endTime,
        metadata: Metadata.manualEntry(),
        notes: title,
        title: title,
      );
      await _healthConnector.writeRecords([record]);
    } catch (e) {
      throw Exception('Failed to save meditation session: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMeditationHistory() async {
    try {
      final now = DateTime.now();
      final startTime = now.subtract(const Duration(days: 30));

      final response = await _healthConnector.readRecords(
        ReadRecordsInTimeRangeRequest(
          dataType: HealthDataType.mindfulnessSession,
          startTime: startTime,
          endTime: now,
        ),
      );

      final records = response.records
          .whereType<MindfulnessSessionRecord>()
          .toList();
      records.sort((a, b) => b.startTime.compareTo(a.startTime));

      return records
          .map(
            (r) => {
              'startTime': r.startTime,
              'endTime': r.endTime,
              'title': r.title ?? 'Meditation',
              'durationMinutes': r.endTime.difference(r.startTime).inMinutes,
            },
          )
          .toList();
    } catch (e) {
      print('Failed to fetch meditation history: $e');
      return [];
    }
  }
}
