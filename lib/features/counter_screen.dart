import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

/// ============================================================
/// COUNTER SCREEN - StateProvider Example
/// ============================================================
/// 
/// This screen demonstrates:
/// 1. StateProvider for simple state
/// 2. ref.watch vs ref.read
/// 3. Modifying state
/// 
/// ============================================================

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// ─────────────────────────────────────────────
    /// WATCHING STATE
    /// ─────────────────────────────────────────────
    /// 
    /// ref.watch(counterProvider) returns the current value (int)
    /// When the value changes, this widget rebuilds
    /// 
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter - StateProvider'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ─────────────────────────────────────────────
            /// EXPLANATION CARD
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 StateProvider',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'StateProvider is perfect for simple state like:\n'
                      '• Counters\n'
                      '• Toggle switches\n'
                      '• Selected tab index\n'
                      '• Form field values',
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
                        '// Define provider\n'
                        'final counterProvider = StateProvider<int>((ref) => 0);\n\n'
                        '// Read value\n'
                        'final count = ref.watch(counterProvider);\n\n'
                        '// Modify value\n'
                        'ref.read(counterProvider.notifier).state++;\n'
                        'ref.read(counterProvider.notifier).state = 10;',
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

            const Spacer(),

            /// ─────────────────────────────────────────────
            /// COUNTER DISPLAY
            /// ─────────────────────────────────────────────
            Text(
              'Count:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 32),

            /// ─────────────────────────────────────────────
            /// COUNTER BUTTONS
            /// ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// DECREMENT
                FloatingActionButton.large(
                  heroTag: 'decrement',
                  onPressed: () {
                    /// ─────────────────────────────────────
                    /// MODIFYING STATE - Method 1
                    /// ─────────────────────────────────────
                    /// 
                    /// Use ref.read() in callbacks (not ref.watch!)
                    /// Access .notifier to get the StateController
                    /// Then modify .state directly
                    /// 
                    ref.read(counterProvider.notifier).state--;
                  },
                  child: const Icon(Icons.remove, size: 32),
                ),
                const SizedBox(width: 24),

                /// INCREMENT
                FloatingActionButton.large(
                  heroTag: 'increment',
                  onPressed: () {
                    ref.read(counterProvider.notifier).state++;
                  },
                  child: const Icon(Icons.add, size: 32),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Additional operations
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                /// RESET
                OutlinedButton.icon(
                  onPressed: () {
                    /// Set to specific value
                    ref.read(counterProvider.notifier).state = 0;
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),

                /// SET TO 100
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(counterProvider.notifier).state = 100;
                  },
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Set to 100'),
                ),

                /// DOUBLE
                OutlinedButton.icon(
                  onPressed: () {
                    /// ─────────────────────────────────────
                    /// MODIFYING STATE - Method 2
                    /// ─────────────────────────────────────
                    /// 
                    /// Use .update() when you need the current value
                    /// 
                    ref.read(counterProvider.notifier).update(
                          (state) => state * 2,
                        );
                  },
                  icon: const Icon(Icons.double_arrow),
                  label: const Text('Double'),
                ),
              ],
            ),

            const Spacer(),

            /// ─────────────────────────────────────────────
            /// IMPORTANT NOTE
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
                        '💡 The counter state persists across screens! '
                        'Go back and return - the value is still there.',
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
