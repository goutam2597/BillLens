import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

class CheckoutPage extends StatefulWidget {
  final String planId;
  final bool isYearly;
  final double price;

  const CheckoutPage({
    super.key,
    required this.planId,
    required this.isYearly,
    required this.price,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGateway = 'card';
  bool _isProcessing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  final List<Map<String, dynamic>> _gateways = [
    {'id': 'card', 'name': 'Credit / Debit Card', 'icon': Icons.credit_card},
    {'id': 'paypal', 'name': 'PayPal', 'icon': Icons.account_balance_wallet},
    {'id': 'google_pay', 'name': 'Google Pay', 'icon': Icons.g_mobiledata},
    {'id': 'apple_pay', 'name': 'Apple Pay', 'icon': Icons.apple},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simulate payment gateway processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment via ${_gateways.firstWhere((g) => g['id'] == _selectedGateway)['name']} initiated.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final subTextColor = colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppPageBar(
        title: 'Checkout',
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(textColor, subTextColor),
            const SizedBox(height: 24),
            _buildBillingForm(textColor, subTextColor),
            const SizedBox(height: 24),
            _buildPaymentGateways(textColor, subTextColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: PrimaryButton(
            text: _isProcessing ? 'Processing...' : 'Pay \$${widget.price.toStringAsFixed(2)}',
            icon: const Icon(Icons.lock_outline, size: 20),
            onPressed: _isProcessing ? null : _processPayment,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(Color textColor, Color subTextColor) {
    return AppGroupedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isYearly ? 'Premium Yearly' : 'Premium Monthly',
                style: GoogleFonts.outfit(fontSize: 15, color: subTextColor),
              ),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingForm(Color textColor, Color subTextColor) {
    return AppGroupedSurface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing Information',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _zipController,
                    label: 'ZIP / Postal',
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _countryController,
              label: 'Country',
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPaymentGateways(Color textColor, Color subTextColor) {
    return AppGroupedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._gateways.map((gateway) {
            final isSelected = _selectedGateway == gateway['id'];
            return InkWell(
              onTap: () => setState(() => _selectedGateway = gateway['id'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      gateway['icon'] as IconData,
                      color: isSelected ? AppColors.primary : subTextColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        gateway['name'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : textColor,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
