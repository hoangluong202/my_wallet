import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../shared/widgets/notification_widget.dart';

class LoginPage extends StatefulWidget {
  final AuthViewModel viewModel;

  const LoginPage({super.key, required this.viewModel});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                ),
              ),
            ),
            // Main content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // App Logo and Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: 40,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'My Wallet',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your finances effortlessly',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to access your wallets and manage your finances',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 32),
                          // Google Sign In Button
                          ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, _) {
                              final isLoading = _viewModel.isLoading;
                              final hasError = _viewModel.error != null;

                              return Column(
                                children: [
                                  if (hasError)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.red.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _viewModel.error ?? '',
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: _viewModel.clearError,
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.red.shade700,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (hasError) const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: isLoading
                                        ? null
                                        : () => _handleGoogleSignIn(),
                                    icon: isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.blue.shade600,
                                                  ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Image.network(
                                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth_providers/google.svg',
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(Icons.login),
                                            ),
                                          ),
                                    label: Text(
                                      isLoading
                                          ? 'Signing in...'
                                          : 'Sign in with Google',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 14,
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.blue.shade600,
                                      elevation: 2,
                                      side: BorderSide(
                                        color: Colors.blue.shade200,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Privacy & Terms
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: 'By signing in, you agree to our ',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600),
                                children: [
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _viewModel.signInWithGoogle();
    if (success && mounted) {
      // Navigation will be handled by router based on auth state
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      SuccessNotification.show(
        context: context,
        message: 'Successfully signed in!',
        duration: const Duration(seconds: 2),
      );
    }
  }
}
