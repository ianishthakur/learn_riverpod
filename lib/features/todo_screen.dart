import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';

/// ============================================================
/// TODO SCREEN - StateNotifierProvider Example
/// ============================================================
/// 
/// This screen demonstrates:
/// 1. StateNotifierProvider for complex state
/// 2. Derived/computed providers
/// 3. Filter pattern
/// 
/// ============================================================

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      /// ─────────────────────────────────────────────
      /// CALLING NOTIFIER METHODS
      /// ─────────────────────────────────────────────
      /// 
      /// Access the notifier with .notifier
      /// Then call methods on it
      /// 
      ref.read(todoProvider.notifier).addTodo(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    /// ─────────────────────────────────────────────
    /// WATCHING MULTIPLE PROVIDERS
    /// ─────────────────────────────────────────────
    /// 
    /// You can watch multiple providers
    /// Widget rebuilds when ANY of them change
    /// 
    final todos = ref.watch(filteredTodosProvider);
    final completedCount = ref.watch(completedTodoCountProvider);
    final pendingCount = ref.watch(pendingTodoCountProvider);
    final currentFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos - StateNotifierProvider'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          /// Clear completed button
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear completed',
            onPressed: () {
              ref.read(todoProvider.notifier).clearCompleted();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// ─────────────────────────────────────────────
          /// EXPLANATION CARD
          /// ─────────────────────────────────────────────
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📖 StateNotifierProvider',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Perfect for complex state with:\n'
                    '• Multiple fields\n'
                    '• Custom methods (add, remove, update)\n'
                    '• Business logic',
                  ),
                ],
              ),
            ),
          ),

          /// ─────────────────────────────────────────────
          /// STATS BAR
          /// ─────────────────────────────────────────────
          /// 
          /// Using derived providers for computed values
          /// 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatChip(
                  label: 'Total',
                  count: completedCount + pendingCount,
                  color: Colors.blue,
                ),
                _StatChip(
                  label: 'Pending',
                  count: pendingCount,
                  color: Colors.orange,
                ),
                _StatChip(
                  label: 'Done',
                  count: completedCount,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          /// ─────────────────────────────────────────────
          /// FILTER CHIPS
          /// ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Filter: '),
                const SizedBox(width: 8),
                ...TodoFilter.values.map((filter) {
                  final isSelected = currentFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter.name.toUpperCase()),
                      onSelected: (_) {
                        /// Modify StateProvider with .notifier.state
                        ref.read(todoFilterProvider.notifier).state = filter;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// ─────────────────────────────────────────────
          /// TODO LIST
          /// ─────────────────────────────────────────────
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checklist,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentFilter == TodoFilter.all
                              ? 'No todos yet!\nAdd one below.'
                              : 'No ${currentFilter.name} todos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return _TodoItem(
                        todo: todo,
                        onToggle: () {
                          ref.read(todoProvider.notifier).toggleTodo(todo.id);
                        },
                        onDelete: () {
                          ref.read(todoProvider.notifier).removeTodo(todo.id);
                        },
                      );
                    },
                  ),
          ),

          /// ─────────────────────────────────────────────
          /// ADD TODO INPUT
          /// ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Add a new todo...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: _addTodo,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Chip Widget
class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

/// Todo Item Widget
class _TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
