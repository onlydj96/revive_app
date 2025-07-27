import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/auth_state.dart' as app_auth;
import '../services/supabase_service.dart';
import '../services/deep_link_service.dart';
import '../router/app_router.dart';

final authProvider = StateNotifierProvider<AuthNotifier, app_auth.AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<app_auth.AuthState> {
  late final StreamSubscription<AuthState> _authSubscription;

  AuthNotifier() : super(const app_auth.AuthState()) {
    _initialize();
    _setupDeepLinkHandler();
  }

  void _initialize() {
    // Check current session
    final session = SupabaseService.currentSession;
    if (session != null) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.authenticated,
        user: session.user,
        session: session,
      );
    } else {
      state = const app_auth.AuthState(status: app_auth.AuthStatus.unauthenticated);
    }

    // Listen to auth changes
    _authSubscription = SupabaseService.client.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;
        if (session != null) {
          state = app_auth.AuthState(
            status: app_auth.AuthStatus.authenticated,
            user: session.user,
            session: session,
          );
        } else {
          state = const app_auth.AuthState(status: app_auth.AuthStatus.unauthenticated);
        }
        // Notify router to refresh
        routerNotifier.notify();
      },
    );
  }

  void _setupDeepLinkHandler() {
    DeepLinkService.instance.setAuthStateCallback((isAuthenticated) {
      if (isAuthenticated) {
        final session = SupabaseService.currentSession;
        if (session != null) {
          state = app_auth.AuthState(
            status: app_auth.AuthStatus.authenticated,
            user: session.user,
            session: session,
          );
        }
      }
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(status: app_auth.AuthStatus.loading);
      
      final response = await SupabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        state = app_auth.AuthState(
          status: app_auth.AuthStatus.authenticated,
          user: response.user,
          session: response.session,
        );
      } else {
        state = const app_auth.AuthState(
          status: app_auth.AuthStatus.error,
          errorMessage: 'Sign in failed',
        );
      }
    } on AuthException catch (e) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      state = state.copyWith(status: app_auth.AuthStatus.loading);
      
      final response = await SupabaseService.signUpWithEmail(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'Member',
        },
      );

      if (response.user != null) {
        // For email confirmation flow
        state = const app_auth.AuthState(
          status: app_auth.AuthStatus.unauthenticated,
          errorMessage: 'Please check your email to confirm your account',
        );
      } else {
        state = const app_auth.AuthState(
          status: app_auth.AuthStatus.error,
          errorMessage: 'Sign up failed',
        );
      }
    } on AuthException catch (e) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  Future<void> signOut() async {
    try {
      state = state.copyWith(status: app_auth.AuthStatus.loading);
      await SupabaseService.signOut();
      state = const app_auth.AuthState(status: app_auth.AuthStatus.unauthenticated);
      // Notify router to refresh for immediate redirect
      routerNotifier.notify();
    } catch (e) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.error,
        errorMessage: 'Sign out failed',
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(status: app_auth.AuthStatus.loading);
      await SupabaseService.resetPassword(email);
      state = state.copyWith(
        status: app_auth.AuthStatus.unauthenticated,
        errorMessage: 'Password reset email sent',
      );
    } catch (e) {
      state = app_auth.AuthState(
        status: app_auth.AuthStatus.error,
        errorMessage: 'Failed to send reset email',
      );
    }
  }

  void clearError() {
    if (state.hasError) {
      state = state.copyWith(
        status: app_auth.AuthStatus.unauthenticated,
        errorMessage: null,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}