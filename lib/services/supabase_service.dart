import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.projectUrl,
      anonKey: SupabaseConfig.projectAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      debug: true, // Enable debug mode to see auth flow
    );
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
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
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