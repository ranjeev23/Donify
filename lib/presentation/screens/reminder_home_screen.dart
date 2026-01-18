import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/subscription_category.dart';
import 'package:remindlyf/domain/providers/subscription_provider.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/presentation/screens/subscriptions_screen.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReminderHomeScreen extends ConsumerStatefulWidget {
  const ReminderHomeScreen({super.key});

  @override
  ConsumerState<ReminderHomeScreen> createState() => _ReminderHomeScreenState();
}

class _ReminderHomeScreenState extends ConsumerState<ReminderHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          // Manage Categories button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, size: 20, color: Colors.orange),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionsScreen(),
                ),
              );
            },
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

    // Categorize subscriptions

    final expired = subscriptions.where((s) => s.isExpired).toList();
    final critical = subscriptions.where((s) {
      if (s.isExpired) return false;
      return s.daysUntilExpiry <= 7;
    }).toList();
    final upcoming = subscriptions.where((s) {
      if (s.isExpired) return false;
      final days = s.daysUntilExpiry;
      return days > 7 && days <= 30;
    }).toList();
    final future = subscriptions.where((s) {
      if (s.isExpired) return false;
      return s.daysUntilExpiry > 30;
    }).toList();

    // Sort by urgency (handle null expiryDate for document-only items)
    expired.sort((a, b) {
      if (a.expiryDate == null && b.expiryDate == null) return 0;
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return b.expiryDate!.compareTo(a.expiryDate!);
    });
    critical.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    upcoming.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    future.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));

    if (subscriptions.isEmpty) {
      return _buildEmptyState(context, categories);
    }

    return Column(
      children: [
        // Stats Overview
        _buildStatsOverview(
          context,
          expired: expired.length,
          critical: critical.length,
          upcoming: upcoming.length,
          future: future.length,
        ),

        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: _getTabGradient(_selectedTabIndex),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            tabs: [
              _buildTab('All', subscriptions.length, Colors.blue),
              _buildTab(
                'Critical',
                critical.length + expired.length,
                Colors.red,
              ),
              _buildTab('Soon', upcoming.length, Colors.orange),
              _buildTab('Later', future.length, Colors.green),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildReminderList(context, subscriptions, categories, 'all'),
              _buildReminderList(
                context,
                [...expired, ...critical],
                categories,
                'critical',
              ),
              _buildReminderList(context, upcoming, categories, 'upcoming'),
              _buildReminderList(context, future, categories, 'future'),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _getTabGradient(int index) {
    switch (index) {
      case 0:
        return [Colors.blue, Colors.indigo];
      case 1:
        return [Colors.red, Colors.deepOrange];
      case 2:
        return [Colors.orange, Colors.amber];
      case 3:
        return [Colors.green, Colors.teal];
      default:
        return [Colors.blue, Colors.indigo];
    }
  }

  Widget _buildTab(String label, int count, Color color) {
    return Tab(
      height: 42,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (count > 0) ...[
            const Gap(4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsOverview(
    BuildContext context, {
    required int expired,
    required int critical,
    required int upcoming,
    required int future,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = expired + critical + upcoming + future;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withAlpha(100),
            colorScheme.secondaryContainer.withAlpha(100),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange, size: 24),
              const Gap(8),
              Text(
                'Overview',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total Total',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          // Progress bar showing distribution
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (expired > 0)
                    Expanded(
                      flex: expired,
                      child: Container(color: Colors.grey),
                    ),
                  if (critical > 0)
                    Expanded(
                      flex: critical,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          ),
                        ),
                      ),
                    ),
                  if (upcoming > 0)
                    Expanded(
                      flex: upcoming,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.amber],
                          ),
                        ),
                      ),
                    ),
                  if (future > 0)
                    Expanded(
                      flex: future,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.teal],
                          ),
                        ),
                      ),
                    ),
                  if (total == 0)
                    Expanded(
                      child: Container(
                        color: colorScheme.outline.withAlpha(50),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Gap(12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Expired', expired, Colors.grey),
              _buildLegendItem('Critical', critical, Colors.red),
              _buildLegendItem('Soon', upcoming, Colors.orange),
              _buildLegendItem('Later', future, Colors.green),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildReminderList(
    BuildContext context,
    List<Subscription> subscriptions,
    List<SubscriptionCategory> categories,
    String type,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'critical'
                  ? Icons.check_circle
                  : type == 'upcoming'
                  ? Icons.schedule
                  : Icons.event_available,
              size: 48,
              color: colorScheme.outline.withAlpha(100),
            ),
            const Gap(12),
            Text(
              type == 'critical'
                  ? 'No urgent reminders!'
                  : type == 'upcoming'
                  ? 'Nothing coming up soon'
                  : 'No reminders in this category',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        final category = categories.firstWhere(
          (c) => c.id == subscription.categoryId,
          orElse: () => SubscriptionCategory()
            ..name = 'Unknown'
            ..colorValue = 0xFF9E9E9E,
        );

        return _buildReminderCard(context, subscription, category)
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn()
            .slideX(begin: 0.1);
      },
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    Subscription subscription,
    SubscriptionCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = Color(category.colorValue);
    final daysLeft = subscription.daysUntilExpiry;
    final isExpired = subscription.isExpired;

    // Calculate urgency for progress bar (0-100, higher = more urgent)
    double urgency;
    Color urgencyColor;
    String urgencyLabel;

    if (isExpired) {
      urgency = 100;
      urgencyColor = Colors.grey;
      urgencyLabel = 'Expired';
    } else if (daysLeft == 0) {
      urgency = 100;
      urgencyColor = Colors.red;
      urgencyLabel = 'Today!';
    } else if (daysLeft <= 3) {
      urgency = 90;
      urgencyColor = Colors.red;
      urgencyLabel = '$daysLeft days left';
    } else if (daysLeft <= 7) {
      urgency = 70;
      urgencyColor = Colors.deepOrange;
      urgencyLabel = '$daysLeft days left';
    } else if (daysLeft <= 14) {
      urgency = 50;
      urgencyColor = Colors.orange;
      urgencyLabel = '~2 weeks';
    } else if (daysLeft <= 30) {
      urgency = 30;
      urgencyColor = Colors.amber;
      urgencyLabel = '~${(daysLeft / 7).ceil()} weeks';
    } else {
      urgency = 10;
      urgencyColor = Colors.green;
      final months = (daysLeft / 30).floor();
      urgencyLabel = months == 1 ? '~1 month' : '~$months months';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired
              ? Colors.grey.withAlpha(50)
              : urgencyColor.withAlpha(50),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReminderDetails(context, subscription, category),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.folder, color: categoryColor, size: 20),
                    ),
                    const Gap(12),
                    // Title and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isExpired
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isExpired ? colorScheme.outline : null,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Gap(6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  subscription.recurrenceLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Urgency badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: urgencyColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: urgencyColor.withAlpha(50)),
                      ),
                      child: Text(
                        urgencyLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: urgencyColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                // Date and progress
                Row(
                  children: [
                    Icon(Icons.event, size: 14, color: colorScheme.outline),
                    const Gap(4),
                    Text(
                      subscription.expiryDate == null
                          ? 'Document (no expiry)'
                          : isExpired
                          ? 'Expired ${DateFormat.MMMd().format(subscription.expiryDate!)}'
                          : 'Expires ${DateFormat.yMMMd().format(subscription.expiryDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                // Urgency Progress Bar
                Row(
                  children: [
                    Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.outline,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: urgency / 100,
                          minHeight: 6,
                          backgroundColor: colorScheme.outline.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            urgencyColor,
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      '${urgency.toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReminderDetails(
    BuildContext context,
    Subscription subscription,
    SubscriptionCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = Color(category.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.folder, color: categoryColor, size: 28),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),
            // Details
            if (subscription.expiryDate != null)
              _buildDetailRow(
                context,
                Icons.event,
                'Expiry Date',
                DateFormat.yMMMMd().format(subscription.expiryDate!),
                subscription.isExpired ? Colors.grey : Colors.orange,
              )
            else
              _buildDetailRow(
                context,
                Icons.folder,
                'Type',
                'Document (no expiry)',
                Colors.blue,
              ),
            const Gap(12),
            _buildDetailRow(
              context,
              Icons.repeat,
              'Recurrence',
              subscription.recurrenceLabel,
              Colors.purple,
            ),
            const Gap(12),
            _buildDetailRow(
              context,
              Icons.timer,
              'Days Remaining',
              subscription.isExpired
                  ? 'Expired ${-subscription.daysUntilExpiry} days ago'
                  : '${subscription.daysUntilExpiry} days',
              subscription.isExpired
                  ? Colors.grey
                  : subscription.daysUntilExpiry <= 7
                  ? Colors.red
                  : Colors.green,
            ),
            if (subscription.description?.isNotEmpty ?? false) ...[
              const Gap(12),
              _buildDetailRow(
                context,
                Icons.notes,
                'Notes',
                subscription.description!,
                Colors.blue,
              ),
            ],
            const Gap(24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToReminderDate(subscription);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('View in Timeline'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final confirmed = await _confirmDelete(
                        context,
                        subscription,
                      );
                      if (confirmed == true) {
                        final repository = ref.read(taskRepositoryProvider);
                        await repository.deleteSubscription(subscription.id);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    Subscription subscription,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text(
          'This will delete "${subscription.name}" and ALL its scheduled timeline tasks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
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

  Widget _buildEmptyState(
    BuildContext context,
    List<SubscriptionCategory> categories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
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
              Icons.notifications_none,
              size: 64,
              color: Colors.orange,
            ),
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const Gap(24),
          Text(
            'No Reminders Yet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(8),
          Text(
            'Create categories and add reminders\nto track expiry dates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const Gap(32),
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Manage Categories'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
