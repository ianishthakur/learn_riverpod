import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';
import '../../features/home_screen.dart';
import '../../features/counter_screen.dart';
import '../../features/todo_screen.dart';
import '../../features/user_screen.dart';
import '../../features/login_screen.dart';
import '../../features/settings_screen.dart';
import '../../features/profile_screen.dart';

/// ============================================================
/// NAVIGATOR 2.0 WITH GOROUTER - COMPLETE GUIDE
/// ============================================================
/// 
/// GoRouter is the recommended way to implement Navigator 2.0
/// 
/// Key Concepts:
/// 1. Routes - Define your app's screens
/// 2. Path Parameters - Dynamic parts of URL (/user/:id)
/// 3. Query Parameters - Optional parameters (?sort=asc)
/// 4. Redirect - Guard routes, check auth
/// 5. ShellRoute - Persistent UI (bottom nav)
/// 6. Nested Routes - Sub-routes
/// 
/// Navigation Methods:
/// - context.go('/path')      - Replace current route
/// - context.push('/path')    - Add to stack
/// - context.pop()            - Go back
/// - context.goNamed('name')  - Navigate by name
/// 
/// ============================================================


// ═══════════════════════════════════════════════════════════════
// ROUTE NAMES - Define constants to avoid typos
// ═══════════════════════════════════════════════════════════════

class Routes {
  Routes._(); // Private constructor

  static const String home = '/';
  static const String login = '/login';
  static const String counter = '/counter';
  static const String todos = '/todos';
  static const String user = '/user/:id';          // Path parameter
  static const String settings = '/settings';
  static const String profile = '/profile';
}


// ═══════════════════════════════════════════════════════════════
// GOROUTER PROVIDER
// ═══════════════════════════════════════════════════════════════

/// We create the router as a Riverpod provider
/// This allows it to react to auth state changes
final appRouterProvider = Provider<GoRouter>((ref) {
  
  /// Watch auth state - router rebuilds when auth changes
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    /// Initial route when app starts
    initialLocation: Routes.home,
    
    /// Enable debug logging (helpful for learning)
    debugLogDiagnostics: true,
    
    /// ─────────────────────────────────────────────
    /// REDIRECT - Guard routes based on conditions
    /// ─────────────────────────────────────────────
    /// 
    /// This runs BEFORE every navigation
    /// Return null to allow, or return path to redirect
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == Routes.login;
      
      /// Protected routes that require authentication
      final protectedRoutes = ['/profile', '/settings'];
      final isProtectedRoute = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );
      
      /// If trying to access protected route without login
      if (isProtectedRoute && !isLoggedIn) {
        /// Redirect to login
        /// We can pass the intended destination as query param
        return '${Routes.login}?redirect=${state.matchedLocation}';
      }
      
      /// If logged in and on login page, go to home
      if (isLoggedIn && isLoginRoute) {
        return Routes.home;
      }
      
      /// Allow navigation (no redirect)
      return null;
    },
    
    /// ─────────────────────────────────────────────
    /// ROUTES DEFINITION
    /// ─────────────────────────────────────────────
    routes: [
      
      /// ═══════════════════════════════════════════
      /// BASIC ROUTE
      /// ═══════════════════════════════════════════
      GoRoute(
        path: Routes.home,
        name: 'home', // Named route for context.goNamed('home')
        builder: (context, state) => const HomeScreen(),
      ),
      
      
      /// ═══════════════════════════════════════════
      /// LOGIN ROUTE - With query parameters
      /// ═══════════════════════════════════════════
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) {
          /// Access query parameters
          /// URL: /login?redirect=/profile
          final redirectPath = state.uri.queryParameters['redirect'];
          return LoginScreen(redirectPath: redirectPath);
        },
      ),
      
      
      /// ═══════════════════════════════════════════
      /// COUNTER ROUTE
      /// ═══════════════════════════════════════════
      GoRoute(
        path: Routes.counter,
        name: 'counter',
        builder: (context, state) => const CounterScreen(),
      ),
      
      
      /// ═══════════════════════════════════════════
      /// TODO ROUTE
      /// ═══════════════════════════════════════════
      GoRoute(
        path: Routes.todos,
        name: 'todos',
        builder: (context, state) => const TodoScreen(),
      ),
      
      
      /// ═══════════════════════════════════════════
      /// USER ROUTE - With path parameters
      /// ═══════════════════════════════════════════
      /// 
      /// Path parameter: /user/:id
      /// Example: /user/123
      /// 
      /// Access with: state.pathParameters['id']
      /// 
      GoRoute(
        path: Routes.user,
        name: 'user',
        builder: (context, state) {
          /// Get the 'id' from the URL
          final userId = state.pathParameters['id']!;
          return UserScreen(userId: userId);
        },
      ),
      
      
      /// ═══════════════════════════════════════════
      /// SETTINGS WITH NESTED ROUTES
      /// ═══════════════════════════════════════════
      /// 
      /// Nested routes share a parent
      /// /settings          -> SettingsScreen
      /// /settings/profile  -> ProfileScreen
      /// 
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          /// Nested route - /settings/profile
          GoRoute(
            path: 'profile', // Note: no leading slash!
            name: 'settings-profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          /// You can add more nested routes here
          /// path: 'notifications' -> /settings/notifications
          /// path: 'privacy'       -> /settings/privacy
        ],
      ),
      
      
      /// ═══════════════════════════════════════════
      /// PROTECTED ROUTE
      /// ═══════════════════════════════════════════
      GoRoute(
        path: Routes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    
    
    /// ─────────────────────────────────────────────
    /// ERROR PAGE - 404 and other errors
    /// ─────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('Path: ${state.uri.toString()}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});


/// ═══════════════════════════════════════════════════════════════
/// NAVIGATION EXAMPLES REFERENCE
/// ═══════════════════════════════════════════════════════════════
/// 
/// // Basic navigation
/// context.go('/counter');           // Replace entire stack
/// context.push('/counter');         // Add to stack
/// context.pop();                    // Go back
/// 
/// // Named routes
/// context.goNamed('counter');
/// context.pushNamed('user', pathParameters: {'id': '123'});
/// 
/// // With query parameters
/// context.go('/login?redirect=/profile');
/// context.goNamed('login', queryParameters: {'redirect': '/profile'});
/// 
/// // Path parameters
/// context.go('/user/123');
/// context.goNamed('user', pathParameters: {'id': '123'});
/// 
/// // Go back with result
/// context.pop(resultData);
/// 
/// // Check if can pop
/// if (context.canPop()) context.pop();
/// 
/// ═══════════════════════════════════════════════════════════════
