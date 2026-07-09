import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
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
    final surfaceColor =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
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
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Join BillLens and simplify your expenses',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Name
                    _buildLabel('Full Name *', textSecondary),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'John Doe',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      borderColor: borderColor,
                      surfaceColor: surfaceColor,
                      textColor: textPrimary,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // Email
                    _buildLabel('Email Address *', textSecondary),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      borderColor: borderColor,
                      surfaceColor: surfaceColor,
                      textColor: textPrimary,
                      keyboardType: TextInputType.emailAddress,
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
                    _buildLabel('Password *', textSecondary),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isDark: isDark,
                      borderColor: borderColor,
                      surfaceColor: surfaceColor,
                      textColor: textPrimary,
                      obscureText: _obscurePassword,
                      suffix: IconButton(
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
                    _buildLabel('Confirm Password *', textSecondary),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isDark: isDark,
                      borderColor: borderColor,
                      surfaceColor: surfaceColor,
                      textColor: textPrimary,
                      obscureText: _obscureConfirm,
                      suffix: IconButton(
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
                    _buildLabel('Business Name (optional)', textSecondary),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _businessController,
                      hint: 'My Company Ltd.',
                      icon: Icons.business_outlined,
                      isDark: isDark,
                      borderColor: borderColor,
                      surfaceColor: surfaceColor,
                      textColor: textPrimary,
                    ),

                    const SizedBox(height: 18),

                    // Currency dropdown
                    _buildLabel('Currency *', textSecondary),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
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
                    _RegisterButton(
                      isLoading: isLoading,
                      onTap: _handleRegister,
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

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color borderColor,
    required Color surfaceColor,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.outfit(fontSize: 15, color: textColor),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
        ),
        prefixIcon: Icon(icon,
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: surfaceColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

// ── Register button ───────────────────────────────────────────────────────────

class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _RegisterButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF93C5FD), Color(0xFF60A5FA)])
              : const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading ? [] : AppColors.primaryShadow,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Create Account',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
