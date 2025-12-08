import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: tasksAsync.when(
        data: (tasks) => _buildStats(context, tasks),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStats(BuildContext context, List<Task> allTasks) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();

    // Calculate stats
    final completedTasks = allTasks.where((t) => t.isCompleted).toList();
    final totalTasks = allTasks.length;
    final completionRate = totalTasks > 0
        ? (completedTasks.length / totalTasks * 100).round()
        : 0;

    // Time stats
    final totalMinutesCompleted = completedTasks.fold<int>(
      0,
      (sum, t) => sum + t.durationMinutes,
    );
    final totalHours = totalMinutesCompleted ~/ 60;
    final totalMinutes = totalMinutesCompleted % 60;

    // Weekly stats
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekTasks = allTasks
        .where(
          (t) =>
              t.dueDate != null &&
              t.dueDate!.isAfter(weekStart) &&
              t.dueDate!.isBefore(now.add(const Duration(days: 1))),
        )
        .toList();
    final weekCompleted = weekTasks.where((t) => t.isCompleted).length;

    // Daily average
    final daysWithTasks = allTasks
        .where((t) => t.dueDate != null)
        .map((t) => DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day))
        .toSet()
        .length;
    final dailyAverage = daysWithTasks > 0
        ? (completedTasks.length / daysWithTasks).toStringAsFixed(1)
        : '0';

    // Tasks with photos
    final tasksWithPhotos = completedTasks
        .where((t) => t.completionPhotoPath != null)
        .length;

    // Streak calculation (consecutive days with completed tasks)
    int currentStreak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    while (true) {
      final dayCompleted = completedTasks.any(
        (t) =>
            t.completedAt != null &&
            t.completedAt!.year == checkDate.year &&
            t.completedAt!.month == checkDate.month &&
            t.completedAt!.day == checkDate.day,
      );
      if (dayCompleted) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero stat
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const Gap(8),
                    Text(
                      '$currentStreak',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Day Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const Gap(4),
                Text(
                  currentStreak > 0
                      ? 'Keep it up! 🔥'
                      : 'Start your streak today!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const Gap(20),

          // Main stats grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  value: '${completedTasks.length}',
                  label: 'Completed',
                  color: Colors.green,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
              ),
              const Gap(12),
              Expanded(
                child: _StatCard(
                  icon: Icons.pie_chart,
                  value: '$completionRate%',
                  label: 'Success Rate',
                  color: Colors.blue,
                ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer,
                  value: totalHours > 0
                      ? '${totalHours}h ${totalMinutes}m'
                      : '${totalMinutes}m',
                  label: 'Time Invested',
                  color: Colors.purple,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
              ),
              const Gap(12),
              Expanded(
                child: _StatCard(
                  icon: Icons.camera_alt,
                  value: '$tasksWithPhotos',
                  label: 'Memories',
                  color: Colors.orange,
                ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1),
              ),
            ],
          ),
          const Gap(24),

          // Weekly progress
          Text(
            'This Week',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tasks Completed', style: theme.textTheme.bodyMedium),
                    Text(
                      '$weekCompleted / ${weekTasks.length}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: weekTasks.isNotEmpty
                        ? weekCompleted / weekTasks.length
                        : 0,
                    minHeight: 10,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final day = weekStart.add(Duration(days: index));
                    final dayTasks = weekTasks
                        .where(
                          (t) =>
                              t.dueDate != null &&
                              t.dueDate!.year == day.year &&
                              t.dueDate!.month == day.month &&
                              t.dueDate!.day == day.day,
                        )
                        .toList();
                    final dayCompleted = dayTasks
                        .where((t) => t.isCompleted)
                        .length;
                    final dayTotal = dayTasks.length;
                    final isToday =
                        day.year == now.year &&
                        day.month == now.month &&
                        day.day == now.day;

                    return Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: dayTotal > 0
                                ? (dayCompleted == dayTotal
                                      ? Colors.green
                                      : colorScheme.primary.withAlpha(100))
                                : colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: dayTotal > 0 && dayCompleted == dayTotal
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Text(
                                    dayTotal > 0 ? '$dayCompleted' : '-',
                                    style: TextStyle(
                                      color: dayTotal > 0
                                          ? Colors.white
                                          : colorScheme.outline,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                          ),
                        ),
                        const Gap(4),
                        Text(
                          DateFormat.E().format(day).substring(0, 1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isToday
                                ? colorScheme.primary
                                : colorScheme.outline,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms),
          const Gap(24),

          // Daily average & insights
          Text(
            'Insights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          _InsightTile(
            icon: Icons.trending_up,
            title: 'Daily Average',
            value: '$dailyAverage tasks/day',
            color: Colors.teal,
          ).animate().fadeIn(delay: 350.ms),
          const Gap(10),
          _InsightTile(
            icon: Icons.schedule,
            title: 'Most Productive',
            value: _getMostProductiveTime(completedTasks),
            color: Colors.indigo,
          ).animate().fadeIn(delay: 400.ms),
          const Gap(10),
          _InsightTile(
            icon: Icons.emoji_events,
            title: 'Total Tasks',
            value: '$totalTasks scheduled all time',
            color: Colors.amber,
          ).animate().fadeIn(delay: 450.ms),
          const Gap(32),

          // Motivation quote
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withAlpha(30),
                  Colors.blue.withAlpha(20),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.withAlpha(50)),
            ),
            child: Column(
              children: [
                const Icon(Icons.format_quote, color: Colors.purple, size: 32),
                const Gap(8),
                Text(
                  _getMotivationalQuote(currentStreak, completionRate),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  String _getMostProductiveTime(List<Task> completedTasks) {
    if (completedTasks.isEmpty) return 'Complete tasks to see!';

    final hourCounts = <int, int>{};
    for (final task in completedTasks) {
      if (task.dueDate != null) {
        final hour = task.dueDate!.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    if (hourCounts.isEmpty) return 'Complete tasks to see!';

    final mostProductiveHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    if (mostProductiveHour < 12) {
      return 'Morning (${mostProductiveHour}:00)';
    } else if (mostProductiveHour < 17) {
      return 'Afternoon (${mostProductiveHour}:00)';
    } else {
      return 'Evening (${mostProductiveHour}:00)';
    }
  }

  String _getMotivationalQuote(int streak, int completionRate) {
    if (streak >= 7) {
      return "You're on fire! A whole week of consistency. Champions are made of habits like yours! 🏆";
    } else if (streak >= 3) {
      return "Three days strong! You're building momentum. Keep pushing forward! 💪";
    } else if (completionRate >= 80) {
      return "Outstanding performance! You're crushing it with $completionRate% success rate! 🌟";
    } else if (completionRate >= 50) {
      return "You're halfway there! Every completed task is a step towards your goals. 🎯";
    } else {
      return "Every journey starts with a single step. Start fresh today and build your streak! 🚀";
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const Gap(8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InsightTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
