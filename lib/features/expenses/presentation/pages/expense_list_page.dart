import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/router/app_routes.dart';

// ---------------------------------------------------------------------------
// Local model
// ---------------------------------------------------------------------------
class _ExpenseItem {
  final String id;
  final String vendor;
  final String category;
  final String amount;
  final double amountValue;
  final String date;
  final IconData icon;
  final Color iconColor;

  const _ExpenseItem({
    required this.id,
    required this.vendor,
    required this.category,
    required this.amount,
    required this.amountValue,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}

// ---------------------------------------------------------------------------
// Dummy data (10+ items)
// ---------------------------------------------------------------------------
const List<_ExpenseItem> _allExpenses = [
  _ExpenseItem(
    id: '1',
    vendor: 'Starbucks',
    category: 'Client Meeting',
    amount: '\$12.50',
    amountValue: 12.50,
    date: '09 Jul 2026',
    icon: Icons.local_cafe_rounded,
    iconColor: Color(0xFF6F4E37),
  ),
  _ExpenseItem(
    id: '2',
    vendor: 'Uber',
    category: 'Travel',
    amount: '\$25.00',
    amountValue: 25.00,
    date: '08 Jul 2026',
    icon: Icons.directions_car_rounded,
    iconColor: Color(0xFF1E293B),
  ),
  _ExpenseItem(
    id: '3',
    vendor: 'Staples',
    category: 'Office Supplies',
    amount: '\$75.00',
    amountValue: 75.00,
    date: '07 Jul 2026',
    icon: Icons.inventory_2_rounded,
    iconColor: Color(0xFFEF4444),
  ),
  _ExpenseItem(
    id: '4',
    vendor: 'Amazon',
    category: 'Software',
    amount: '\$49.99',
    amountValue: 49.99,
    date: '06 Jul 2026',
    icon: Icons.shopping_bag_rounded,
    iconColor: Color(0xFFF59E0B),
  ),
  _ExpenseItem(
    id: '5',
    vendor: 'Marriott Hotel',
    category: 'Accommodation',
    amount: '\$189.00',
    amountValue: 189.00,
    date: '05 Jul 2026',
    icon: Icons.hotel_rounded,
    iconColor: Color(0xFF8B5CF6),
  ),
  _ExpenseItem(
    id: '6',
    vendor: 'Delta Airlines',
    category: 'Travel',
    amount: '\$340.00',
    amountValue: 340.00,
    date: '04 Jul 2026',
    icon: Icons.flight_rounded,
    iconColor: Color(0xFF2563EB),
  ),
  _ExpenseItem(
    id: '7',
    vendor: 'Whole Foods',
    category: 'Meals',
    amount: '\$47.20',
    amountValue: 47.20,
    date: '03 Jul 2026',
    icon: Icons.restaurant_rounded,
    iconColor: Color(0xFF10B981),
  ),
  _ExpenseItem(
    id: '8',
    vendor: 'Adobe',
    category: 'Software',
    amount: '\$54.99',
    amountValue: 54.99,
    date: '02 Jul 2026',
    icon: Icons.design_services_rounded,
    iconColor: Color(0xFFEC4899),
  ),
  _ExpenseItem(
    id: '9',
    vendor: 'FedEx',
    category: 'Shipping',
    amount: '\$18.75',
    amountValue: 18.75,
    date: '01 Jul 2026',
    icon: Icons.local_shipping_rounded,
    iconColor: Color(0xFFFF6B35),
  ),
  _ExpenseItem(
    id: '10',
    vendor: 'Microsoft 365',
    category: 'Software',
    amount: '\$22.00',
    amountValue: 22.00,
    date: '30 Jun 2026',
    icon: Icons.cloud_rounded,
    iconColor: Color(0xFF06B6D4),
  ),
  _ExpenseItem(
    id: '11',
    vendor: 'The UPS Store',
    category: 'Office',
    amount: '\$9.06',
    amountValue: 9.06,
    date: '29 Jun 2026',
    icon: Icons.print_rounded,
    iconColor: Color(0xFF6366F1),
  ),
];

const List<String> _filterChips = [
  'All',
  'Today',
  'This Week',
  'This Month',
  'Custom',
];

// ---------------------------------------------------------------------------
// Expense List Page
// ---------------------------------------------------------------------------
class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  int _selectedFilter = 0;
  bool _searchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ExpenseItem> get _filteredExpenses {
    if (_searchQuery.isEmpty) return _allExpenses;
    final q = _searchQuery.toLowerCase();
    return _allExpenses
        .where((e) =>
            e.vendor.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q))
        .toList();
  }

  double get _total =>
      _filteredExpenses.fold(0.0, (sum, e) => sum + e.amountValue);

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final expenses = _filteredExpenses;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(
          isDark, surfaceColor, textPrimary, textSecondary, borderColor),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.addExpense),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: Column(
        children: [
          // Search bar (collapsible)
          if (_searchVisible)
            _SearchBar(
              controller: _searchController,
              isDark: isDark,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          // Filter chips
          _FilterChipRow(
            selected: _selectedFilter,
            isDark: isDark,
            onSelected: (i) => setState(() => _selectedFilter = i),
          ),
          // Total summary card
          _TotalCard(
            total: '\$${_total.toStringAsFixed(2)}',
            count: expenses.length,
            isDark: isDark,
            surfaceColor: surfaceColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            borderColor: borderColor,
          ),
          // List or empty state
          Expanded(
            child: expenses.isEmpty
                ? _EmptyState(
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary)
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: expenses.length,
                      itemBuilder: (ctx, i) {
                        final e = expenses[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ExpenseListCard(
                            expense: e,
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            borderColor: borderColor,
                            onTap: () => context.go('/expenses/${e.id}'),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color surfaceColor,
      Color textPrimary, Color textSecondary, Color borderColor) {
    return AppBar(
      backgroundColor: surfaceColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: textPrimary, size: 20),
        onPressed: () => context.go(AppRoutes.dashboard),
      ),
      title: Text(
        'Expenses',
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _searchVisible ? Icons.search_off_rounded : Icons.search_rounded,
            color: textPrimary,
          ),
          onPressed: () {
            setState(() {
              _searchVisible = !_searchVisible;
              if (!_searchVisible) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list_rounded, color: textPrimary),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Search expenses...',
          hintStyle: GoogleFonts.outfit(
            color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.primary, size: 20),
          filled: true,
          fillColor: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row
// ---------------------------------------------------------------------------
class _FilterChipRow extends StatelessWidget {
  final int selected;
  final bool isDark;
  final ValueChanged<int> onSelected;

  const _FilterChipRow({
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filterChips.length,
        itemBuilder: (ctx, i) {
          final isSelected = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight),
                  ),
                ),
                child: Text(
                  _filterChips[i],
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total summary card
// ---------------------------------------------------------------------------
class _TotalCard extends StatelessWidget {
  final String total;
  final int count;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;

  const _TotalCard({
    required this.total,
    required this.count,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4D2563EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calculate_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            '$count expense${count == 1 ? '' : 's'}',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            'Total: ',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          Text(
            total,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expense list card
// ---------------------------------------------------------------------------
class _ExpenseListCard extends StatelessWidget {
  final _ExpenseItem expense;
  final bool isDark;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final VoidCallback onTap;

  const _ExpenseListCard({
    required this.expense,
    required this.isDark,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow:
              isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: expense.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(expense.icon, color: expense.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.vendor,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.category,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expense.amount,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expense.date,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _EmptyState({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Expenses Found',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding your expenses to track your spending.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.addExpense),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(
                'Add Expense',
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
