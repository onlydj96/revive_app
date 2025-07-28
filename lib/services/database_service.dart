import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class DatabaseService {
  static SupabaseClient get _client => SupabaseService.client;

  // Generic CRUD operations
  static Future<List<Map<String, dynamic>>> getAll(String table, {
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from(table).select();
    
    dynamic finalQuery = query;
    
    if (orderBy != null) {
      finalQuery = finalQuery.order(orderBy, ascending: ascending);
    }
    
    if (limit != null) {
      finalQuery = finalQuery.limit(limit);
    }
    
    if (offset != null) {
      finalQuery = finalQuery.range(offset, offset + (limit ?? 100) - 1);
    }
    
    final response = await finalQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getById(String table, String id) async {
    final response = await _client
        .from(table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  static Future<Map<String, dynamic>?> create(String table, Map<String, dynamic> data) async {
    final response = await _client
        .from(table)
        .insert(data)
        .select()
        .single();
    return response;
  }

  static Future<Map<String, dynamic>?> update(String table, String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  static Future<void> delete(String table, String id) async {
    await _client
        .from(table)
        .delete()
        .eq('id', id);
  }

  // User profile operations
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await getById('user_profiles', userId);
  }

  static Future<Map<String, dynamic>?> updateUserProfile(String userId, Map<String, dynamic> data) async {
    return await update('user_profiles', userId, data);
  }

  static Future<Map<String, dynamic>?> updateUserRole(String userId, String role) async {
    return await update('user_profiles', userId, {'role': role});
  }

  // Updates operations
  static Future<List<Map<String, dynamic>>> getUpdates({
    bool? isPinned,
    String? type,
    int? limit,
  }) async {
    var query = _client.from('updates').select();
    
    if (isPinned != null) {
      query = query.eq('is_pinned', isPinned);
    }
    
    if (type != null) {
      query = query.eq('type', type);
    }
    
    var orderedQuery = query.order('created_at', ascending: false);
    
    if (limit != null) {
      orderedQuery = orderedQuery.limit(limit);
    }
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> createUpdate(Map<String, dynamic> data) async {
    // Add current user as author
    final user = SupabaseService.currentUser;
    if (user != null) {
      data['author_id'] = user.id;
      data['author_name'] = user.userMetadata?['full_name'] ?? user.email?.split('@')[0] ?? 'Unknown';
    }
    
    return await create('updates', data);
  }

  // Media items operations
  static Future<List<Map<String, dynamic>>> getMediaItems({
    String? type,
    String? category,
    String? search,
    String? albumId,
    int? limit,
  }) async {
    var query = _client.from('media_items').select();
    
    if (type != null) {
      query = query.eq('type', type);
    }
    
    if (category != null) {
      query = query.eq('category', category);
    }
    
    if (search != null && search.isNotEmpty) {
      query = query.or('title.ilike.%$search%,description.ilike.%$search%');
    }
    
    if (albumId != null) {
      query = query.eq('album_id', albumId);
    }
    
    var orderedQuery = query.order('created_at', ascending: false);
    
    if (limit != null) {
      orderedQuery = orderedQuery.limit(limit);
    }
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> createMediaItem(Map<String, dynamic> data) async {
    // Add current user as uploader
    final user = SupabaseService.currentUser;
    if (user != null) {
      data['uploaded_by'] = user.id;
    }
    
    return await create('media_items', data);
  }

  // Events operations
  static Future<List<Map<String, dynamic>>> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
  }) async {
    var query = _client.from('events').select();
    
    if (startDate != null) {
      query = query.gte('start_time', startDate.toIso8601String());
    }
    
    if (endDate != null) {
      query = query.lte('end_time', endDate.toIso8601String());
    }
    
    if (category != null) {
      query = query.eq('category', category);
    }
    
    var orderedQuery = query.order('start_time', ascending: true);
    
    if (limit != null) {
      orderedQuery = orderedQuery.limit(limit);
    }
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> createEvent(Map<String, dynamic> data) async {
    // Add current user as creator
    final user = SupabaseService.currentUser;
    if (user != null) {
      data['created_by'] = user.id;
    }
    
    return await create('events', data);
  }

  // Teams operations
  static Future<List<Map<String, dynamic>>> getTeams({
    String? type,
    String? category,
    bool? isActive,
    int? limit,
  }) async {
    var query = _client.from('teams').select();
    
    if (type != null) {
      query = query.eq('type', type);
    }
    
    if (category != null) {
      query = query.eq('category', category);
    }
    
    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }
    
    var orderedQuery = query.order('name', ascending: true);
    
    if (limit != null) {
      orderedQuery = orderedQuery.limit(limit);
    }
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  // Sermons operations
  static Future<List<Map<String, dynamic>>> getSermons({
    String? speaker,
    String? series,
    String? search,
    int? limit,
  }) async {
    var query = _client.from('sermons').select();
    
    if (speaker != null) {
      query = query.eq('speaker', speaker);
    }
    
    if (series != null) {
      query = query.eq('series', series);
    }
    
    if (search != null && search.isNotEmpty) {
      query = query.or('title.ilike.%$search%,description.ilike.%$search%');
    }
    
    var orderedQuery = query.order('service_date', ascending: false);
    
    if (limit != null) {
      orderedQuery = orderedQuery.limit(limit);
    }
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> createSermon(Map<String, dynamic> data) async {
    // Add current user as uploader
    final user = SupabaseService.currentUser;
    if (user != null) {
      data['uploaded_by'] = user.id;
    }
    
    return await create('sermons', data);
  }

  // Bulletins operations
  static Future<List<Map<String, dynamic>>> getBulletins({int? limit}) async {
    var query = _client.from('bulletins').select();
    var orderedQuery = query.order('service_date', ascending: false);
    
    if (limit != null) {
      orderedQuery = orderedQuery.limit(limit);
    }
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> createBulletin(Map<String, dynamic> data) async {
    // Add current user as creator
    final user = SupabaseService.currentUser;
    if (user != null) {
      data['created_by'] = user.id;
    }
    
    return await create('bulletins', data);
  }

  // User collections (bookmarks)
  static Future<List<Map<String, dynamic>>> getUserCollections(String userId, {String? type}) async {
    var query = _client.from('user_collections').select().eq('user_id', userId);
    
    if (type != null) {
      query = query.eq('collection_type', type);
    }
    
    var orderedQuery = query.order('created_at', ascending: false);
    
    final response = await orderedQuery;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addToCollection(String userId, String type, String itemId) async {
    await _client.from('user_collections').insert({
      'user_id': userId,
      'collection_type': type,
      'item_id': itemId,
    });
  }

  static Future<void> removeFromCollection(String userId, String type, String itemId) async {
    await _client
        .from('user_collections')
        .delete()
        .eq('user_id', userId)
        .eq('collection_type', type)
        .eq('item_id', itemId);
  }

  // Event registrations
  static Future<void> registerForEvent(String eventId, String userId, String userName, String userEmail) async {
    await _client.from('event_registrations').insert({
      'event_id': eventId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
    });
  }

  static Future<void> cancelEventRegistration(String eventId, String userId) async {
    await _client
        .from('event_registrations')
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  // Team memberships
  static Future<void> joinTeam(String teamId, String userId, String userName) async {
    await _client.from('team_memberships').insert({
      'team_id': teamId,
      'user_id': userId,
      'user_name': userName,
    });
  }

  static Future<void> leaveTeam(String teamId, String userId) async {
    await _client
        .from('team_memberships')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', userId);
  }

  // Real-time subscriptions
  static RealtimeChannel subscribeToTable(String table, void Function(Map<String, dynamic>) onInsert, 
      void Function(Map<String, dynamic>) onUpdate, void Function(Map<String, dynamic>) onDelete) {
    final channel = _client.channel('public:$table');
    
    channel
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: table,
            callback: (payload) => onInsert(payload.newRecord))
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: table,
            callback: (payload) => onUpdate(payload.newRecord))
        .onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: table,
            callback: (payload) => onDelete(payload.oldRecord))
        .subscribe();
    
    return channel;
  }
}