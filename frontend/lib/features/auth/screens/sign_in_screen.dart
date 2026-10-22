import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/components/aurora_card.dart';
import '../../../core/components/habit_button.dart';
import '../../../core/components/habit_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController(text: 'alex@habitflow.pro');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/today');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            'Your 14-Day Streak is Active',
                            style: AppTypography.titleMedium(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ).copyWith(fontSize: 14),
                          ),
                          Text(
                            'Sign in to synchronize with cloud backups.',
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
              const SizedBox(height: 28),
              // Headline
              Text(
                'Welcome Back',
                style: AppTypography.displayMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter your credentials to access your flow state.',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: AppTypography.labelMedium(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sign In CTA
              HabitButton(
                label: 'Sign In to HabitFlow',
                isLoading: _isLoading,
                onPressed: _handleSignIn,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 24),
              // Google OAuth Button
              HabitButton(
                label: 'Continue with Google',
                variant: HabitButtonVariant.outline,
                icon: Icons.g_mobiledata_rounded,
                onPressed: _handleSignIn,
              ),
              const SizedBox(height: 12),
              // Passkey / Biometric Option
              HabitButton(
                label: 'Biometric / Passkey Login',
                variant: HabitButtonVariant.ghost,
                icon: Icons.fingerprint_rounded,
                onPressed: _handleSignIn,
              ),
              const SizedBox(height: 24),
              // Offline Mode CTA
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/today'),
                  icon: const Icon(Icons.offline_bolt_outlined, size: 18),
                  label: const Text('Continue in Offline Mode'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
