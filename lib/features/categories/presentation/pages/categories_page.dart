import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Categories',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFF2563EB), size: 24),
            onPressed: _showAddSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // Stats row
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
                color: const Color(0xFF7C3AED),
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

          // Business section
          _SectionHeader(
            title: 'Business',
            count: _business.length,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 12),
          ..._business.map(
            (cat) => _CategoryTile(
              category: cat,
              onDelete: () => _deleteCategory(cat),
              onEdit: () => _showAddSheet(),
            ),
          ),

          const SizedBox(height: 24),

          // Personal section
          _SectionHeader(
            title: 'Personal',
            count: _personal.length,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          ..._personal.map(
            (cat) => _CategoryTile(
              category: cat,
              onDelete: () => _deleteCategory(cat),
              onEdit: () => _showAddSheet(),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
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
                color: color.withValues(alpha: 0.8),
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
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.type == 'Business'
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.type,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: category.type == 'Business'
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 18, color: Color(0xFF64748B)),
            onPressed: onEdit,
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
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: const Color(0xFFE2E8F0),
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
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameController,
            style: GoogleFonts.outfit(
                fontSize: 14, color: const Color(0xFF0F172A)),
            decoration: InputDecoration(
              labelText: 'Category Name',
              labelStyle: GoogleFonts.outfit(
                  fontSize: 13, color: const Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
              color: const Color(0xFF64748B),
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
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        type,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : const Color(0xFF64748B),
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
              color: const Color(0xFF64748B),
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
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Save Category',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
