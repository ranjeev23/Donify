import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:remindlyf/data/models/expense_category.dart';
import 'package:remindlyf/data/models/income.dart';
import 'package:remindlyf/domain/providers/money_provider.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/presentation/widgets/spending_analytics_sheet.dart';

class MoneyManagerScreen extends ConsumerStatefulWidget {
  const MoneyManagerScreen({super.key});

  @override
  ConsumerState<MoneyManagerScreen> createState() => _MoneyManagerScreenState();
}

class _MoneyManagerScreenState extends ConsumerState<MoneyManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final statsAsync = ref.watch(monthlyStatsProvider);
    final categoriesAsync = ref.watch(categoriesByTypeProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Premium dark header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1a1a2e),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Dark gradient background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                      ),
                    ),
                  ),
                  // Decorative glow effects
                  Positioned(
                    top: -60,
                    right: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6366F1).withAlpha(50),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: -50,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withAlpha(35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            children: [
                              Text(
                                'Money Manager',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showStatisticsSheet(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(15),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.insights_rounded,
                                    color: Colors.white60,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          // Stats content
                          statsAsync.when(
                            data: (stats) => GestureDetector(
                              onLongPress: () =>
                                  _showBalanceBreakdown(context, stats),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Month badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: Colors.white54,
                                        ),
                                        const Gap(8),
                                        Text(
                                          DateFormat.MMMM().format(
                                            DateTime.now(),
                                          ),
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(16),
                                  // Balance
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '₹${stats.remainingBalance.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w700,
                                          color: stats.remainingBalance >= 0
                                              ? Colors.white
                                              : const Color(0xFFFF6B6B),
                                          letterSpacing: -1.5,
                                          height: 1.1,
                                        ),
                                      ),
                                      const Gap(12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(5),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          'Hold for details',
                                          style: TextStyle(
                                            color: Colors.white24,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      Text(
                                        'Available Balance',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () =>
                                            _showIncomeListSheet(context),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(10),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withAlpha(15),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.history_rounded,
                                                size: 14,
                                                color: Colors.white70,
                                              ),
                                              const Gap(6),
                                              Text(
                                                'Income Log',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(20),
                                  // Income/Spent row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF10B981,
                                            ).withAlpha(15),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFF10B981,
                                              ).withAlpha(30),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF10B981,
                                                  ).withAlpha(25),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.south_west_rounded,
                                                  size: 18,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ),
                                              const Gap(12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Income',
                                                    style: TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${_formatAmount(stats.totalIncome)}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF10B981),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFFF6B6B,
                                            ).withAlpha(10),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFFFF6B6B,
                                              ).withAlpha(25),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFF6B6B,
                                                  ).withAlpha(20),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.north_east_rounded,
                                                  size: 18,
                                                  color: Color(0xFFFF6B6B),
                                                ),
                                              ),
                                              const Gap(12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Spent',
                                                    style: TextStyle(
                                                      color: Colors.white38,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${_formatAmount(stats.totalSpent)}',
                                                    style: const TextStyle(
                                                      color: Color(0xFFFF6B6B),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                              ),
                            ),
                            error: (e, s) => const Text(
                              'Error',
                              style: TextStyle(color: Colors.white54),
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

          // Spacer
          const SliverToBoxAdapter(child: Gap(12)),

          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.outline,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.eco_outlined, size: 20), text: 'Needs'),
                  Tab(
                    icon: Icon(Icons.shopping_bag_outlined, size: 20),
                    text: 'Wants',
                  ),
                  Tab(
                    icon: Icon(Icons.savings_outlined, size: 20),
                    text: 'Savings',
                  ),
                ],
              ),
              colorScheme.surface,
            ),
          ),

          // Categories content
          SliverFillRemaining(
            child: categoriesAsync.when(
              data: (groupedCategories) => TabBarView(
                controller: _tabController,
                children: [
                  _CategoryList(
                    type: ExpenseType.needs,
                    categories: groupedCategories[ExpenseType.needs] ?? [],
                    color: const Color(0xFF3B82F6), // Blue for Needs
                    description:
                        'Essential expenses like groceries, rent, utilities',
                  ),
                  _CategoryList(
                    type: ExpenseType.wants,
                    categories: groupedCategories[ExpenseType.wants] ?? [],
                    color: const Color(0xFFF59E0B), // Yellow for Wants
                    description:
                        'Non-essential but enjoyable like dining out, entertainment',
                  ),
                  _CategoryList(
                    type: ExpenseType.savings,
                    categories: groupedCategories[ExpenseType.savings] ?? [],
                    color: const Color(0xFF10B981), // Green for Savings
                    description: 'Investments, emergency fund, savings goals',
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // Balance breakdown sheet (long press)
  void _showBalanceBreakdown(BuildContext context, MonthlyStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Gap(20),
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
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
                        'Balance Breakdown',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat.MMMM().format(DateTime.now()),
                        style: TextStyle(
                          color: colorScheme.outline,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Cash & UPI Remaining - Main Focus
            Row(
              children: [
                // Cash Remaining
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF10B981).withAlpha(15),
                          const Color(0xFF059669).withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withAlpha(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.money_rounded,
                                size: 20,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              stats.cashRemaining >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: stats.cashRemaining >= 0
                                  ? const Color(0xFF10B981)
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          'Cash',
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '₹${stats.cashRemaining.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: stats.cashRemaining >= 0
                                ? const Color(0xFF10B981)
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                // UPI Remaining
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6366F1).withAlpha(15),
                          const Color(0xFF8B5CF6).withAlpha(10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withAlpha(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withAlpha(25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                size: 20,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              stats.upiRemaining >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: stats.upiRemaining >= 0
                                  ? const Color(0xFF6366F1)
                                  : Colors.redAccent,
                            ),
                          ],
                        ),
                        const Gap(12),
                        Text(
                          'UPI / Bank',
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          '₹${stats.upiRemaining.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: stats.upiRemaining >= 0
                                ? const Color(0xFF6366F1)
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpendRow(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
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
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTypeItem(
    Color color,
    IconData icon,
    String label,
    double amount,
  ) {
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
        const Gap(10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpendingBar(
    String label,
    double amount,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13)),
            Text(
              '₹${amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withAlpha(30),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  // Statistics sheet
  void _showStatisticsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => const SpendingAnalyticsSheet(),
      ),
    );
  }

  void _showAddIncomeSheet(BuildContext context) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    IncomeType selectedType = IncomeType.cash;
    DateTime selectedDate = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Gap(14),
                  Text(
                    'Add Income',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // Amount Input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                  hintText: '0',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const Gap(20),

              // Income Type Selection
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedType = IncomeType.cash),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedType == IncomeType.cash
                              ? Colors.green.withAlpha(30)
                              : colorScheme.surfaceContainerHighest.withAlpha(
                                  60,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedType == IncomeType.cash
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.money_rounded,
                              color: selectedType == IncomeType.cash
                                  ? Colors.green
                                  : colorScheme.outline,
                              size: 28,
                            ),
                            const Gap(6),
                            Text(
                              'Cash',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selectedType == IncomeType.cash
                                    ? Colors.green
                                    : colorScheme.onSurfaceVariant,
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
                      onTap: () =>
                          setModalState(() => selectedType = IncomeType.upi),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedType == IncomeType.upi
                              ? Colors.purple.withAlpha(30)
                              : colorScheme.surfaceContainerHighest.withAlpha(
                                  60,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedType == IncomeType.upi
                                ? Colors.purple
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.phonelink_ring_rounded,
                              color: selectedType == IncomeType.upi
                                  ? Colors.purple
                                  : colorScheme.outline,
                              size: 28,
                            ),
                            const Gap(6),
                            Text(
                              'UPI',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selectedType == IncomeType.upi
                                    ? Colors.purple
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Note Input
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  prefixIcon: Icon(
                    Icons.notes,
                    color: colorScheme.outline,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const Gap(16),

              // Date picker
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setModalState(() => selectedDate = date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: colorScheme.outline,
                      ),
                      const Gap(12),
                      Text(
                        DateFormat.yMMMd().format(selectedDate),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: colorScheme.outline),
                    ],
                  ),
                ),
              ),
              const Gap(24),

              // Save Button
              FilledButton(
                onPressed: () async {
                  final amountText = amountController.text.trim();
                  if (amountText.isEmpty) return;

                  final amount = double.tryParse(amountText);
                  if (amount == null || amount <= 0) return;

                  final income = Income()
                    ..amount = amount
                    ..type = selectedType
                    ..note = noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim()
                    ..incomeDate = selectedDate;

                  final repository = ref.read(taskRepositoryProvider);
                  await repository.addIncome(income);

                  // Invalidate stats to refresh balance
                  ref.invalidate(monthlyStatsProvider);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '₹${amount.toStringAsFixed(0)} income added!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Income',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show income list with edit/delete
  void _showIncomeListSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
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
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Gap(14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Income History',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tap to edit, swipe to delete',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showAddIncomeSheet(context);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Income list
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final incomesAsync = ref.watch(incomesProvider);
                    return incomesAsync.when(
                      data: (incomes) {
                        if (incomes.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 48,
                                    color: Colors.green,
                                  ),
                                ),
                                const Gap(16),
                                Text(
                                  'No Income Yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  'Tap + to add your first income',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Sort by date (newest first)
                        final sortedIncomes = List<Income>.from(
                          incomes,
                        )..sort((a, b) => b.incomeDate.compareTo(a.incomeDate));

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: sortedIncomes.length,
                          itemBuilder: (context, index) {
                            final income = sortedIncomes[index];
                            return _buildIncomeCard(context, income);
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, Income income) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData typeIcon;
    Color typeColor;
    switch (income.type) {
      case IncomeType.cash:
        typeIcon = Icons.money;
        typeColor = Colors.green;
        break;
      case IncomeType.upi:
        typeIcon = Icons.phone_android;
        typeColor = Colors.purple;
        break;
      case IncomeType.bankTransfer:
        typeIcon = Icons.account_balance;
        typeColor = Colors.blue;
        break;
      case IncomeType.other:
        typeIcon = Icons.wallet;
        typeColor = Colors.orange;
        break;
    }

    return Dismissible(
      key: Key('income_${income.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeleteIncome(context, income),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            Gap(6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: typeColor.withAlpha(40)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditIncomeSheet(context, income),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 24),
                  ),
                  const Gap(14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₹${income.amount.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                income.typeLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          DateFormat(
                            'MMM d, yyyy • h:mm a',
                          ).format(income.incomeDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        if (income.note != null && income.note!.isNotEmpty) ...[
                          const Gap(4),
                          Text(
                            income.note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Edit hint
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteIncome(BuildContext context, Income income) async {
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
              'Delete ₹${income.amount.toStringAsFixed(0)} income?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'This will be removed from your ${DateFormat.MMMM().format(income.incomeDate)} income.',
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
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
      final repository = ref.read(taskRepositoryProvider);
      await repository.deleteIncome(income.id);
      ref.invalidate(monthlyStatsProvider);
      return true;
    }
    return false;
  }

  void _showEditIncomeSheet(BuildContext context, Income income) {
    final amountController = TextEditingController(
      text: income.amount.toStringAsFixed(0),
    );
    final noteController = TextEditingController(text: income.note ?? '');
    IncomeType selectedType = income.type;
    DateTime selectedDate = income.incomeDate;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Gap(14),
                  Text(
                    'Edit Income',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // Amount Input
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const Gap(16),

              // Income Type Selection
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(10),
              Row(
                children: [
                  _buildTypeOption(
                    setModalState,
                    'Cash',
                    Icons.money,
                    IncomeType.cash,
                    selectedType,
                    (t) => setModalState(() => selectedType = t),
                  ),
                  const Gap(8),
                  _buildTypeOption(
                    setModalState,
                    'UPI',
                    Icons.phone_android,
                    IncomeType.upi,
                    selectedType,
                    (t) => setModalState(() => selectedType = t),
                  ),
                ],
              ),
              const Gap(16),

              // Note
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  hintText: 'Add note (optional)',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const Gap(20),

              // Save Button
              FilledButton(
                onPressed: () async {
                  final amountText = amountController.text.trim();
                  if (amountText.isEmpty) return;

                  final amount = double.tryParse(amountText);
                  if (amount == null || amount <= 0) return;

                  final updatedIncome = income.copyWith(
                    amount: amount,
                    type: selectedType,
                    note: noteController.text.trim().isEmpty
                        ? null
                        : noteController.text.trim(),
                    incomeDate: selectedDate,
                  );

                  final repository = ref.read(taskRepositoryProvider);
                  await repository.updateIncome(updatedIncome);

                  // Invalidate stats to refresh balance
                  ref.invalidate(monthlyStatsProvider);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Income updated!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    StateSetter setModalState,
    String label,
    IconData icon,
    IncomeType type,
    IncomeType selectedType,
    Function(IncomeType) onSelect,
  ) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withAlpha(30)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.green
                    : Theme.of(context).colorScheme.outline,
              ),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tab bar delegate for pinned header
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

// Category list for each tab
class _CategoryList extends ConsumerWidget {
  final ExpenseType type;
  final List<ExpenseCategory> categories;
  final Color color;
  final String description;

  const _CategoryList({
    required this.type,
    required this.categories,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsAsync = ref.watch(monthlyStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          // Description
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Gap(16),
          // Categories grid
          if (categories.isEmpty)
            _EmptyState(type: type, color: color)
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: categories.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == categories.length) {
                    return _AddCategoryButton(type: type, color: color);
                  }
                  final category = categories[index];
                  final categoryTotal = statsAsync.whenOrNull(
                    data: (stats) => stats.categoryTotals[category.id] ?? 0.0,
                  );
                  return _CategoryCard(
                    category: category,
                    total: categoryTotal ?? 0,
                    color: color,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  final ExpenseType type;
  final Color color;

  const _EmptyState({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == ExpenseType.needs
                    ? Icons.eco_outlined
                    : type == ExpenseType.wants
                    ? Icons.shopping_bag_outlined
                    : Icons.savings_outlined,
                size: 48,
                color: color.withAlpha(150),
              ),
            ),
            const Gap(16),
            Text(
              'No categories yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Create your first ${type.name} category',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const Gap(24),
            _AddCategoryButton(type: type, color: color),
          ],
        ),
      ),
    );
  }
}

// Add category button
class _AddCategoryButton extends ConsumerWidget {
  final ExpenseType type;
  final Color color;

  const _AddCategoryButton({required this.type, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddCategoryDialog(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(40),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: color, size: 22),
            const Gap(10),
            Text(
              'Add ${type.name} category',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    // Default color based on type
    final int defaultColor = type == ExpenseType.needs
        ? 0xFF3B82F6 // Blue
        : type == ExpenseType.wants
        ? 0xFFF59E0B // Orange
        : 0xFF10B981; // Green

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    type == ExpenseType.needs
                        ? Icons.eco
                        : type == ExpenseType.wants
                        ? Icons.shopping_bag
                        : Icons.savings,
                    color: color,
                    size: 20,
                  ),
                ),
                const Gap(12),
                Text(
                  'New ${type.name} Category',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Gap(24),
            // Name input
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: type == ExpenseType.needs
                    ? 'e.g., Groceries, Rent'
                    : type == ExpenseType.wants
                    ? 'e.g., Dining Out, Movies'
                    : 'e.g., Emergency Fund, SIP',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label_outline),
              ),
            ),
            const Gap(28),
            // Create button
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final category = ExpenseCategory()
                  ..name = name
                  ..type = type
                  ..colorValue = defaultColor;

                final repository = ref.read(taskRepositoryProvider);
                await repository.addExpenseCategory(category);

                if (context.mounted) Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create Category',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Category card
class _CategoryCard extends ConsumerWidget {
  final ExpenseCategory category;
  final double total;
  final Color color;

  const _CategoryCard({
    required this.category,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = Color(category.colorValue);

    return GestureDetector(
      onTap: () => _showCategoryExpenses(context, ref),
      onLongPress: () => _showCategoryOptions(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: categoryColor.withAlpha(40)),
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForCategory(category.name),
                color: categoryColor,
                size: 22,
              ),
            ),
            const Gap(14),
            // Category name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'This month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
                const Gap(2),
                Icon(Icons.chevron_right, size: 18, color: colorScheme.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('food') || lowerName.contains('grocer')) {
      return Icons.restaurant;
    } else if (lowerName.contains('rent') || lowerName.contains('home')) {
      return Icons.home;
    } else if (lowerName.contains('transport') || lowerName.contains('fuel')) {
      return Icons.directions_car;
    } else if (lowerName.contains('shop') || lowerName.contains('cloth')) {
      return Icons.shopping_bag;
    } else if (lowerName.contains('movie') || lowerName.contains('entertain')) {
      return Icons.movie;
    } else if (lowerName.contains('din') || lowerName.contains('eat')) {
      return Icons.restaurant_menu;
    } else if (lowerName.contains('invest') || lowerName.contains('sip')) {
      return Icons.trending_up;
    } else if (lowerName.contains('save') || lowerName.contains('fund')) {
      return Icons.savings;
    } else if (lowerName.contains('health') || lowerName.contains('medical')) {
      return Icons.medical_services;
    } else if (lowerName.contains('util') || lowerName.contains('bill')) {
      return Icons.receipt_long;
    }
    return Icons.category;
  }

  void _showCategoryExpenses(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to category detail with expenses list
  }

  void _showCategoryOptions(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Gap(20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.red),
              ),
              title: const Text('Delete Category'),
              subtitle: const Text('This will not delete expenses'),
              onTap: () async {
                Navigator.pop(context);
                final repository = ref.read(taskRepositoryProvider);
                await repository.deleteExpenseCategory(category.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
