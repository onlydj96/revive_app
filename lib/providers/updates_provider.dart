import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update.dart';

final updatesProvider = StateNotifierProvider<UpdatesNotifier, List<Update>>((ref) {
  return UpdatesNotifier();
});

final pinnedUpdatesProvider = Provider<List<Update>>((ref) {
  final updates = ref.watch(updatesProvider);
  return updates.where((update) => update.isPinned).toList();
});

final recentUpdatesProvider = Provider<List<Update>>((ref) {
  final updates = ref.watch(updatesProvider);
  final now = DateTime.now();
  return updates
      .where((update) => !update.isPinned)
      .where((update) => update.createdAt.isAfter(now.subtract(const Duration(days: 30))))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

class UpdatesNotifier extends StateNotifier<List<Update>> {
  UpdatesNotifier() : super([]) {
    _loadMockUpdates();
  }

  void _loadMockUpdates() {
    final now = DateTime.now();
    state = [
      Update(
        id: '1',
        title: 'Easter Service Times',
        content: 'Join us for our special Easter services on April 7th at 9:00 AM and 11:00 AM. Come celebrate the resurrection of our Lord!',
        type: UpdateType.announcement,
        createdAt: now.subtract(const Duration(hours: 2)),
        author: 'Pastor Mike',
        isPinned: true,
        tags: ['easter', 'service'],
      ),
      Update(
        id: '2',
        title: 'Prayer Request: Johnson Family',
        content: 'Please keep the Johnson family in your prayers as they navigate through this difficult time.',
        type: UpdateType.prayer,
        createdAt: now.subtract(const Duration(hours: 6)),
        author: 'Sarah Wilson',
        tags: ['prayer', 'family'],
      ),
      Update(
        id: '3',
        title: 'New Members Class',
        content: 'Our next new members class will be held on March 25th at 2:00 PM in Room 203. Registration is now open.',
        type: UpdateType.announcement,
        createdAt: now.subtract(const Duration(days: 1)),
        author: 'Admin Team',
        tags: ['membership', 'class'],
      ),
      Update(
        id: '4',
        title: 'Youth Group Fundraiser Success!',
        content: 'Amazing news! Our youth group raised \$2,500 for their mission trip. Thank you to everyone who supported!',
        type: UpdateType.celebration,
        createdAt: now.subtract(const Duration(days: 2)),
        author: 'Youth Pastor Dave',
        tags: ['youth', 'fundraiser', 'mission'],
      ),
      Update(
        id: '5',
        title: 'Building Maintenance Notice',
        content: 'The main parking lot will be closed for maintenance this Saturday from 8 AM to 4 PM. Please use the side entrance.',
        type: UpdateType.announcement,
        createdAt: now.subtract(const Duration(days: 3)),
        author: 'Facilities Team',
        isPinned: true,
        tags: ['maintenance', 'parking'],
      ),
    ];
  }

  void addUpdate(Update update) {
    state = [update, ...state];
  }

  void updateUpdate(Update updatedUpdate) {
    state = state.map((update) {
      return update.id == updatedUpdate.id ? updatedUpdate : update;
    }).toList();
  }

  void deleteUpdate(String updateId) {
    state = state.where((update) => update.id != updateId).toList();
  }

  void togglePin(String updateId) {
    state = state.map((update) {
      if (update.id == updateId) {
        return update.copyWith(isPinned: !update.isPinned);
      }
      return update;
    }).toList();
  }
}