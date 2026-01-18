import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:remindlyf/presentation/widgets/add_task_sheet.dart';
import 'package:remindlyf/presentation/widgets/timeline_view.dart';
import 'package:remindlyf/presentation/widgets/drafts_sheet.dart';
import 'package:remindlyf/presentation/screens/reminder_tab.dart';
import 'package:remindlyf/presentation/screens/money_manager_screen.dart';
import 'package:remindlyf/presentation/screens/backup_screen.dart';

// Provider for current bottom nav index
final bottomNavIndexProvider = StateProvider<int>(
  (ref) => 0,
); // Start with Vault tab (Documents & Reminders)

// Provider for navbar visibility (controlled by scroll)
final navbarVisibleProvider = StateProvider<bool>((ref) => true);

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: const [ReminderTab(), TodayTab(), MoneyManagerScreen()],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(80, 0, 80, 12 + bottomPadding),
        height: 52,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(240),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withAlpha(20),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavIcon(
                context,
                index: 0,
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield_rounded,
                color: Colors.orange,
                isSelected: currentIndex == 0,
              ),
              _buildNavIcon(
                context,
                index: 1,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                color: colorScheme.primary,
                isSelected: currentIndex == 1,
              ),
              _buildNavIcon(
                context,
                index: 2,
                icon: Icons.wallet_outlined,
                activeIcon: Icons.wallet_rounded,
                color: const Color(0xFF8B5CF6),
                isSelected: currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withAlpha(180),
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ==================== TODAY TAB ====================

class TodayTab extends ConsumerStatefulWidget {
  const TodayTab({super.key});

  @override
  ConsumerState<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends ConsumerState<TodayTab> {
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          DraftsSheet(selectedDate: selectedDate),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.tips_and_updates_rounded,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BackupScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.cloud_sync,
                      size: 20,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          'Donify',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddTaskSheet(initialDate: selectedDate),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date row with calendar toggle
          _DateRowWithCalendar(
            selectedDate: selectedDate,
            showCalendar: _showCalendar,
            onToggleCalendar: () =>
                setState(() => _showCalendar = !_showCalendar),
          ),

          // Calendar (expandable)
          if (_showCalendar)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: TableCalendar<Task>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.week,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: 42,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selected, focused) {
                    ref.read(selectedDateProvider.notifier).state = selected;
                    _focusedDay = focused;
                  },
                  eventLoader: (day) {
                    return tasksAsync.whenOrNull(
                          data: (tasks) => tasks.where((task) {
                            if (task.dueDate == null) return false;
                            return isSameDay(task.dueDate!, day);
                          }).toList(),
                        ) ??
                        [];
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: colorScheme.secondary.withAlpha(60),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                    markersMaxCount: 3,
                    cellMargin: const EdgeInsets.all(3),
                    weekendTextStyle: TextStyle(color: colorScheme.error),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    headerPadding: const EdgeInsets.symmetric(vertical: 6),
                    titleTextStyle: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    weekendStyle: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),

          // Stats bar (tasks done + total time)
          _StatsBar(tasksAsync: tasksAsync, selectedDate: selectedDate),

          // Timeline
          Expanded(
            child: tasksAsync.when(
              data: (allTasks) {
                final dayTasks = allTasks.where((task) {
                  if (task.dueDate == null) return false;
                  return isSameDay(task.dueDate!, selectedDate);
                }).toList();

                return TimelineView(
                  tasks: dayTasks,
                  selectedDate: selectedDate,
                  allDayTasks: dayTasks,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// Date row with calendar toggle
class _DateRowWithCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final bool showCalendar;
  final VoidCallback onToggleCalendar;

  const _DateRowWithCalendar({
    required this.selectedDate,
    required this.showCalendar,
    required this.onToggleCalendar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = _isToday(selectedDate);
    final isPast = _isPastDay(selectedDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withAlpha(80),
            colorScheme.secondaryContainer.withAlpha(60),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withAlpha(30)),
      ),
      child: Row(
        children: [
          // Date icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPast ? Icons.history : (isToday ? Icons.today : Icons.event),
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const Gap(12),
          // Date text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? 'Today'
                      : (isPast
                            ? 'Past'
                            : DateFormat('EEEE').format(selectedDate)),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(selectedDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Calendar toggle button
          GestureDetector(
            onTap: onToggleCalendar,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: showCalendar
                    ? colorScheme.primary.withAlpha(40)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: showCalendar
                    ? Border.all(color: colorScheme.primary.withAlpha(80))
                    : null,
              ),
              child: Icon(
                showCalendar ? Icons.keyboard_arrow_up : Icons.calendar_month,
                size: 20,
                color: showCalendar
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isPastDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }
}

// Stats bar showing tasks done and total time
class _StatsBar extends StatelessWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final DateTime selectedDate;

  const _StatsBar({required this.tasksAsync, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return tasksAsync.when(
      data: (allTasks) {
        final dayTasks = allTasks.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.year == selectedDate.year &&
              task.dueDate!.month == selectedDate.month &&
              task.dueDate!.day == selectedDate.day;
        }).toList();

        final completedCount = dayTasks.where((t) => t.isCompleted).length;
        final totalCount = dayTasks.length;
        final totalMinutes = dayTasks.fold<int>(
          0,
          (sum, t) => sum + t.durationMinutes,
        );

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Tasks done
              _StatChip(
                icon: Icons.check_circle_outline,
                label: 'Done',
                value: '$completedCount/$totalCount',
                color: Colors.green,
              ),
              const Gap(16),
              Container(
                height: 24,
                width: 1,
                color: colorScheme.outlineVariant.withAlpha(50),
              ),
              const Gap(16),
              // Total time
              _StatChip(
                icon: Icons.schedule,
                label: 'Total',
                value: _formatMinutes(totalMinutes),
                color: colorScheme.primary,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ==================== DATE HEADER ====================

class _DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final AsyncValue<List<Task>> tasksAsync;

  const _DateHeader({required this.selectedDate, required this.tasksAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPast = _isPastDay(selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPast
                      ? Icons.history
                      : (_isToday(selectedDate)
                            ? Icons.today
                            : Icons.calendar_today),
                  size: 14,
                  color: colorScheme.onPrimary,
                ),
                const Gap(6),
                Text(
                  _getFullDateLabel(selectedDate),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          tasksAsync.whenOrNull(
                data: (tasks) {
                  final dayTasks = tasks
                      .where(
                        (t) =>
                            t.dueDate != null &&
                            isSameDay(t.dueDate!, selectedDate),
                      )
                      .toList();
                  final completed = dayTasks.where((t) => t.isCompleted).length;
                  final total = dayTasks.length;

                  if (total == 0) {
                    return _Badge(
                      icon: Icons.wb_sunny,
                      text: 'Free Day',
                      color: Colors.green,
                    );
                  }

                  final totalTaskMinutes = dayTasks.fold<int>(
                    0,
                    (sum, t) => sum + t.durationMinutes,
                  );

                  if (isPast) {
                    final rate = (completed / total * 100).round();
                    return Row(
                      children: [
                        _Badge(
                          icon: rate == 100 ? Icons.star : Icons.pie_chart,
                          text: '$rate%',
                          color: rate == 100 ? Colors.amber : Colors.purple,
                        ),
                        const Gap(6),
                        _Badge(
                          icon: Icons.access_time_filled,
                          text: _formatMinutes(totalTaskMinutes),
                          color: Colors.blue,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      _Badge(
                        icon: completed == total
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        text: '$completed/$total',
                        color: completed == total
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                      const Gap(6),
                      _Badge(
                        icon: Icons.access_time_filled,
                        text: _formatMinutes(totalTaskMinutes),
                        color: Colors.blue,
                      ),
                    ],
                  );
                },
              ) ??
              const SizedBox(),
        ],
      ),
    );
  }

  bool _isPastDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getFullDateLabel(DateTime date) {
    final now = DateTime.now();
    final dayName = DateFormat.EEEE().format(date);
    final dateStr = DateFormat.MMMd().format(date);

    if (isSameDay(date, now)) {
      return 'Today, $dateStr';
    }
    if (isSameDay(date, now.add(const Duration(days: 1)))) {
      return 'Tomorrow, $dateStr';
    }
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday, $dateStr';
    }
    return '$dayName, $dateStr';
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Badge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const Gap(4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
