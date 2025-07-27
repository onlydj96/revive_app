import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final authState = ref.watch(authProvider);
  return UserNotifier(authState.user);
});

class UserNotifier extends StateNotifier<User?> {
  final supabase.User? _supabaseUser;

  UserNotifier(this._supabaseUser) : super(null) {
    _loadUserFromSupabase();
  }

  void _loadUserFromSupabase() {
    if (_supabaseUser != null) {
      final metadata = _supabaseUser!.userMetadata ?? {};
      
      state = User(
        id: _supabaseUser!.id,
        name: metadata['full_name'] ?? _supabaseUser!.email?.split('@')[0] ?? 'User',
        email: _supabaseUser!.email ?? '',
        profileImageUrl: metadata['avatar_url'],
        role: metadata['role'] ?? 'Member',
        joinDate: DateTime.parse(_supabaseUser!.createdAt),
      );
    } else {
      state = null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    if (state != null && _supabaseUser != null) {
      try {
        // Update Supabase user metadata
        await SupabaseService.client.auth.updateUser(
          supabase.UserAttributes(
            data: {
              'full_name': name ?? state!.name,
              'avatar_url': profileImageUrl ?? state!.profileImageUrl,
            },
          ),
        );

        // Update local state
        state = state!.copyWith(
          name: name,
          profileImageUrl: profileImageUrl,
        );
      } catch (e) {
        // Handle error - could emit to an error provider
        print('Error updating profile: $e');
      }
    }
  }

  void signOut() {
    state = null;
  }
}