import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/presentation/widgets/task_detail_sheet.dart';
import 'package:remindlyf/presentation/widgets/task_completion_dialog.dart';
import 'package:remindlyf/presentation/widgets/day_recap_view.dart';
import 'package:remindlyf/presentation/widgets/immediate_task_sheet.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';

class TimelineView extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final DateTime selectedDate;
  final List<Task> allDayTasks;

  const TimelineView({
    super.key,
    required this.tasks,
    required this.selectedDate,
    required this.allDayTasks,
  });

  @override
  ConsumerState<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends ConsumerState<TimelineView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isReorderMode = false;

  // Wake/Sleep times from preferences
  int _wakeUpHour = 7;
  int _wakeUpMinute = 0;
  int _sleepHour = 23;
  int _sleepMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadPreferences() async {
    final repository = ref.read(taskRepositoryProvider);
    final prefs = await repository.getPreferences();
    if (mounted) {
      setState(() {
        _wakeUpHour = prefs.wakeUpHour;
        _wakeUpMinute = prefs.wakeUpMinute;
        _sleepHour = prefs.sleepHour;
        _sleepMinute = prefs.sleepMinute;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _scrollToCurrentTime() {
    if (!_isSameDay(widget.selectedDate, DateTime.now())) return;

    final now = DateTime.now();
    final scheduledTasks = widget.tasks.where((t) => t.dueDate != null).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    if (scheduledTasks.isEmpty) return;

    int targetIndex = 0;
    for (int i = 0; i < scheduledTasks.length; i++) {
      if (scheduledTasks[i].endTime!.isAfter(now)) {
        targetIndex = i;
        break;
      }
      targetIndex = i;
    }

    final scrollOffset = (targetIndex * 80.0) - 50;

    if (scrollOffset > 0 && _scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            scrollOffset.clamp(0, _scrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPastDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Past day - show recap
    if (_isPastDay(widget.selectedDate)) {
      return DayRecapView(date: widget.selectedDate, tasks: widget.tasks);
    }

    // Exclude drafts from timeline - only show real scheduled tasks
    final scheduledTasks =
        widget.tasks.where((t) => t.dueDate != null && !t.isDraft).toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final isToday = _isSameDay(widget.selectedDate, DateTime.now());
    final now = DateTime.now();

    // Find current task or free time
    Task? currentTask;
    FreeTimeInfo? currentFreeTime;

    if (isToday) {
      // Check if there's a current task
      for (final task in scheduledTasks) {
        if (task.dueDate!.isBefore(now) &&
            (task.endTime?.isAfter(now) ?? false) &&
            !task.isCompleted) {
          currentTask = task;
          break;
        }
      }

      // If no current task, calculate free time
      if (currentTask == null) {
        currentFreeTime = _getCurrentFreeTime(scheduledTasks, now);
      }
    }

    // Get future NON-FIXED tasks for reordering (fixed tasks can never be reordered)
    // Also exclude the currently executing task - it should not be reorderable
    final reorderableTasks = scheduledTasks
        .where(
          (t) =>
              !t.isCompleted &&
              !t.isFixed &&
              // Exclude currently executing task (started but not ended)
              !(t.dueDate!.isBefore(now) &&
                  (t.endTime?.isAfter(now) ?? false)) &&
              // Only include future tasks (not yet started)
              t.dueDate!.isAfter(now),
        )
        .toList();

    // Check if we have any schedulable tasks (at least one non-completed task for today)
    final hasReorderableTasks = scheduledTasks.any(
      (t) => !t.isCompleted && !t.isFixed,
    );

    return Column(
      children: [
        // Always show current activity banner
        if (isToday)
          currentTask != null
              ? _CurrentTaskBanner(
                  task: currentTask,
                  onDone: () => _completeTask(currentTask!),
                  onUrgent: () => _openImmediateTaskSheet(currentTask),
                )
              : _FreeTimeBanner(
                  freeTime: currentFreeTime,
                  onAddImmediate: () => _openImmediateTaskSheet(null),
                ),

        // Header with reorder option
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                'Timeline',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Current time badge
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        DateFormat.jm().format(now),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasReorderableTasks) ...[
                const Gap(8),
                GestureDetector(
                  onTap: () => setState(() => _isReorderMode = !_isReorderMode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isReorderMode
                          ? Colors.green.withAlpha(30)
                          : colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isReorderMode
                            ? Colors.green.withAlpha(80)
                            : colorScheme.primary.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isReorderMode ? Icons.check : Icons.swap_vert,
                          size: 16,
                          color: _isReorderMode
                              ? Colors.green
                              : colorScheme.primary,
                        ),
                        const Gap(6),
                        Text(
                          _isReorderMode ? 'Done' : 'Reorder',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isReorderMode
                                ? Colors.green
                                : colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Timeline or empty state
        Expanded(
          child: scheduledTasks.isEmpty
              ? _buildEmptyTimeline(context)
              : _isReorderMode
              ? _buildReorderableList(context, reorderableTasks)
              : _buildTimelineList(
                  context,
                  scheduledTasks,
                  isToday,
                  now,
                  currentTask,
                ),
        ),
      ],
    );
  }

  FreeTimeInfo? _getCurrentFreeTime(List<Task> tasks, DateTime now) {
    if (tasks.isEmpty) {
      // Entire day is free
      final dayEnd = DateTime(now.year, now.month, now.day, 23, 0);
      return FreeTimeInfo(start: now, end: dayEnd, nextTask: null);
    }

    // Check if we're before the first task
    if (tasks.first.dueDate!.isAfter(now)) {
      return FreeTimeInfo(
        start: now,
        end: tasks.first.dueDate!,
        nextTask: tasks.first,
      );
    }

    // Find the gap we're currently in
    for (int i = 0; i < tasks.length - 1; i++) {
      final currentEnd = tasks[i].endTime!;
      final nextStart = tasks[i + 1].dueDate!;

      if (now.isAfter(currentEnd) && now.isBefore(nextStart)) {
        return FreeTimeInfo(start: now, end: nextStart, nextTask: tasks[i + 1]);
      }
    }

    // We're after all tasks
    if (tasks.isNotEmpty && now.isAfter(tasks.last.endTime!)) {
      final dayEnd = DateTime(now.year, now.month, now.day, 23, 0);
      return FreeTimeInfo(start: now, end: dayEnd, nextTask: null);
    }

    return null;
  }

  Widget _buildReorderableList(
    BuildContext context,
    List<Task> reorderableTasks,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (reorderableTasks.isEmpty) {
      return Center(
        child: Text(
          'No reorderable tasks',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Instructions banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(50),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.primary.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
              const Gap(10),
              Expanded(
                child: Text(
                  'Drag tasks to reorder. Tasks will be rescheduled starting from now.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reorderableTasks.length,
            onReorder: (oldIndex, newIndex) async {
              if (oldIndex < newIndex) newIndex--;

              final repository = ref.read(taskRepositoryProvider);
              final tasks = List<Task>.from(reorderableTasks);
              final task = tasks.removeAt(oldIndex);
              tasks.insert(newIndex, task);

              // Get all tasks for today to find fixed tasks
              final allTasks = await repository.getAllTasks();
              final now = DateTime.now();
              final selectedDate = widget.selectedDate;

              final wakeUpTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                _wakeUpHour,
                _wakeUpMinute,
              );
              final sleepTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                _sleepHour,
                _sleepMinute,
              );

              // Get all fixed tasks for today (these don't move)
              final fixedTasks =
                  allTasks
                      .where(
                        (t) =>
                            t.dueDate != null &&
                            _isSameDay(t.dueDate!, selectedDate) &&
                            t.isFixed &&
                            !t.isCompleted,
                      )
                      .toList()
                    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

              // Determine start time
              DateTime currentTime;
              final isSelectedToday = _isSameDay(selectedDate, now);

              if (isSelectedToday && now.isAfter(wakeUpTime)) {
                // Find currently executing task (not reorderable, not fixed)
                final reorderableTaskIds = tasks.map((t) => t.id).toSet();
                final fixedTaskIds = fixedTasks.map((t) => t.id).toSet();

                Task? currentTask;
                for (final t in allTasks.where(
                  (t) =>
                      t.dueDate != null &&
                      _isSameDay(t.dueDate!, now) &&
                      !t.isCompleted,
                )) {
                  if (!reorderableTaskIds.contains(t.id) &&
                      !fixedTaskIds.contains(t.id) &&
                      t.dueDate!.isBefore(now) &&
                      t.endTime!.isAfter(now)) {
                    currentTask = t;
                    break;
                  }
                }

                if (currentTask != null) {
                  currentTime = currentTask.endTime!;
                } else {
                  currentTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    now.hour,
                    now.minute + 1,
                  );
                }
              } else {
                currentTime = wakeUpTime;
              }

              // Schedule tasks around fixed tasks
              bool hasError = false;
              String? errorMessage;

              for (final t in tasks) {
                // Skip past any fixed tasks that start before or at current time
                for (final fixed in fixedTasks) {
                  // If there's a fixed task that would conflict with our current slot
                  if (fixed.dueDate!.isBefore(
                        currentTime.add(Duration(minutes: t.durationMinutes)),
                      ) &&
                      fixed.endTime!.isAfter(currentTime)) {
                    // Skip to after this fixed task
                    currentTime = fixed.endTime!;
                  }
                }

                final newEndTime = currentTime.add(
                  Duration(minutes: t.durationMinutes),
                );

                // Check if task overlaps with any fixed task
                bool overlapsFixed = false;
                for (final fixed in fixedTasks) {
                  if (currentTime.isBefore(fixed.endTime!) &&
                      newEndTime.isAfter(fixed.dueDate!)) {
                    // Would overlap with fixed task, skip to after it
                    currentTime = fixed.endTime!;
                    overlapsFixed = true;
                    break;
                  }
                }

                if (overlapsFixed) {
                  // Recalculate with new current time
                  final adjustedEnd = currentTime.add(
                    Duration(minutes: t.durationMinutes),
                  );
                  if (adjustedEnd.isAfter(sleepTime)) {
                    hasError = true;
                    errorMessage =
                        'Task "${t.title}" doesn\'t fit before sleep time';
                    break;
                  }
                  t.dueDate = currentTime;
                  await repository.updateTask(t);
                  currentTime = t.endTime!;
                } else if (newEndTime.isAfter(sleepTime)) {
                  hasError = true;
                  errorMessage =
                      'Task "${t.title}" doesn\'t fit before sleep time';
                  break;
                } else {
                  t.dueDate = currentTime;
                  await repository.updateTask(t);
                  currentTime = t.endTime!;
                }
              }

              if (hasError && errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                  ),
                );
              }

              // Exit reorder mode after reordering
              setState(() => _isReorderMode = false);
            },
            itemBuilder: (context, index) {
              final task = reorderableTasks[index];
              return Container(
                key: ValueKey(task.id),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary.withAlpha(50)),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(10),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.drag_handle, color: colorScheme.primary),
                  title: Text(
                    task.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${DateFormat.jm().format(task.dueDate!)} • ${task.durationMinutes}m',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(
    BuildContext context,
    List<Task> tasks,
    bool isToday,
    DateTime now,
    Task? currentTask,
  ) {
    final theme = Theme.of(context);
    final timelineItems = _buildTimelineItems(
      tasks,
      widget.selectedDate,
      isToday,
      now,
    );

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: timelineItems.length,
      itemBuilder: (context, index) {
        final item = timelineItems[index];

        // Current time marker
        if (item.type == TimelineItemType.currentTime) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NOW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.red.withAlpha(0)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final isCurrentItem =
            isToday &&
            item.type == TimelineItemType.task &&
            item.task?.id == currentTask?.id;

        if (isCurrentItem) {
          return _buildCurrentTaskCard(context, item, now);
        }

        // Handle wake up marker with tap to edit
        if (item.type == TimelineItemType.wakeUp) {
          return _buildEditableMarkerCard(
            context,
            icon: Icons.wb_sunny,
            label: 'Wake Up',
            color: Colors.orange,
            time: item.startTime,
            onTap: () => _editWakeUpTime(item.startTime),
          );
        }

        // Handle sleep marker with tap to edit
        if (item.type == TimelineItemType.sleep) {
          return _buildEditableMarkerCard(
            context,
            icon: Icons.nightlight_round,
            label: 'Sleep',
            color: Colors.indigo,
            time: item.startTime,
            onTap: () => _editSleepTime(item.startTime),
          );
        }

        return _TimelineCard(
          item: item,
          allDayTasks: widget.allDayTasks,
          selectedDate: widget.selectedDate,
          onComplete: item.task != null && !item.task!.isCompleted
              ? () => _completeTask(item.task!)
              : null,
        );
      },
    );
  }

  Widget _buildEditableMarkerCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required DateTime time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(
                    DateFormat.jm().format(time),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.edit, size: 14, color: color.withAlpha(150)),
                    const Gap(4),
                    Text(
                      'Tap to edit',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color.withAlpha(150),
                        fontSize: 10,
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

  Future<void> _editWakeUpTime(DateTime currentTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      helpText: 'Set Wake Up Time',
    );
    if (time != null) {
      final repository = ref.read(taskRepositoryProvider);
      final prefs = await repository.getPreferences();

      final newWakeUp = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        time.hour,
        time.minute,
      );

      // Get tasks for today
      final allTasks = await repository.getAllTasks();
      final dayTasks =
          allTasks
              .where(
                (t) =>
                    t.dueDate != null &&
                    t.dueDate!.year == widget.selectedDate.year &&
                    t.dueDate!.month == widget.selectedDate.month &&
                    t.dueDate!.day == widget.selectedDate.day &&
                    !t.isCompleted,
              )
              .toList()
            ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

      // Push tasks that start before new wake up time
      DateTime nextStartTime = newWakeUp;
      for (final task in dayTasks) {
        if (!task.isFixed && task.dueDate!.isBefore(newWakeUp)) {
          task.dueDate = nextStartTime;
          await repository.updateTask(task);
          nextStartTime = task.endTime!;
        } else if (!task.isFixed && task.dueDate!.isBefore(nextStartTime)) {
          // This task was after wake but now needs to shift due to cascading
          task.dueDate = nextStartTime;
          await repository.updateTask(task);
          nextStartTime = task.endTime!;
        }
      }

      prefs.wakeUpHour = time.hour;
      prefs.wakeUpMinute = time.minute;
      await repository.savePreferences(prefs);
      await _loadPreferences();
    }
  }

  Future<void> _editSleepTime(DateTime currentTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentTime),
      helpText: 'Set Sleep Time',
    );
    if (time != null) {
      final repository = ref.read(taskRepositoryProvider);
      final prefs = await repository.getPreferences();

      final newSleep = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        time.hour,
        time.minute,
      );

      // Get tasks for today
      final allTasks = await repository.getAllTasks();
      final dayTasks =
          allTasks
              .where(
                (t) =>
                    t.dueDate != null &&
                    t.dueDate!.year == widget.selectedDate.year &&
                    t.dueDate!.month == widget.selectedDate.month &&
                    t.dueDate!.day == widget.selectedDate.day &&
                    !t.isCompleted,
              )
              .toList()
            ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

      // Check if any tasks end after new sleep time
      final tasksAfterSleep = dayTasks
          .where((t) => !t.isFixed && t.endTime!.isAfter(newSleep))
          .toList();

      if (tasksAfterSleep.isNotEmpty) {
        // Calculate total duration of tasks that need to fit
        final totalMinutes = tasksAfterSleep.fold<int>(
          0,
          (sum, t) => sum + t.durationMinutes,
        );

        // Check if there's enough time
        final wakeUpTime = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          prefs.wakeUpHour,
          prefs.wakeUpMinute,
        );
        final availableMinutes = newSleep.difference(wakeUpTime).inMinutes;
        final usedMinutes = dayTasks
            .where((t) => t.isFixed || !tasksAfterSleep.contains(t))
            .fold<int>(0, (sum, t) => sum + t.durationMinutes);

        if (totalMinutes > (availableMinutes - usedMinutes)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Not enough time! ${tasksAfterSleep.length} tasks don\'t fit.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        // Re-schedule all non-fixed tasks to fit within boundaries
        final nonFixedTasks = dayTasks.where((t) => !t.isFixed).toList();
        DateTime nextStart = wakeUpTime;

        // Skip past current time if today
        final now = DateTime.now();
        if (_isSameDay(widget.selectedDate, now) && now.isAfter(wakeUpTime)) {
          nextStart = DateTime(
            now.year,
            now.month,
            now.day,
            now.hour,
            now.minute + 1,
          );
        }

        for (final task in nonFixedTasks) {
          if (nextStart
              .add(Duration(minutes: task.durationMinutes))
              .isAfter(newSleep)) {
            // Can't fit this task, skip (will show warning)
            continue;
          }
          task.dueDate = nextStart;
          await repository.updateTask(task);
          nextStart = task.endTime!;
        }
      }

      prefs.sleepHour = time.hour;
      prefs.sleepMinute = time.minute;
      await repository.savePreferences(prefs);
      await _loadPreferences();
    }
  }

  Widget _buildCurrentTaskCard(
    BuildContext context,
    TimelineItem item,
    DateTime now,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final task = item.task!;

    final totalDuration = item.endTime.difference(item.startTime).inMinutes;
    final elapsed = now.difference(item.startTime).inMinutes;
    final progress = (elapsed / totalDuration).clamp(0.0, 1.0);
    final remaining = item.endTime.difference(now);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(
                    DateFormat.jm().format(item.startTime),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  const Gap(4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(80),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: Colors.red.withAlpha(80),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () => _openTaskDetail(task),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withAlpha(20),
                        colorScheme.primaryContainer.withAlpha(30),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${remaining.inMinutes}m left',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Text(
                        task.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation(Colors.red),
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
    );
  }

  void _openTaskDetail(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        task: task,
        dayTasks: widget.allDayTasks,
        selectedDate: widget.selectedDate,
      ),
    );
  }

  void _openImmediateTaskSheet(Task? currentRunningTask) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImmediateTaskSheet(
        currentRunningTask: currentRunningTask,
        dayTasks: widget.allDayTasks,
        selectedDate: widget.selectedDate,
      ),
    );
  }

  DateTime _roundToNext5Minutes(DateTime time) {
    final minutes = time.minute;
    final roundedMinutes = ((minutes ~/ 5) + 1) * 5;
    if (roundedMinutes >= 60) {
      return DateTime(time.year, time.month, time.day, time.hour + 1, 0);
    }
    return DateTime(time.year, time.month, time.day, time.hour, roundedMinutes);
  }

  void _completeTask(Task task) {
    showDialog(
      context: context,
      builder: (ctx) => TaskCompletionDialog(
        taskTitle: task.title,
        onComplete: (note, photoPath) async {
          final repository = ref.read(taskRepositoryProvider);
          final now = DateTime.now();

          final updatedTask = task.copyWith(
            isCompleted: true,
            completionNote: note,
            completionPhotoPath: photoPath,
            completedAt: now,
          );
          await repository.updateTask(updatedTask);

          await _pullTasksForward(task, now);
        },
      ),
    );
  }

  Future<void> _pullTasksForward(Task completedTask, DateTime now) async {
    final repository = ref.read(taskRepositoryProvider);

    // Fetch fresh tasks from database
    final allTasks = await repository.getAllTasks();
    final dayTasks = allTasks
        .where(
          (t) =>
              t.dueDate != null &&
              t.dueDate!.year == widget.selectedDate.year &&
              t.dueDate!.month == widget.selectedDate.month &&
              t.dueDate!.day == widget.selectedDate.day,
        )
        .toList();

    // Get remaining uncompleted, non-fixed tasks that haven't ended yet
    final remainingTasks =
        dayTasks
            .where(
              (t) =>
                  !t.isCompleted &&
                  t.id != completedTask.id &&
                  !t.isFixed &&
                  t.dueDate != null &&
                  t.endTime!.isAfter(now),
            ) // Check endTime, not dueDate
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    if (remainingTasks.isEmpty) return;

    // Start from the next minute (immediate start)
    DateTime currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );

    // Update each task to start at the new time
    for (final task in remainingTasks) {
      task.dueDate = currentTime;
      await repository.updateTask(task);
      currentTime = task.endTime!;
    }
  }

  Widget _buildEmptyTimeline(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wb_sunny_outlined,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const Gap(12),
          Text(
            'No tasks scheduled',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(4),
          Text(
            'Add a task to get started',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  List<TimelineItem> _buildTimelineItems(
    List<Task> tasks,
    DateTime date,
    bool isToday,
    DateTime now,
  ) {
    final List<TimelineItem> items = [];

    // Use wake/sleep times from state (loaded from preferences)
    final wakeUpTime = DateTime(
      date.year,
      date.month,
      date.day,
      _wakeUpHour,
      _wakeUpMinute,
    );
    final sleepTime = DateTime(
      date.year,
      date.month,
      date.day,
      _sleepHour,
      _sleepMinute,
    );

    // Add wake up marker at the start
    items.add(
      TimelineItem(
        type: TimelineItemType.wakeUp,
        startTime: wakeUpTime,
        endTime: wakeUpTime,
        durationMinutes: 0,
      ),
    );

    DateTime currentTime = wakeUpTime;
    bool nowMarkerAdded = false;

    for (final task in tasks) {
      final taskStart = task.dueDate!;
      final taskEnd = task.endTime!;

      // Add current time marker between tasks
      if (isToday &&
          !nowMarkerAdded &&
          taskStart.isAfter(now) &&
          currentTime.isBefore(now)) {
        items.add(
          TimelineItem(
            type: TimelineItemType.currentTime,
            startTime: now,
            endTime: now,
            durationMinutes: 0,
          ),
        );
        nowMarkerAdded = true;
      }

      if (taskStart.isAfter(currentTime)) {
        final freeMinutes = taskStart.difference(currentTime).inMinutes;
        if (freeMinutes >= 10) {
          items.add(
            TimelineItem(
              type: TimelineItemType.freeTime,
              startTime: currentTime,
              endTime: taskStart,
              durationMinutes: freeMinutes,
            ),
          );
        }
      }

      items.add(
        TimelineItem(
          type: TimelineItemType.task,
          task: task,
          startTime: taskStart,
          endTime: taskEnd,
          durationMinutes: task.durationMinutes,
        ),
      );

      currentTime = taskEnd;
    }

    if (isToday && !nowMarkerAdded && now.isAfter(currentTime)) {
      items.add(
        TimelineItem(
          type: TimelineItemType.currentTime,
          startTime: now,
          endTime: now,
          durationMinutes: 0,
        ),
      );
    }

    // Add free time until sleep if any
    if (currentTime.isBefore(sleepTime)) {
      final freeMinutes = sleepTime.difference(currentTime).inMinutes;
      if (freeMinutes >= 10) {
        items.add(
          TimelineItem(
            type: TimelineItemType.freeTime,
            startTime: currentTime,
            endTime: sleepTime,
            durationMinutes: freeMinutes,
          ),
        );
      }
    }

    // Add sleep marker at the end
    items.add(
      TimelineItem(
        type: TimelineItemType.sleep,
        startTime: sleepTime,
        endTime: sleepTime,
        durationMinutes: 0,
      ),
    );

    return items;
  }
}

class _CurrentTaskBanner extends StatelessWidget {
  final Task task;
  final VoidCallback onDone;
  final VoidCallback onUrgent;

  const _CurrentTaskBanner({
    required this.task,
    required this.onDone,
    required this.onUrgent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final remaining = task.endTime!.difference(now);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (task.isFixed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FIXED',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  '${remaining.inMinutes}m remaining',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Urgent button
          IconButton(
            onPressed: onUrgent,
            icon: const Icon(Icons.flash_on, color: Colors.amber, size: 22),
            tooltip: 'Add Urgent Task',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(30),
              padding: const EdgeInsets.all(8),
            ),
          ),
          // Done button - only for non-fixed tasks
          if (!task.isFixed) ...[
            const Gap(6),
            FilledButton(
              onPressed: onDone,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ],
      ),
    );
  }
}

class _FreeTimeBanner extends StatelessWidget {
  final FreeTimeInfo? freeTime;
  final VoidCallback? onAddImmediate;

  const _FreeTimeBanner({this.freeTime, this.onAddImmediate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (freeTime == null) return const SizedBox.shrink();

    final remaining = freeTime!.end.difference(DateTime.now());
    final hasNextTask = freeTime!.nextTask != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.coffee, color: Colors.white, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Time',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  hasNextTask
                      ? 'Next: ${freeTime!.nextTask!.title} in ${remaining.inMinutes}m'
                      : '${_formatDuration(remaining.inMinutes)} until end of day',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Add Task Now button
          FilledButton.icon(
            onPressed: onAddImmediate,
            icon: const Icon(Icons.flash_on, size: 16),
            label: const Text('Add Task'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}

class FreeTimeInfo {
  final DateTime start;
  final DateTime end;
  final Task? nextTask;

  FreeTimeInfo({required this.start, required this.end, this.nextTask});
}

enum TimelineItemType { wakeUp, task, freeTime, currentTime, sleep }

class TimelineItem {
  final TimelineItemType type;
  final Task? task;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;

  TimelineItem({
    required this.type,
    this.task,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
  });
}

class _TimelineCard extends StatelessWidget {
  final TimelineItem item;
  final List<Task> allDayTasks;
  final DateTime selectedDate;
  final VoidCallback? onComplete;

  const _TimelineCard({
    required this.item,
    required this.allDayTasks,
    required this.selectedDate,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final isPast = item.endTime.isBefore(now);

    // Handle wake up marker
    if (item.type == TimelineItemType.wakeUp) {
      return _buildMarkerCard(
        context,
        icon: Icons.wb_sunny,
        label: 'Wake Up',
        color: Colors.orange,
        time: item.startTime,
      );
    }

    // Handle sleep marker
    if (item.type == TimelineItemType.sleep) {
      return _buildMarkerCard(
        context,
        icon: Icons.nightlight_round,
        label: 'Sleep',
        color: Colors.indigo,
        time: item.startTime,
      );
    }

    final isTask = item.type == TimelineItemType.task;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  DateFormat.jm().format(item.startTime),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isPast
                        ? colorScheme.outline.withAlpha(100)
                        : (isTask ? colorScheme.primary : colorScheme.outline),
                    fontWeight: isTask ? FontWeight.bold : FontWeight.normal,
                    fontSize: 9,
                  ),
                ),
                const Gap(4),
                Container(
                  width: isTask ? 8 : 6,
                  height: isTask ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPast
                        ? (item.task?.isCompleted ?? false
                              ? Colors.green
                              : colorScheme.outline.withAlpha(50))
                        : (isTask
                              ? colorScheme.primary
                              : colorScheme.outlineVariant),
                  ),
                  child: item.task?.isCompleted ?? false
                      ? const Icon(Icons.check, size: 5, color: Colors.white)
                      : null,
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: colorScheme.outlineVariant.withAlpha(
                      isPast ? 40 : 80,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: isTask
                  ? _buildTaskCard(context, item.task!, isPast)
                  : _buildFreeTimeCard(context, isPast),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required DateTime time,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  DateFormat.jm().format(time),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
                const Gap(4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const Gap(8),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTaskCard(BuildContext context, Task task, bool isPast) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSubscriptionTask = task.isSubscriptionReminder;

    // Subscription reminder tasks get orange styling
    final cardColor = isSubscriptionTask
        ? (isPast ? Colors.orange.withAlpha(15) : Colors.orange.withAlpha(30))
        : (isPast
              ? (task.isCompleted
                    ? Colors.green.withAlpha(10)
                    : colorScheme.surfaceContainerHighest.withAlpha(30))
              : colorScheme.primaryContainer.withAlpha(40));

    final borderColor = isSubscriptionTask
        ? Colors.orange.withAlpha(60)
        : (isPast
              ? (task.isCompleted
                    ? Colors.green.withAlpha(40)
                    : colorScheme.outlineVariant.withAlpha(40))
              : colorScheme.primary.withAlpha(40));

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailSheet(
            task: task,
            dayTasks: allDayTasks,
            selectedDate: selectedDate,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Subscription reminder indicator
            if (isSubscriptionTask)
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  size: 14,
                  color: Colors.deepOrange,
                ),
              ),
            if (task.isCompleted && !isSubscriptionTask)
              Container(
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.green),
              ),
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: isPast
                      ? colorScheme.outline
                      : (isSubscriptionTask
                            ? Colors.deepOrange.shade700
                            : null),
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '${task.durationMinutes}m',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSubscriptionTask ? Colors.orange : colorScheme.outline,
                fontSize: 10,
              ),
            ),
            if (task.isFixed) ...[
              const Gap(4),
              const Icon(Icons.lock, size: 10, color: Colors.orange),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTimeCard(BuildContext context, bool isPast) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey.withAlpha(10) : Colors.green.withAlpha(10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPast
              ? Colors.grey.withAlpha(25)
              : Colors.green.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.coffee,
            size: 12,
            color: isPast ? Colors.grey : Colors.green.shade600,
          ),
          const Gap(6),
          Text(
            'Free',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPast ? Colors.grey : Colors.green.shade700,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          Text(
            _formatDuration(item.durationMinutes),
            style: theme.textTheme.labelSmall?.copyWith(
              color: isPast ? Colors.grey : Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins == 0 ? '${hours}h' : '${hours}h${mins}m';
    }
    return '${minutes}m';
  }
}
