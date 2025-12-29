import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';

/// ============================================================
/// SETTINGS SCREEN - Nested Routes Example
/// ============================================================
/// 
/// This screen demonstrates:
/// 1. Nested routes in GoRouter
/// 2. Navigation within nested routes
/// 3. StreamProvider for real-time data
/// 
/// ============================================================

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Watch dark mode toggle
    final isDarkMode = ref.watch(isDarkModeProvider);

    /// ─────────────────────────────────────────────
    /// STREAM PROVIDER EXAMPLE
    /// ─────────────────────────────────────────────
    final timerAsync = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings - Nested Routes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ─────────────────────────────────────────────
            /// NESTED ROUTES EXPLANATION
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📂 Nested Routes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nested routes share a parent path:\n'
                      '• /settings         → This screen\n'
                      '• /settings/profile → Profile screen\n',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'GoRoute(\n'
                        '  path: \'/settings\',\n'
                        '  builder: (context, state) => SettingsScreen(),\n'
                        '  routes: [\n'
                        '    GoRoute(\n'
                        '      path: \'profile\', // No leading slash!\n'
                        '      builder: ... => ProfileScreen(),\n'
                        '    ),\n'
                        '  ],\n'
                        '),',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ─────────────────────────────────────────────
            /// STREAM PROVIDER CARD
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔄 StreamProvider Example',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'StreamProvider handles streams automatically.\n'
                      'Perfect for real-time data like Firebase.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, size: 32),
                          const SizedBox(width: 12),
                          timerAsync.when(
                            data: (seconds) => Text(
                              'Timer: $seconds seconds',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            loading: () => const Text('Starting...'),
                            error: (e, s) => Text('Error: $e'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// SETTINGS LIST
            /// ─────────────────────────────────────────────
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  /// Profile - Nested route
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    subtitle: const Text('Nested route: /settings/profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      /// Navigate to nested route
                      context.push('/settings/profile');
                    },
                  ),
                  const Divider(height: 1),

                  /// Dark mode toggle
                  SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Using StateProvider'),
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(isDarkModeProvider.notifier).state = value;
                    },
                  ),
                  const Divider(height: 1),

                  /// About
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('About'),
                    subtitle: Text('Riverpod & GoRouter Learning App'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// NAVIGATION EXAMPLES
            /// ─────────────────────────────────────────────
            Text(
              'Navigation Methods:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('go(\'/\')'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/counter'),
                  icon: const Icon(Icons.add),
                  label: const Text('push(\'/counter\')'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot pop!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('pop()'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// TIP
            /// ─────────────────────────────────────────────
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '💡 go() replaces the entire stack\n'
                        'push() adds to the stack (can go back)',
                        style: TextStyle(fontSize: 13),
                      ),
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
