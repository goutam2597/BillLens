import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String _selectedCurrency = 'USD';

  static const List<Map<String, String>> _currencies = [
    {'code': 'USD', 'label': 'USD – US Dollar'},
    {'code': 'EUR', 'label': 'EUR – Euro'},
    {'code': 'GBP', 'label': 'GBP – British Pound'},
    {'code': 'INR', 'label': 'INR – Indian Rupee'},
    {'code': 'JPY', 'label': 'JPY – Japanese Yen'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          RegisterEvent(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            businessName: _businessController.text.trim().isEmpty
                ? null
                : _businessController.text.trim(),
            currency: _selectedCurrency,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 2,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => context.safePop(AppRoutes.welcome),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go(AppRoutes.dashboard);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Join BillLens and simplify your expenses',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Name
                    AppTextField(
                      label: 'Full Name *',
                      hint: 'John Doe',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
                    AppTextField(
                      label: 'Email Address *',
                      hint: 'you@example.com',
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(v.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Password
                    AppTextField(
                      label: 'Password *',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Confirm Password
                    AppTextField(
                      label: 'Confirm Password *',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        tooltip:
                            _obscureConfirm ? 'Show password' : 'Hide password',
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Business Name (optional)
                    AppTextField(
                      label: 'Business Name (optional)',
                      hint: 'My Company Ltd.',
                      controller: _businessController,
                      prefixIcon: const Icon(Icons.business_outlined),
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 18),

                    // Currency dropdown
                    Text(
                      'Currency *',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(14),
                          dropdownColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: textSecondary),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: textPrimary,
                          ),
                          items: _currencies
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c['code'],
                                  child: Text(
                                    c['label']!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCurrency = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Create Account button
                    PrimaryButton(
                      text: 'Create Account',
                      isLoading: isLoading,
                      onPressed: _handleRegister,
                      height: 54,
                    ),

                    const SizedBox(height: 28),

                    // Login link
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.login),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
