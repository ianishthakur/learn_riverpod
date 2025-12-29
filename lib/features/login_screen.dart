import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../core/router/app_router.dart';

/// ============================================================
/// LOGIN SCREEN - Auth Flow & Query Parameters
/// ============================================================
/// 
/// This screen demonstrates:
/// 1. Authentication with StateNotifierProvider
/// 2. Query parameters for redirect
/// 3. Loading states
/// 4. Navigation after login
/// 
/// ============================================================

class LoginScreen extends ConsumerStatefulWidget {
  /// redirectPath comes from query parameter
  /// URL: /login?redirect=/profile → redirectPath = '/profile'
  final String? redirectPath;

  const LoginScreen({
    super.key,
    this.redirectPath,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'test@test.com');
  final _passwordController = TextEditingController(text: 'password');
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    /// ─────────────────────────────────────────────
    /// CALLING ASYNC METHODS ON NOTIFIER
    /// ─────────────────────────────────────────────
    final success = await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (success && mounted) {
      /// ─────────────────────────────────────────────
      /// NAVIGATION AFTER LOGIN
      /// ─────────────────────────────────────────────
      /// 
      /// If we have a redirect path, go there
      /// Otherwise go to home
      /// 
      if (widget.redirectPath != null) {
        context.go(widget.redirectPath!);
      } else {
        context.go(Routes.home);
      }
    } else if (mounted) {
      setState(() {
        _errorMessage = 'Invalid credentials. Try test@test.com / password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Watch auth state for loading indicator
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ─────────────────────────────────────────────
            /// QUERY PARAMETERS EXPLANATION
            /// ─────────────────────────────────────────────
            if (widget.redirectPath != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Query Parameters',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You were redirected here because you tried to access:\n'
                        '${widget.redirectPath}\n\n'
                        'After login, you\'ll be taken there automatically.',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// ─────────────────────────────────────────────
            /// AUTH FLOW EXPLANATION
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔐 Authentication Flow',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. User tries to access protected route\n'
                      '2. Router redirect() checks auth state\n'
                      '3. Not logged in → redirect to /login?redirect=...\n'
                      '4. User logs in → state changes\n'
                      '5. Router rebuilds → redirect to destination',
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
                        '// In router redirect:\n'
                        'redirect: (context, state) {\n'
                        '  if (isProtectedRoute && !isLoggedIn) {\n'
                        '    return \'/login?redirect=\${state.matchedLocation}\';\n'
                        '  }\n'
                        '  return null; // allow\n'
                        '},',
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
            /// LOGIN FORM
            /// ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.account_circle, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    /// Email field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    /// Password field
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),

                    /// Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    /// Login button
                    FilledButton.icon(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      icon: authState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        authState.isLoading ? 'Signing in...' : 'Sign In',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ─────────────────────────────────────────────
            /// TEST CREDENTIALS
            /// ─────────────────────────────────────────────
            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '✅ Test credentials:\n'
                        'Email: test@test.com\n'
                        'Password: password',
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
