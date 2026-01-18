import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:remindlyf/data/models/expense.dart';
import 'package:remindlyf/data/models/expense_category.dart';
import 'package:remindlyf/domain/providers/money_provider.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  final int? taskId;
  final String? taskTitle;
  final DateTime? expenseDate;
  final Expense? existingExpense; // For editing

  const AddExpenseSheet({
    super.key,
    this.taskId,
    this.taskTitle,
    this.expenseDate,
    this.existingExpense,
  });

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  ExpenseCategory? _selectedCategory;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.existingExpense?.amount.toStringAsFixed(0) ?? '',
    );
    _noteController = TextEditingController(
      text: widget.existingExpense?.note ?? '',
    );
    if (widget.existingExpense != null) {
      _selectedPaymentMethod = widget.existingExpense!.paymentMethod;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const Gap(20),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.existingExpense != null
                            ? 'Edit Expense'
                            : 'Add Expense',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.taskTitle != null) ...[
                        const Gap(2),
                        Text(
                          'For: ${widget.taskTitle}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Gap(28),

            // Amount input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withAlpha(30)),
              ),
              child: Column(
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Gap(4),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Quick amounts
            Row(
              children: [100, 200, 500, 1000].map((amount) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        _amountController.text = amount.toString();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('₹$amount'),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(24),

            // Payment Method selection
            Text(
              'Payment Method',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _selectedPaymentMethod = PaymentMethod.cash,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _selectedPaymentMethod == PaymentMethod.cash
                            ? const Color(0xFF10B981).withAlpha(20)
                            : colorScheme.surfaceContainerHighest.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPaymentMethod == PaymentMethod.cash
                              ? const Color(0xFF10B981)
                              : colorScheme.outline.withAlpha(30),
                          width: _selectedPaymentMethod == PaymentMethod.cash
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.money_rounded,
                            color: _selectedPaymentMethod == PaymentMethod.cash
                                ? const Color(0xFF10B981)
                                : colorScheme.outline,
                            size: 20,
                          ),
                          const Gap(8),
                          Text(
                            'Cash',
                            style: TextStyle(
                              color:
                                  _selectedPaymentMethod == PaymentMethod.cash
                                  ? const Color(0xFF10B981)
                                  : colorScheme.outline,
                              fontWeight:
                                  _selectedPaymentMethod == PaymentMethod.cash
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _selectedPaymentMethod = PaymentMethod.upi,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _selectedPaymentMethod == PaymentMethod.upi
                            ? const Color(0xFF6366F1).withAlpha(20)
                            : colorScheme.surfaceContainerHighest.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPaymentMethod == PaymentMethod.upi
                              ? const Color(0xFF6366F1)
                              : colorScheme.outline.withAlpha(30),
                          width: _selectedPaymentMethod == PaymentMethod.upi
                              ? 2
                              : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            color: _selectedPaymentMethod == PaymentMethod.upi
                                ? const Color(0xFF6366F1)
                                : colorScheme.outline,
                            size: 20,
                          ),
                          const Gap(8),
                          Text(
                            'UPI',
                            style: TextStyle(
                              color: _selectedPaymentMethod == PaymentMethod.upi
                                  ? const Color(0xFF6366F1)
                                  : colorScheme.outline,
                              fontWeight:
                                  _selectedPaymentMethod == PaymentMethod.upi
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Category selection with search
            Text(
              'Category',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(12),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.outline,
                          size: 20,
                        ),
                        const Gap(10),
                        const Expanded(
                          child: Text(
                            'Create categories in Money Manager first',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Load selected category if editing
                if (widget.existingExpense != null &&
                    _selectedCategory == null) {
                  _selectedCategory = categories.firstWhere(
                    (c) => c.id == widget.existingExpense!.categoryId,
                    orElse: () => categories.first,
                  );
                }

                return _CategorySearchSelector(
                  categories: categories.where((c) => c.isActive).toList(),
                  selectedCategory: _selectedCategory,
                  onSelected: (cat) => setState(() => _selectedCategory = cat),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
            const Gap(20),

            // Note input
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add a note about this expense',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notes),
              ),
            ),
            const Gap(28),

            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _saveExpense,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.existingExpense != null
                          ? 'Update Expense'
                          : 'Add Expense',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(taskRepositoryProvider);

      final expense =
          widget.existingExpense?.copyWith(
            amount: amount,
            categoryId: _selectedCategory!.id,
            paymentMethod: _selectedPaymentMethod,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          ) ??
          (Expense()
            ..amount = amount
            ..categoryId = _selectedCategory!.id
            ..taskId = widget.taskId
            ..paymentMethod = _selectedPaymentMethod
            ..note = _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim()
            ..expenseDate = widget.expenseDate ?? DateTime.now());

      if (widget.existingExpense != null) {
        await repository.updateExpense(expense);
      } else {
        await repository.addExpense(expense);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('Failed to save expense');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// Category search selector widget
class _CategorySearchSelector extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final ExpenseCategory? selectedCategory;
  final Function(ExpenseCategory) onSelected;

  const _CategorySearchSelector({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  State<_CategorySearchSelector> createState() =>
      _CategorySearchSelectorState();
}

class _CategorySearchSelectorState extends State<_CategorySearchSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getTypeColor(ExpenseType type) {
    switch (type) {
      case ExpenseType.needs:
        return const Color(0xFF3B82F6); // Blue
      case ExpenseType.wants:
        return const Color(0xFFF59E0B); // Yellow
      case ExpenseType.savings:
        return const Color(0xFF10B981); // Green
    }
  }

  String _getTypeLabel(ExpenseType type) {
    switch (type) {
      case ExpenseType.needs:
        return 'Needs';
      case ExpenseType.wants:
        return 'Wants';
      case ExpenseType.savings:
        return 'Savings';
    }
  }

  IconData _getTypeIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.needs:
        return Icons.eco;
      case ExpenseType.wants:
        return Icons.shopping_bag;
      case ExpenseType.savings:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter categories by search query
    final filtered = widget.categories.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected category display
        if (widget.selectedCategory != null && !_showResults) ...[
          GestureDetector(
            onTap: () => setState(() => _showResults = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _getTypeColor(
                  widget.selectedCategory!.type,
                ).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getTypeColor(
                    widget.selectedCategory!.type,
                  ).withAlpha(60),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(widget.selectedCategory!.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(widget.selectedCategory!.type),
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedCategory!.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getTypeLabel(widget.selectedCategory!.type),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getTypeColor(widget.selectedCategory!.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit, size: 18, color: colorScheme.outline),
                ],
              ),
            ),
          ),
        ] else ...[
          // Search input
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withAlpha(30)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {
                _searchQuery = value;
                _showResults = true;
              }),
              onTap: () => setState(() => _showResults = true),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const Gap(12),

          // Results list
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No categories found',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final cat = filtered[index];
                      final color = _getTypeColor(cat.type);
                      final isSelected = widget.selectedCategory?.id == cat.id;

                      return GestureDetector(
                        onTap: () {
                          widget.onSelected(cat);
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _showResults = false;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withAlpha(30)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: color.withAlpha(60))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  cat.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getTypeLabel(cat.type),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                              if (isSelected) ...[
                                const Gap(8),
                                Icon(Icons.check, size: 16, color: color),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

// Type label widget
class _TypeLabel extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _TypeLabel({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const Gap(6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Category chip widget
class _CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withAlpha(40),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          category.name,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
