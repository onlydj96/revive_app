// This file is deprecated. Use SupabaseService instead.
// Keeping for backward compatibility during migration.

import 'supabase_service.dart';

@Deprecated(
    'Use SupabaseService instead. This will be removed in a future version.')
class DatabaseService {
  // Delegate all calls to the new unified SupabaseService

  // Generic CRUD operations
  static Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
    bool excludeSoftDeleted = false,
  }) async {
    return SupabaseService.getAll(
      table,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      excludeSoftDeleted: excludeSoftDeleted,
    );
  }

  static Future<Map<String, dynamic>?> getById(String table, String id) async {
    return SupabaseService.getById(table, id);
  }

  static Future<Map<String, dynamic>?> create(
      String table, Map<String, dynamic> data) async {
    return SupabaseService.create(table, data);
  }

  static Future<Map<String, dynamic>?> update(
      String table, String id, Map<String, dynamic> data) async {
    return SupabaseService.update(table, id, data);
  }

  static Future<void> delete(String table, String id) async {
    return SupabaseService.delete(table, id);
  }

  // User profile operations
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return getById('user_profiles', userId);
  }

  static Future<Map<String, dynamic>?> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    return update('user_profiles', userId, data);
  }

  static Future<Map<String, dynamic>?> updateUserRole(
      String userId, String role) async {
    return update('user_profiles', userId, {'role': role});
  }

  // Simplified operations - use SupabaseService directly for complex queries
  static Future<List<Map<String, dynamic>>> getUpdates({
    bool? isPinned,
    String? type,
    int? limit,
  }) async {
    return SupabaseService.getAll('updates',
        orderBy: 'created_at', ascending: false, limit: limit);
  }

  static Future<Map<String, dynamic>?> createUpdate(
      Map<String, dynamic> data) async {
    return SupabaseService.create('updates', data);
  }

  static Future<List<Map<String, dynamic>>> getMediaItems({
    String? type,
    String? category,
    String? search,
    String? albumId,
    String? folderId,
    int? limit,
    bool excludeSoftDeleted = true,
  }) async {
    return SupabaseService.getAll('media_items',
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        excludeSoftDeleted: excludeSoftDeleted);
  }

  static Future<Map<String, dynamic>?> createMediaItem(
      Map<String, dynamic> data) async {
    return SupabaseService.create('media_items', data);
  }

  static Future<List<Map<String, dynamic>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
  }) async {
    return SupabaseService.getAll('events',
        orderBy: 'start_time', ascending: true, limit: limit);
  }

  static Future<Map<String, dynamic>?> createEvent(
      Map<String, dynamic> data) async {
    return SupabaseService.create('events', data);
  }

  static Future<List<Map<String, dynamic>>> getTeams({
    String? type,
    String? category,
    bool? isActive,
    int? limit,
  }) async {
    return SupabaseService.getAll('teams',
        orderBy: 'name', ascending: true, limit: limit);
  }

  static Future<List<Map<String, dynamic>>> getSermons({
    String? speaker,
    String? series,
    String? search,
    int? limit,
  }) async {
    return SupabaseService.getAll('sermons',
        orderBy: 'service_date', ascending: false, limit: limit);
  }

  static Future<Map<String, dynamic>?> createSermon(
      Map<String, dynamic> data) async {
    return SupabaseService.create('sermons', data);
  }

  static Future<List<Map<String, dynamic>>> getBulletins({int? limit}) async {
    return SupabaseService.getAll('bulletins',
        orderBy: 'service_date', ascending: false, limit: limit);
  }

  static Future<Map<String, dynamic>?> createBulletin(
      Map<String, dynamic> data) async {
    return SupabaseService.create('bulletins', data);
  }

  // User collections (bookmarks)
  static Future<List<Map<String, dynamic>>> getUserCollections(String userId,
      {String? type}) async {
    return SupabaseService.getAll('user_collections',
        orderBy: 'created_at', ascending: false);
  }

  static Future<void> addToCollection(
      String userId, String type, String itemId) async {
    await SupabaseService.create('user_collections', {
      'user_id': userId,
      'collection_type': type,
      'item_id': itemId,
    });
  }

  static Future<void> removeFromCollection(
      String userId, String type, String itemId) async {
    // For delete operations with complex conditions, use SupabaseService.client directly
    await SupabaseService.client
        .from('user_collections')
        .delete()
        .eq('user_id', userId)
        .eq('collection_type', type)
        .eq('item_id', itemId);
  }

  // Event registrations
  static Future<void> registerForEvent(
      String eventId, String userId, String userName, String userEmail) async {
    await SupabaseService.create('event_registrations', {
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
    });
  }

  static Future<void> cancelEventRegistration(
      String eventId, String userId) async {
    await SupabaseService.client
        .from('event_registrations')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  // Team memberships
  static Future<void> joinTeam(
      String teamId, String userId, String userName) async {
    await SupabaseService.create('team_memberships', {
      'team_id': teamId,
      'user_id': userId,
      'user_name': userName,
    });
  }

  static Future<void> leaveTeam(String teamId, String userId) async {
    await SupabaseService.client
        .from('team_memberships')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', userId);
  }

  // Generic query method - delegate to SupabaseService
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    // For complex queries, use SupabaseService.getAll with basic parameters
    return SupabaseService.getAll(table,
        orderBy: orderBy, ascending: ascending, limit: limit);
  }

  // Real-time subscriptions - delegate to SupabaseService
  static subscribeToTable(
      String table,
      void Function(Map<String, dynamic>) onInsert,
      void Function(Map<String, dynamic>) onUpdate,
      void Function(Map<String, dynamic>) onDelete) {
    return SupabaseService.subscribeToTable(
        table, onInsert, onUpdate, onDelete);
  }
}
