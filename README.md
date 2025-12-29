# 📚 Riverpod & Navigator 2.0 (GoRouter) Learning App

A simple, well-documented Flutter app to help you understand **Riverpod State Management** and **Navigator 2.0 with GoRouter**.

## 🎯 What You'll Learn

### Riverpod State Management
- ✅ Provider (read-only values)
- ✅ StateProvider (simple mutable state)
- ✅ StateNotifierProvider (complex state with methods)
- ✅ FutureProvider (async data)
- ✅ StreamProvider (real-time data)
- ✅ `.family` modifier (parameterized providers)
- ✅ `.autoDispose` modifier (auto cleanup)
- ✅ Derived/computed providers

### Navigator 2.0 with GoRouter
- ✅ Basic routing
- ✅ Path parameters (`/user/:id`)
- ✅ Query parameters (`/login?redirect=/profile`)
- ✅ Nested routes (`/settings/profile`)
- ✅ Redirect (route guards)
- ✅ Protected routes (auth check)
- ✅ Error handling (404 page)

## 🚀 Getting Started

```bash
# 1. Navigate to the project
cd riverpod_learn_app

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point with ProviderScope
├── core/
│   ├── providers.dart        # All providers with detailed comments
│   └── router/
│       └── app_router.dart   # GoRouter configuration
└── features/
    ├── home_screen.dart      # Navigation hub
    ├── counter_screen.dart   # StateProvider example
    ├── todo_screen.dart      # StateNotifierProvider example
    ├── user_screen.dart      # FutureProvider + path params
    ├── login_screen.dart     # Auth + query params
    ├── settings_screen.dart  # Nested routes + StreamProvider
    └── profile_screen.dart   # Protected route
```

## 📖 Key Concepts

### 1. ProviderScope (main.dart)
```dart
void main() {
  runApp(
    ProviderScope(  // Required! Stores all state
      child: MyApp(),
    ),
  );
}
```

### 2. Provider Types

| Provider | Use Case | Example |
|----------|----------|---------|
| `Provider` | Read-only, constants, computed | App name, API URL |
| `StateProvider` | Simple mutable state | Counter, toggle, selection |
| `StateNotifierProvider` | Complex state + methods | Todo list, auth state |
| `FutureProvider` | Async data (API calls) | Fetch user, load data |
| `StreamProvider` | Real-time data | Timer, Firebase, WebSocket |

### 3. Reading Providers

```dart
// In build method - LISTEN to changes
final count = ref.watch(counterProvider);

// In callbacks - ONE-TIME read
ref.read(counterProvider.notifier).state++;
```

### 4. Navigation

```dart
// Replace entire stack
context.go('/path');

// Add to stack (can go back)
context.push('/path');

// Go back
context.pop();

// Named routes
context.goNamed('user', pathParameters: {'id': '123'});
```

## 🔐 Auth Flow Demo

1. Try to access `/profile` without logging in
2. You'll be redirected to `/login?redirect=/profile`
3. Login with: `test@test.com` / `password`
4. After login, you're redirected to `/profile`

## 🧪 Test Scenarios

### Counter (StateProvider)
- Increment/decrement the counter
- Navigate away and come back - state persists!

### Todos (StateNotifierProvider)
- Add, toggle, and delete todos
- Use filters to show all/completed/pending
- Clear completed todos

### User Profile (FutureProvider.family)
- View users 1, 2, 3 (valid)
- Try user 99 (not found)
- Watch the loading state

### Settings (StreamProvider + Nested Routes)
- Watch the timer stream update in real-time
- Navigate to nested route `/settings/profile`

## 📝 Quick Reference

### StateProvider
```dart
// Define
final counterProvider = StateProvider<int>((ref) => 0);

// Read
final count = ref.watch(counterProvider);

// Modify
ref.read(counterProvider.notifier).state++;
ref.read(counterProvider.notifier).state = 10;
ref.read(counterProvider.notifier).update((s) => s * 2);
```

### StateNotifierProvider
```dart
// State class
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);
  
  void addTodo(String title) {
    state = [...state, Todo(title: title)];
  }
}

// Provider
final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

// Use
final todos = ref.watch(todoProvider);
ref.read(todoProvider.notifier).addTodo('New todo');
```

### FutureProvider with family
```dart
// Define
final userProvider = FutureProvider.family<User, String>((ref, id) async {
  return await fetchUser(id);
});

// Use with parameter
final userAsync = ref.watch(userProvider('123'));

userAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
  data: (user) => Text(user.name),
);
```

### GoRouter Redirect (Auth Guard)
```dart
GoRouter(
  redirect: (context, state) {
    final isLoggedIn = authState.isAuthenticated;
    final isLoginRoute = state.matchedLocation == '/login';
    
    if (!isLoggedIn && isProtectedRoute) {
      return '/login?redirect=${state.matchedLocation}';
    }
    
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }
    
    return null; // No redirect
  },
  routes: [...],
);
```

## 💡 Tips

1. **Use `ref.watch` in build()** - Listens to changes
2. **Use `ref.read` in callbacks** - One-time read, no rebuild
3. **Use `context.push` to go back** - Adds to navigation stack
4. **Use `context.go` to replace** - Replaces entire stack
5. **State persists** - Provider state lives as long as something watches it
6. **Use `.autoDispose`** - Cleanup state when no longer used

## 📚 Resources

- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Navigation 2.0](https://docs.flutter.dev/development/ui/navigation)

---

Happy Learning! 🎉
