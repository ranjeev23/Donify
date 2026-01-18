import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/subscription_category.dart';
import 'package:remindlyf/domain/providers/subscription_provider.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/core/services/pdf_service.dart';
import 'package:remindlyf/presentation/screens/main_screen.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:open_file/open_file.dart';

// Provider for reminder tab view mode
final reminderViewModeProvider = StateProvider<int>(
  (ref) => 0,
); // 0 = All, 1 = Categories

class ReminderTab extends ConsumerStatefulWidget {
  const ReminderTab({super.key});

  @override
  ConsumerState<ReminderTab> createState() => _ReminderTabState();
}

class _ReminderTabState extends ConsumerState<ReminderTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _itemSearchQuery = ''; // Search query for documents/reminders
  final Set<int> _expandedCategories = {};
  final Set<int> _expandedSubfolders = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
          _itemSearchQuery = ''; // Clear search when switching tabs
        });
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.security, size: 18, color: Colors.white),
            ),
            const Gap(8),
            Text(
              'Vault',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
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

    // Categorize subscriptions by urgency
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

    if (subscriptions.isEmpty && categories.isEmpty) {
      return _buildEmptyState(context);
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
          total: subscriptions.length,
        ),

        // View Toggle Tabs
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
                colors: _selectedTabIndex == 0
                    ? [Colors.blue.shade500, Colors.blue.shade700]
                    : [Colors.orange, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_copy, size: 18),
                    Gap(6),
                    Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_active, size: 18),
                    Gap(6),
                    Text(
                      'Reminders',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDocumentsView(context, subscriptions, categories),
              _buildRemindersView(context, subscriptions, categories),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(
    BuildContext context, {
    required int expired,
    required int critical,
    required int upcoming,
    required int future,
    required int total,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withAlpha(15),
            Colors.deepOrange.withAlpha(15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withAlpha(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Expired',
            expired,
            Colors.grey,
            Icons.warning_amber,
          ),
          _buildStatDivider(colorScheme),
          _buildStatItem(
            context,
            'Critical',
            critical,
            Colors.red,
            Icons.priority_high,
          ),
          _buildStatDivider(colorScheme),
          _buildStatItem(
            context,
            'Soon',
            upcoming,
            Colors.orange,
            Icons.schedule,
          ),
          _buildStatDivider(colorScheme),
          _buildStatItem(
            context,
            'Later',
            future,
            Colors.green,
            Icons.event_available,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const Gap(6),
        Text(
          '$count',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ColorScheme colorScheme) {
    return Container(
      height: 40,
      width: 1,
      color: colorScheme.outline.withAlpha(30),
    );
  }

  void _showAllDocumentsGallery(
    BuildContext context,
    List<Subscription> subscriptions,
  ) {
    // Collect all documents with their parent info
    final allDocs = <Map<String, dynamic>>[];
    for (final sub in subscriptions) {
      if (sub.documentPhotos.isNotEmpty) {
        for (final photo in sub.documentPhotos) {
          allDocs.add({'path': photo, 'name': sub.name, 'subscription': sub});
        }
      }
    }

    if (allDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              Gap(8),
              Text('No documents stored yet'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blue.shade600,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AllDocumentsGallery(documents: allDocs),
    );
  }

  Widget _buildAllRemindersView(
    BuildContext context,
    List<Subscription> subscriptions,
    List<SubscriptionCategory> categories,
  ) {
    // Legacy method - redirecting to documents view
    return _buildDocumentsView(context, subscriptions, categories);
  }

  // ==================== DOCUMENTS VIEW ====================
  Widget _buildDocumentsView(
    BuildContext context,
    List<Subscription> subscriptions,
    List<SubscriptionCategory> categories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get only document categories
    final docCategories = categories.where((c) => c.isDocument).toList();

    // Filter categories and items by search
    final query = _itemSearchQuery.toLowerCase();
    final filteredCategories = query.isEmpty
        ? docCategories
        : docCategories.where((cat) {
            // Match category name
            if (cat.name.toLowerCase().contains(query)) return true;
            // Match any item in category
            final catItems = subscriptions.where((s) => s.categoryId == cat.id);
            return catItems.any((s) => s.name.toLowerCase().contains(query));
          }).toList();

    return Column(
      children: [
        // Search bar with Add Category button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(60),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _itemSearchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search categories & documents...',
                      hintStyle: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blue,
                        size: 22,
                      ),
                      suffixIcon: _itemSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.outline,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _itemSearchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              // Add Category button
              GestureDetector(
                onTap: () => _showAddDocumentCategoryDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),

        // Categories with items
        Expanded(
          child: filteredCategories.isEmpty
              ? _buildEmptyCategoriesState(
                  context,
                  isDoc: true,
                  hasSearch: _itemSearchQuery.isNotEmpty,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 100,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    // Filter items: must belong to this category AND not be inside a subfolder
                    // Items with parentFolderId set will appear inside their subfolder, not here
                    final categoryItems = subscriptions
                        .where(
                          (s) =>
                              s.categoryId == category.id &&
                              s.parentFolderId == null,
                        )
                        .toList();

                    // If searching, filter items within category too
                    final displayItems = query.isEmpty
                        ? categoryItems
                        : categoryItems
                              .where(
                                (s) =>
                                    s.name.toLowerCase().contains(query) ||
                                    category.name.toLowerCase().contains(query),
                              )
                              .toList();

                    // Sort by name
                    displayItems.sort((a, b) => a.name.compareTo(b.name));

                    return _buildCategoryWithItems(
                          context,
                          category,
                          displayItems,
                        )
                        .animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn()
                        .slideX(begin: -0.03);
                  },
                ),
        ),
      ],
    );
  }

  // ==================== REMINDERS VIEW ====================
  Widget _buildRemindersView(
    BuildContext context,
    List<Subscription> subscriptions,
    List<SubscriptionCategory> categories,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get only reminder categories
    final reminderCategories = categories.where((c) => !c.isDocument).toList();

    // Filter categories and items by search
    final query = _itemSearchQuery.toLowerCase();
    final filteredCategories = query.isEmpty
        ? reminderCategories
        : reminderCategories.where((cat) {
            // Match category name
            if (cat.name.toLowerCase().contains(query)) return true;
            // Match any item in category
            final catItems = subscriptions.where((s) => s.categoryId == cat.id);
            return catItems.any((s) => s.name.toLowerCase().contains(query));
          }).toList();

    return Column(
      children: [
        // Search bar with Add Category button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(60),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _itemSearchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search categories & reminders...',
                      hintStyle: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.orange,
                        size: 22,
                      ),
                      suffixIcon: _itemSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: colorScheme.outline,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _itemSearchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              // Add Category button
              GestureDetector(
                onTap: () => _showAddReminderCategoryDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),

        // Categories with items
        Expanded(
          child: filteredCategories.isEmpty
              ? _buildEmptyCategoriesState(
                  context,
                  isDoc: false,
                  hasSearch: _itemSearchQuery.isNotEmpty,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 100,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    // Filter items: must belong to this category AND not be inside a subfolder
                    // Items with parentFolderId set will appear inside their subfolder, not here
                    final categoryItems = subscriptions
                        .where(
                          (s) =>
                              s.categoryId == category.id &&
                              s.parentFolderId == null,
                        )
                        .toList();

                    // If searching, filter items within category too
                    final displayItems = query.isEmpty
                        ? categoryItems
                        : categoryItems
                              .where(
                                (s) =>
                                    s.name.toLowerCase().contains(query) ||
                                    category.name.toLowerCase().contains(query),
                              )
                              .toList();

                    // Sort by urgency (soonest first)
                    displayItems.sort((a, b) {
                      if (a.isExpired && !b.isExpired) return 1;
                      if (!a.isExpired && b.isExpired) return -1;
                      if (a.expiryDate != null && b.expiryDate != null) {
                        return a.daysUntilExpiry.compareTo(b.daysUntilExpiry);
                      }
                      return a.name.compareTo(b.name);
                    });

                    return _buildCategoryWithItems(
                          context,
                          category,
                          displayItems,
                        )
                        .animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn()
                        .slideX(begin: -0.03);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyItemsState(
    BuildContext context, {
    required bool isDoc,
    required bool hasSearch,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDoc ? Colors.blue : Colors.orange;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (hasSearch ? Colors.grey : color).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasSearch
                  ? Icons.search_off
                  : (isDoc ? Icons.folder_copy : Icons.notifications_active),
              size: 48,
              color: hasSearch ? Colors.grey : color,
            ),
          ),
          const Gap(16),
          Text(
            hasSearch
                ? 'No Results'
                : (isDoc ? 'No Documents Yet' : 'No Reminders Yet'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            hasSearch
                ? 'Try a different search term'
                : 'Tap + to add your first ${isDoc ? 'document' : 'reminder'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state for when no categories exist
  Widget _buildEmptyCategoriesState(
    BuildContext context, {
    required bool isDoc,
    required bool hasSearch,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDoc ? Colors.blue : Colors.orange;

    if (hasSearch) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 48, color: Colors.grey),
            ),
            const Gap(16),
            Text(
              'No Results',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Try a different search term',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withAlpha(30),
                  (isDoc ? Colors.indigo : Colors.deepOrange).withAlpha(30),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDoc ? Icons.folder_copy_outlined : Icons.notifications_none,
              size: 64,
              color: color,
            ),
          ).animate().scale(delay: 200.ms, duration: 400.ms),
          const Gap(24),
          Text(
            isDoc ? 'Organize Your Documents' : 'Track Important Dates',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(8),
          Text(
            isDoc
                ? 'Create categories like "Passport", "License"\nto store important document photos'
                : 'Create categories like "OTT", "Insurance"\nto track renewals and never miss a deadline',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const Gap(32),
          FilledButton.icon(
            onPressed: () => isDoc
                ? _showAddDocumentCategoryDialog(context)
                : _showAddReminderCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: Text('Create ${isDoc ? 'Document' : 'Reminder'} Category'),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  // Build expandable category card with items inside
  Widget _buildCategoryWithItems(
    BuildContext context,
    SubscriptionCategory category,
    List<Subscription> items,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _expandedCategories.contains(category.id);
    final categoryColor = Color(category.colorValue);

    // Count urgent items
    final urgentCount = items
        .where((s) => !s.isExpired && s.daysUntilExpiry <= 7)
        .length;

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor.withAlpha(80),
                          categoryColor.withAlpha(40),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      category.isDocument
                          ? Icons.folder_copy
                          : Icons.notifications_active,
                      color: categoryColor,
                      size: 20,
                    ),
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
                          items.isEmpty
                              ? 'No items yet'
                              : '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Urgent badge
                  if (urgentCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.priority_high,
                            size: 12,
                            color: Colors.red,
                          ),
                          const Gap(2),
                          Text(
                            '$urgentCount',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                  ],
                  // Add item button
                  GestureDetector(
                    onTap: () => _showAddItemSheet(context, category),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [categoryColor.withAlpha(150), categoryColor],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Gap(8),
                  // Delete
                  GestureDetector(
                    onTap: () => _deleteCategory(category),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                  const Gap(4),
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
            secondChild: Column(
              children: [
                // Add subfolder option for document categories - always show
                if (category.isDocument) ...[
                  const Divider(height: 1),
                  InkWell(
                    onTap: () => _showAddSubfolderSheet(context, category),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.create_new_folder_outlined,
                              size: 16,
                              color: Colors.amber,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            'Create Subfolder',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.add,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Empty state hint
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: categoryColor.withAlpha(30),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: categoryColor,
                          ),
                          const Gap(8),
                          Text(
                            'Tap + to add ${category.isDocument ? 'documents' : 'reminders'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  if (!category.isDocument) const Divider(height: 1),
                  ...items.map((sub) => _buildItemTile(context, sub, category)),
                ],
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

  // Build individual item tile within a category
  Widget _buildItemTile(
    BuildContext context,
    Subscription subscription,
    SubscriptionCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = Color(category.colorValue);

    // Handle subfolders specially
    if (subscription.isFolder) {
      return _buildSubfolderTile(context, subscription, category);
    }

    final isExpired = subscription.isExpired;
    final daysLeft = subscription.daysUntilExpiry;
    final hasPhotos = subscription.documentPhotos.isNotEmpty;
    final hasPdfs = subscription.pdfDocuments.isNotEmpty;
    final hasOtherDocs = subscription.otherDocuments.isNotEmpty;
    final hasDocuments = hasPhotos || hasPdfs || hasOtherDocs;

    // Get urgency color
    Color urgencyColor = Colors.green;
    if (subscription.expiryDate != null) {
      if (isExpired) {
        urgencyColor = Colors.grey;
      } else if (daysLeft <= 3) {
        urgencyColor = Colors.red;
      } else if (daysLeft <= 7) {
        urgencyColor = Colors.deepOrange;
      } else if (daysLeft <= 30) {
        urgencyColor = Colors.orange;
      }
    }

    return Dismissible(
      key: Key('item_${subscription.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeleteItem(context, subscription),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: () => hasDocuments
            ? _showDocumentViewer(context, subscription)
            : _showReminderDetails(context, subscription, category),
        onLongPress: () =>
            _showItemOptionsMenu(context, subscription, category),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Urgency indicator
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(12),
              // Photo preview or icon
              if (hasPhotos)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: categoryColor.withAlpha(40)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.file(
                      File(subscription.documentPhotos.first),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.photo,
                          color: colorScheme.outline,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: urgencyColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.event_note, color: urgencyColor, size: 20),
                ),
              const Gap(12),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isExpired
                            ? TextDecoration.lineThrough
                            : null,
                        color: isExpired ? colorScheme.outline : null,
                      ),
                    ),
                    Text(
                      subscription.expiryDate == null
                          ? 'Document'
                          : isExpired
                          ? 'Expired ${DateFormat.yMMMd().format(subscription.expiryDate!)}'
                          : 'Expires ${DateFormat.yMMMd().format(subscription.expiryDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // Photo count
              if (hasPhotos) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo, size: 12, color: Colors.blue),
                      const Gap(2),
                      Text(
                        '${subscription.documentPhotos.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
              ],
              // Days remaining
              if (subscription.expiryDate != null && !isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: urgencyColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    daysLeft == 0 ? 'Today' : '${daysLeft}d',
                    style: TextStyle(
                      fontSize: 11,
                      color: urgencyColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Gap(4),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.outline.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build subfolder tile that can be expanded to show contents
  Widget _buildSubfolderTile(
    BuildContext context,
    Subscription subfolder,
    SubscriptionCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _expandedSubfolders.contains(subfolder.id);

    // Watch for items inside this subfolder
    final allSubscriptions =
        ref.watch(subscriptionsProvider).asData?.value ?? [];
    final subfolderItems = allSubscriptions
        .where((s) => s.parentFolderId == subfolder.id && !s.isFolder)
        .toList();

    return Column(
      children: [
        // Subfolder header
        Dismissible(
          key: Key('subfolder_${subfolder.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) =>
              _confirmDeleteSubfolder(context, subfolder, subfolderItems),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSubfolders.remove(subfolder.id);
                } else {
                  _expandedSubfolders.add(subfolder.id);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subfolder.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subfolderItems.isEmpty
                              ? 'Empty folder'
                              : '${subfolderItems.length} ${subfolderItems.length == 1 ? 'item' : 'items'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add item to subfolder button
                  GestureDetector(
                    onTap: () =>
                        _showAddToSubfolderSheet(context, category, subfolder),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const Gap(8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Expanded subfolder contents
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: subfolderItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                    right: 14,
                    top: 4,
                    bottom: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const Gap(8),
                        Text(
                          'Tap + to add documents',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    children: subfolderItems.map((item) {
                      return _buildSubfolderItemTile(
                        context,
                        item,
                        category,
                        subfolder,
                      );
                    }).toList(),
                  ),
                ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  // Build item tile within a subfolder
  Widget _buildSubfolderItemTile(
    BuildContext context,
    Subscription subscription,
    SubscriptionCategory category,
    Subscription subfolder,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhotos =
        subscription.documentPhotos.isNotEmpty ||
        subscription.pdfDocuments.isNotEmpty;

    return Dismissible(
      key: Key('subitem_${subscription.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeleteItem(context, subscription),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
      ),
      child: InkWell(
        onTap: () => hasPhotos
            ? _showDocumentViewer(context, subscription)
            : _showReminderDetails(context, subscription, category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.amber.withAlpha(60), width: 2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                hasPhotos
                    ? Icons.insert_drive_file
                    : Icons.description_outlined,
                size: 18,
                color: Colors.blue,
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  subscription.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasPhotos)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${subscription.totalFileCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Gap(4),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colorScheme.outline.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteSubfolder(
    BuildContext context,
    Subscription subfolder,
    List<Subscription> contents,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subfolder?'),
        content: Text(
          contents.isEmpty
              ? 'Delete "${subfolder.name}"?'
              : 'Delete "${subfolder.name}" and all ${contents.length} item(s) inside it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repository = ref.read(taskRepositoryProvider);
              // Delete all items inside the subfolder
              for (final item in contents) {
                await repository.deleteSubscription(item.id);
              }
              // Delete the subfolder itself
              await repository.deleteSubscription(subfolder.id);
              Navigator.pop(ctx, true);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddToSubfolderSheet(
    BuildContext context,
    SubscriptionCategory category,
    Subscription subfolder,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          AddReminderSheet(category: category, parentFolderId: subfolder.id),
    );
  }

  // Show dialog to add a Document category
  void _showAddDocumentCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuickAddCategorySheet(isDocument: true),
    );
  }

  // Show dialog to add a Reminder category
  void _showAddReminderCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuickAddCategorySheet(isDocument: false),
    );
  }

  Widget _buildVaultItemCard(
    BuildContext context,
    Subscription subscription,
    SubscriptionCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhotos = subscription.documentPhotos.isNotEmpty;
    final hasPdfs = subscription.pdfDocuments.isNotEmpty;
    final hasOtherDocs = subscription.otherDocuments.isNotEmpty;
    final hasDocuments = hasPhotos || hasPdfs || hasOtherDocs;
    final hasExpiry = subscription.expiryDate != null;
    final daysLeft = subscription.daysUntilExpiry;
    final isExpired = subscription.isExpired;

    // Get urgency color
    Color urgencyColor = Colors.green;
    if (hasExpiry) {
      if (isExpired) {
        urgencyColor = Colors.grey;
      } else if (daysLeft <= 3) {
        urgencyColor = Colors.red;
      } else if (daysLeft <= 7) {
        urgencyColor = Colors.deepOrange;
      } else if (daysLeft <= 30) {
        urgencyColor = Colors.orange;
      }
    }

    final cardColor = category.isDocument ? Colors.blue : Colors.orange;

    return Dismissible(
      key: Key('vault_item_${subscription.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeleteItem(context, subscription),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            Gap(8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardColor.withAlpha(40)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => hasDocuments
                ? _showDocumentViewer(context, subscription)
                : _showReminderDetails(context, subscription, category),
            onLongPress: () =>
                _showItemOptionsMenu(context, subscription, category),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Thumbnail or Icon
                  if (hasPhotos)
                    _buildPhotoPreview(subscription.documentPhotos)
                  else
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: urgencyColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.event_note,
                        color: urgencyColor,
                        size: 28,
                      ),
                    ),
                  const Gap(14),

                  // Info
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        // Tags row
                        Row(
                          children: [
                            if (hasPhotos) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo,
                                      size: 12,
                                      color: Colors.blue,
                                    ),
                                    const Gap(4),
                                    Text(
                                      '${subscription.documentPhotos.length} ${subscription.documentPhotos.length == 1 ? 'page' : 'pages'}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(6),
                            ],
                            if (hasExpiry)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: urgencyColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isExpired
                                      ? 'Expired'
                                      : daysLeft == 0
                                      ? 'Today!'
                                      : daysLeft == 1
                                      ? '1 day left'
                                      : '$daysLeft days',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: urgencyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Hint text
                        const Gap(6),
                        Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 10,
                              color: colorScheme.outline.withAlpha(150),
                            ),
                            const Gap(4),
                            Text(
                              'Hold for options',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.outline.withAlpha(150),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // View icon
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasPhotos
                              ? Icons.visibility
                              : Icons.arrow_forward_ios,
                          size: 18,
                          color: cardColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows confirmation dialog for deleting an item
  Future<bool> _confirmDeleteItem(
    BuildContext context,
    Subscription subscription,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red warning icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever,
                size: 40,
                color: Colors.red,
              ),
            ),
            const Gap(20),
            Text(
              'Delete "${subscription.name}"?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'This action cannot be undone. All photos and data will be permanently deleted.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 18),
                        Gap(6),
                        Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );

    if (result == true) {
      await _deleteSubscription(subscription);
      return true;
    }
    return false;
  }

  /// Shows options menu on long press
  void _showItemOptionsMenu(
    BuildContext context,
    Subscription subscription,
    SubscriptionCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPhotos = subscription.documentPhotos.isNotEmpty;
    final hasPdfs = subscription.pdfDocuments.isNotEmpty;
    final hasOtherDocs = subscription.otherDocuments.isNotEmpty;
    final hasDocuments = hasPhotos || hasPdfs || hasOtherDocs;
    final cardColor = category.isDocument ? Colors.blue : Colors.orange;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    color: cardColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.isDocument
                        ? Icons.folder_copy
                        : Icons.notifications_active,
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            const Divider(height: 1),
            const Gap(12),
            // Options
            if (hasDocuments)
              _buildOptionTile(
                icon: Icons.visibility,
                iconColor: Colors.blue,
                title: 'View Documents',
                subtitle: hasPhotos && hasPdfs
                    ? '${subscription.documentPhotos.length} photo(s), ${subscription.pdfDocuments.length} PDF(s)'
                    : hasPhotos
                    ? '${subscription.documentPhotos.length} photo(s)'
                    : '${subscription.pdfDocuments.length} PDF(s)',
                onTap: () {
                  Navigator.pop(ctx);
                  _showDocumentViewer(context, subscription);
                },
              ),
            if (hasPhotos)
              _buildOptionTile(
                icon: Icons.picture_as_pdf,
                iconColor: Colors.red.shade600,
                title: 'Export as PDF',
                subtitle: 'Save document photos to Files',
                onTap: () async {
                  Navigator.pop(ctx);
                  await _exportAsPdf(context, subscription);
                },
              ),
            if (subscription.linkedTaskIds.isNotEmpty ||
                subscription.reminderDate != null)
              _buildOptionTile(
                icon: Icons.calendar_today,
                iconColor: Colors.green,
                title: 'View Reminder Days',
                subtitle: 'Jump to reminder in calendar',
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateToReminderDays(subscription);
                },
              ),
            _buildOptionTile(
              icon: Icons.edit,
              iconColor: Colors.orange,
              title: 'Edit',
              subtitle: 'Modify name, dates, photos, or PDFs',
              onTap: () {
                Navigator.pop(ctx);
                _showEditItemSheet(context, subscription);
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline,
              iconColor: Colors.red,
              title: 'Delete',
              subtitle: 'Remove this item permanently',
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await _confirmDeleteItem(
                  context,
                  subscription,
                );
                if (confirmed) {
                  // Item was deleted
                }
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// Export document images as PDF
  Future<void> _exportAsPdf(
    BuildContext context,
    Subscription subscription,
  ) async {
    if (subscription.documentPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No photos to export'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text(
                'Creating PDF...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await PdfService.exportImagesToPdf(
        subscription.documentPhotos,
        documentName: subscription.name,
      );

      if (context.mounted) Navigator.pop(context); // Close loading dialog

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                Gap(8),
                Text('PDF exported successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to reminder days in the main calendar
  void _navigateToReminderDays(Subscription subscription) {
    final reminderDate = subscription.reminderDate;
    if (reminderDate == null) return;

    // Set the selected date to the reminder date
    ref.read(selectedDateProvider.notifier).state = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
    );

    // Switch to Today tab (index 1)
    ref.read(bottomNavIndexProvider.notifier).state = 1;
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }

  /// Deletes a subscription
  Future<void> _deleteSubscription(Subscription subscription) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.deleteSubscription(subscription.id);
  }

  Widget _buildPhotoPreview(List<String> photos) {
    if (photos.isEmpty) return const SizedBox.shrink();

    final file = File(photos.first);

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(30)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          fit: StackFit.expand,
          children: [
            file.existsSync()
                ? Image.file(file, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
            // Photo count badge
            if (photos.length > 1)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${photos.length - 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDocumentViewer(BuildContext context, Subscription subscription) {
    final hasPhotos = subscription.documentPhotos.isNotEmpty;
    final hasPdfs = subscription.pdfDocuments.isNotEmpty;
    final hasOtherDocs = subscription.otherDocuments.isNotEmpty;

    // If only has other documents (no photos/PDFs), show them in a special view
    if (!hasPhotos && !hasPdfs && hasOtherDocs) {
      _showOtherDocumentsSheet(context, subscription);
      return;
    }

    // Otherwise show the full document viewer
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FullScreenDocumentViewer(subscription: subscription),
    );
  }

  void _showOtherDocumentsSheet(
    BuildContext context,
    Subscription subscription,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final otherDocs = subscription.otherDocuments;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.withAlpha(30),
                            Colors.blue.withAlpha(30),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.folder_open,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${otherDocs.length} ${otherDocs.length == 1 ? 'file' : 'files'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // File list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: otherDocs.length,
                  itemBuilder: (context, index) {
                    final filePath = otherDocs[index];
                    final fileName = filePath.split('/').last;
                    final extension = fileName.contains('.')
                        ? fileName.split('.').last.toLowerCase()
                        : '';

                    // Get icon and color based on file type
                    IconData icon;
                    Color color;

                    switch (extension) {
                      case 'xls':
                      case 'xlsx':
                      case 'csv':
                        icon = Icons.table_chart;
                        color = Colors.green;
                        break;
                      case 'doc':
                      case 'docx':
                        icon = Icons.description;
                        color = Colors.blue;
                        break;
                      case 'ppt':
                      case 'pptx':
                        icon = Icons.slideshow;
                        color = Colors.orange;
                        break;
                      case 'txt':
                        icon = Icons.text_snippet;
                        color = Colors.grey;
                        break;
                      case 'zip':
                      case 'rar':
                      case '7z':
                        icon = Icons.folder_zip;
                        color = Colors.amber;
                        break;
                      default:
                        icon = Icons.insert_drive_file;
                        color = Colors.teal;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            try {
                              await OpenFile.open(filePath);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Cannot open file: $e'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withAlpha(15),
                                  color.withAlpha(8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: color.withAlpha(40)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(30),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(icon, color: color, size: 24),
                                ),
                                const Gap(14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Gap(2),
                                      Text(
                                        extension.toUpperCase(),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: color,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.open_in_new,
                                    color: color,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Back to app hint
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const Gap(8),
                        Text(
                          'Tap a file to open it with the default app',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

    // Determine urgency color
    Color urgencyColor;

    if (isExpired) {
      urgencyColor = Colors.grey;
    } else if (daysLeft <= 3) {
      urgencyColor = Colors.red;
    } else if (daysLeft <= 7) {
      urgencyColor = Colors.deepOrange;
    } else if (daysLeft <= 30) {
      urgencyColor = Colors.orange;
    } else {
      urgencyColor = Colors.green;
    }

    // Calculate progress for urgency bar (0.0 to 1.0)
    // Progress increases as deadline approaches
    // 30+ days = 0%, 0 days = 100%
    double urgencyProgress;
    if (isExpired) {
      urgencyProgress = 1.0;
    } else if (daysLeft >= 30) {
      urgencyProgress = 0.1; // Minimum visible progress
    } else if (daysLeft >= 14) {
      // 14-30 days: 10% to 30%
      urgencyProgress = 0.1 + (30 - daysLeft) / 16 * 0.2;
    } else if (daysLeft >= 7) {
      // 7-14 days: 30% to 50%
      urgencyProgress = 0.3 + (14 - daysLeft) / 7 * 0.2;
    } else if (daysLeft >= 3) {
      // 3-7 days: 50% to 75%
      urgencyProgress = 0.5 + (7 - daysLeft) / 4 * 0.25;
    } else {
      // 0-3 days: 75% to 100%
      urgencyProgress = 0.75 + (3 - daysLeft) / 3 * 0.25;
    }

    // Get gradient colors for progress bar based on urgency
    List<Color> progressGradient;
    if (isExpired) {
      progressGradient = [Colors.grey.shade400, Colors.grey.shade600];
    } else if (daysLeft <= 3) {
      progressGradient = [Colors.red.shade400, Colors.red.shade700];
    } else if (daysLeft <= 7) {
      progressGradient = [Colors.deepOrange.shade400, Colors.red.shade500];
    } else if (daysLeft <= 14) {
      progressGradient = [Colors.orange.shade400, Colors.deepOrange.shade500];
    } else if (daysLeft <= 30) {
      progressGradient = [Colors.amber.shade400, Colors.orange.shade500];
    } else {
      progressGradient = [Colors.green.shade400, Colors.green.shade600];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpired
              ? Colors.grey.withAlpha(30)
              : urgencyColor.withAlpha(30),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReminderDetails(context, subscription, category),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and category row
                Row(
                  children: [
                    // Urgency indicator bar
                    Container(
                      width: 3,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: progressGradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Gap(12),
                    // Name and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isExpired
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isExpired ? colorScheme.outline : null,
                            ),
                          ),
                          const Gap(4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
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
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                // Progress bar with end date and time left
                _buildUrgencyProgressBar(
                  context,
                  urgencyProgress,
                  progressGradient,
                  urgencyColor,
                  daysLeft,
                  isExpired,
                  subscription.expiryDate ?? DateTime.now(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyProgressBar(
    BuildContext context,
    double progress,
    List<Color> gradient,
    Color urgencyColor,
    int daysLeft,
    bool isExpired,
    DateTime expiryDate,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine the label for time remaining
    String timeLabel;
    if (isExpired) {
      timeLabel = 'Past due';
    } else if (daysLeft == 0) {
      timeLabel = 'Due today';
    } else if (daysLeft == 1) {
      timeLabel = '1 day left';
    } else if (daysLeft <= 7) {
      timeLabel = '$daysLeft days left';
    } else if (daysLeft <= 30) {
      final weeks = (daysLeft / 7).ceil();
      timeLabel = '~$weeks ${weeks == 1 ? 'week' : 'weeks'} left';
    } else {
      final months = (daysLeft / 30).floor();
      timeLabel = '~$months ${months == 1 ? 'month' : 'months'} left';
    }

    return Column(
      children: [
        // Progress bar
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(6),
        // End date and time left
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM d, yyyy').format(expiryDate),
              style: TextStyle(fontSize: 10, color: colorScheme.outline),
            ),
            Text(
              timeLabel,
              style: TextStyle(
                fontSize: 10,
                color: urgencyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesView(
    BuildContext context,
    List<SubscriptionCategory> categories,
    List<Subscription> subscriptions,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open,
                size: 48,
                color: Colors.purple,
              ),
            ),
            const Gap(16),
            Text(
              'No Categories Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Tap + to create your first category',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categorySubscriptions = subscriptions
            .where((s) => s.categoryId == category.id)
            .toList();

        return _buildCategoryCard(context, category, categorySubscriptions)
            .animate(delay: Duration(milliseconds: 50 * index))
            .fadeIn()
            .slideX(begin: -0.05);
      },
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

    // Count urgent items
    final urgentCount = subscriptions
        .where((s) => !s.isExpired && s.daysUntilExpiry <= 7)
        .length;

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
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      category.isDocument
                          ? Icons.folder_copy
                          : Icons.notifications_active,
                      color: categoryColor,
                      size: 20,
                    ),
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
                  // Urgent badge
                  if (urgentCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.priority_high,
                            size: 12,
                            color: Colors.red,
                          ),
                          const Gap(2),
                          Text(
                            '$urgentCount',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                  ],
                  // Add item button
                  IconButton(
                    onPressed: () => _showAddItemSheet(context, category),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 16, color: categoryColor),
                    ),
                    tooltip: 'Add item',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const Gap(4),
                  // Delete
                  IconButton(
                    onPressed: () => _deleteCategory(category),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: colorScheme.error.withAlpha(150),
                    ),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const Gap(4),
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
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(
                          30,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const Gap(8),
                          Text(
                            'Tap + to add a reminder',
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
                        (sub) =>
                            _buildSubscriptionTile(context, sub, categoryColor),
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
    final daysLeft = subscription.daysUntilExpiry;

    return InkWell(
      onTap: () => _showEditItemSheet(context, subscription),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.grey
                    : daysLeft <= 7
                    ? Colors.red
                    : daysLeft <= 30
                    ? Colors.orange
                    : Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isExpired ? TextDecoration.lineThrough : null,
                      color: isExpired ? colorScheme.outline : null,
                    ),
                  ),
                  Text(
                    subscription.expiryDate == null
                        ? 'Document'
                        : isExpired
                        ? 'Expired ${DateFormat.yMMMd().format(subscription.expiryDate!)}'
                        : 'Expires ${DateFormat.yMMMd().format(subscription.expiryDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Photo count for documents
            if (subscription.documentPhotos.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo, size: 12, color: Colors.blue),
                    const Gap(2),
                    Text(
                      '${subscription.documentPhotos.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
            ],
            if (subscription.expiryDate != null && !isExpired)
              Text(
                daysLeft == 0 ? 'Today' : '$daysLeft d',
                style: TextStyle(
                  fontSize: 12,
                  color: daysLeft <= 7 ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Gap(4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: colorScheme.outline.withAlpha(100),
            ),
          ],
        ),
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
            'Track Important Dates',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(8),
          Text(
            'Create categories to organize your\nreminders and never miss a deadline',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          const Gap(32),
          FilledButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Category'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  // ==================== DIALOGS & SHEETS ====================

  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCategorySheet(),
    );
  }

  /// Shows sheet to add a new document. Auto-creates a "Documents" folder if none exists.
  void _showAddDocumentSheet(
    BuildContext context,
    List<SubscriptionCategory> categories,
  ) async {
    // Find existing document category or create one
    var docCategory = categories.where((c) => c.isDocument).toList();

    if (docCategory.isEmpty) {
      // Create default Documents folder
      final repository = ref.read(taskRepositoryProvider);
      final newCat = SubscriptionCategory()
        ..name = 'Documents'
        ..isDocument = true
        ..colorValue = 0xFF2196F3;
      await repository.addCategory(newCat);

      // Refresh and get the new category
      final cats = await repository.getAllCategories();
      docCategory = cats.where((c) => c.isDocument).toList();
    }

    if (docCategory.isNotEmpty && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddReminderSheet(category: docCategory.first),
      );
    }
  }

  /// Shows sheet to add a new reminder. Auto-creates a "Reminders" folder if none exists.
  void _showAddReminderSheet(
    BuildContext context,
    List<SubscriptionCategory> categories,
  ) async {
    // Find existing reminder category or create one
    var reminderCategory = categories.where((c) => !c.isDocument).toList();

    if (reminderCategory.isEmpty) {
      // Create default Reminders folder
      final repository = ref.read(taskRepositoryProvider);
      final newCat = SubscriptionCategory()
        ..name = 'Reminders'
        ..isDocument = false
        ..colorValue = 0xFFFF9800;
      await repository.addCategory(newCat);

      // Refresh and get the new category
      final cats = await repository.getAllCategories();
      reminderCategory = cats.where((c) => !c.isDocument).toList();
    }

    if (reminderCategory.isNotEmpty && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            AddReminderSheet(category: reminderCategory.first),
      );
    }
  }

  Future<void> _saveCategory(
    BuildContext ctx,
    String name,
    bool isDocument,
  ) async {
    if (name.trim().isEmpty) return;

    final repository = ref.read(taskRepositoryProvider);
    final category = SubscriptionCategory()
      ..name = name.trim()
      ..isDocument = isDocument
      ..colorValue = isDocument
          ? 0xFF2196F3
          : 0xFFFF9800; // Blue for docs, Orange for reminders

    await repository.addCategory(category);
    if (ctx.mounted) Navigator.pop(ctx);
  }

  int _getRandomColor() {
    final colors = [
      0xFFE91E63,
      0xFF2196F3,
      0xFF4CAF50,
      0xFFFF9800,
      0xFF9C27B0,
      0xFF00BCD4,
      0xFFFF5722,
      0xFF607D8B,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Future<void> _deleteCategory(SubscriptionCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'This will delete "${category.name}" and all its reminders.',
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
      builder: (context) => AddReminderSheet(category: category),
    );
  }

  void _showAddSubfolderSheet(
    BuildContext context,
    SubscriptionCategory category,
  ) {
    final nameController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.amber.shade600],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.create_new_folder,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Gap(14),
                  Text(
                    'Create Subfolder',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              // Name field
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'e.g., Personal, Work, Travel',
                  prefixIcon: const Icon(Icons.folder_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const Gap(12),
              Text(
                'Subfolders help you organize documents within "${category.name}"',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const Gap(24),
              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a folder name'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    final repository = ref.read(taskRepositoryProvider);
                    final subfolder = Subscription()
                      ..name = name
                      ..categoryId = category.id
                      ..isFolder = true;

                    await repository.addSubscription(subfolder);

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.folder,
                                color: Colors.white,
                                size: 18,
                              ),
                              const Gap(8),
                              Text('Subfolder "$name" created!'),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.amber.shade700,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Create Subfolder'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditItemSheet(BuildContext context, Subscription subscription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderSheet(subscription: subscription),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.folder, color: categoryColor, size: 24),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            category.name,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 13,
                            ),
                          ),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              subscription.recurrenceLabel,
                              style: const TextStyle(
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
              ],
            ),
            const Gap(20),
            if (subscription.expiryDate != null)
              _buildDetailRow(
                Icons.event,
                'Expiry',
                DateFormat.yMMMd().format(subscription.expiryDate!),
                Colors.orange,
              )
            else
              _buildDetailRow(
                Icons.folder,
                'Type',
                'Document (no expiry)',
                Colors.blue,
              ),
            const Gap(10),
            _buildDetailRow(
              Icons.timer,
              'Status',
              subscription.isExpired
                  ? 'Expired ${-subscription.daysUntilExpiry} days ago'
                  : '${subscription.daysUntilExpiry} days remaining',
              subscription.isExpired
                  ? Colors.grey
                  : (subscription.daysUntilExpiry <= 7
                        ? Colors.red
                        : Colors.green),
            ),
            if (subscription.description?.isNotEmpty ?? false) ...[
              const Gap(10),
              _buildDetailRow(
                Icons.notes,
                'Notes',
                subscription.description!,
                Colors.blue,
              ),
            ],
            // Document Photos Gallery
            if (subscription.documentPhotos.isNotEmpty) ...[
              const Gap(16),
              Row(
                children: [
                  const Icon(Icons.photo_library, size: 16, color: Colors.blue),
                  const Gap(6),
                  Text(
                    'Document Photos (${subscription.documentPhotos.length})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Gap(10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: subscription.documentPhotos.length,
                  itemBuilder: (context, index) {
                    final path = subscription.documentPhotos[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < subscription.documentPhotos.length - 1
                            ? 8
                            : 0,
                      ),
                      child: GestureDetector(
                        onTap: () => _showPhotoViewer(
                          context,
                          subscription.documentPhotos,
                          index,
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.withAlpha(40),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showEditItemSheet(context, subscription);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final repository = ref.read(taskRepositoryProvider);
                      await repository.deleteSubscription(subscription.id);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  void _showPhotoViewer(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _PhotoViewerDialog(photos: photos, initialIndex: initialIndex),
    );
  }
}

// ==================== ADD CATEGORY SHEET ====================

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  final _nameController = TextEditingController();
  bool _isDocument = true; // Default to Document

  @override
  void dispose() {
    _nameController.dispose();
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
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.create_new_folder,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Folder',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Choose a type for your folder',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
          const Gap(24),

          // Type Selection
          Text(
            'What type of folder?',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              // Document option
              Expanded(
                child: _buildTypeOption(
                  context,
                  isDocument: true,
                  icon: Icons.folder_copy,
                  title: 'Document',
                  subtitle: 'For storing photos\nof important papers',
                  color: Colors.blue,
                ),
              ),
              const Gap(12),
              // Reminder option
              Expanded(
                child: _buildTypeOption(
                  context,
                  isDocument: false,
                  icon: Icons.notifications_active,
                  title: 'Reminder',
                  subtitle: 'For tracking dates\n& expiry reminders',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const Gap(24),

          // Name input
          Text(
            'Folder Name',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: _isDocument
                  ? 'e.g., Passport, Aadhar, License...'
                  : 'e.g., Birthdays, Netflix, Insurance...',
              prefixIcon: Icon(
                _isDocument ? Icons.folder_copy : Icons.notifications_active,
                color: _isDocument ? Colors.blue : Colors.orange,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Gap(24),

          // Create button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _createCategory,
              style: FilledButton.styleFrom(
                backgroundColor: _isDocument ? Colors.blue : Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDocument
                        ? Icons.folder_copy
                        : Icons.notifications_active,
                    size: 20,
                  ),
                  const Gap(8),
                  Text(
                    'Create ${_isDocument ? 'Document' : 'Reminder'} Folder',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required bool isDocument,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _isDocument == isDocument;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _isDocument = isDocument),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(20)
              : colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withAlpha(30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : colorScheme.outline.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : colorScheme.outline,
                size: 28,
              ),
            ),
            const Gap(12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isSelected ? color : colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.outline,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a folder name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final repository = ref.read(taskRepositoryProvider);
    final category = SubscriptionCategory()
      ..name = _nameController.text.trim()
      ..isDocument = _isDocument
      ..colorValue = _isDocument ? 0xFF2196F3 : 0xFFFF9800;

    await repository.addCategory(category);
    if (mounted) Navigator.pop(context);
  }
}

// ==================== QUICK ADD CATEGORY SHEET ====================

class _QuickAddCategorySheet extends ConsumerStatefulWidget {
  final bool isDocument;

  const _QuickAddCategorySheet({required this.isDocument});

  @override
  ConsumerState<_QuickAddCategorySheet> createState() =>
      _QuickAddCategorySheetState();
}

class _QuickAddCategorySheetState
    extends ConsumerState<_QuickAddCategorySheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = widget.isDocument ? Colors.blue : Colors.orange;
    final icon = widget.isDocument
        ? Icons.folder_copy
        : Icons.notifications_active;

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
                  gradient: LinearGradient(
                    colors: widget.isDocument
                        ? [Colors.blue.shade400, Colors.blue.shade600]
                        : [Colors.orange.shade400, Colors.deepOrange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.create_new_folder,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create ${widget.isDocument ? 'Document' : 'Reminder'} Category',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.isDocument
                          ? 'e.g., Passport, License, Insurance'
                          : 'e.g., Netflix, Gym, Subscriptions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
          const Gap(24),

          // Name input
          Text(
            'Category Name',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: widget.isDocument
                  ? 'e.g., Passport, Aadhar, License...'
                  : 'e.g., OTT, Insurance, Birthdays...',
              prefixIcon: Icon(icon, color: color),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) => _createCategory(),
          ),
          const Gap(24),

          // Create button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _createCategory,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const Gap(8),
                  Text(
                    'Create Category',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final repository = ref.read(taskRepositoryProvider);
    final category = SubscriptionCategory()
      ..name = _nameController.text.trim()
      ..isDocument = widget.isDocument
      ..colorValue = widget.isDocument ? 0xFF2196F3 : 0xFFFF9800;

    await repository.addCategory(category);
    if (mounted) Navigator.pop(context);
  }
}

// ==================== ADD REMINDER SHEET ====================

class AddReminderSheet extends ConsumerStatefulWidget {
  final SubscriptionCategory? category;
  final Subscription? subscription;
  final int? parentFolderId; // For adding items to subfolders

  const AddReminderSheet({
    super.key,
    this.category,
    this.subscription,
    this.parentFolderId,
  });

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customIntervalController = TextEditingController(text: '30');
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  bool _showDescription = false;
  bool _trackExpiry = false; // New: whether to track expiry
  RecurrenceType _recurrenceType = RecurrenceType.yearly;
  int _customIntervalDays = 30;
  int _reminderDays = 1; // Days before expiry to remind

  // Document photos
  List<String> _documentPhotos = [];
  // PDF documents
  List<String> _pdfDocuments = [];
  // Other documents (Excel, Word, etc.)
  List<String> _otherDocuments = [];
  final _imagePicker = ImagePicker();

  bool get isEditing => widget.subscription != null;
  int get categoryId => widget.category?.id ?? widget.subscription!.categoryId;

  // Check if this is a Document category (not Reminder)
  bool get isDocumentCategory => widget.category?.isDocument ?? false;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.subscription!.name;
      _descriptionController.text = widget.subscription!.description ?? '';
      _trackExpiry = widget.subscription!.expiryDate != null;
      if (widget.subscription!.expiryDate != null) {
        _expiryDate = widget.subscription!.expiryDate!;
      }
      _showDescription = widget.subscription!.description?.isNotEmpty ?? false;
      _recurrenceType = widget.subscription!.recurrenceType;
      _customIntervalDays = widget.subscription!.customIntervalDays;
      _customIntervalController.text = _customIntervalDays.toString();
      _documentPhotos = List.from(widget.subscription!.documentPhotos);
      _pdfDocuments = List.from(widget.subscription!.pdfDocuments);
      _otherDocuments = List.from(widget.subscription!.otherDocuments);
      _reminderDays = widget.subscription!.reminderDays;
    } else {
      // For new items: Reminders have expiry ON by default, Documents OFF
      _trackExpiry = !isDocumentCategory;
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

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Fixed Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Column(
                children: [
                  // Drag handle
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
                  const Gap(16),
                  // Header with close button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDocumentCategory
                                ? [Colors.blue.shade400, Colors.blue.shade600]
                                : [
                                    Colors.orange.shade400,
                                    Colors.deepOrange.shade400,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isDocumentCategory
                              ? Icons.folder_copy
                              : Icons.notifications_active,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing
                                  ? 'Edit ${isDocumentCategory ? 'Document' : 'Reminder'}'
                                  : 'Add ${isDocumentCategory ? 'Document' : 'Reminder'}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isDocumentCategory
                                  ? 'Store photos of your document'
                                  : 'Track important dates & get reminders',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditing)
                        IconButton(
                          onPressed: _deleteItem,
                          icon: Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                            size: 22,
                          ),
                        ),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      'Name *',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    TextField(
                      controller: _nameController,
                      autofocus: !isEditing,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., Passport, Birthday, Netflix subscription...',
                        prefixIcon: Icon(
                          Icons.label_outline,
                          color: Colors.orange.shade400,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withAlpha(80),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const Gap(24),

                    // Document Photos Section - Only for Document categories
                    if (isDocumentCategory)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withAlpha(15),
                              Colors.purple.withAlpha(10),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withAlpha(40)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.photo_library,
                                  size: 20,
                                  color: Colors.blue.shade600,
                                ),
                                const Gap(8),
                                Text(
                                  'Document Photos',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const Spacer(),
                                if (_documentPhotos.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_documentPhotos.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(12),
                            _buildDocumentPhotosSection(theme, colorScheme),
                          ],
                        ),
                      ),
                    const Gap(20),

                    // Track Expiry Toggle
                    GestureDetector(
                      onTap: () => setState(() => _trackExpiry = !_trackExpiry),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _trackExpiry
                              ? Colors.orange.withAlpha(15)
                              : colorScheme.surfaceContainerHighest.withAlpha(
                                  60,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _trackExpiry
                                ? Colors.orange.withAlpha(50)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _trackExpiry ? Icons.alarm_on : Icons.alarm_off,
                              size: 20,
                              color: _trackExpiry
                                  ? Colors.orange
                                  : colorScheme.outline,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Track Expiry Date',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _trackExpiry
                                          ? Colors.orange.shade700
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    _trackExpiry
                                        ? 'Get reminded before expiry'
                                        : 'Optional - no reminder',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _trackExpiry,
                              onChanged: (v) =>
                                  setState(() => _trackExpiry = v),
                              activeColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expiry Settings (conditional)
                    if (_trackExpiry) ...[
                      const Gap(16),
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
                            color: colorScheme.surfaceContainerHighest
                                .withAlpha(80),
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
                      const Gap(16),
                      Text(
                        'Renewal Frequency',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(8),
                      _buildRecurrenceSelector(theme, colorScheme),
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
                                  if (days != null && days > 0)
                                    setState(() => _customIntervalDays = days);
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
                    ],
                    const Gap(16),

                    // Notes toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showDescription = !_showDescription),
                      child: Row(
                        children: [
                          Icon(
                            _showDescription
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                            color: colorScheme.outline,
                          ),
                          const Gap(4),
                          Text(
                            _showDescription
                                ? 'Hide notes'
                                : 'Add notes (optional)',
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
                          hintText: 'Additional notes about this document...',
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withAlpha(80),
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
                          backgroundColor: Colors.orange.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save, size: 20),
                            const Gap(8),
                            Text(
                              isEditing ? 'Update' : 'Save to Vault',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

    // Only set expiry date if tracking is enabled
    final DateTime? finalExpiryDate = _trackExpiry ? _expiryDate : null;

    if (isEditing) {
      final updated = widget.subscription!.copyWith(
        name: name,
        expiryDate: finalExpiryDate,
        clearExpiryDate: !_trackExpiry, // Clear if not tracking
        description: description.isEmpty ? null : description,
        recurrenceType: _recurrenceType,
        customIntervalDays: _customIntervalDays,
        reminderDays: _reminderDays,
        documentPhotos: _documentPhotos,
        pdfDocuments: _pdfDocuments,
        otherDocuments: _otherDocuments,
      );
      await repository.updateSubscription(updated);
    } else {
      final subscription = Subscription()
        ..name = name
        ..categoryId = categoryId
        ..expiryDate = finalExpiryDate
        ..description = description.isEmpty ? null : description
        ..recurrenceType = _recurrenceType
        ..customIntervalDays = _customIntervalDays
        ..reminderDays = _reminderDays
        ..documentPhotos = _documentPhotos
        ..pdfDocuments = _pdfDocuments
        ..otherDocuments = _otherDocuments
        ..parentFolderId = widget.parentFolderId;
      await repository.addSubscription(subscription);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Document updated!' : 'Document saved!'),
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
        title: const Text('Delete Reminder?'),
        content: Text(
          'Delete "${widget.subscription!.name}" and all its scheduled tasks?',
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

  Widget _buildDocumentPhotosSection(ThemeData theme, ColorScheme colorScheme) {
    final totalFiles =
        _documentPhotos.length + _pdfDocuments.length + _otherDocuments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Single "Add File" button
        GestureDetector(
          onTap: _pickAnyFile,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withAlpha(20),
                  Colors.purple.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Document',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      'Photos, PDFs, Excel, Word & more',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.blue.shade400),
              ],
            ),
          ),
        ),

        // Combined file gallery
        if (totalFiles > 0) ...[
          const Gap(16),
          Row(
            children: [
              Icon(Icons.folder_open, size: 16, color: Colors.blue.shade600),
              const Gap(6),
              Text(
                'Attached Files ($totalFiles)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Gap(10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalFiles,
              itemBuilder: (context, index) {
                // Combine all files: photos first, then PDFs, then others
                if (index < _documentPhotos.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildPhotoThumbnail(_documentPhotos[index], index),
                  );
                } else if (index <
                    _documentPhotos.length + _pdfDocuments.length) {
                  final pdfIndex = index - _documentPhotos.length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildPdfThumbnail(
                      _pdfDocuments[pdfIndex],
                      pdfIndex,
                    ),
                  );
                } else {
                  final otherIndex =
                      index - _documentPhotos.length - _pdfDocuments.length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _buildOtherDocThumbnail(
                      _otherDocuments[otherIndex],
                      otherIndex,
                    ),
                  );
                }
              },
            ),
          ),
          const Gap(6),
          Text(
            'Tap to view • Long press to delete',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddPhotoButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const Gap(6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(String path, int index) {
    return GestureDetector(
      onTap: () => _viewPhoto(path),
      onLongPress: () => _deletePhoto(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickAnyFile() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              Text(
                'Add Document',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(6),
              Text(
                'Choose how you want to add your document',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  // Camera option
                  Expanded(
                    child: _buildFilePickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickPhoto(ImageSource.camera);
                      },
                    ),
                  ),
                  const Gap(12),
                  // Gallery option
                  Expanded(
                    child: _buildFilePickerOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickPhoto(ImageSource.gallery);
                      },
                    ),
                  ),
                  const Gap(12),
                  // Files option
                  Expanded(
                    child: _buildFilePickerOption(
                      icon: Icons.folder_rounded,
                      label: 'Files',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickFromFiles();
                      },
                    ),
                  ),
                ],
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromFiles() async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final originalFileName = result.files.single.name;

        // Get file extension
        final extension = originalFileName.contains('.')
            ? originalFileName.split('.').last.toLowerCase()
            : '';

        final appDir = await getApplicationDocumentsDirectory();

        // Route to appropriate list based on file type
        if ([
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'heic',
          'bmp',
        ].contains(extension)) {
          // It's an image
          final fileName =
              'photo_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final savedPath = '${appDir.path}/$fileName';
          await File(originalPath).copy(savedPath);
          setState(() => _documentPhotos.add(savedPath));
        } else if (extension == 'pdf') {
          // It's a PDF
          final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final savedPath = '${appDir.path}/$fileName';
          await File(originalPath).copy(savedPath);
          setState(() => _pdfDocuments.add(savedPath));
        } else {
          // It's another document type
          final fileName =
              'doc_${DateTime.now().millisecondsSinceEpoch}.$extension';
          final savedPath = '${appDir.path}/$fileName';
          await File(originalPath).copy(savedPath);
          setState(() => _otherDocuments.add(savedPath));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Save to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = '${appDir.path}/$fileName';

        await File(pickedFile.path).copy(savedPath);

        setState(() {
          _documentPhotos.add(savedPath);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking photo: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewPhoto(String path) {
    final index = _documentPhotos.indexOf(path);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Photo ${index + 1} of ${_documentPhotos.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),
              // Photo display
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.file(File(path), fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              const Gap(16),
              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await PdfService.sharePdf(path, 'Photo_${index + 1}');
                        },
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (index >= 0) _deletePhoto(index);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deletePhoto(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This photo will be removed from this document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _documentPhotos.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdf() async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;

        // Copy to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final savedPath = '${appDir.path}/$fileName';

        await File(originalPath).copy(savedPath);

        setState(() {
          _pdfDocuments.add(savedPath);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking PDF: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPdfThumbnail(String path, int index) {
    final fileName = path.split('/').last;

    return GestureDetector(
      onTap: () => _viewPdf(path),
      onLongPress: () => _deletePdf(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 28,
              ),
            ),
            const Gap(6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                fileName.length > 12
                    ? '${fileName.substring(0, 10)}...'
                    : fileName,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPdf(String path) {
    final index = _pdfDocuments.indexOf(path);
    final fileName = path.split('/').last;

    // Open full-screen PDF viewer
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PdfPageViewer(
        pdfPath: path,
        fileName: fileName,
        onDelete: () {
          Navigator.pop(ctx);
          if (index >= 0) _deletePdf(index);
        },
      ),
    );
  }

  void _deletePdf(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete PDF?'),
        content: const Text('This PDF will be removed from this document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _pdfDocuments.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ========== Other Documents Methods ==========

  Future<void> _pickOtherDocument() async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final originalPath = result.files.single.path!;
        final originalFileName = result.files.single.name;

        // Get file extension
        final extension = originalFileName.contains('.')
            ? originalFileName.split('.').last.toLowerCase()
            : '';

        // Skip if it's a photo or PDF (those have their own handlers)
        if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Use Camera/Gallery button for images'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
        if (extension == 'pdf') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Use PDF button for PDF files'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        // Copy to app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'doc_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final savedPath = '${appDir.path}/$fileName';

        await File(originalPath).copy(savedPath);

        setState(() {
          _otherDocuments.add(savedPath);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOtherDocThumbnail(String path, int index) {
    final fileName = path.split('/').last;
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    // Get icon and color based on file type
    IconData icon;
    Color color;

    switch (extension) {
      case 'xls':
      case 'xlsx':
      case 'csv':
        icon = Icons.table_chart;
        color = Colors.green;
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'ppt':
      case 'pptx':
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      case 'txt':
        icon = Icons.text_snippet;
        color = Colors.grey;
        break;
      case 'zip':
      case 'rar':
      case '7z':
        icon = Icons.folder_zip;
        color = Colors.amber;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.teal;
    }

    return GestureDetector(
      onTap: () => _viewOtherDocument(path),
      onLongPress: () => _deleteOtherDocument(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                fileName.length > 12
                    ? '${fileName.substring(0, 10)}...'
                    : fileName,
                style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewOtherDocument(String path) async {
    try {
      // Open file with system handler
      await OpenFile.open(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open file: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteOtherDocument(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete File?'),
        content: const Text('This file will be removed from this document.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _otherDocuments.removeAt(index);
              });
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ==================== FULL SCREEN DOCUMENT VIEWER ====================

class _FullScreenDocumentViewer extends ConsumerStatefulWidget {
  final Subscription subscription;

  const _FullScreenDocumentViewer({required this.subscription});

  @override
  ConsumerState<_FullScreenDocumentViewer> createState() =>
      _FullScreenDocumentViewerState();
}

class _FullScreenDocumentViewerState
    extends ConsumerState<_FullScreenDocumentViewer> {
  late PageController _pageController;
  int _currentPage = 0;
  late Subscription _subscription;

  // PDF state
  PdfController? _pdfController;
  int _pdfTotalPages = 0;
  bool _isPdfLoading = true;
  String? _pdfError;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _subscription = widget.subscription;
    _loadPdfIfNeeded();
  }

  Future<void> _loadPdfIfNeeded() async {
    final photos = _subscription.documentPhotos;
    final pdfs = _subscription.pdfDocuments;

    // If there are no photos but there are PDFs, load the first PDF
    if (photos.isEmpty && pdfs.isNotEmpty) {
      try {
        final document = await PdfDocument.openFile(pdfs.first);
        if (mounted) {
          setState(() {
            _pdfController = PdfController(document: Future.value(document));
            _pdfTotalPages = document.pagesCount;
            _isPdfLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _pdfError = 'Failed to load PDF: $e';
            _isPdfLoading = false;
          });
        }
      }
    } else {
      setState(() => _isPdfLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _refreshSubscription() async {
    final repository = ref.read(taskRepositoryProvider);
    final updated = await repository.getSubscription(_subscription.id);
    if (updated != null && mounted) {
      setState(() => _subscription = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final photos = _subscription.documentPhotos;
    final pdfs = _subscription.pdfDocuments;
    final otherDocs = _subscription.otherDocuments;
    final hasExpiry = _subscription.expiryDate != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.7,
      maxChildSize: 0.98,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Column(
                children: [
                  // Drag handle
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
                  const Gap(16),
                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.subscription.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                if (photos.isNotEmpty)
                                  Text(
                                    '${photos.length} ${photos.length == 1 ? 'photo' : 'photos'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (photos.isNotEmpty && pdfs.isNotEmpty)
                                  Text(
                                    ', ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                if (pdfs.isNotEmpty)
                                  Text(
                                    '${pdfs.length} ${pdfs.length == 1 ? 'PDF' : 'PDFs'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if ((photos.isNotEmpty || pdfs.isNotEmpty) &&
                                    otherDocs.isNotEmpty)
                                  Text(
                                    ', ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                if (otherDocs.isNotEmpty)
                                  Text(
                                    '${otherDocs.length} ${otherDocs.length == 1 ? 'file' : 'files'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (hasExpiry) ...[
                                  Text(
                                    ' • ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                  Text(
                                    _subscription.isExpired
                                        ? 'Expired'
                                        : 'Exp: ${DateFormat.yMMMd().format(_subscription.expiryDate!)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _subscription.isExpired
                                          ? Colors.grey
                                          : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(12),

            // Page indicator - show for photos OR PDFs
            if (photos.length > 1 ||
                (photos.isEmpty && pdfs.isNotEmpty && _pdfTotalPages > 1))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: photos.isNotEmpty
                            ? Colors.blue.withAlpha(20)
                            : Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swipe,
                            size: 16,
                            color: photos.isNotEmpty
                                ? Colors.blue.shade700
                                : Colors.red.shade700,
                          ),
                          const Gap(8),
                          Text(
                            photos.isNotEmpty
                                ? 'Page ${_currentPage + 1} of ${photos.length}'
                                : 'Page ${_currentPage + 1} of $_pdfTotalPages',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: photos.isNotEmpty
                                  ? Colors.blue.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            '• Swipe to browse',
                            style: TextStyle(
                              fontSize: 12,
                              color: photos.isNotEmpty
                                  ? Colors.blue.shade400
                                  : Colors.red.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Gap(12),

            // Document pages - show Photos OR PDF pages
            Expanded(
              child: photos.isNotEmpty
                  // Show photos as before
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: photos.length,
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      itemBuilder: (context, index) {
                        final file = File(photos[index]);

                        return GestureDetector(
                          onLongPress: () => _showImageOptions(context, index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colorScheme.outline.withAlpha(30),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(19),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: InteractiveViewer(
                                        minScale: 0.5,
                                        maxScale: 5.0,
                                        child: file.existsSync()
                                            ? Image.file(
                                                file,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    _buildErrorWidget(),
                                              )
                                            : _buildErrorWidget(),
                                      ),
                                    ),
                                    // Long press hint
                                    Positioned(
                                      bottom: 16,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withAlpha(120),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: const Text(
                                            'Long press for options',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  // Show PDF pages if no photos but has PDFs
                  : pdfs.isNotEmpty
                  ? _isPdfLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.red),
                                Gap(16),
                                Text('Loading PDF pages...'),
                              ],
                            ),
                          )
                        : _pdfError != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const Gap(16),
                                Text(
                                  _pdfError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          )
                        : _pdfController != null
                        ? GestureDetector(
                            onLongPress: () =>
                                _showPdfOptions(context, pdfs.first),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(10),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.outline.withAlpha(30),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(19),
                                  child: Stack(
                                    children: [
                                      PdfView(
                                        controller: _pdfController!,
                                        onPageChanged: (page) {
                                          setState(
                                            () => _currentPage = page - 1,
                                          );
                                        },
                                        builders:
                                            PdfViewBuilders<
                                              DefaultBuilderOptions
                                            >(
                                              options:
                                                  const DefaultBuilderOptions(),
                                              documentLoaderBuilder: (_) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.red,
                                                        ),
                                                  ),
                                              pageLoaderBuilder: (_) =>
                                                  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.red,
                                                        ),
                                                  ),
                                              errorBuilder: (_, error) =>
                                                  Center(
                                                    child: Text(
                                                      error.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                      ),
                                      // Long press hint
                                      Positioned(
                                        bottom: 16,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(
                                                120,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Text(
                                              'Long press for options',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Center(child: Text('Unable to load PDF'))
                  // No photos or PDFs
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const Gap(16),
                          Text(
                            'No documents attached',
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
            ),

            // Page dots
            if (photos.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    photos.length,
                    (index) => GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: index == _currentPage ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? Colors.blue
                              : colorScheme.outline.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const Gap(8),

            // PDF section - only show if there are BOTH photos AND PDFs
            // (since PDFs are shown directly in main area when there are no photos)
            if (photos.isNotEmpty && pdfs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          size: 16,
                          color: Colors.red,
                        ),
                        const Gap(6),
                        Text(
                          'Attached PDFs (${pdfs.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to view',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pdfs.length,
                        itemBuilder: (context, index) {
                          final pdfPath = pdfs[index];
                          final fileName = pdfPath.split('/').last;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < pdfs.length - 1 ? 12 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => _openPdfViewer(pdfPath, fileName),
                              child: Container(
                                width: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.red.withAlpha(15),
                                      Colors.red.withAlpha(30),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withAlpha(40),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withAlpha(30),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                    ),
                                    const Gap(6),
                                    Text(
                                      fileName.length > 15
                                          ? '${fileName.substring(0, 12)}...'
                                          : fileName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Other documents section - show if there are other docs
            if (otherDocs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          size: 16,
                          color: Colors.teal,
                        ),
                        const Gap(6),
                        Text(
                          'Other Files (${otherDocs.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to open',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.teal.shade400,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: otherDocs.length,
                        itemBuilder: (context, index) {
                          final filePath = otherDocs[index];
                          final fileName = filePath.split('/').last;
                          final extension = fileName.contains('.')
                              ? fileName.split('.').last.toLowerCase()
                              : '';

                          // Get icon and color based on file type
                          IconData icon;
                          Color color;

                          switch (extension) {
                            case 'xls':
                            case 'xlsx':
                            case 'csv':
                              icon = Icons.table_chart;
                              color = Colors.green;
                              break;
                            case 'doc':
                            case 'docx':
                              icon = Icons.description;
                              color = Colors.blue;
                              break;
                            case 'ppt':
                            case 'pptx':
                              icon = Icons.slideshow;
                              color = Colors.orange;
                              break;
                            case 'txt':
                              icon = Icons.text_snippet;
                              color = Colors.grey;
                              break;
                            case 'zip':
                            case 'rar':
                            case '7z':
                              icon = Icons.folder_zip;
                              color = Colors.amber;
                              break;
                            default:
                              icon = Icons.insert_drive_file;
                              color = Colors.teal;
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < otherDocs.length - 1 ? 12 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => _openOtherDocument(filePath),
                              child: Container(
                                width: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      color.withAlpha(15),
                                      color.withAlpha(30),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: color.withAlpha(40),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withAlpha(30),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(icon, color: color, size: 24),
                                    ),
                                    const Gap(6),
                                    Text(
                                      fileName.length > 15
                                          ? '${fileName.substring(0, 12)}...'
                                          : fileName,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // Edit button
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: Colors.blue,
                      onTap: _showEditSheet,
                    ),
                  ),
                  const Gap(8),
                  // Download/Share button for PDFs (when viewing PDF only)
                  if (photos.isEmpty && pdfs.isNotEmpty)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.download_outlined,
                        label: 'Download',
                        color: Colors.green,
                        onTap: () => _downloadPdf(pdfs.first),
                      ),
                    ),
                  // Export as PDF button for photos
                  if (photos.isNotEmpty)
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.picture_as_pdf_outlined,
                        label: 'Export PDF',
                        color: Colors.red,
                        onTap: _exportAsPdf,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const Gap(6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(String pdfPath) async {
    final fileName = pdfPath.split('/').last.replaceAll('.pdf', '');
    await PdfService.sharePdf(pdfPath, fileName);
  }

  Future<void> _openOtherDocument(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open file: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPdfOptions(BuildContext context, String pdfPath) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileName = pdfPath.split('/').last;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              Text(
                fileName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              // Edit option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                ),
                title: const Text('Edit Document'),
                subtitle: const Text('Modify document details'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditSheet();
                },
              ),
              // Download option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                title: const Text('Download / Share'),
                subtitle: const Text('Save or share this PDF'),
                onTap: () {
                  Navigator.pop(ctx);
                  _downloadPdf(pdfPath);
                },
              ),
              // Delete option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
                title: const Text('Delete PDF'),
                subtitle: const Text('Remove this PDF from document'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeletePdfFromViewer(pdfPath);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPdfViewer(String pdfPath, String fileName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PdfPageViewer(
        pdfPath: pdfPath,
        fileName: fileName,
        onDelete: () {
          // Close the PDF viewer
          Navigator.pop(ctx);
          // Show confirmation and delete
          _confirmDeletePdfFromViewer(pdfPath);
        },
      ),
    );
  }

  Future<void> _confirmDeletePdfFromViewer(String pdfPath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete PDF?'),
        content: const Text(
          'This PDF will be permanently removed from this document.',
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
      final newPdfs = List<String>.from(_subscription.pdfDocuments);
      newPdfs.remove(pdfPath);

      final updated = _subscription.copyWith(pdfDocuments: newPdfs);
      await repository.updateSubscription(updated);

      if (mounted) {
        setState(() {
          _subscription = updated;
        });
      }
    }
  }

  void _showImageOptions(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              Text(
                'Photo ${index + 1} of ${_subscription.documentPhotos.length}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(12),
              // Edit full document
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_document, color: Colors.blue),
                ),
                title: const Text('Edit Document'),
                subtitle: const Text('Change name, add/remove photos, expiry'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditSheet();
                },
              ),
              // Delete this photo
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Delete This Photo'),
                subtitle: const Text('Remove just this photo from document'),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeletePhoto(index);
                },
              ),
              // Share this photo
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share_outlined, color: Colors.green),
                ),
                title: const Text('Share Photo'),
                subtitle: const Text('Share this photo individually'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await PdfService.sharePdf(
                    _subscription.documentPhotos[index],
                    _subscription.name,
                  );
                },
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePhoto(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This photo will be permanently removed.'),
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
      final newPhotos = List<String>.from(_subscription.documentPhotos);
      newPhotos.removeAt(index);

      final updated = _subscription.copyWith(documentPhotos: newPhotos);
      await repository.updateSubscription(updated);

      if (newPhotos.isEmpty && mounted) {
        Navigator.pop(context); // Close viewer if no photos left
      } else if (mounted) {
        setState(() {
          _subscription = updated;
          if (_currentPage >= newPhotos.length) {
            _currentPage = newPhotos.length - 1;
            _pageController.jumpToPage(_currentPage);
          }
        });
      }
    }
  }

  void _showEditSheet() async {
    // Get the category for this subscription
    final repository = ref.read(taskRepositoryProvider);
    final category = await repository.getCategory(_subscription.categoryId);

    if (!mounted) return;

    Navigator.pop(context); // Close document viewer

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          AddReminderSheet(category: category, subscription: _subscription),
    );
  }

  void _showReminderDays() {
    final reminderDates = _calculateReminderDates();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const Gap(12),
            const Text('Reminder Dates'),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: reminderDates.isEmpty
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey),
                    Gap(12),
                    Text(
                      'No upcoming reminder dates',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reminders scheduled ${_subscription.reminderDays} day(s) before expiry:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Gap(12),
                      ...reminderDates.map(
                        (date) => _buildReminderDateTile(date, ctx),
                      ),
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (reminderDates.isNotEmpty)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Close document viewer
                // Navigate to the first reminder date
                final firstDate = reminderDates.first;
                ref.read(selectedDateProvider.notifier).state = firstDate;
                ref.read(bottomNavIndexProvider.notifier).state =
                    1; // Today tab
              },
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('Go to Calendar'),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            ),
        ],
      ),
    );
  }

  Widget _buildReminderDateTile(DateTime date, BuildContext ctx) {
    final isPast = date.isBefore(DateTime.now());
    final isToday = _isToday(date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(ctx);
          Navigator.pop(context); // Close document viewer
          ref.read(selectedDateProvider.notifier).state = date;
          ref.read(bottomNavIndexProvider.notifier).state = 1; // Today tab
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday
                ? Colors.orange.withAlpha(20)
                : (isPast
                      ? Colors.grey.withAlpha(10)
                      : Colors.blue.withAlpha(10)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday
                  ? Colors.orange.withAlpha(50)
                  : (isPast
                        ? Colors.grey.withAlpha(30)
                        : Colors.blue.withAlpha(30)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isToday
                    ? Icons.today
                    : (isPast ? Icons.event_busy : Icons.event_available),
                color: isToday
                    ? Colors.orange
                    : (isPast ? Colors.grey : Colors.blue),
                size: 20,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMEd().format(date),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isPast ? Colors.grey : null,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      isToday
                          ? 'Today'
                          : (isPast
                                ? 'Past'
                                : '${date.difference(DateTime.now()).inDays + 1} days from now'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isToday
                            ? Colors.orange
                            : (isPast ? Colors.grey : Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPast)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  List<DateTime> _calculateReminderDates() {
    final List<DateTime> dates = [];
    final baseExpiryDate = _subscription.expiryDate;

    if (baseExpiryDate == null) return dates;

    final reminderDays = _subscription.reminderDays;

    switch (_subscription.recurrenceType) {
      case RecurrenceType.once:
        dates.add(baseExpiryDate.subtract(Duration(days: reminderDays)));
        break;
      case RecurrenceType.monthly:
        for (int i = 0; i < 12; i++) {
          final expiryDate = DateTime(
            baseExpiryDate.year,
            baseExpiryDate.month + i,
            baseExpiryDate.day,
          );
          dates.add(expiryDate.subtract(Duration(days: reminderDays)));
        }
        break;
      case RecurrenceType.yearly:
        dates.add(baseExpiryDate.subtract(Duration(days: reminderDays)));
        final nextYearExpiry = DateTime(
          baseExpiryDate.year + 1,
          baseExpiryDate.month,
          baseExpiryDate.day,
        );
        dates.add(nextYearExpiry.subtract(Duration(days: reminderDays)));
        break;
      case RecurrenceType.custom:
        final intervalDays = _subscription.customIntervalDays;
        DateTime currentExpiry = baseExpiryDate;
        final oneYearFromNow = DateTime.now().add(const Duration(days: 365));

        while (currentExpiry.isBefore(oneYearFromNow)) {
          dates.add(currentExpiry.subtract(Duration(days: reminderDays)));
          currentExpiry = currentExpiry.add(Duration(days: intervalDays));
        }
        break;
    }

    return dates;
  }

  Future<void> _exportAsPdf() async {
    if (_subscription.documentPhotos.isEmpty &&
        _subscription.pdfDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No documents to export'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text(
                'Creating PDF...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await PdfService.exportImagesToPdf(
        _subscription.documentPhotos,
        documentName: _subscription.name,
      );

      if (mounted) Navigator.pop(context); // Close loading

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                Gap(8),
                Text('PDF exported successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
            const Gap(8),
            Text(
              'Image not found',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ALL DOCUMENTS GALLERY ====================

class _AllDocumentsGallery extends StatelessWidget {
  final List<Map<String, dynamic>> documents;

  const _AllDocumentsGallery({required this.documents});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle and Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(16),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Documents',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${documents.length} photo${documents.length == 1 ? '' : 's'} stored',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Grid of documents
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  final file = File(doc['path'] as String);
                  final name = doc['name'] as String;

                  return GestureDetector(
                    onTap: () => _showFullImage(context, doc['path'] as String),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withAlpha(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image
                            file.existsSync()
                                ? Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.broken_image,
                                        color: colorScheme.outline,
                                        size: 32,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: colorScheme.outline,
                                      size: 32,
                                    ),
                                  ),
                            // Label at bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withAlpha(200),
                                      Colors.black.withAlpha(0),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Tap indicator
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Close'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(200),
                foregroundColor: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PHOTO VIEWER DIALOG ====================

class _PhotoViewerDialog extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerDialog({required this.photos, required this.initialIndex});

  @override
  State<_PhotoViewerDialog> createState() => _PhotoViewerDialogState();
}

class _PhotoViewerDialogState extends State<_PhotoViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photo counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.photos.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(12),
          // Photo viewer
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      File(widget.photos[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Gap(16),
          // Navigation dots
          if (widget.photos.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.photos.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? Colors.white
                        : Colors.white.withAlpha(80),
                  ),
                ),
              ),
            ),
          const Gap(16),
          // Close button
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(200),
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// PDF Page Viewer widget - renders PDF pages that can be swiped like images
class _PdfPageViewer extends StatefulWidget {
  final String pdfPath;
  final String fileName;
  final VoidCallback onDelete;

  const _PdfPageViewer({
    required this.pdfPath,
    required this.fileName,
    required this.onDelete,
  });

  @override
  State<_PdfPageViewer> createState() => _PdfPageViewerState();
}

class _PdfPageViewerState extends State<_PdfPageViewer> {
  PdfController? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final document = await PdfDocument.openFile(widget.pdfPath);
      setState(() {
        _pdfController = PdfController(document: Future.value(document));
        _totalPages = document.pagesCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Column(
                children: [
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
                  const Gap(16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.fileName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_totalPages > 0)
                              Text(
                                '$_totalPages ${_totalPages == 1 ? 'page' : 'pages'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(12),

            // Page indicator
            if (_totalPages > 1 && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withAlpha(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Page $_currentPage of $_totalPages',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        '• Swipe to browse',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Gap(12),

            // PDF Pages
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.red),
                          Gap(16),
                          Text('Loading PDF pages...'),
                        ],
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const Gap(16),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )
                  : PdfView(
                      controller: _pdfController!,
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                      },
                      builders: PdfViewBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(),
                        documentLoaderBuilder: (_) => const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                        pageLoaderBuilder: (_) => const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                        errorBuilder: (_, error) => Center(
                          child: Text(
                            error.toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
            ),

            // Page dots
            if (_totalPages > 1 && _totalPages <= 10 && !_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: index + 1 == _currentPage ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index + 1 == _currentPage
                            ? Colors.red
                            : colorScheme.outline.withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await PdfService.sharePdf(
                          widget.pdfPath,
                          widget.fileName.replaceAll('.pdf', ''),
                        );
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
