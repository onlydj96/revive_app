class SupabaseConfig {
  static const String url = 'https://goetblgcpplhbmbuttyv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvZXRibGdjcHBsaGJtYnV0dHl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDIzMTYsImV4cCI6MjA2OTExODMxNn0.ByhsFrbrjFeQj1LvSmHhTtOMuwGpHHvjW81Ea9ZMeTM';

  // For development purposes, you can use these placeholder values
  // Replace with your actual Supabase project URL and anon key
  static const String devUrl = 'https://goetblgcpplhbmbuttyv.supabase.co';
  static const String devAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdvZXRibGdjcHBsaGJtYnV0dHl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM1NDIzMTYsImV4cCI6MjA2OTExODMxNn0.ByhsFrbrjFeQj1LvSmHhTtOMuwGpHHvjW81Ea9ZMeTM';

  // Use development values for now
  static String get projectUrl => devUrl;
  static String get projectAnonKey => devAnonKey;
}
