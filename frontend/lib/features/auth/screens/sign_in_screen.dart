import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_flow_logo.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/services/motivation_quotes_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _nameController = TextEditingController(text: 'Alex Rivera');
  final _emailController = TextEditingController(text: 'alex@habitflow.pro');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (_isSignUp && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }

    bool success = false;
    if (_isSignUp) {
      success = await ref.read(authProvider.notifier).register(
            email: email,
            password: password,
            name: _nameController.text.trim(),
          );
    } else {
      success = await ref.read(authProvider.notifier).login(
            email: email,
            password: password,
          );
    }

    if (success && mounted) {
      context.go('/today');
    } else if (mounted) {
      final err = ref.read(authProvider).errorMessage ?? '';
      if (err.toLowerCase().contains('connect') ||
          err.toLowerCase().contains('network') ||
          err.toLowerCase().contains('server') ||
          err.toLowerCase().contains('time')) {
        _showOfflineFallbackDialog(email, _isSignUp ? _nameController.text.trim() : null);
      }
    }
  }

  void _showOfflineFallbackDialog(String email, String? name) {
    final apiClient = ref.read(apiClientProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.streakFire),
            SizedBox(width: 8),
            Text('Server Offline'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not connect to the backend server at:\n${apiClient.currentBaseUrl}\n\n'
              'Ensure your PC backend is running ("npm run dev" on 192.168.1.2:5000), or continue in Offline / Demo Mode now.',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showServerConfigDialog();
            },
            child: const Text('Change Server IP'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).continueOffline(
                    name: name ?? email.split('@').first,
                    email: email,
                  );
              context.go('/today');
            },
            child: const Text('Continue Offline'),
          ),
        ],
      ),
    );
  }

  void _showServerConfigDialog() {
    final sessionStorage = ref.read(sessionStorageProvider);
    final apiClient = ref.read(apiClientProvider);
    final urlController = TextEditingController(
      text: apiClient.currentBaseUrl,
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Backend API Server'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure the REST API endpoint for physical device testing or cloud hosting:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'https://habitflow-pro-bz24.onrender.com/api/v1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Quick Presets:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('Render Cloud (onrender.com)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          urlController.text = 'https://habitflow-pro-bz24.onrender.com/api/v1';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('PC Wi-Fi (192.168.1.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          urlController.text = 'http://192.168.1.2:5000/api/v1';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          urlController.text = 'http://10.0.2.2:5000/api/v1';
                        });
                      },
                    ),
                    ActionChip(
                      label: const Text('Localhost (5000)', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        setDialogState(() {
                          urlController.text = 'http://localhost:5000/api/v1';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Make sure your computer runs "npm run dev" inside backend/ and both phone and PC are on the same Wi-Fi.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final newUrl = urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  await sessionStorage.setCustomBaseUrl(newUrl);
                  apiClient.updateBaseUrl(newUrl);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Server URL updated to $newUrl')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Server Config Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Text(
                      'CLOUD SYNC v1.0',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_ethernet_rounded),
                    tooltip: 'Server Connection Settings',
                    onPressed: _showServerConfigDialog,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Streak Safeguard Teaser Card
              AuroraCard(
                hasAuroraBorder: true,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.streakFire,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Cloud Sync & Backup',
                            style: AppTypography.titleMedium(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'Sign in to synchronize your habits and streaks.',
                            style: AppTypography.labelMedium(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Brand Logo & Starting Motivation
              const HabitFlowLogo(size: 46),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final q = MotivationQuotesService.getRandomQuote();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: q.accentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(q.icon, size: 16, color: q.accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '“${q.quote}” — ${q.author}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Headline
              Text(
                _isSignUp ? 'Create Account' : 'Welcome Back',
                style: AppTypography.displayMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? 'Start building compound daily habits on cloud storage.'
                    : 'Enter your credentials to access your flow state.',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Error Banner if error exists
              if (authState.errorMessage != null && authState.errorMessage!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Name Field (only for Sign Up)
              if (_isSignUp) ...[
                HabitTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Alex Rivera',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
              ],

              // Email Field
              HabitTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'alex@habitflow.pro',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              HabitTextField(
                controller: _passwordController,
                label: 'Password',
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Toggle Sign In / Sign Up Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                    });
                  },
                  child: Text(
                    _isSignUp
                        ? 'Already have an account? Sign In'
                        : 'Don\'t have an account? Sign Up',
                    style: AppTypography.labelMedium(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Submit CTA Button
              HabitButton(
                label: _isSignUp ? 'Create HabitFlow Account' : 'Sign In to HabitFlow',
                isLoading: isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 12),

              // Instant 1-Tap Demo Sign In Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: AppColors.primary.withOpacity(0.4),
                  ),
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).signInDemoUser();
                  context.go('/today');
                },
                icon: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                label: Text(
                  '1-Tap Demo Sign In (Explore Instantly)',
                  style: AppTypography.button(color: AppColors.primary).copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppColors.darkSurfaceContainerHigh
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'OR',
                      style: AppTypography.labelMedium(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark
                          ? AppColors.darkSurfaceContainerHigh
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Offline Mode CTA
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).continueOffline();
                    context.go('/today');
                  },
                  icon: const Icon(Icons.offline_bolt_outlined, size: 18),
                  label: const Text('Continue in Offline Mode'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}
}
