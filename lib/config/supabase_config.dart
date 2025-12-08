import 'package:flutter_dotenv/flutter_dotenv.dart';

// FIXED P0-5: Moved Supabase credentials to environment variables
// Create a .env file based on .env.example and fill in your credentials
class SupabaseConfig {
  // =============================================
  // SECURITY: Credentials are now loaded from .env file
  // Copy .env.example to .env and fill in your actual values
  // Get from: https://supabase.com/dashboard/project/YOUR_PROJECT_ID/settings/api
  // =============================================

  static String get projectUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception(
        'SUPABASE_URL not found in .env file. '
        'Copy .env.example to .env and configure your credentials.',
      );
    }
    return url;
  }

  static String get projectAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY not found in .env file. '
        'Copy .env.example to .env and configure your credentials.',
      );
    }
    return key;
  }
}
