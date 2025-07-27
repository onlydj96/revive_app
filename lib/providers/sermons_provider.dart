import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sermon.dart';

final sermonsProvider = StateNotifierProvider<SermonsNotifier, List<Sermon>>((ref) {
  return SermonsNotifier();
});

final latestSermonProvider = Provider<Sermon?>((ref) {
  final sermons = ref.watch(sermonsProvider);
  if (sermons.isEmpty) return null;
  
  final sortedSermons = [...sermons]..sort((a, b) => b.date.compareTo(a.date));
  return sortedSermons.first;
});

class SermonsNotifier extends StateNotifier<List<Sermon>> {
  SermonsNotifier() : super([]) {
    _loadMockSermons();
  }

  void _loadMockSermons() {
    final now = DateTime.now();
    state = [
      Sermon(
        id: '1',
        title: 'Walking by Faith, Not by Sight',
        speaker: 'Pastor Mike',
        date: now.subtract(const Duration(days: 7)),
        audioUrl: 'https://example.com/sermon1.mp3',
        videoUrl: 'https://example.com/sermon1.mp4',
        transcript: 'Today we explore what it means to walk by faith...',
        thumbnailUrl: 'https://example.com/sermon1_thumb.jpg',
        tags: ['faith', 'trust', 'Christian living'],
        series: 'Faith Series',
        biblePassage: '2 Corinthians 5:7',
      ),
      Sermon(
        id: '2',
        title: 'The Power of Prayer',
        speaker: 'Pastor Mike',
        date: now.subtract(const Duration(days: 14)),
        audioUrl: 'https://example.com/sermon2.mp3',
        videoUrl: 'https://example.com/sermon2.mp4',
        thumbnailUrl: 'https://example.com/sermon2_thumb.jpg',
        tags: ['prayer', 'spiritual discipline'],
        series: 'Spiritual Disciplines',
        biblePassage: 'Matthew 6:9-13',
      ),
      Sermon(
        id: '3',
        title: 'Love Your Neighbor',
        speaker: 'Guest Speaker Sarah',
        date: now.subtract(const Duration(days: 21)),
        audioUrl: 'https://example.com/sermon3.mp3',
        thumbnailUrl: 'https://example.com/sermon3_thumb.jpg',
        tags: ['love', 'community', 'service'],
        series: 'Love Series',
        biblePassage: 'Mark 12:31',
      ),
    ];
  }

  void addSermon(Sermon sermon) {
    state = [...state, sermon];
  }

  void updateSermon(Sermon updatedSermon) {
    state = state.map((sermon) {
      return sermon.id == updatedSermon.id ? updatedSermon : sermon;
    }).toList();
  }

  void deleteSermon(String sermonId) {
    state = state.where((sermon) => sermon.id != sermonId).toList();
  }
}