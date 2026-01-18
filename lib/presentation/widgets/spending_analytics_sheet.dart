import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:remindlyf/data/models/expense.dart';
import 'package:remindlyf/data/models/expense_category.dart';
import 'package:remindlyf/domain/providers/money_provider.dart';

enum ChartPeriod { daily, weekly, monthly }

enum PaymentFilter { all, cash, upi }

class SpendingAnalyticsSheet extends ConsumerStatefulWidget {
  const SpendingAnalyticsSheet({super.key});

  @override
  ConsumerState<SpendingAnalyticsSheet> createState() =>
      _SpendingAnalyticsSheetState();
}

class _SpendingAnalyticsSheetState
    extends ConsumerState<SpendingAnalyticsSheet> {
  ChartPeriod _selectedPeriod = ChartPeriod.daily;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsAsync = ref.watch(monthlyStatsProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return Container(
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
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
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
                        'Spending Analytics',
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
          ),

          // Content
          Expanded(
            child: expensesAsync.when(
              data: (expenses) => statsAsync.when(
                data: (stats) => _buildContent(context, expenses, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Expense> allExpenses,
    MonthlyStats stats,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    // Get chart data based on selected period
    final chartData = _getChartData(allExpenses, now);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Period Selector
        _buildPeriodSelector(colorScheme),
        const Gap(20),

        // Spending Chart - Scrollable and Tappable
        _buildSpendingChart(context, chartData, allExpenses),
        const Gap(24),

        // Top 5 Categories Pie Chart
        _buildTopCategoriesPieChart(context, allExpenses, stats),
        const Gap(24),

        // Category Progress Bars
        Text(
          'Category Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const Gap(12),
        _buildCategoryProgress(
          context,
          'Needs',
          stats.needsTotal,
          stats.totalSpent,
          const Color(0xFF3B82F6),
          Icons.eco_rounded,
        ),
        const Gap(10),
        _buildCategoryProgress(
          context,
          'Wants',
          stats.wantsTotal,
          stats.totalSpent,
          const Color(0xFFF59E0B),
          Icons.shopping_bag_rounded,
        ),
        const Gap(10),
        _buildCategoryProgress(
          context,
          'Savings',
          stats.savingsTotal,
          stats.totalSpent,
          const Color(0xFF10B981),
          Icons.savings_rounded,
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
      ],
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ChartPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          final label = period == ChartPeriod.daily
              ? 'Daily'
              : period == ChartPeriod.weekly
              ? 'Weekly'
              : 'Monthly';
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedPeriod = period;
                _touchedIndex = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpendingChart(
    BuildContext context,
    List<ChartDataPoint> data,
    List<Expense> allExpenses,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxY = _getMaxY(data);

    if (data.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: colorScheme.outline,
              ),
              const Gap(8),
              Text(
                'No spending data',
                style: TextStyle(color: colorScheme.outline),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate chart dimensions
    final barWidth = 42.0;
    final barSpacing = 14.0;
    final chartContentWidth = data.length * (barWidth + barSpacing);
    final screenWidth =
        MediaQuery.of(context).size.width - 40 - 60; // minus padding and y-axis
    final needsScroll = chartContentWidth > screenWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scroll hint
        if (needsScroll)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const Gap(4),
                      Text(
                        'Swipe chart to see more • Tap bar for details',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Chart container with fixed Y-axis
        Container(
          height: 260,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Fixed Y-Axis
              Container(
                width: 55,
                padding: const EdgeInsets.only(top: 16, bottom: 50, left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildYAxisLabel(_formatAmount(maxY * 1.2), colorScheme),
                    _buildYAxisLabel(_formatAmount(maxY * 0.9), colorScheme),
                    _buildYAxisLabel(_formatAmount(maxY * 0.6), colorScheme),
                    _buildYAxisLabel(_formatAmount(maxY * 0.3), colorScheme),
                    _buildYAxisLabel('₹0', colorScheme),
                  ],
                ),
              ),

              // Scrollable Chart Area
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: needsScroll ? chartContentWidth : screenWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceEvenly,
                            maxY: maxY * 1.2,
                            barTouchData: BarTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchCallback: (event, response) {
                                // Handle tap event
                                if (event is FlTapUpEvent &&
                                    response?.spot != null) {
                                  final index =
                                      response!.spot!.touchedBarGroupIndex;
                                  if (index >= 0 && index < data.length) {
                                    _showPeriodExpenses(
                                      context,
                                      data[index],
                                      allExpenses,
                                    );
                                  }
                                }

                                // Handle highlighting
                                setState(() {
                                  if (response?.spot != null &&
                                      event is! FlTapUpEvent &&
                                      event is! FlLongPressEnd) {
                                    _touchedIndex =
                                        response!.spot!.touchedBarGroupIndex;
                                  } else {
                                    _touchedIndex = null;
                                  }
                                });
                              },
                              touchTooltipData: BarTouchTooltipData(
                                tooltipMargin: 12,
                                fitInsideVertically: true,
                                fitInsideHorizontally: true,
                                direction: TooltipDirection.top,
                                getTooltipColor: (group) =>
                                    const Color(0xFF1E293B),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final point = data[groupIndex];
                                  return BarTooltipItem(
                                    '',
                                    const TextStyle(),
                                    children: [
                                      // Date
                                      TextSpan(
                                        text: point.dayLabel,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const TextSpan(text: '\n'),
                                      // Total Amount - Hero
                                      TextSpan(
                                        text:
                                            '₹${point.total.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          height: 1.4,
                                        ),
                                      ),
                                      const TextSpan(text: '\n'),
                                      // Divider line
                                      TextSpan(
                                        text: '─────────────\n',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(30),
                                          fontSize: 8,
                                          height: 2,
                                        ),
                                      ),
                                      // Cash row
                                      const TextSpan(
                                        text: 'Cash    ',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '₹${point.cash.toStringAsFixed(0)}\n',
                                        style: const TextStyle(
                                          color: Color(0xFF34D399),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          height: 1.6,
                                        ),
                                      ),
                                      // UPI row
                                      const TextSpan(
                                        text: 'UPI      ',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '₹${point.upi.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Color(0xFF818CF8),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      // Tap hint
                                      const TextSpan(text: '\n'),
                                      const TextSpan(
                                        text: '👆 Tap for details',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          height: 2,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 42,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= data.length) {
                                      return const SizedBox();
                                    }
                                    final point = data[index];
                                    final isToday = point.isToday;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isToday
                                              ? colorScheme.primary
                                              : colorScheme
                                                    .surfaceContainerHighest
                                                    .withAlpha(80),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          point.label,
                                          style: TextStyle(
                                            color: isToday
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxY / 4,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: colorScheme.outline.withAlpha(20),
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: data.asMap().entries.map((entry) {
                              final index = entry.key;
                              final point = entry.value;
                              final isTouched = _touchedIndex == index;

                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: point.total == 0 ? 0.01 : point.total,
                                    width: barWidth,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: isTouched
                                          ? [
                                              colorScheme.primary,
                                              colorScheme.primary.withAlpha(
                                                220,
                                              ),
                                            ]
                                          : point.isToday
                                          ? [
                                              colorScheme.primary.withAlpha(
                                                200,
                                              ),
                                              colorScheme.primary.withAlpha(
                                                160,
                                              ),
                                            ]
                                          : [
                                              colorScheme.primary.withAlpha(
                                                140,
                                              ),
                                              colorScheme.primary.withAlpha(80),
                                            ],
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: maxY * 1.2,
                                      color: colorScheme.outline.withAlpha(10),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYAxisLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        color: colorScheme.outline,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  List<ChartDataPoint> _getChartData(List<Expense> expenses, DateTime now) {
    switch (_selectedPeriod) {
      case ChartPeriod.daily:
        // Show last 30 days
        return List.generate(30, (index) {
          final date = now.subtract(Duration(days: 29 - index));
          final dayExpenses = expenses.where(
            (e) =>
                e.expenseDate.year == date.year &&
                e.expenseDate.month == date.month &&
                e.expenseDate.day == date.day,
          );

          double total = 0, cash = 0, upi = 0;
          for (final exp in dayExpenses) {
            total += exp.amount;
            if (exp.paymentMethod == PaymentMethod.cash) {
              cash += exp.amount;
            } else {
              upi += exp.amount;
            }
          }

          final isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return ChartDataPoint(
            label: date.day.toString(),
            dayLabel: DateFormat('EEE, MMM d').format(date),
            total: total,
            cash: cash,
            upi: upi,
            isToday: isToday,
            date: date,
          );
        });

      case ChartPeriod.weekly:
        // Show last 8 weeks
        return List.generate(8, (weekIndex) {
          final weekEnd = now.subtract(Duration(days: (7 - weekIndex) * 7));
          final weekStart = weekEnd.subtract(const Duration(days: 6));

          final weekExpenses = expenses.where(
            (e) =>
                e.expenseDate.isAfter(
                  weekStart.subtract(const Duration(days: 1)),
                ) &&
                e.expenseDate.isBefore(weekEnd.add(const Duration(days: 1))),
          );

          double total = 0, cash = 0, upi = 0;
          for (final exp in weekExpenses) {
            total += exp.amount;
            if (exp.paymentMethod == PaymentMethod.cash) {
              cash += exp.amount;
            } else {
              upi += exp.amount;
            }
          }

          return ChartDataPoint(
            label: 'W${weekIndex + 1}',
            dayLabel:
                '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d').format(weekEnd)}',
            total: total,
            cash: cash,
            upi: upi,
            isToday: weekIndex == 7,
            date: weekStart,
            endDate: weekEnd,
          );
        });

      case ChartPeriod.monthly:
        // Show last 6 months
        return List.generate(6, (monthIndex) {
          final month = DateTime(now.year, now.month - 5 + monthIndex, 1);
          final monthEnd = DateTime(month.year, month.month + 1, 0);

          final monthExpenses = expenses.where(
            (e) =>
                e.expenseDate.isAfter(
                  month.subtract(const Duration(days: 1)),
                ) &&
                e.expenseDate.isBefore(monthEnd.add(const Duration(days: 1))),
          );

          double total = 0, cash = 0, upi = 0;
          for (final exp in monthExpenses) {
            total += exp.amount;
            if (exp.paymentMethod == PaymentMethod.cash) {
              cash += exp.amount;
            } else {
              upi += exp.amount;
            }
          }

          return ChartDataPoint(
            label: DateFormat.MMM().format(month),
            dayLabel: DateFormat('MMMM yyyy').format(month),
            total: total,
            cash: cash,
            upi: upi,
            isToday: month.month == now.month && month.year == now.year,
            date: month,
            endDate: monthEnd,
          );
        });
    }
  }

  double _getMaxY(List<ChartDataPoint> data) {
    double max = 0;
    for (final point in data) {
      if (point.total > max) max = point.total;
    }
    return max == 0 ? 1000 : max;
  }

  String _formatAmount(double value) {
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}k';
    }
    return '₹${value.toStringAsFixed(0)}';
  }

  /// Show expense details for a selected bar/period
  void _showPeriodExpenses(
    BuildContext context,
    ChartDataPoint point,
    List<Expense> allExpenses,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter expenses for this period
    final List<Expense> periodExpenses;
    if (point.endDate != null) {
      // Weekly or monthly period
      periodExpenses = allExpenses.where((e) {
        return e.expenseDate.isAfter(
              point.date.subtract(const Duration(days: 1)),
            ) &&
            e.expenseDate.isBefore(point.endDate!.add(const Duration(days: 1)));
      }).toList();
    } else {
      // Daily period
      periodExpenses = allExpenses.where((e) {
        return e.expenseDate.year == point.date.year &&
            e.expenseDate.month == point.date.month &&
            e.expenseDate.day == point.date.day;
      }).toList();
    }

    // Sort by date (newest first)
    periodExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                            Colors.purple.shade400,
                            Colors.purple.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
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
                            point.dayLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.withAlpha(30),
                                      Colors.purple.withAlpha(15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '₹${point.total.toStringAsFixed(0)} • ${periodExpenses.length} items',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
              ),
              // Payment summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.money_rounded,
                              size: 18,
                              color: Colors.green.shade600,
                            ),
                            const Gap(6),
                            Text(
                              '₹${point.cash.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_android_rounded,
                              size: 18,
                              color: Colors.purple.shade600,
                            ),
                            const Gap(6),
                            Text(
                              '₹${point.upi.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.purple.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              const Divider(height: 1),
              // Expense list
              Expanded(
                child: periodExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Colors.purple.withAlpha(150),
                              ),
                            ),
                            const Gap(16),
                            Text(
                              'No expenses',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'No spending recorded for this period',
                              style: TextStyle(color: colorScheme.outline),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: periodExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = periodExpenses[index];
                          final isUpi =
                              expense.paymentMethod == PaymentMethod.upi;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest
                                  .withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Amount
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.withAlpha(30),
                                        Colors.orange.withAlpha(15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '₹${expense.amount.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                        ),
                                  ),
                                ),
                                const Gap(12),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (expense.note != null &&
                                          expense.note!.isNotEmpty)
                                        Text(
                                          expense.note!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Row(
                                        children: [
                                          Icon(
                                            isUpi
                                                ? Icons.phone_android_rounded
                                                : Icons.money_rounded,
                                            size: 14,
                                            color: isUpi
                                                ? Colors.purple
                                                : Colors.green,
                                          ),
                                          const Gap(4),
                                          Text(
                                            isUpi ? 'UPI' : 'Cash',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isUpi
                                                  ? Colors.purple
                                                  : Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Gap(8),
                                          Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: colorScheme.outline,
                                          ),
                                          const Gap(4),
                                          Text(
                                            DateFormat.jm().format(
                                              expense.expenseDate,
                                            ),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  /// Build pie chart showing top 5 spending categories
  Widget _buildTopCategoriesPieChart(
    BuildContext context,
    List<Expense> allExpenses,
    MonthlyStats stats,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        // Get current month expenses
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final monthExpenses = allExpenses.where((e) {
          return e.expenseDate.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          );
        }).toList();

        // Calculate totals by category
        final Map<int, double> categoryTotals = {};
        for (final expense in monthExpenses) {
          if (expense.categoryId != null) {
            categoryTotals[expense.categoryId!] =
                (categoryTotals[expense.categoryId!] ?? 0) + expense.amount;
          }
        }

        if (categoryTotals.isEmpty) {
          return const SizedBox.shrink();
        }

        // Sort and get top 5
        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top5 = sortedCategories.take(5).toList();

        // Colors for pie chart
        final pieColors = [
          const Color(0xFFFF6B6B), // Red
          const Color(0xFF4ECDC4), // Teal
          const Color(0xFFFFE66D), // Yellow
          const Color(0xFF95E1D3), // Mint
          const Color(0xFFA78BFA), // Purple
        ];

        final totalTop5 = top5.fold<double>(0, (sum, e) => sum + e.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Top Spending Categories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat.MMMM().format(now),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Pie Chart
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 28,
                        sections: top5.asMap().entries.map((entry) {
                          final index = entry.key;
                          final amount = entry.value.value;
                          final percentage = totalTop5 > 0
                              ? (amount / totalTop5) * 100
                              : 0;

                          return PieChartSectionData(
                            color: pieColors[index % pieColors.length],
                            value: amount,
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 35,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Gap(20),
                  // Legend
                  Expanded(
                    child: Column(
                      children: top5.asMap().entries.map((entry) {
                        final index = entry.key;
                        final categoryId = entry.value.key;
                        final amount = entry.value.value;
                        final category = categories.firstWhere(
                          (c) => c.id == categoryId,
                          orElse: () => ExpenseCategory()..name = 'Other',
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: pieColors[index % pieColors.length],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '₹${amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: pieColors[index % pieColors.length],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryProgress(
    BuildContext context,
    String label,
    double amount,
    double total,
    Color color,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = total > 0 ? (amount / total) : 0.0;

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label: ₹${amount.toStringAsFixed(0)}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(40),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const Gap(8),
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: colorScheme.outline, fontSize: 12),
                ),
              ],
            ),
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: color.withAlpha(30),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartDataPoint {
  final String label;
  final String dayLabel;
  final double total;
  final double cash;
  final double upi;
  final bool isToday;
  final DateTime
  date; // The specific date (for daily) or start date (for weekly/monthly)
  final DateTime? endDate; // End date for weekly/monthly periods

  ChartDataPoint({
    required this.label,
    required this.dayLabel,
    required this.total,
    required this.cash,
    required this.upi,
    required this.isToday,
    required this.date,
    this.endDate,
  });
}
