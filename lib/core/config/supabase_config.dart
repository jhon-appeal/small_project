import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://qiacdnrjqbiyfzyrvrnl.supabase.co';
  static const String anonKey = 'sb_publishable_MSBWxTQbhAt7Xs_xNu1M9Q_Av7fBSvS';

  // Helper to get Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}

