import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bulletin.dart';

// Provider for all bulletins
final bulletinsProvider =
    StateNotifierProvider<BulletinsNotifier, List<Bulletin>>((ref) {
  return BulletinsNotifier();
});

// Provider for current week's bulletin
final bulletinProvider = Provider<Bulletin?>((ref) {
  final bulletins = ref.watch(bulletinsProvider);
  final now = DateTime.now();

  // Find bulletin for current week
  return bulletins.cast<Bulletin?>().firstWhere(
    (b) {
      if (b == null) return false;
      final weekStart = b.weekOf;
      final weekEnd = weekStart.add(const Duration(days: 6));
      return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          now.isBefore(weekEnd.add(const Duration(days: 1)));
    },
    orElse: () => null,
  );
});

// Provider for bulletin by ID
final bulletinByIdProvider = Provider.family<Bulletin?, String>((ref, id) {
  final bulletins = ref.watch(bulletinsProvider);
  try {
    return bulletins.firstWhere((b) => b.id == id);
  } catch (e) {
    return null;
  }
});

// Provider for bulletins by year
final bulletinsByYearProvider =
    Provider.family<List<Bulletin>, int>((ref, year) {
  final bulletins = ref.watch(bulletinsProvider);
  return bulletins.where((b) => b.weekOf.year == year).toList()
    ..sort((a, b) => b.weekOf.compareTo(a.weekOf)); // Most recent first
});

class BulletinsNotifier extends StateNotifier<List<Bulletin>> {
  BulletinsNotifier() : super([]) {
    _loadBulletins();
  }

  void _loadBulletins() {
    // Generate bulletins for all Sundays in 2025
    final bulletins = <Bulletin>[];
    final year2025Start = DateTime(2025, 1, 1);

    // Find first Sunday of 2025
    DateTime currentDate = year2025Start;
    while (currentDate.weekday != DateTime.sunday) {
      currentDate = currentDate.add(const Duration(days: 1));
    }

    int bulletinNumber = 1;

    // Generate bulletins for each Sunday in 2025
    while (currentDate.year == 2025) {
      bulletins.add(_generateSampleBulletin(currentDate, bulletinNumber));
      currentDate = currentDate.add(const Duration(days: 7)); // Next Sunday
      bulletinNumber++;
    }

    state = bulletins;
  }

  Bulletin _generateSampleBulletin(DateTime weekOf, int number) {
    final themes = [
      'Walking in Faith',
      'God\'s Unfailing Love',
      'The Power of Prayer',
      'Living in Grace',
      'Hope and Renewal',
      'Faithful Stewardship',
      'The Good Shepherd',
      'Light of the World',
      'Serving with Joy',
      'God\'s Amazing Grace',
    ];

    final sermonLeaders = ['Sai', 'Serah', 'Doug', 'Hans'];
    final praiseLeaders = ['Luke', 'Hans'];

    final theme = themes[number % themes.length];
    final sermonLeader = sermonLeaders[number % sermonLeaders.length];
    final praiseLeader = praiseLeaders[number % praiseLeaders.length];
    final weekOfFormatted = '${weekOf.month}/${weekOf.day}/${weekOf.year}';

    return Bulletin(
      id: 'bulletin_$number',
      weekOf: weekOf,
      theme: theme,
      bannerImageUrl:
          number % 3 == 0 ? 'https://example.com/bulletin_banner.jpg' : null,
      schedule: [
        WorshipScheduleItem(
          time: '3:30 PM',
          activity: 'Pray Together',
          leader: null,
        ),
        WorshipScheduleItem(
          time: '3:45 - 4:15 PM',
          activity: 'Praise & Worship',
          leader: praiseLeader,
        ),
        WorshipScheduleItem(
          time: '4:15 - 4:30 PM',
          activity: 'Break Time & Small Talk',
          leader: null,
        ),
        WorshipScheduleItem(
          time: '4:30 - 5:00 PM',
          activity: 'Sermon',
          leader: sermonLeader,
        ),
        WorshipScheduleItem(
          time: '5:00 - 5:10 PM',
          activity: 'Announcements',
          leader: null,
        ),
        WorshipScheduleItem(
          time: '5:10 PM',
          activity: 'Closing',
          leader: null,
        ),
      ],
      items: [
        BulletinItem(
          id: '${number}_1',
          title: 'Welcome',
          content:
              'Welcome to Revive Church! We\'re so glad you\'re here with us this week of $weekOfFormatted.',
          order: 1,
        ),
        BulletinItem(
          id: '${number}_2',
          title: 'This Week\'s Message',
          content:
              '$sermonLeader will be sharing about "$theme" and how it applies to our daily walk with Christ.',
          order: 2,
        ),
        BulletinItem(
          id: '${number}_3',
          title: 'Upcoming Events',
          content:
              '• Bible Study - Tuesday 7:00 PM\n• Youth Group - Friday 6:30 PM\n• Women\'s Ministry - Saturday 10:00 AM',
          order: 3,
        ),
        BulletinItem(
          id: '${number}_4',
          title: 'Prayer Requests',
          content:
              'Please keep our church family in your prayers. If you have a prayer request, please share it with our pastoral team.',
          order: 4,
        ),
        BulletinItem(
          id: '${number}_5',
          title: 'Announcements',
          content:
              'Thank you for being part of our church community. Your presence makes a difference!',
          order: 5,
        ),
      ],
    );
  }

  void addBulletin(Bulletin bulletin) {
    state = [...state, bulletin];
  }

  void updateBulletin(Bulletin updatedBulletin) {
    state = [
      for (final bulletin in state)
        if (bulletin.id == updatedBulletin.id) updatedBulletin else bulletin,
    ];
  }

  void deleteBulletin(String bulletinId) {
    state = state.where((b) => b.id != bulletinId).toList();
  }

  void addBulletinItem(String bulletinId, BulletinItem item) {
    state = [
      for (final bulletin in state)
        if (bulletin.id == bulletinId)
          bulletin.copyWith(items: [...bulletin.items, item])
        else
          bulletin,
    ];
  }

  void updateBulletinItem(String bulletinId, BulletinItem updatedItem) {
    state = [
      for (final bulletin in state)
        if (bulletin.id == bulletinId)
          bulletin.copyWith(
            items: [
              for (final item in bulletin.items)
                if (item.id == updatedItem.id) updatedItem else item,
            ],
          )
        else
          bulletin,
    ];
  }

  void deleteBulletinItem(String bulletinId, String itemId) {
    state = [
      for (final bulletin in state)
        if (bulletin.id == bulletinId)
          bulletin.copyWith(
            items: bulletin.items.where((item) => item.id != itemId).toList(),
          )
        else
          bulletin,
    ];
  }
}
