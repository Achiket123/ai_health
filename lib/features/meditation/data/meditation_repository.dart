import 'package:ai_health/features/meditation/data/meditation_item.dart';

class MeditationRepository {
  MeditationRepository();

  // Hardcoded items as requested by user
  List<MeditationItem> _items = [];

  Future<List<MeditationItem>> getItems() async {
    if (_items.isNotEmpty) return _items;

    _items = [
      // --- Beats / Music (isTutorial: false) ---
      MeditationItem(
        id: 'b1',
        title: 'Morning Positive Energy',
        url: 'https://www.youtube.com/watch?v=1ZYbU82GVz4',
        thumbnailUrl: 'https://img.youtube.com/vi/1ZYbU82GVz4/0.jpg',
        isTutorial: false,
        duration: '10:00',
      ),
      MeditationItem(
        id: 'b2',
        title: 'Deep Focus Beats',
        url: 'https://www.youtube.com/watch?v=jfKfPfyJRdk',
        thumbnailUrl: 'https://img.youtube.com/vi/jfKfPfyJRdk/0.jpg',
        isTutorial: false,
        duration: '60:00',
      ),
      MeditationItem(
        id: 'b3',
        title: 'Rain Sounds for Sleep',
        url: 'https://www.youtube.com/watch?v=mPZkdNFkNps',
        thumbnailUrl: 'https://img.youtube.com/vi/mPZkdNFkNps/0.jpg',
        isTutorial: false,
        duration: '120:00',
      ),
      MeditationItem(
        id: 'b4',
        title: 'Tibetan Singing Bowls',
        url: 'https://www.youtube.com/watch?v=Q5dU6serXkg',
        thumbnailUrl: 'https://img.youtube.com/vi/Q5dU6serXkg/0.jpg',
        isTutorial: false,
        duration: '30:00',
      ),
      MeditationItem(
        id: 'b5',
        title: 'Alpha Waves for Creativity',
        url: 'https://www.youtube.com/watch?v=WPni755-Krg',
        thumbnailUrl: 'https://img.youtube.com/vi/WPni755-Krg/0.jpg',
        isTutorial: false,
        duration: '45:00',
      ),
      MeditationItem(
        id: 'b6',
        title: 'Nature Sounds - Forest',
        url: 'https://www.youtube.com/watch?v=xNN7iTA57jM',
        thumbnailUrl: 'https://img.youtube.com/vi/xNN7iTA57jM/0.jpg',
        isTutorial: false,
        duration: '60:00',
      ),
      MeditationItem(
        id: 'b7',
        title: 'LoFi Hip Hop - Study',
        url: 'https://www.youtube.com/watch?v=5qap5aO4i9A',
        thumbnailUrl: 'https://img.youtube.com/vi/5qap5aO4i9A/0.jpg',
        isTutorial: false,
        duration: 'N/A',
      ),
      MeditationItem(
        id: 'b8',
        title: 'Ambient Space Music',
        url: 'https://www.youtube.com/watch?v=w097Q0fEkmc',
        thumbnailUrl: 'https://img.youtube.com/vi/w097Q0fEkmc/0.jpg',
        isTutorial: false,
        duration: '180:00',
      ),
      MeditationItem(
        id: 'b9',
        title: 'Ocean Waves Relaxation',
        url: 'https://www.youtube.com/watch?v=Bnfp402d2jI',
        thumbnailUrl: 'https://img.youtube.com/vi/Bnfp402d2jI/0.jpg',
        isTutorial: false,
        duration: '60:00',
      ),
      MeditationItem(
        id: 'b10',
        title: 'Delta Waves Deep Sleep',
        url: 'https://www.youtube.com/watch?v=1t856417f7I',
        thumbnailUrl: 'https://img.youtube.com/vi/1t856417f7I/0.jpg',
        isTutorial: false,
        duration: '240:00',
      ),

      // --- Tutorials (isTutorial: true) ---
      MeditationItem(
        id: 't1',
        title: 'Beginner Meditation Guide',
        url: 'https://www.youtube.com/watch?v=inpok4MKVLM',
        thumbnailUrl: 'https://img.youtube.com/vi/inpok4MKVLM/0.jpg',
        isTutorial: true,
        duration: '10:00',
      ),
      MeditationItem(
        id: 't2',
        title: 'Breathing Techniques',
        url: 'https://www.youtube.com/watch?v=nM0xDI5R50E',
        thumbnailUrl: 'https://img.youtube.com/vi/nM0xDI5R50E/0.jpg',
        isTutorial: true,
        duration: '05:00',
      ),
      MeditationItem(
        id: 't3',
        title: '10 Minute Mindfulness',
        url: 'https://www.youtube.com/watch?v=ZToicYcHIOU',
        thumbnailUrl: 'https://img.youtube.com/vi/ZToicYcHIOU/0.jpg',
        isTutorial: true,
        duration: '10:00',
      ),
      MeditationItem(
        id: 't4',
        title: 'How to Meditate - Simple',
        url: 'https://www.youtube.com/watch?v=U9YKY7fdwyg',
        thumbnailUrl: 'https://img.youtube.com/vi/U9YKY7fdwyg/0.jpg',
        isTutorial: true,
        duration: '12:00',
      ),
      MeditationItem(
        id: 't5',
        title: 'Guided Sleep Meditation',
        url: 'https://www.youtube.com/watch?v=aEqlQvczMJQ',
        thumbnailUrl: 'https://img.youtube.com/vi/aEqlQvczMJQ/0.jpg',
        isTutorial: true,
        duration: '20:00',
      ),
      MeditationItem(
        id: 't6',
        title: 'Anxiety Relief',
        url: 'https://www.youtube.com/watch?v=O-6f5wQXSu8',
        thumbnailUrl: 'https://img.youtube.com/vi/O-6f5wQXSu8/0.jpg',
        isTutorial: true,
        duration: '15:00',
      ),
      MeditationItem(
        id: 't7',
        title: 'Body Scan Meditation',
        url: 'https://www.youtube.com/watch?v=QS21O1l8d1A',
        thumbnailUrl: 'https://img.youtube.com/vi/QS21O1l8d1A/0.jpg',
        isTutorial: true,
        duration: '30:00',
      ),
      MeditationItem(
        id: 't8',
        title: 'Loving Kindness',
        url: 'https://www.youtube.com/watch?v=sz7cpV7ERsM',
        thumbnailUrl: 'https://img.youtube.com/vi/sz7cpV7ERsM/0.jpg',
        isTutorial: true,
        duration: '18:00',
      ),
      MeditationItem(
        id: 't9',
        title: 'Morning Gratitude',
        url: 'https://www.youtube.com/watch?v=U5lZ9CXBsWQ',
        thumbnailUrl: 'https://img.youtube.com/vi/U5lZ9CXBsWQ/0.jpg',
        isTutorial: true,
        duration: '07:00',
      ),
      MeditationItem(
        id: 't10',
        title: 'Stress Relief Breathing',
        url: 'https://www.youtube.com/watch?v=F28MGLlpP90',
        thumbnailUrl: 'https://img.youtube.com/vi/F28MGLlpP90/0.jpg',
        isTutorial: true,
        duration: '08:00',
      ),
    ];

    return _items;
  }
}
