import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/utils/app_utils.dart';
import 'package:billlens/core/widgets/app_widgets.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../helpers/expense_ui_helper.dart';

const List<String> _filterChips = [
  'All',
  'Today',
  'This Week',
  'This Month',
];

// ---------------------------------------------------------------------------
// Expense List Page
// ---------------------------------------------------------------------------
class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExpenseListView();
  }
}

class _ExpenseListView extends StatefulWidget {
  const _ExpenseListView();

  @override
  State<_ExpenseListView> createState() => _ExpenseListViewState();
}

class _ExpenseListViewState extends State<_ExpenseListView> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    final filter = _filterChips[_selectedFilter];
    var list = expenses;
    if (filter != 'All') {
      list = list.where((e) => isWithinRange(e.date, filter)).toList();
    }
    return list;
  }

  void _onSearchChanged(String value) {
    final bloc = context.read<ExpenseBloc>();
    if (value.trim().isEmpty) {
      bloc.add(const LoadExpensesRequested());
    } else {
      bloc.add(SearchExpensesRequested(value.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addExpense),
        backgroundColor: AppColors.primary,
        tooltip: 'Add expense',
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final expenses =
              state is ExpenseLoaded ? state.expenses : <Expense>[];
          final filtered = _applyFilters(expenses);
          final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async =>
                context.read<ExpenseBloc>().add(const LoadExpensesRequested()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                AppRootSliverBar(
                  title: 'Expenses',
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _SearchBar(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        AppGroupedSurface(
                          child: Column(
                            children: [
                              _FilterChipRow(
                                selected: _selectedFilter,
                                onSelected: (i) =>
                                    setState(() => _selectedFilter = i),
                              ),
                              const SizedBox(height: 16),
                              _TotalSummary(
                                total: AppUtils.formatCurrency(total),
                                count: filtered.length,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                  sliver: _buildBody(state: state, filtered: filtered),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody({
    required ExpenseState state,
    required List<Expense> filtered,
  }) {
    if (state is ExpenseLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (state is ExpenseError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context
                    .read<ExpenseBloc>()
                    .add(const LoadExpensesRequested()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (filtered.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(),
      );
    }
    return SliverList.builder(
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final expense = filtered[i];
        final meta = categoryMeta(expense.categoryName);
        return _ExpenseLedgerRow(
          expense: expense,
          icon: meta.icon,
          iconColor: meta.color,
          showDivider: i < filtered.length - 1,
          onTap: () => context.push('/expenses/${expense.id}'),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.outfit(fontSize: 14, color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        hintStyle: GoogleFonts.outfit(color: colorScheme.onSurfaceVariant),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip row
// ---------------------------------------------------------------------------
class _FilterChipRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _FilterChipRow({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filterChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final isSelected = i == selected;
          return ChoiceChip(
            label: Text(_filterChips[i]),
            selected: isSelected,
            onSelected: (_) => onSelected(i),
            showCheckmark: false,
            backgroundColor: colorScheme.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color:
                  isSelected ? AppColors.primary : colorScheme.outlineVariant,
            ),
            labelStyle: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total summary card
// ---------------------------------------------------------------------------
class _TotalSummary extends StatelessWidget {
  final String total;
  final int count;

  const _TotalSummary({
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period total',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                total,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count expense${count == 1 ? '' : 's'}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Expense list card
// ---------------------------------------------------------------------------
class _ExpenseLedgerRow extends StatelessWidget {
  final Expense expense;
  final IconData icon;
  final Color iconColor;
  final bool showDivider;
  final VoidCallback onTap;

  const _ExpenseLedgerRow({
    required this.expense,
    required this.icon,
    required this.iconColor,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: colorScheme.outlineVariant))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.vendor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.categoryName ?? 'Uncategorized',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppUtils.formatCurrency(expense.amount,
                      currency: expense.currency),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatExpenseDate(expense.date),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0x1A2563EB),
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
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding your expenses to track your spending.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addExpense),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              'Add Expense',
              style:
                  GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
