import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      print('🚀 [SUPABASE] Starting initialization...');
      print('   URL: ${SupabaseConfig.projectUrl}');
      print('   Anon Key: ${SupabaseConfig.projectAnonKey.substring(0, 20)}...');

      await Supabase.initialize(
        url: SupabaseConfig.projectUrl,
        anonKey: SupabaseConfig.projectAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        debug: kDebugMode,
      );

      print('✅ [SUPABASE] Initialization successful');

      // Clear invalid session if session recovery fails
      // This handles cases where the project was paused or tokens expired
      try {
        final session = client.auth.currentSession;
        if (session != null) {
          print('🔄 [SUPABASE] Found existing session, attempting refresh...');
          // Try to refresh the session to verify it's still valid
          await client.auth.refreshSession();
          print('✅ [SUPABASE] Session refresh successful');
        } else {
          print('ℹ️  [SUPABASE] No existing session found');
        }
      } on AuthException catch (e) {
        // Auth-specific errors should clear the session
        print('⚠️  [SUPABASE] Auth error during session refresh: ${e.message}');
        print('   Status: ${e.statusCode}');

        // Clear session only for auth-related errors (401, 403, invalid token, etc.)
        if (e.statusCode == '401' ||
            e.statusCode == '403' ||
            e.message.toLowerCase().contains('invalid') ||
            e.message.toLowerCase().contains('expired')) {
          await client.auth.signOut();
          print('🔄 [SUPABASE] Invalid session cleared');
        } else {
          // Other auth errors: log but keep session (might be temporary)
          print('⚠️  [SUPABASE] Session refresh failed but keeping session for retry');
        }
      } catch (e) {
        // Non-auth errors (network, timeout, etc.) should not clear session
        print('⚠️  [SUPABASE] Network/system error during refresh: $e');
        print('   Keeping session for retry when network recovers');
      }
    } catch (e, stackTrace) {
      print('❌ [SUPABASE] Initialization FAILED');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static bool get isLoggedIn => currentSession != null;

  // Auth methods
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔗 [SUPABASE] Attempting connection to: ${SupabaseConfig.projectUrl}');
      print('🔑 [SUPABASE] Using anon key: ${SupabaseConfig.projectAnonKey.substring(0, 20)}...');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ [SUPABASE] Sign in request completed');
      return response;
    } catch (e) {
      print('❌ [SUPABASE] Sign in error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
      emailRedirectTo: 'ezer://auth-callback',
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // === DATABASE OPERATIONS (Consolidated from DatabaseService) ===

  // Generic CRUD operations
  static Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
    bool excludeSoftDeleted = false,
  }) async {
    dynamic query = client.from(table).select();

    if (excludeSoftDeleted) {
      query = query.isFilter('deleted_at', null);
    }

    if (orderBy != null) {
      query = query.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (offset != null) {
      query = query.range(offset, offset + (limit ?? 100) - 1);
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getById(String table, String id) async {
    final response =
        await client.from(table).select().eq('id', id).maybeSingle();
    return response;
  }

  static Future<Map<String, dynamic>?> create(
      String table, Map<String, dynamic> data) async {
    // Add audit fields if user is logged in
    if (currentUser != null) {
      data['created_by'] ??= currentUser!.id;
      data['updated_by'] = currentUser!.id;
    }

    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  static Future<Map<String, dynamic>?> update(
      String table, String id, Map<String, dynamic> data) async {
    // Add audit fields
    if (currentUser != null) {
      data['updated_by'] = currentUser!.id;
    }

    // Check if record exists first
    final existing =
        await client.from(table).select('id').eq('id', id).maybeSingle();

    if (existing == null) {
      throw Exception('Record with id $id not found in table $table');
    }

    // Perform update
    await client.from(table).update(data).eq('id', id);

    // Return updated record
    final response = await client.from(table).select().eq('id', id).single();

    return response;
  }

  static Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  static Future<void> softDelete(String table, String id) async {
    await update(table, id, {'deleted_at': DateTime.now().toIso8601String()});
  }

  // Real-time subscriptions
  static RealtimeChannel subscribeToTable(
      String table,
      void Function(Map<String, dynamic>) onInsert,
      void Function(Map<String, dynamic>) onUpdate,
      void Function(Map<String, dynamic>) onDelete) {
    final channel = client.channel('public:$table');

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

  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Real-time subscription helper
  static RealtimeChannel createChannel(String channelName) {
    return client.channel(channelName);
  }

  // Database helpers
  static SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  // Storage helpers
  static SupabaseStorageClient get storage => client.storage;
}
