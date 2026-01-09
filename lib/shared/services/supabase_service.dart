import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => SupabaseConfig.client;

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}

