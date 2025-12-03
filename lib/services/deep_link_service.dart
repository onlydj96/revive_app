import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'supabase_service.dart';

class DeepLinkService {
  static final _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  static DeepLinkService get instance => _instance;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Callback for when auth state changes via deep link
  Function(bool isAuthenticated)? onAuthStateChanged;

  Future<void> initialize() async {
    _appLinks = AppLinks();

    // Handle app launch via deep link (when app is closed)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleDeepLink(initialLink);
      }
    } on PlatformException {}

    // Handle deep links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => {}, // Silently handle errors
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    // Check if it's an auth callback
    if (uri.scheme == 'ezer' && uri.host == 'auth-callback') {
      await _handleAuthCallback(uri);
    }
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    try {
      // Modern Supabase Flutter automatically handles deep links
      // We just need to notify that a deep link was received
      // The auth state change will be handled by the auth listener in AuthNotifier

      // Give Supabase time to process the authentication
      await Future.delayed(const Duration(seconds: 1));

      // Check if authentication was successful
      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        onAuthStateChanged?.call(true);
      } else {
        // Don't call onAuthStateChanged(false) immediately
        // as the auth state listener will handle it
      }
    } catch (e) {
      onAuthStateChanged?.call(false);
    }
  }

  void setAuthStateCallback(Function(bool isAuthenticated) callback) {
    onAuthStateChanged = callback;
  }

  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}
