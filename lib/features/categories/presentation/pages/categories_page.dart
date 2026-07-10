import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:billlens/core/router/app_routes.dart';
import 'package:billlens/core/router/context_ext.dart';
import 'package:billlens/core/theme/app_colors.dart';
import 'package:billlens/core/widgets/app_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category model
// ─────────────────────────────────────────────────────────────────────────────
class _Category {
  final String name;
  final String type; // 'Business' | 'Personal'
  final Color color;

  const _Category({
    required this.name,
    required this.type,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Default categories
// ─────────────────────────────────────────────────────────────────────────────
final List<_Category> _defaultBusiness = [
  const _Category(
      name: 'Client Meeting', type: 'Business', color: Color(0xFF2563EB)),
  const _Category(name: 'Travel', type: 'Business', color: Color(0xFF7C3AED)),
  const _Category(
      name: 'Office Supplies', type: 'Business', color: Color(0xFFF59E0B)),
  const _Category(name: 'Software', type: 'Business', color: Color(0xFF10B981)),
  const _Category(
      name: 'Meals & Dining', type: 'Business', color: Color(0xFFEF4444)),
  const _Category(
      name: 'Marketing', type: 'Business', color: Color(0xFFEC4899)),
  const _Category(name: 'Training', type: 'Business', color: Color(0xFF06B6D4)),
  const _Category(
      name: 'Equipment', type: 'Business', color: Color(0xFF8B5CF6)),
  const _Category(
      name: 'Utilities', type: 'Business', color: Color(0xFF64748B)),
  const _Category(
      name: 'Subscriptions', type: 'Business', color: Color(0xFF0EA5E9)),
];

final List<_Category> _defaultPersonal = [
  const _Category(
      name: 'Groceries', type: 'Personal', color: Color(0xFF10B981)),
  const _Category(
      name: 'Entertainment', type: 'Personal', color: Color(0xFFF59E0B)),
  const _Category(
      name: 'Healthcare', type: 'Personal', color: Color(0xFFEF4444)),
  const _Category(
      name: 'Transport', type: 'Personal', color: Color(0xFF2563EB)),
  const _Category(name: 'Shopping', type: 'Personal', color: Color(0xFFEC4899)),
];

// ─────────────────────────────────────────────────────────────────────────────
// Picker colors
// ─────────────────────────────────────────────────────────────────────────────
const List<Color> _pickerColors = [
  Color(0xFF2563EB),
  Color(0xFF10B981),
  Color(0xFF7C3AED),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
  Color(0xFF64748B),
];

// ─────────────────────────────────────────────────────────────────────────────
// Categories Page
// ─────────────────────────────────────────────────────────────────────────────
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late List<_Category> _business;
  late List<_Category> _personal;

  @override
  void initState() {
    super.initState();
    _business = List.of(_defaultBusiness);
    _personal = List.of(_defaultPersonal);
  }

  List<_Category> get _allCategories => [..._business, ..._personal];

  void _deleteCategory(_Category cat) {
    setState(() {
      _business.remove(cat);
      _personal.remove(cat);
    });
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCategorySheet(
        onSave: (cat) {
          setState(() {
            if (cat.type == 'Business') {
              _business.add(cat);
            } else {
              _personal.add(cat);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppPageBar(
        title: 'Categories',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => context.safePop(AppRoutes.dashboard),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            onPressed: _showAddSheet,
            tooltip: 'Add category',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              _StatChip(
                label: 'Total',
                value: '${_allCategories.length}',
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Business',
                value: '${_business.length}',
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              _StatChip(
                label: 'Personal',
                value: '${_personal.length}',
                color: const Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppSectionHeader(title: 'Business (${_business.length})'),
          const SizedBox(height: 8),
          AppGroupedSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: _business.asMap().entries.map((entry) {
                final cat = entry.value;
                return Column(
                  children: [
                    _CategoryTile(
                      category: cat,
                      onDelete: () => _deleteCategory(cat),
                      onEdit: () => _showAddSheet(),
                    ),
                    if (entry.key < _business.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          AppSectionHeader(title: 'Personal (${_personal.length})'),
          const SizedBox(height: 8),
          AppGroupedSurface(
            padding: EdgeInsets.zero,
            child: Column(
              children: _personal.asMap().entries.map((entry) {
                final cat = entry.value;
                return Column(
                  children: [
                    _CategoryTile(
                      category: cat,
                      onDelete: () => _deleteCategory(cat),
                      onEdit: () => _showAddSheet(),
                    ),
                    if (entry.key < _personal.length - 1)
                      const Divider(height: 1, indent: 72),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Chip
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Tile
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final _Category category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _CategoryTile({
    required this.category,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Colored circle with initial
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                category.name[0].toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: category.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Name + type badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category.type,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Edit
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: colorScheme.onSurfaceVariant),
            onPressed: onEdit,
            tooltip: 'Edit category',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: Color(0xFFEF4444)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text('Delete Category',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  content: Text(
                      'Remove "${category.name}" from your categories?',
                      style: GoogleFonts.outfit()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF64748B))),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Delete',
                          style: GoogleFonts.outfit(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Delete category',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Category Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AddCategorySheet extends StatefulWidget {
  final void Function(_Category) onSave;

  const _AddCategorySheet({required this.onSave});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  String _selectedType = 'Business';
  Color _selectedColor = _pickerColors[0];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    widget.onSave(_Category(
      name: name,
      type: _selectedType,
      color: _selectedColor,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + bottomInset),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Add Category',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameController,
            style:
                GoogleFonts.outfit(fontSize: 14, color: colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Category Name',
              labelStyle: GoogleFonts.outfit(
                  fontSize: 13, color: colorScheme.onSurfaceVariant),
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
                borderSide:
                    const BorderSide(color: Color(0xFF2563EB), width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Type toggle
          Text(
            'Type',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Business', 'Personal'].map((type) {
              final selected = _selectedType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: type == 'Business' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF2563EB)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2563EB)
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Color picker
          Text(
            'Color',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _pickerColors.map((color) {
              final selected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Save button
          PrimaryButton(
            text: 'Save Category',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
