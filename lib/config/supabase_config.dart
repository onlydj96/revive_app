class SupabaseConfig {
  // =============================================
  // IMPORTANT: Update these with your new Supabase project credentials
  // Get from: https://supabase.com/dashboard/project/izpyshqmtewizuutcnwl/settings/api
  // =============================================

  // Project ID: izpyshqmtewizuutcnwl
  static const String url = 'https://izpyshqmtewizuutcnwl.supabase.co';

  // Anon public key from Supabase Dashboard
  // Path: Project Settings → API → Project API keys → anon public
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6cHlzaHFtdGV3aXp1dXRjbndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MTY1ODIsImV4cCI6MjA3OTA5MjU4Mn0.5WfvjSkvh1sn1cAW9LolKV3bA_9MK3X3ITPCP3d5KL0';

  // Development configuration
  static const String devUrl = 'https://izpyshqmtewizuutcnwl.supabase.co';
  static const String devAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml6cHlzaHFtdGV3aXp1dXRjbndsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MTY1ODIsImV4cCI6MjA3OTA5MjU4Mn0.5WfvjSkvh1sn1cAW9LolKV3bA_9MK3X3ITPCP3d5KL0';

  // Active configuration
  static String get projectUrl => devUrl;
  static String get projectAnonKey => devAnonKey;
}
