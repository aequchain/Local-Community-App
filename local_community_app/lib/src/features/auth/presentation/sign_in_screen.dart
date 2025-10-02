import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/design_tokens.dart';
import '../../campaigns/presentation/campaign_feed_screen.dart';
import '../application/auth_service.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  static const routeName = 'sign-in';

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AequusDesignTokens.durations.relaxed,
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.13),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.21, 0.89, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeIn.value,
              child: SlideTransition(
                position: _slideUp,
                child: child,
              ),
            );
          },
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AequusDesignTokens.spacing.s34),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 377),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        size: 89,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s34),
                      Text(
                        'Welcome back',
                        style: theme.textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s13),
                      Text(
                        'Sign in to continue supporting your community',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s55),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: AequusDesignTokens.radii.s13,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s21),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AequusDesignTokens.radii.s13,
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSignIn(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      if (_errorMessage != null) ...[
                        SizedBox(height: AequusDesignTokens.spacing.s13),
                        Container(
                          padding: EdgeInsets.all(
                            AequusDesignTokens.spacing.s13,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: AequusDesignTokens.radii.s13,
                          ),
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: AequusDesignTokens.spacing.s34),
                      FilledButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        child: _isLoading
                            ? SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s13),
                      TextButton(
                        onPressed: _isLoading ? null : () {},
                        child: const Text('Forgot password?'),
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s21),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AequusDesignTokens.spacing.s13,
                            ),
                            child: Text(
                              'OR',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s21),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                      ),
                      SizedBox(height: AequusDesignTokens.spacing.s34),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: AequusDesignTokens.spacing.s8,
                              ),
                            ),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.goNamed(CampaignFeedScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();

      if (mounted) {
        context.goNamed(CampaignFeedScreen.routeName);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }
}
