import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bulletin.dart';

final bulletinProvider = StateNotifierProvider<BulletinNotifier, Bulletin?>((ref) {
  return BulletinNotifier();
});

class BulletinNotifier extends StateNotifier<Bulletin?> {
  BulletinNotifier() : super(null) {
    _loadCurrentBulletin();
  }

  void _loadCurrentBulletin() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    state = Bulletin(
      id: '1',
      weekOf: startOfWeek,
      theme: 'Walking in Faith',
      bannerImageUrl: 'https://example.com/bulletin_banner.jpg',
      items: [
        BulletinItem(
          id: '1',
          title: 'Welcome',
          content: 'Welcome to Revive Church! We\'re glad you\'re here.',
          order: 1,
        ),
        BulletinItem(
          id: '2',
          title: 'This Week\'s Message',
          content: 'Pastor Mike will be sharing about "Walking by Faith, Not by Sight" from 2 Corinthians 5:7.',
          order: 2,
        ),
        BulletinItem(
          id: '3',
          title: 'Upcoming Events',
          content: '• Bible Study - Tuesday 7:00 PM\n• Youth Group - Friday 6:30 PM\n• Easter Service - April 7th',
          order: 3,
        ),
        BulletinItem(
          id: '4',
          title: 'Prayer Requests',
          content: 'Please keep the Johnson family in your prayers during this difficult time.',
          order: 4,
        ),
        BulletinItem(
          id: '5',
          title: 'Announcements',
          content: 'New Members Class starts March 25th. Sign up at the welcome desk!',
          order: 5,
        ),
      ],
    );
  }

  void updateBulletin(Bulletin bulletin) {
    state = bulletin;
  }

  void addBulletinItem(BulletinItem item) {
    if (state != null) {
      final newItems = [...state!.items, item];
      state = state!.copyWith(items: newItems);
    }
  }

  void updateBulletinItem(BulletinItem updatedItem) {
    if (state != null) {
      final newItems = state!.items.map((item) {
        return item.id == updatedItem.id ? updatedItem : item;
      }).toList();
      state = state!.copyWith(items: newItems);
    }
  }

  void deleteBulletinItem(String itemId) {
    if (state != null) {
      final newItems = state!.items.where((item) => item.id != itemId).toList();
      state = state!.copyWith(items: newItems);
    }
  }
}