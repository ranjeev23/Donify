import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/presentation/screens/subscriptions_screen.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:remindlyf/presentation/widgets/add_task_sheet.dart';
import 'package:remindlyf/presentation/widgets/timeline_view.dart';
import 'package:remindlyf/presentation/widgets/drafts_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showCalendar = false; // Calendar hidden by default
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
        title: Text(
          'Donify',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active,
              size: 20,
              color: Colors.orange,
            ),
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
        actions: [
          // Drafts button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb, size: 20, color: Colors.amber),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraftsSheet(selectedDate: selectedDate),
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showCalendar
                    ? colorScheme.primary.withAlpha(40)
                    : colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
                border: _showCalendar
                    ? Border.all(color: colorScheme.primary.withAlpha(80))
                    : null,
              ),
              child: Icon(
                _showCalendar ? Icons.calendar_today : Icons.calendar_month,
                size: 20,
                color: _showCalendar ? colorScheme.primary : null,
              ),
            ),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          // Calendar - only show when _showCalendar is true
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
                  calendarFormat: CalendarFormat.week, // Always week format
                  rowHeight: 42,
                  selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    ref.read(selectedDateProvider.notifier).state = selectedDay;
                    setState(() => _focusedDay = focusedDay);
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
                      color: colorScheme.primary.withAlpha(80),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                      ),
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

          // Date header with stats
          _DateHeader(selectedDate: selectedDate, tasksAsync: tasksAsync),

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTaskSheet(initialDate: selectedDate),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

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
          // Full date display
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
          // Stats badge - show task time done
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

                  // Calculate total task time
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
    // Always show full date with day name
    final dayName = DateFormat.EEEE().format(date); // e.g., "Saturday"
    final dateStr = DateFormat.MMMd().format(date); // e.g., "Dec 7"

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
