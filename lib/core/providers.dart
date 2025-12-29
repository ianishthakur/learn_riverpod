import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ============================================================
/// RIVERPOD PROVIDERS - COMPLETE GUIDE
/// ============================================================
/// 
/// Riverpod has several types of providers:
/// 
/// 1. Provider          - Read-only value (computed/constant)
/// 2. StateProvider     - Simple mutable state (int, String, bool)
/// 3. StateNotifierProvider - Complex state with methods
/// 4. FutureProvider    - Async data (API calls)
/// 5. StreamProvider    - Stream data (real-time updates)
/// 
/// Modifiers:
/// - .family    - Pass parameters to provider
/// - .autoDispose - Auto cleanup when not used
/// 
/// ============================================================


// ═══════════════════════════════════════════════════════════════
// 1. PROVIDER - Read-only values
// ═══════════════════════════════════════════════════════════════

/// Provider is for values that don't change, or computed values.
/// 
/// Example: App name, API base URL, computed values
final appNameProvider = Provider<String>((ref) {
  return 'Riverpod Learning App';
});

/// Provider can depend on other providers using 'ref.watch'
final greetingProvider = Provider<String>((ref) {
  final appName = ref.watch(appNameProvider);
  return 'Welcome to $appName!';
});


// ═══════════════════════════════════════════════════════════════
// 2. STATE PROVIDER - Simple mutable state
// ═══════════════════════════════════════════════════════════════

/// StateProvider is for simple state that can change.
/// Perfect for: counters, toggles, selected index, form fields
/// 
/// The state can be modified using:
/// - ref.read(provider.notifier).state = newValue
/// - ref.read(provider.notifier).update((state) => state + 1)

/// Simple counter
final counterProvider = StateProvider<int>((ref) {
  return 0; // Initial value
});

/// Theme mode toggle
final isDarkModeProvider = StateProvider<bool>((ref) {
  return false;
});

/// Selected tab index
final selectedTabProvider = StateProvider<int>((ref) {
  return 0;
});


// ═══════════════════════════════════════════════════════════════
// 3. STATE NOTIFIER PROVIDER - Complex state with methods
// ═══════════════════════════════════════════════════════════════

/// StateNotifierProvider is for complex state with multiple fields
/// and methods to modify the state.
/// 
/// You need TWO classes:
/// 1. A State class (immutable data)
/// 2. A StateNotifier class (manages the state)

/// -------- Todo Example --------

/// Step 1: Define the Todo model
class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  /// copyWith pattern for immutable updates
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Step 2: Create the StateNotifier
/// This class MANAGES the state and has methods to modify it
class TodoNotifier extends StateNotifier<List<Todo>> {
  /// Initialize with empty list or initial data
  TodoNotifier() : super([]);

  /// Add a new todo
  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    /// Create NEW list (immutable pattern)
    state = [...state, newTodo];
  }

  /// Toggle todo completion
  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }

  /// Remove todo
  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  /// Clear all completed
  void clearCompleted() {
    state = state.where((todo) => !todo.isCompleted).toList();
  }
}

/// Step 3: Create the provider
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

/// -------- Derived/Computed Providers --------

/// You can create providers that depend on other providers
/// These are like computed properties

/// Count of completed todos
final completedTodoCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider);
  return todos.where((todo) => todo.isCompleted).length;
});

/// Count of pending todos
final pendingTodoCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider);
  return todos.where((todo) => !todo.isCompleted).length;
});

/// Filter enum for todo list
enum TodoFilter { all, completed, pending }

final todoFilterProvider = StateProvider<TodoFilter>((ref) {
  return TodoFilter.all;
});

/// Filtered todos based on selected filter
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.completed:
      return todos.where((todo) => todo.isCompleted).toList();
    case TodoFilter.pending:
      return todos.where((todo) => !todo.isCompleted).toList();
    case TodoFilter.all:
      return todos;
  }
});


// ═══════════════════════════════════════════════════════════════
// 4. FUTURE PROVIDER - Async data
// ═══════════════════════════════════════════════════════════════

/// FutureProvider is for async operations like API calls.
/// It automatically handles loading, data, and error states.

/// Simulated API call
Future<List<String>> fetchUsers() async {
  await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
  return ['Alice', 'Bob', 'Charlie', 'David'];
}

/// Basic FutureProvider
final usersProvider = FutureProvider<List<String>>((ref) async {
  return await fetchUsers();
});

/// FutureProvider with .autoDispose
/// The data is cleared when no widget is listening
final usersAutoDisposeProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  return await fetchUsers();
});


// ═══════════════════════════════════════════════════════════════
// 5. STREAM PROVIDER - Real-time data
// ═══════════════════════════════════════════════════════════════

/// StreamProvider is for streams like real-time updates,
/// WebSocket connections, Firebase Realtime Database, etc.

/// Simulated stream - emits a number every second
Stream<int> timerStream() {
  return Stream.periodic(
    const Duration(seconds: 1),
    (count) => count,
  );
}

final timerProvider = StreamProvider<int>((ref) {
  return timerStream();
});


// ═══════════════════════════════════════════════════════════════
// 6. FAMILY MODIFIER - Pass parameters to providers
// ═══════════════════════════════════════════════════════════════

/// .family allows you to pass parameters to a provider
/// Useful for: fetching user by ID, product by ID, etc.

/// Simulated API call with parameter
Future<String> fetchUserById(String userId) async {
  await Future.delayed(const Duration(seconds: 1));
  final users = {
    '1': 'Alice (ID: 1)',
    '2': 'Bob (ID: 2)',
    '3': 'Charlie (ID: 3)',
  };
  return users[userId] ?? 'User not found';
}

/// FutureProvider with family modifier
/// Usage: ref.watch(userByIdProvider('1'))
final userByIdProvider = FutureProvider.family<String, String>((ref, userId) async {
  return await fetchUserById(userId);
});

/// StateProvider with family (less common but possible)
/// Creates separate state for each parameter
final itemQuantityProvider = StateProvider.family<int, String>((ref, productId) {
  return 1; // Default quantity
});


// ═══════════════════════════════════════════════════════════════
// 7. AUTH STATE EXAMPLE - Complete real-world example
// ═══════════════════════════════════════════════════════════════

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? userName;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.userName,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? userName,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation for demo
    if (email == 'test@test.com' && password == 'password') {
      state = AuthState(
        isAuthenticated: true,
        userId: '123',
        userName: email.split('@').first,
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  }

  void logout() {
    state = const AuthState();
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider - just check if logged in
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
