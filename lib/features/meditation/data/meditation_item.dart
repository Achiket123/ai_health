class MeditationItem {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final bool isTutorial;
  final String? duration;

  MeditationItem({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.isTutorial,
    this.duration,
  });

  MeditationItem copyWith({
    String? id,
    String? title,
    String? url,
    String? thumbnailUrl,
    bool? isTutorial,
    String? duration,
  }) {
    return MeditationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isTutorial: isTutorial ?? this.isTutorial,
      duration: duration ?? this.duration,
    );
  }
}
