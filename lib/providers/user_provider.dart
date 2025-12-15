import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';
import 'auth_provider.dart';

final _logger = Logger('UserProvider');

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  final authState = ref.watch(authProvider);
  return UserNotifier(authState.user);
});

class UserNotifier extends StateNotifier<User?> {
  final supabase.User? _supabaseUser;

  UserNotifier(this._supabaseUser) : super(null) {
    _loadUserFromSupabase();
  }

  Future<void> _loadUserFromSupabase() async {
    if (_supabaseUser != null) {
      try {
        // Try to get user profile from database first
        final profileData =
            await SupabaseService.getById('user_profiles', _supabaseUser.id);

        // Check if still mounted before updating state
        if (!mounted) return;

        if (profileData != null) {
          // Use database profile
          state = User(
            id: profileData['id'] as String? ?? _supabaseUser.id,
            name: profileData['full_name'] as String? ?? 'User',
            email: profileData['email'] as String? ?? _supabaseUser.email ?? '',
            profileImageUrl: profileData['profile_image_url'] as String?,
            role: profileData['role'] as String? ?? 'member',
            joinDate: profileData['join_date'] != null
                ? DateTime.parse(profileData['join_date'] as String)
                : DateTime.parse(_supabaseUser.createdAt),
          );
        } else {
          // Fallback to auth metadata (for backward compatibility)
          final metadata = _supabaseUser.userMetadata ?? {};

          state = User(
            id: _supabaseUser.id,
            name: (metadata['full_name'] as String?) ??
                _supabaseUser.email?.split('@')[0] ??
                'User',
            email: _supabaseUser.email ?? '',
            profileImageUrl: metadata['avatar_url'] as String?,
            role: (metadata['role'] as String?) ?? 'member',
            joinDate: DateTime.parse(_supabaseUser.createdAt),
          );
        }
      } catch (e) {
        // Check if still mounted before updating state
        if (!mounted) return;

        // If database query fails, fall back to auth metadata
        final metadata = _supabaseUser.userMetadata ?? {};

        state = User(
          id: _supabaseUser.id,
          name: (metadata['full_name'] as String?) ??
              _supabaseUser.email?.split('@')[0] ??
              'User',
          email: _supabaseUser.email ?? '',
          profileImageUrl: metadata['avatar_url'] as String?,
          role: (metadata['role'] as String?) ?? 'member',
          joinDate: DateTime.parse(_supabaseUser.createdAt),
        );
      }
    } else {
      state = null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
    String? phone,
    String? address,
    String? emergencyContact,
  }) async {
    if (state != null && _supabaseUser != null) {
      try {
        final updateData = <String, dynamic>{};
        if (name != null) {
          updateData['full_name'] = name;
        }
        if (email != null) {
          updateData['email'] = email;
        }
        if (profileImageUrl != null) {
          updateData['profile_image_url'] = profileImageUrl;
        }
        if (phone != null) {
          updateData['phone'] = phone;
        }
        if (address != null) {
          updateData['address'] = address;
        }
        if (emergencyContact != null) {
          updateData['emergency_contact'] = emergencyContact;
        }

        // Update database profile
        await SupabaseService.update('user_profiles', _supabaseUser.id, updateData);

        // Update local state
        state = state!.copyWith(
          name: name,
          email: email,
          profileImageUrl: profileImageUrl,
        );
      } catch (e) {
        // Handle error - could emit to an error provider
        _logger.error('Error updating profile', e);
        rethrow;
      }
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await SupabaseService.update('user_profiles', userId, {'role': role});

      // Check if still mounted before refreshing
      if (!mounted) return;

      // If updating current user, refresh the profile
      if (userId == _supabaseUser?.id) {
        await _loadUserFromSupabase();
      }
    } catch (e) {
      _logger.error('Error updating user role', e);
      rethrow;
    }
  }

  void signOut() {
    state = null;
  }
}
