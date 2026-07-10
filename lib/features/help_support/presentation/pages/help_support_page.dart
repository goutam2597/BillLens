import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppPageBar(
        title: 'Help & Support',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.safePop(AppRoutes.dashboard),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          const AppSectionHeader(title: 'Frequently asked questions'),
          const SizedBox(height: 8),
          AppGroupedSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: const [
                _FaqTile(
                  question: 'How do I scan a receipt?',
                  answer:
                      'Tap the "Scan Receipt" button on the dashboard, align your receipt within the camera frame, and tap capture. The AI will automatically extract vendor, amount, date, and category.',
                ),
                _FaqTile(
                  question: 'Can I use the app offline?',
                  answer:
                      'Yes! BillLens is offline-first. All expenses are saved locally first and synced to the cloud when you have internet. You can scan, add, and manage expenses without any connection.',
                ),
                _FaqTile(
                  question: 'How does AI categorization work?',
                  answer:
                      'Our AI analyzes the vendor name and purchase pattern to suggest the right business category. You can always override the suggestion if needed. Premium users get more accurate AI insights.',
                ),
                _FaqTile(
                  question: 'How do I export my expenses?',
                  answer:
                      'Go to the Reports section, select the report type (Monthly, Tax, Business, etc.), and tap Export. You can export as PDF or CSV. Premium users have access to more report types.',
                ),
                _FaqTile(
                  question: 'What payment methods are supported?',
                  answer:
                      'You can track expenses with Cash, Credit Card, Debit Card, Bank Transfer, UPI, PayPal, and other payment methods. Custom payment methods can also be added.',
                ),
                _FaqTile(
                  question: 'Is my data secure?',
                  answer:
                      'Your data is encrypted both in transit and at rest. Receipt images and expense data are stored securely. We never share your data with third parties. See our Privacy Policy for details.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppSectionHeader(title: 'Contact us'),
          const SizedBox(height: 8),
          AppGroupedSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ContactCard(
                  icon: Icons.email_outlined,
                  title: 'Email support',
                  subtitle: 'support@billlens.com',
                  onTap: () => _launchUrl('mailto:support@billlens.com'),
                ),
                _ContactCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Live chat',
                  subtitle: 'Available 9AM-6PM EST',
                  onTap: () => _launchUrl('https://billlens.com/chat'),
                ),
                _ContactCard(
                  icon: Icons.help_outline_rounded,
                  title: 'Help center',
                  subtitle: 'Browse all articles',
                  onTap: () => _launchUrl('https://billlens.com/help'),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppSectionHeader(title: 'Legal'),
          const SizedBox(height: 8),
          AppGroupedSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _LinkTile(
                  title: 'Privacy policy',
                  onTap: () => _launchUrl('https://billlens.com/privacy'),
                ),
                _LinkTile(
                  title: 'Terms of service',
                  onTap: () => _launchUrl('https://billlens.com/terms'),
                ),
                _LinkTile(
                  title: 'Refund policy',
                  onTap: () => _launchUrl('https://billlens.com/refunds'),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'BillLens v1.0.0',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Smart Receipt Scanner AI',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2026 BillLens. All rights reserved.',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Text(
          question,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        iconColor: const Color(0xFF2563EB),
        collapsedIconColor: colorScheme.onSurfaceVariant,
        children: [
          Text(
            answer,
            style: GoogleFonts.outfit(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: colorScheme.outlineVariant))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool showDivider;
  const _LinkTile({
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: colorScheme.outlineVariant))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
