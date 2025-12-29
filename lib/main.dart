import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

/// ============================================================
/// RIVERPOD & NAVIGATOR 2.0 LEARNING APP
/// ============================================================
/// 
/// This app teaches you:
/// 1. Riverpod State Management
/// 2. Navigator 2.0 with GoRouter
/// 
/// ============================================================

void main() {
  runApp(
    /// ProviderScope is REQUIRED for Riverpod to work.
    /// It stores all your providers and their states.
    /// 
    /// Think of it as a container that holds all your app's state.
    /// You wrap your entire app with it.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Using ConsumerWidget instead of StatelessWidget
/// This gives us access to 'ref' to read providers
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 'ref.watch' listens to changes in the provider
    /// When appRouterProvider changes, this widget rebuilds
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Learn Riverpod & GoRouter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      
      /// Using routerConfig for Navigator 2.0 (GoRouter)
      /// This replaces the old 'routes' and 'onGenerateRoute'
      routerConfig: router,
    );
  }
}
