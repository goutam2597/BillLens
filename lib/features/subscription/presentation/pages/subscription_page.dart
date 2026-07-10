import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isYearly = false;

  final List<Map<String, dynamic>> _premiumFeatures = [
    {'label': 'Unlimited scans', 'included': true},
    {'label': 'No ads', 'included': true},
    {'label': 'Full AI insights', 'included': true},
    {'label': 'Cloud backup', 'included': true},
    {'label': 'Advanced reports', 'included': true},
    {'label': 'Priority support', 'included': true},
  ];

  final List<Map<String, dynamic>> _freeFeatures = [
    {'label': '10 scans/month', 'included': false},
    {'label': 'Basic reports only', 'included': false},
    {'label': 'Ads enabled', 'included': false},
    {'label': 'Limited AI insights', 'included': false},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final subTextColor = colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppPageBar(
        title: 'Upgrade to Premium',
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          tooltip: 'Close',
          onPressed: () => context.safePop(AppRoutes.profile),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.premiumGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Go Premium',
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock the full power of BillLens',
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: subTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Free Plan Card
            _buildFreePlanCard(textColor, subTextColor),
            const SizedBox(height: 16),

            // Premium Plan Card
            _buildPremiumPlanCard(textColor),
            const SizedBox(height: 16),

            // Comparison Table
            _buildComparisonList(textColor, subTextColor),
            const SizedBox(height: 24),

            // Restore Purchase
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Restoring purchases...',
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF2563EB),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: Text(
                'Restore Purchase',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: subTextColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: PrimaryButton(
            text: _isYearly ? 'Upgrade Yearly' : 'Upgrade Monthly',
            icon: const Icon(Icons.workspace_premium_outlined, size: 20),
            onPressed: _startUpgrade,
          ),
        ),
      ),
    );
  }

  void _startUpgrade() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Redirecting to payment...',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFreePlanCard(Color textColor, Color subTextColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppGroupedSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Free Plan',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Current Plan',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\$0 / month',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 14),
          ..._freeFeatures.map((f) => _buildFeatureRow(
                label: f['label'] as String,
                included: false,
                textColor: textColor,
                subTextColor: subTextColor,
              )),
        ],
      ),
    );
  }

  Widget _buildPremiumPlanCard(Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3D8F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Premium',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'BEST VALUE',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Billing Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isYearly = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isYearly ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Monthly',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: !_isYearly
                              ? const Color(0xFF1D3D8F)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isYearly = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isYearly ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Yearly',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isYearly
                              ? const Color(0xFF1D3D8F)
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Text(
            _isYearly ? '\$79.99 / year' : '\$9.99 / month',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (_isYearly)
            Text(
              'Save 33% vs monthly',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 16),

          ..._premiumFeatures.map((f) => _buildFeatureRow(
                label: f['label'] as String,
                included: true,
                textColor: Colors.white,
                subTextColor: Colors.white60,
              )),
        ],
      ),
    );
  }

  Widget _buildComparisonList(Color textColor, Color subTextColor) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    final features = [
      'Unlimited receipt scans',
      'Ad-free experience',
      'Full AI-powered insights',
      'Cloud backup & sync',
      'Advanced reporting',
      'Priority support',
    ];
    final freeFeaturesBool = [false, false, false, false, false, false];
    final premiumFeaturesBool = [true, true, true, true, true, true];

    return AppGroupedSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Feature',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: subTextColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: subTextColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Premium',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),
          ...List.generate(features.length, (i) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          features[i],
                          style: GoogleFonts.outfit(
                              fontSize: 13, color: textColor),
                        ),
                      ),
                      Expanded(
                        child: Icon(
                          freeFeaturesBool[i]
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: freeFeaturesBool[i]
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Icon(
                          premiumFeaturesBool[i]
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: premiumFeaturesBool[i]
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < features.length - 1)
                  Divider(height: 1, color: borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required String label,
    required bool included,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            color: included ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: included ? textColor : subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
