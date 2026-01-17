import 'package:health_connector/health_connector_internal.dart';


extension MindfulnessSessionTypeExtension on MindfulnessSessionType {
  
  String get displayName {
    return switch (this) {
      MindfulnessSessionType.meditation => 'Meditation',
      MindfulnessSessionType.breathing => 'Breathing',
      MindfulnessSessionType.unknown => 'Unknown',
      MindfulnessSessionType.music => 'Music',
      MindfulnessSessionType.movement => 'Movement',
      MindfulnessSessionType.unguided => 'Unguided',
    };
  }
}
