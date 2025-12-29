import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/router/app_router.dart';

/// ============================================================
/// HOME SCREEN - Navigation Hub
/// ============================================================
/// 
/// This screen demonstrates:
/// 1. Reading providers with ref.watch
/// 2. Basic navigation with GoRouter
/// 
/// ============================================================

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// ─────────────────────────────────────────────
    /// READING PROVIDERS
    /// ─────────────────────────────────────────────
    /// 
    /// ref.watch - Listens to changes, rebuilds widget
    /// ref.read  - One-time read, doesn't listen
    /// 
    /// Use ref.watch in build()
    /// Use ref.read in callbacks (onPressed, etc.)
    
    final greeting = ref.watch(greetingProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod & GoRouter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          /// Show login status
          if (authState.isAuthenticated)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                avatar: const Icon(Icons.person, size: 18),
                label: Text(authState.userName ?? 'User'),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ─────────────────────────────────────────────
            /// GREETING FROM PROVIDER
            /// ─────────────────────────────────────────────
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// NAVIGATION MENU
            /// ─────────────────────────────────────────────
            Text(
              'Learn by Example:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            /// Counter Example - StateProvider
            _NavigationCard(
              icon: Icons.add_circle_outline,
              title: 'Counter Example',
              subtitle: 'Learn StateProvider & basic state',
              onTap: () {
                /// ─────────────────────────────────────────
                /// NAVIGATION METHODS
                /// ─────────────────────────────────────────
                /// 
                /// context.go('/path')   - Replaces entire stack
                /// context.push('/path') - Adds to stack (can go back)
                /// 
                context.push(Routes.counter);
              },
            ),

            /// Todo Example - StateNotifierProvider
            _NavigationCard(
              icon: Icons.checklist,
              title: 'Todo List Example',
              subtitle: 'Learn StateNotifierProvider & complex state',
              onTap: () => context.push(Routes.todos),
            ),

            /// User Example - Path Parameters
            _NavigationCard(
              icon: Icons.person_search,
              title: 'User Profile (Path Params)',
              subtitle: 'Learn FutureProvider.family & path parameters',
              onTap: () {
                /// Path parameter example
                /// Goes to /user/1
                context.push('/user/1');
              },
            ),

            /// Settings - Nested Routes
            _NavigationCard(
              icon: Icons.settings,
              title: 'Settings (Nested Routes)',
              subtitle: 'Learn nested navigation',
              onTap: () => context.push(Routes.settings),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            /// ─────────────────────────────────────────────
            /// AUTH SECTION
            /// ─────────────────────────────────────────────
            Text(
              'Authentication Example:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            if (!authState.isAuthenticated) ...[
              _NavigationCard(
                icon: Icons.login,
                title: 'Login',
                subtitle: 'Test: test@test.com / password',
                onTap: () => context.push(Routes.login),
              ),
              _NavigationCard(
                icon: Icons.lock,
                title: 'Profile (Protected)',
                subtitle: 'Will redirect to login',
                onTap: () => context.push(Routes.profile),
              ),
            ] else ...[
              _NavigationCard(
                icon: Icons.person,
                title: 'My Profile',
                subtitle: 'Protected route - now accessible!',
                onTap: () => context.push(Routes.profile),
              ),
              _NavigationCard(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Clear authentication state',
                color: Colors.red.shade50,
                onTap: () {
                  /// Use ref.read in callbacks!
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ],

            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// PROVIDER CONCEPTS SUMMARY
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📚 Quick Reference',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const _CodeSnippet(
                      title: 'Provider Types:',
                      code: '''
Provider           → Read-only values
StateProvider      → Simple mutable state  
StateNotifierProvider → Complex state
FutureProvider     → Async data
StreamProvider     → Stream data''',
                    ),
                    const SizedBox(height: 12),
                    const _CodeSnippet(
                      title: 'Navigation:',
                      code: '''
context.go('/path')    → Replace stack
context.push('/path')  → Add to stack
context.pop()          → Go back
context.goNamed('name') → By name''',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation Card Widget
class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Code Snippet Widget
class _CodeSnippet extends StatelessWidget {
  final String title;
  final String code;

  const _CodeSnippet({
    required this.title,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
