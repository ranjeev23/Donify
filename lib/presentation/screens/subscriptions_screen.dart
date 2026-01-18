import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/subscription_category.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/domain/providers/subscription_provider.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  final Set<int> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final categoriesAsync = ref.watch(subscriptionCategoriesProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reminders',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Add Category button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
            onPressed: () => _showAddCategoryDialog(context),
          ),
          const Gap(8),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) => subscriptionsAsync.when(
          data: (subscriptions) =>
              _buildContent(context, categories, subscriptions),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<SubscriptionCategory> categories,
    List<Subscription> subscriptions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categories.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),

          // Category List
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final categorySubscriptions = subscriptions
                .where((s) => s.categoryId == category.id)
                .toList();

            return _buildCategoryCard(context, category, categorySubscriptions)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn()
                .slideX(begin: -0.1);
          }),

          const Gap(100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withAlpha(30),
                  Colors.deepOrange.withAlpha(30),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.orange,
            ),
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const Gap(24),
          Text(
            'No Categories Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(8),
          Text(
            'Create a category to start\ntracking expiry dates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const Gap(32),
          FilledButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Category'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    SubscriptionCategory category,
    List<Subscription> subscriptions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _expandedCategories.contains(category.id);
    final categoryColor = Color(category.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: categoryColor.withAlpha(50)),
      ),
      child: Column(
        children: [
          // Category Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategories.remove(category.id);
                } else {
                  _expandedCategories.add(category.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.folder, color: categoryColor, size: 20),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subscriptions.isEmpty
                              ? 'No items'
                              : '${subscriptions.length} ${subscriptions.length == 1 ? 'item' : 'items'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add item button
                  IconButton(
                    onPressed: () => _showAddItemSheet(context, category),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 18, color: categoryColor),
                    ),
                    tooltip: 'Add item',
                  ),
                  // Delete category
                  IconButton(
                    onPressed: () => _deleteCategory(category),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error.withAlpha(150),
                    ),
                    tooltip: 'Delete category',
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: subscriptions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          30,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: colorScheme.outline,
                          ),
                          const Gap(8),
                          Text(
                            'Tap + to add an item',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      const Divider(height: 1),
                      ...subscriptions.map(
                        (subscription) => _buildSubscriptionTile(
                          context,
                          subscription,
                          categoryColor,
                        ),
                      ),
                    ],
                  ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTile(
    BuildContext context,
    Subscription subscription,
    Color categoryColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpired = subscription.isExpired;
    final isExpiringToday = subscription.isExpiringToday;
    final daysLeft = subscription.daysUntilExpiry;

    return InkWell(
      onTap: () => _showEditItemSheet(context, subscription),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.grey
                    : isExpiringToday
                    ? Colors.red
                    : daysLeft <= 7
                    ? Colors.orange
                    : Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isExpired ? TextDecoration.lineThrough : null,
                      color: isExpired ? colorScheme.outline : null,
                    ),
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      Icon(Icons.event, size: 12, color: colorScheme.outline),
                      const Gap(4),
                      Text(
                        subscription.expiryDate == null
                            ? 'Document'
                            : isExpired
                            ? 'Expired ${DateFormat.MMMd().format(subscription.expiryDate!)}'
                            : isExpiringToday
                            ? 'Expires today!'
                            : 'Expires ${DateFormat.MMMd().format(subscription.expiryDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isExpiringToday
                              ? Colors.red
                              : colorScheme.outline,
                          fontWeight: isExpiringToday ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Days badge
            if (!isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (daysLeft <= 3
                              ? Colors.red
                              : daysLeft <= 7
                              ? Colors.orange
                              : Colors.green)
                          .withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  daysLeft == 0
                      ? 'Today'
                      : daysLeft == 1
                      ? '1 day'
                      : '$daysLeft days',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: daysLeft <= 3
                        ? Colors.red
                        : daysLeft <= 7
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Navigate to reminder
            if (!isExpired && subscription.linkedTaskId != null)
              IconButton(
                onPressed: () => _navigateToReminderDate(subscription),
                icon: Icon(Icons.arrow_forward, size: 18, color: categoryColor),
                tooltip: 'Go to reminder',
              ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS & SHEETS ====================

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g., Personal Documents',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _saveCategory(ctx, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _saveCategory(ctx, controller.text),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory(BuildContext ctx, String name) async {
    if (name.trim().isEmpty) return;

    final repository = ref.read(taskRepositoryProvider);
    final category = SubscriptionCategory()
      ..name = name.trim()
      ..colorValue = _getRandomColor();

    await repository.addCategory(category);
    if (ctx.mounted) Navigator.pop(ctx);
  }

  int _getRandomColor() {
    final colors = [
      0xFFE91E63, // Pink
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFFFF9800, // Orange
      0xFF9C27B0, // Purple
      0xFF00BCD4, // Cyan
      0xFFFF5722, // Deep Orange
      0xFF607D8B, // Blue Grey
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Future<void> _deleteCategory(SubscriptionCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('This will delete "${category.name}" and all its items.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(taskRepositoryProvider);
      // Delete all subscriptions in this category
      final subscriptions = await repository.getSubscriptionsByCategory(
        category.id,
      );
      for (final sub in subscriptions) {
        await repository.deleteSubscription(sub.id);
      }
      await repository.deleteCategory(category.id);
    }
  }

  void _showAddItemSheet(BuildContext context, SubscriptionCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemSheet(category: category),
    );
  }

  void _showEditItemSheet(BuildContext context, Subscription subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemSheet(subscription: subscription),
    );
  }

  void _navigateToReminderDate(Subscription subscription) {
    final reminderDate = subscription.reminderDate;
    if (reminderDate == null) return;
    ref.read(selectedDateProvider.notifier).state = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
    );
    Navigator.pop(context);
  }
}

// ==================== ADD ITEM SHEET ====================

class _AddItemSheet extends ConsumerStatefulWidget {
  final SubscriptionCategory? category;
  final Subscription? subscription;

  const _AddItemSheet({this.category, this.subscription});

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customIntervalController = TextEditingController(text: '30');
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  bool _showDescription = false;
  RecurrenceType _recurrenceType = RecurrenceType.once;
  int _customIntervalDays = 30;

  bool get isEditing => widget.subscription != null;
  int get categoryId => widget.category?.id ?? widget.subscription!.categoryId;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.subscription!.name;
      _descriptionController.text = widget.subscription!.description ?? '';
      if (widget.subscription!.expiryDate != null) {
        _expiryDate = widget.subscription!.expiryDate!;
      }
      _showDescription = widget.subscription!.description?.isNotEmpty ?? false;
      _recurrenceType = widget.subscription!.recurrenceType;
      _customIntervalDays = widget.subscription!.customIntervalDays;
      _customIntervalController.text = _customIntervalDays.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _customIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const Gap(20),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_alert,
                    color: Colors.orange,
                    size: 22,
                  ),
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Item' : 'Add Item',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.category != null)
                      Text(
                        'to ${widget.category!.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (isEditing)
                  IconButton(
                    onPressed: _deleteItem,
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  ),
              ],
            ),
            const Gap(24),

            // Name Input
            Text(
              'Name',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            TextField(
              controller: _nameController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g., Passport, Netflix...',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _saveItem(),
            ),
            const Gap(20),

            // Expiry Date
            Text(
              'Expiry Date',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            InkWell(
              onTap: _pickExpiryDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.orange,
                    ),
                    const Gap(12),
                    Text(
                      DateFormat.yMMMd().format(_expiryDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    _buildDaysUntilBadge(),
                  ],
                ),
              ),
            ),
            const Gap(20),

            // Recurrence Type
            Text(
              'How often?',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            _buildRecurrenceSelector(theme, colorScheme),

            // Custom interval input (only show when custom is selected)
            if (_recurrenceType == RecurrenceType.custom) ...[
              const Gap(12),
              Row(
                children: [
                  Text(
                    'Repeat every',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(8),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _customIntervalController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withAlpha(80),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        final days = int.tryParse(value);
                        if (days != null && days > 0) {
                          setState(() => _customIntervalDays = days);
                        }
                      },
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'days',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const Gap(16),

            // Description Toggle
            GestureDetector(
              onTap: () => setState(() => _showDescription = !_showDescription),
              child: Row(
                children: [
                  Icon(
                    _showDescription ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colorScheme.outline,
                  ),
                  const Gap(4),
                  Text(
                    _showDescription ? 'Hide notes' : 'Add notes (optional)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            if (_showDescription) ...[
              const Gap(12),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Additional notes...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const Gap(24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveItem,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update' : 'Save',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysUntilBadge() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      _expiryDate.year,
      _expiryDate.month,
      _expiryDate.day,
    );
    final daysUntil = expiry.difference(today).inDays;

    Color badgeColor;
    String text;

    if (daysUntil < 0) {
      badgeColor = Colors.grey;
      text = '${-daysUntil}d ago';
    } else if (daysUntil == 0) {
      badgeColor = Colors.red;
      text = 'Today';
    } else if (daysUntil <= 7) {
      badgeColor = Colors.orange;
      text = '$daysUntil days';
    } else if (daysUntil <= 30) {
      badgeColor = Colors.green;
      text = '$daysUntil days';
    } else {
      badgeColor = Colors.blue;
      final months = (daysUntil / 30).floor();
      text = months == 1 ? '~1 month' : '~$months months';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Widget _buildRecurrenceSelector(ThemeData theme, ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildRecurrenceChip(
          theme,
          colorScheme,
          RecurrenceType.once,
          'Once',
          Icons.looks_one,
          Colors.blue,
        ),
        _buildRecurrenceChip(
          theme,
          colorScheme,
          RecurrenceType.monthly,
          'Monthly',
          Icons.calendar_view_month,
          Colors.purple,
        ),
        _buildRecurrenceChip(
          theme,
          colorScheme,
          RecurrenceType.yearly,
          'Yearly',
          Icons.event_repeat,
          Colors.orange,
        ),
        _buildRecurrenceChip(
          theme,
          colorScheme,
          RecurrenceType.custom,
          'Custom',
          Icons.tune,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildRecurrenceChip(
    ThemeData theme,
    ColorScheme colorScheme,
    RecurrenceType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _recurrenceType == type;

    return GestureDetector(
      onTap: () => setState(() => _recurrenceType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(30)
              : colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : colorScheme.outline,
            ),
            const Gap(6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? color : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final repository = ref.read(taskRepositoryProvider);
    final description = _descriptionController.text.trim();

    if (isEditing) {
      final updated = widget.subscription!.copyWith(
        name: name,
        expiryDate: _expiryDate,
        description: description.isEmpty ? null : description,
        recurrenceType: _recurrenceType,
        customIntervalDays: _customIntervalDays,
      );
      await repository.updateSubscription(updated);
    } else {
      final subscription = Subscription()
        ..name = name
        ..categoryId = categoryId
        ..expiryDate = _expiryDate
        ..description = description.isEmpty ? null : description
        ..recurrenceType = _recurrenceType
        ..customIntervalDays = _customIntervalDays;
      await repository.addSubscription(subscription);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Updated!'
                : 'Reminder added! Task created for ${DateFormat.MMMd().format(_expiryDate.subtract(const Duration(days: 1)))}',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Delete "${widget.subscription!.name}" and its reminder task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(taskRepositoryProvider);
      await repository.deleteSubscription(widget.subscription!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
