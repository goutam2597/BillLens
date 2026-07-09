import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upgrade to Premium',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero Icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'Go Premium',
              style: GoogleFonts.outfit(
                fontSize: 28,
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
            _buildFreePlanCard(surfaceColor, textColor, subTextColor, isDark),
            const SizedBox(height: 16),

            // Premium Plan Card
            _buildPremiumPlanCard(textColor),
            const SizedBox(height: 16),

            // Comparison Table
            _buildComparisonList(surfaceColor, textColor, subTextColor, isDark),
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
    );
  }

  Widget _buildFreePlanCard(
      Color surfaceColor, Color textColor, Color subTextColor, bool isDark) {
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.5),
      ),
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
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D3D8F), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(23),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    ),
                    borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 20),

            // Upgrade Button
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Redirecting to payment...',
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Upgrade Now',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonList(
      Color surfaceColor, Color textColor, Color subTextColor, bool isDark) {
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
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

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
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
