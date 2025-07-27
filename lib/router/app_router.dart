import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/resources_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/teams_screen.dart';
import '../screens/updates_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/sanctuary_map_screen.dart';
import '../screens/team_detail_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/media_detail_screen.dart';
import '../screens/update_detail_screen.dart';
import '../screens/sermon_detail_screen.dart';
import '../screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

// Create a provider for router refresh
class RouterNotifier extends ChangeNotifier {
  static final _instance = RouterNotifier._internal();
  factory RouterNotifier() => _instance;
  RouterNotifier._internal();
  
  void notify() => notifyListeners();
}

final routerNotifier = RouterNotifier();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: routerNotifier,
  redirect: (context, state) {
    // Skip redirect during splash screen - let splash screen handle initialization
    if (state.matchedLocation == '/splash') {
      return null;
    }
    
    try {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authProvider);
      
      final isAuthRoute = ['/login', '/signup', '/email-verification', '/splash'].contains(state.matchedLocation);
      
      // If not authenticated and trying to access protected routes, redirect to login
      if (!authState.isAuthenticated && !isAuthRoute) {
        return '/login';
      }
      
      // If authenticated and trying to access auth routes, redirect to home
      if (authState.isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null;
    } catch (e) {
      // If Supabase is not initialized yet, redirect to splash
      return '/splash';
    }
  },
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Authentication Routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return EmailVerificationScreen(email: email);
      },
    ),
    
    // Main App Routes (Protected)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/resources',
          builder: (context, state) => const ResourcesScreen(),
        ),
        GoRoute(
          path: '/schedule',
          builder: (context, state) => const ScheduleScreen(),
        ),
        GoRoute(
          path: '/teams',
          builder: (context, state) => const TeamsScreen(),
        ),
        GoRoute(
          path: '/updates',
          builder: (context, state) => const UpdatesScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/sanctuary-map',
      builder: (context, state) => const SanctuaryMapScreen(),
    ),
    GoRoute(
      path: '/team/:id',
      builder: (context, state) {
        final teamId = state.pathParameters['id']!;
        return TeamDetailScreen(teamId: teamId);
      },
    ),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final eventId = state.pathParameters['id']!;
        return EventDetailScreen(eventId: eventId);
      },
    ),
    GoRoute(
      path: '/media/:id',
      builder: (context, state) {
        final mediaId = state.pathParameters['id']!;
        return MediaDetailScreen(mediaId: mediaId);
      },
    ),
    GoRoute(
      path: '/update/:id',
      builder: (context, state) {
        final updateId = state.pathParameters['id']!;
        return UpdateDetailScreen(updateId: updateId);
      },
    ),
    GoRoute(
      path: '/sermon/:id',
      builder: (context, state) {
        final sermonId = state.pathParameters['id']!;
        return SermonDetailScreen(sermonId: sermonId);
      },
    ),
  ],
);