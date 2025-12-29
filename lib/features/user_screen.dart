import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';

/// ============================================================
/// USER SCREEN - FutureProvider & Path Parameters
/// ============================================================
/// 
/// This screen demonstrates:
/// 1. FutureProvider for async data
/// 2. FutureProvider.family for parameterized providers
/// 3. Path parameters in GoRouter
/// 4. Loading, data, and error states
/// 
/// ============================================================

class UserScreen extends ConsumerWidget {
  /// userId comes from the path parameter
  /// URL: /user/123 → userId = '123'
  final String userId;

  const UserScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// ─────────────────────────────────────────────
    /// FUTURE PROVIDER WITH FAMILY
    /// ─────────────────────────────────────────────
    /// 
    /// .family allows passing parameters to providers
    /// Each unique parameter creates a new provider instance
    /// 
    /// userByIdProvider('1') and userByIdProvider('2') 
    /// are different providers!
    /// 
    final userAsync = ref.watch(userByIdProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text('User $userId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ─────────────────────────────────────────────
            /// PATH PARAMETERS EXPLANATION
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔗 Path Parameters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('URL pattern: /user/:id'),
                    Text('Current URL: /user/$userId'),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '// In route definition:\n'
                        'GoRoute(\n'
                        '  path: \'/user/:id\',\n'
                        '  builder: (context, state) {\n'
                        '    final userId = state.pathParameters[\'id\']!;\n'
                        '    return UserScreen(userId: userId);\n'
                        '  },\n'
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
            /// FUTURE PROVIDER EXPLANATION
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏳ FutureProvider.family',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'FutureProvider handles async data automatically:\n'
                      '• Shows loading state\n'
                      '• Shows data when ready\n'
                      '• Handles errors',
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
                        '// Define provider with family\n'
                        'final userByIdProvider = \n'
                        '  FutureProvider.family<String, String>(\n'
                        '    (ref, userId) async {\n'
                        '      return await fetchUserById(userId);\n'
                        '    }\n'
                        ');\n\n'
                        '// Use with parameter\n'
                        'final userAsync = ref.watch(userByIdProvider(\'123\'));',
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

            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// ASYNC VALUE HANDLING
            /// ─────────────────────────────────────────────
            /// 
            /// FutureProvider returns AsyncValue which has:
            /// - .when() - Handle all states
            /// - .whenData() - Only handle data
            /// - .isLoading, .hasValue, .hasError
            /// 
            Text(
              'User Data:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            /// Using .when() pattern
            userAsync.when(
              /// LOADING STATE
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading user data...'),
                    ],
                  ),
                ),
              ),

              /// ERROR STATE
              error: (error, stack) => Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text('Error: $error'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          /// Refresh the provider
                          ref.invalidate(userByIdProvider(userId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              /// DATA STATE
              data: (userName) => Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          userName.isNotEmpty ? userName[0] : '?',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text('✅ Data loaded successfully!'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ─────────────────────────────────────────────
            /// NAVIGATION TO OTHER USERS
            /// ─────────────────────────────────────────────
            Text(
              'View other users:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['1', '2', '3', '99'].map((id) {
                final isCurrentUser = id == userId;
                return ElevatedButton(
                  onPressed: isCurrentUser
                      ? null
                      : () {
                          /// Navigate to another user
                          /// This creates a new instance of the screen
                          context.push('/user/$id');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentUser
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  child: Text(
                    'User $id${isCurrentUser ? ' (current)' : ''}',
                  ),
                );
              }).toList(),
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
                        '💡 User 99 will show "User not found" - \n'
                        'demonstrating how to handle edge cases!',
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
