import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bulletin.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

// Provider for all bulletins
// PERF: StateNotifierProvider automatically keeps alive
final bulletinsProvider =
    StateNotifierProvider<BulletinsNotifier, AsyncValue<List<Bulletin>>>((ref) {
  return BulletinsNotifier();
});

// Provider for current week's bulletin
// PERF: AutoDispose disabled to cache bulletin data across page transitions
final bulletinProvider = Provider<Bulletin?>((ref) {
  final bulletinsAsync = ref.watch(bulletinsProvider);

  return bulletinsAsync.when(
    data: (bulletins) {
      final now = DateTime.now();
      try {
        return bulletins.firstWhere(
          (b) {
            final weekStart = b.weekOf;
            final weekEnd = weekStart.add(const Duration(days: 6));
            return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                now.isBefore(weekEnd.add(const Duration(days: 1)));
          },
        );
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for bulletin by ID
final bulletinByIdProvider = Provider.family<Bulletin?, String>((ref, id) {
  final bulletinsAsync = ref.watch(bulletinsProvider);

  return bulletinsAsync.when(
    data: (bulletins) {
      try {
        return bulletins.firstWhere((b) => b.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for bulletins by year
final bulletinsByYearProvider =
    Provider.family<List<Bulletin>, int>((ref, year) {
  final bulletinsAsync = ref.watch(bulletinsProvider);

  return bulletinsAsync.when(
    data: (bulletins) {
      return bulletins.where((b) => b.weekOf.year == year).toList()
        ..sort((a, b) => b.weekOf.compareTo(a.weekOf)); // Most recent first
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class BulletinsNotifier extends StateNotifier<AsyncValue<List<Bulletin>>> {
  final _logger = Logger('BulletinsNotifier');

  BulletinsNotifier() : super(const AsyncValue.loading()) {
    _loadBulletins();
    _setupRealtimeSubscription();
  }

  RealtimeChannel? _channel;

  Future<void> _loadBulletins() async {
    try {
      _logger.debug('Loading bulletins...');
      state = const AsyncValue.loading();

      // Load bulletins from Supabase
      final bulletinData = await SupabaseService.getAll(
        'bulletins',
        orderBy: 'week_of',
        ascending: false,
      );
      _logger.debug('Loaded ${bulletinData.length} bulletins from database');

      // Load all bulletins with their items and schedules
      final bulletins = await Future.wait(
        bulletinData.map((data) async {
          final bulletinId = data['id'] as String;

          // Load bulletin items
          final itemsData = await SupabaseService.client
              .from('bulletin_items')
              .select()
              .eq('bulletin_id', bulletinId)
              .order('display_order');

          final items = (itemsData as List)
              .map((item) => BulletinItem.fromJson(item))
              .toList();

          // Load worship schedule items
          final scheduleData = await SupabaseService.client
              .from('worship_schedule_items')
              .select()
              .eq('bulletin_id', bulletinId)
              .order('display_order');

          final schedule = (scheduleData as List)
              .map((item) => WorshipScheduleItem.fromJson(item))
              .toList();

          return Bulletin.fromJson(
            data,
            items: items,
            schedule: schedule,
          );
        }),
      );

      _logger.debug('Successfully loaded ${bulletins.length} bulletins with items and schedules');
      state = AsyncValue.data(bulletins);
    } catch (error, stackTrace) {
      _logger.error('Error loading bulletins', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    _channel = SupabaseService.subscribeToTable(
      'bulletins',
      (newRecord) {
        // Handle insert - reload to get items and schedule
        _loadBulletins();
      },
      (updatedRecord) {
        // Handle update - reload to get latest data
        _loadBulletins();
      },
      (deletedRecord) {
        // Handle delete
        final deletedId = deletedRecord['id'] as String;
        state.whenData((bulletins) {
          state = AsyncValue.data(
            bulletins.where((b) => b.id != deletedId).toList(),
          );
        });
      },
    );
  }

  Future<void> createBulletin({
    required DateTime weekOf,
    required String theme,
    String? bannerImageUrl,
    required List<BulletinItem> items,
    required List<WorshipScheduleItem> schedule,
  }) async {
    try {
      // Create bulletin
      final bulletinData = {
        'week_of': weekOf.toIso8601String(),
        'theme': theme,
        'banner_image_url': bannerImageUrl,
        'title': theme, // For backward compatibility
      };

      final createdBulletin = await SupabaseService.create('bulletins', bulletinData);
      final bulletinId = (createdBulletin?['id'] ?? '') as String;

      // Create bulletin items
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        await SupabaseService.client.from('bulletin_items').insert({
          'bulletin_id': bulletinId,
          'title': item.title,
          'content': item.content,
          'display_order': i,
        });
      }

      // Create worship schedule items
      for (var i = 0; i < schedule.length; i++) {
        final scheduleItem = schedule[i];
        await SupabaseService.client.from('worship_schedule_items').insert({
          'bulletin_id': bulletinId,
          'time': scheduleItem.time,
          'activity': scheduleItem.activity,
          'leader': scheduleItem.leader,
          'display_order': i,
          'linked_bulletin_item_id': scheduleItem.linkedBulletinItemId,
        });
      }

      // Reload bulletins
      await _loadBulletins();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateBulletin({
    required String bulletinId,
    DateTime? weekOf,
    String? theme,
    String? bannerImageUrl,
    List<BulletinItem>? items,
    List<WorshipScheduleItem>? schedule,
  }) async {
    try {
      // Update bulletin
      final bulletinData = <String, dynamic>{};
      if (weekOf != null) bulletinData['week_of'] = weekOf.toIso8601String();
      if (theme != null) {
        bulletinData['theme'] = theme;
        bulletinData['title'] = theme; // For backward compatibility
      }
      if (bannerImageUrl != null) {
        bulletinData['banner_image_url'] = bannerImageUrl;
      }

      if (bulletinData.isNotEmpty) {
        await SupabaseService.update('bulletins', bulletinId, bulletinData);
      }

      // Update bulletin items if provided
      if (items != null) {
        // Delete existing items
        await SupabaseService.client
            .from('bulletin_items')
            .delete()
            .eq('bulletin_id', bulletinId);

        // Insert new items
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          await SupabaseService.client.from('bulletin_items').insert({
            'bulletin_id': bulletinId,
            'title': item.title,
            'content': item.content,
            'display_order': i,
          });
        }
      }

      // Update worship schedule items if provided
      if (schedule != null) {
        // Delete existing schedule items
        await SupabaseService.client
            .from('worship_schedule_items')
            .delete()
            .eq('bulletin_id', bulletinId);

        // Insert new schedule items
        for (var i = 0; i < schedule.length; i++) {
          final scheduleItem = schedule[i];
          await SupabaseService.client.from('worship_schedule_items').insert({
            'bulletin_id': bulletinId,
            'time': scheduleItem.time,
            'activity': scheduleItem.activity,
            'leader': scheduleItem.leader,
            'display_order': i,
            'linked_bulletin_item_id': scheduleItem.linkedBulletinItemId,
          });
        }
      }

      // Reload bulletins
      await _loadBulletins();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteBulletin(String bulletinId) async {
    try {
      await SupabaseService.delete('bulletins', bulletinId);
      // Items and schedule will be cascade deleted by database

      state.whenData((bulletins) {
        state = AsyncValue.data(
          bulletins.where((b) => b.id != bulletinId).toList(),
        );
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    await _loadBulletins();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
