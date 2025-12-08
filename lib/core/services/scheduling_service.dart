import 'package:remindlyf/data/models/task.dart';

/// Represents a free time slot in the day
class FreeGap {
  final DateTime start;
  final DateTime end;

  FreeGap({required this.start, required this.end});

  int get durationMinutes => end.difference(start).inMinutes;

  bool canFit(int minutes) => durationMinutes >= minutes;

  @override
  String toString() =>
      'FreeGap(${start.hour}:${start.minute} - ${end.hour}:${end.minute}, ${durationMinutes}m)';
}

/// Result of a scheduling operation
class ScheduleResult {
  final bool success;
  final String message;
  final List<Task> updatedTasks;
  final int? maxPossibleIncrease;
  final int? totalFreeMinutes;
  final FreeGap? suggestedSlot;

  ScheduleResult({
    required this.success,
    required this.message,
    this.updatedTasks = const [],
    this.maxPossibleIncrease,
    this.totalFreeMinutes,
    this.suggestedSlot,
  });

  factory ScheduleResult.success(String message, List<Task> tasks) {
    return ScheduleResult(success: true, message: message, updatedTasks: tasks);
  }

  factory ScheduleResult.failure(
    String message, {
    int? maxIncrease,
    int? freeMinutes,
    FreeGap? slot,
  }) {
    return ScheduleResult(
      success: false,
      message: message,
      maxPossibleIncrease: maxIncrease,
      totalFreeMinutes: freeMinutes,
      suggestedSlot: slot,
    );
  }
}

/// Smart Scheduling Service
/// Handles auto-assignment, duration changes, and cascade shifting
class SchedulingService {
  // Default day boundaries (can be overridden)
  static int dayStartHour = 7;
  static int dayStartMinute = 0;
  static int dayEndHour = 23;
  static int dayEndMinute = 0;

  /// Set custom wake/sleep hours
  static void setDayBoundaries({
    required int wakeHour,
    required int wakeMinute,
    required int sleepHour,
    required int sleepMinute,
  }) {
    dayStartHour = wakeHour;
    dayStartMinute = wakeMinute;
    dayEndHour = sleepHour;
    dayEndMinute = sleepMinute;
  }

  /// Get the start of the scheduling day
  /// If the date is today, returns the current time (rounded up to next 5 min)
  static DateTime getDayStart(DateTime date) {
    final now = DateTime.now();
    final dayStart = DateTime(
      date.year,
      date.month,
      date.day,
      dayStartHour,
      dayStartMinute,
    );

    // If this is today and we're past the day start, use current time
    if (_isSameDay(date, now) && now.isAfter(dayStart)) {
      // Round up to next minute
      return DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    }

    return dayStart;
  }

  /// Get the end of the scheduling day
  static DateTime getDayEnd(DateTime date) {
    return DateTime(date.year, date.month, date.day, dayEndHour, dayEndMinute);
  }

  /// Get sorted tasks for a specific day (only scheduled tasks)
  static List<Task> getTasksForDay(List<Task> allTasks, DateTime date) {
    return allTasks
        .where((t) => t.dueDate != null && _isSameDay(t.dueDate!, date))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  /// Find all free gaps in a day (only future gaps for today)
  static List<FreeGap> findFreeGaps(List<Task> dayTasks, DateTime date) {
    final gaps = <FreeGap>[];
    final dayStart = getDayStart(date); // This now respects current time
    final dayEnd = getDayEnd(date);

    // If day start is past day end, no available time
    if (dayStart.isAfter(dayEnd) || dayStart.isAtSameMomentAs(dayEnd)) {
      return gaps;
    }

    if (dayTasks.isEmpty) {
      gaps.add(FreeGap(start: dayStart, end: dayEnd));
      return gaps;
    }

    // Sort tasks by start time
    final sortedTasks = List<Task>.from(dayTasks)
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // Filter out tasks that have already ended (for today)
    final now = DateTime.now();
    final futureTasks = _isSameDay(date, now)
        ? sortedTasks.where((t) => t.endTime!.isAfter(now)).toList()
        : sortedTasks;

    DateTime currentTime = dayStart;

    for (final task in futureTasks) {
      // Skip tasks that started in the past but haven't ended
      final effectiveTaskStart = task.dueDate!.isBefore(currentTime)
          ? currentTime
          : task.dueDate!;

      if (effectiveTaskStart.isAfter(currentTime)) {
        final gapMinutes = effectiveTaskStart.difference(currentTime).inMinutes;
        if (gapMinutes >= 5) {
          // Minimum gap of 5 minutes
          gaps.add(FreeGap(start: currentTime, end: effectiveTaskStart));
        }
      }

      // Move current time to after this task ends
      if (task.endTime!.isAfter(currentTime)) {
        currentTime = task.endTime!;
      }
    }

    // Gap at the end of day
    if (currentTime.isBefore(dayEnd)) {
      final gapMinutes = dayEnd.difference(currentTime).inMinutes;
      if (gapMinutes >= 5) {
        gaps.add(FreeGap(start: currentTime, end: dayEnd));
      }
    }

    return gaps;
  }

  /// Calculate total free minutes in a day (from now onwards for today)
  static int getTotalFreeMinutes(List<Task> dayTasks, DateTime date) {
    final gaps = findFreeGaps(dayTasks, date);
    return gaps.fold(0, (sum, gap) => sum + gap.durationMinutes);
  }

  /// Calculate the maximum possible increase for a specific task
  static int getMaxPossibleIncrease(
    Task task,
    List<Task> dayTasks,
    DateTime date,
  ) {
    if (task.dueDate == null) return 0;

    final sortedTasks = List<Task>.from(dayTasks)
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final taskIndex = sortedTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) return 0;

    final dayEnd = getDayEnd(date);

    // Calculate available space by considering cascade push
    int availableMinutes = 0;
    DateTime currentEnd = task.endTime!;

    for (int i = taskIndex + 1; i < sortedTasks.length; i++) {
      final nextTask = sortedTasks[i];

      // Gap before next task
      final gap = nextTask.dueDate!.difference(currentEnd).inMinutes;
      availableMinutes += gap > 0 ? gap : 0;

      // If next task is fixed, we can't push past it
      if (nextTask.isFixed) {
        break;
      }

      currentEnd = nextTask.endTime!;
    }

    // Add remaining time to day end
    final remainingToDayEnd = dayEnd.difference(currentEnd).inMinutes;
    if (remainingToDayEnd > 0) {
      availableMinutes += remainingToDayEnd;
    }

    return availableMinutes > 0 ? availableMinutes : 0;
  }

  /// Increase task duration with cascade push
  static ScheduleResult increaseDuration(
    Task task,
    int additionalMinutes,
    List<Task> dayTasks,
    DateTime date,
  ) {
    if (task.dueDate == null) {
      return ScheduleResult.failure('Task has no scheduled time');
    }

    final maxIncrease = getMaxPossibleIncrease(task, dayTasks, date);

    if (additionalMinutes > maxIncrease) {
      return ScheduleResult.failure(
        'Not enough space. Maximum increase possible: ${_formatMinutes(maxIncrease)}',
        maxIncrease: maxIncrease,
        freeMinutes: getTotalFreeMinutes(dayTasks, date),
      );
    }

    // Clone tasks for modification
    final updatedTasks = dayTasks.map((t) => t.copyWith()).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final taskIndex = updatedTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) {
      return ScheduleResult.failure('Task not found');
    }

    // Increase the target task duration
    updatedTasks[taskIndex].durationMinutes += additionalMinutes;
    final newEndTime = updatedTasks[taskIndex].endTime!;

    // Cascade push subsequent movable tasks
    DateTime lastEnd = newEndTime;
    for (int i = taskIndex + 1; i < updatedTasks.length; i++) {
      final nextTask = updatedTasks[i];

      if (nextTask.isFixed) {
        // Cannot move fixed task - check for overlap
        if (lastEnd.isAfter(nextTask.dueDate!)) {
          // Revert and fail
          return ScheduleResult.failure(
            'Cannot overlap with fixed task "${nextTask.title}"',
            maxIncrease: maxIncrease,
          );
        }
        lastEnd = nextTask.endTime!;
        continue;
      }

      // Push task forward if needed
      if (lastEnd.isAfter(nextTask.dueDate!)) {
        nextTask.dueDate = lastEnd;
      }
      lastEnd = nextTask.endTime!;
    }

    return ScheduleResult.success(
      'Duration increased by ${_formatMinutes(additionalMinutes)}',
      updatedTasks,
    );
  }

  /// Decrease task duration (optionally cascade pull)
  static ScheduleResult decreaseDuration(
    Task task,
    int reduceMinutes,
    List<Task> dayTasks,
    DateTime date, {
    bool cascadePull = false,
  }) {
    if (task.dueDate == null) {
      return ScheduleResult.failure('Task has no scheduled time');
    }

    if (reduceMinutes >= task.durationMinutes) {
      return ScheduleResult.failure('Cannot reduce below minimum duration');
    }

    // Clone tasks for modification
    final updatedTasks = dayTasks.map((t) => t.copyWith()).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    final taskIndex = updatedTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) {
      return ScheduleResult.failure('Task not found');
    }

    // Decrease the target task duration
    updatedTasks[taskIndex].durationMinutes -= reduceMinutes;

    if (cascadePull) {
      // Pull subsequent movable tasks earlier
      DateTime lastEnd = updatedTasks[taskIndex].endTime!;

      for (int i = taskIndex + 1; i < updatedTasks.length; i++) {
        final nextTask = updatedTasks[i];

        if (nextTask.isFixed) {
          lastEnd = nextTask.endTime!;
          continue;
        }

        // Pull task to immediately after the previous one
        if (nextTask.dueDate!.isAfter(lastEnd)) {
          nextTask.dueDate = lastEnd;
        }
        lastEnd = nextTask.endTime!;
      }
    }

    return ScheduleResult.success(
      'Duration decreased by ${_formatMinutes(reduceMinutes)}',
      updatedTasks,
    );
  }

  /// Auto-assign time for a new task
  static ScheduleResult autoAssignTime(
    Task newTask,
    List<Task> dayTasks,
    DateTime date,
  ) {
    final gaps = findFreeGaps(dayTasks, date);
    final requiredMinutes = newTask.durationMinutes;

    // Try to find a gap that fits exactly
    for (final gap in gaps) {
      if (gap.canFit(requiredMinutes)) {
        newTask.dueDate = gap.start;
        final updatedTasks = [...dayTasks, newTask];
        return ScheduleResult.success(
          'Task scheduled at ${_formatTime(gap.start)}',
          updatedTasks,
        );
      }
    }

    // No exact gap - try cascade push
    final sortedTasks = List<Task>.from(dayTasks)
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // Find the best position to insert and push
    for (int i = 0; i <= sortedTasks.length; i++) {
      DateTime insertTime;

      if (i == 0) {
        insertTime = getDayStart(date);
      } else {
        insertTime = sortedTasks[i - 1].endTime!;
      }

      // Check if we can fit here with cascade push
      final testTask = newTask.copyWith()..dueDate = insertTime;
      final testTasks = [...sortedTasks];
      testTasks.insert(i, testTask);

      if (_canFitWithCascade(testTasks, date)) {
        // Apply cascade push
        final updatedTasks = _applyCascadePush(testTasks, date);
        return ScheduleResult.success(
          'Task scheduled at ${_formatTime(insertTime)} (tasks adjusted)',
          updatedTasks,
        );
      }
    }

    // Cannot fit today
    final totalFree = getTotalFreeMinutes(dayTasks, date);
    final largestGap = gaps.isNotEmpty
        ? gaps.reduce((a, b) => a.durationMinutes > b.durationMinutes ? a : b)
        : null;

    return ScheduleResult.failure(
      'Cannot fit ${_formatMinutes(requiredMinutes)} task today. '
      'Available: ${_formatMinutes(totalFree)}',
      freeMinutes: totalFree,
      slot: largestGap,
    );
  }

  /// Add a fixed task and reorganize around it
  static ScheduleResult addFixedTask(
    Task fixedTask,
    List<Task> dayTasks,
    DateTime date,
  ) {
    if (fixedTask.dueDate == null) {
      return ScheduleResult.failure('Fixed task must have a start time');
    }

    fixedTask.isFixed = true;

    // Check for overlap with other fixed tasks
    for (final task in dayTasks) {
      if (task.isFixed && _tasksOverlap(fixedTask, task)) {
        return ScheduleResult.failure(
          'Overlaps with fixed task "${task.title}"',
        );
      }
    }

    // Clone tasks
    final updatedTasks = dayTasks.map((t) => t.copyWith()).toList();
    updatedTasks.add(fixedTask);
    updatedTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    // Reorganize movable tasks around fixed ones
    final result = _reorganizeAroundFixed(updatedTasks, date);
    if (result != null) {
      return ScheduleResult.success(
        'Fixed task added. ${result.movedCount} tasks adjusted.',
        result.tasks,
      );
    }

    return ScheduleResult.failure(
      'Cannot fit all tasks around this fixed time',
    );
  }

  /// Reorganize all movable tasks around fixed tasks
  static _ReorganizeResult? _reorganizeAroundFixed(
    List<Task> tasks,
    DateTime date,
  ) {
    final dayStart = getDayStart(date);
    final dayEnd = getDayEnd(date);

    // Separate fixed and movable tasks
    final fixedTasks = tasks.where((t) => t.isFixed).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final movableTasks = tasks.where((t) => !t.isFixed).toList();

    if (movableTasks.isEmpty) {
      return _ReorganizeResult(tasks, 0);
    }

    // Sort movable by original time
    movableTasks.sort((a, b) {
      return (a.dueDate ?? DateTime(2099)).compareTo(
        b.dueDate ?? DateTime(2099),
      );
    });

    // Find all available slots
    final slots = <FreeGap>[];
    DateTime current = dayStart;

    for (final fixed in fixedTasks) {
      if (fixed.dueDate!.isAfter(current)) {
        slots.add(FreeGap(start: current, end: fixed.dueDate!));
      }
      current = fixed.endTime!;
    }

    if (current.isBefore(dayEnd)) {
      slots.add(FreeGap(start: current, end: dayEnd));
    }

    // Try to fit movable tasks in slots
    int movedCount = 0;
    final placedTasks = <Task>[];

    for (final task in movableTasks) {
      bool placed = false;

      for (int i = 0; i < slots.length; i++) {
        if (slots[i].canFit(task.durationMinutes)) {
          final oldTime = task.dueDate;
          task.dueDate = slots[i].start;

          // Update slot
          slots[i] = FreeGap(start: task.endTime!, end: slots[i].end);

          if (slots[i].durationMinutes < 5) {
            slots.removeAt(i);
          }

          if (oldTime != task.dueDate) movedCount++;
          placed = true;
          placedTasks.add(task);
          break;
        }
      }

      if (!placed) {
        return null; // Cannot fit all tasks
      }
    }

    // Combine fixed and placed tasks
    final allTasks = [...fixedTasks, ...placedTasks];
    allTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

    return _ReorganizeResult(allTasks, movedCount);
  }

  static bool _canFitWithCascade(List<Task> tasks, DateTime date) {
    final dayEnd = getDayEnd(date);
    DateTime lastEnd = getDayStart(date);

    for (final task in tasks) {
      if (task.isFixed) {
        if (lastEnd.isAfter(task.dueDate!)) {
          return false; // Would overlap with fixed task
        }
        lastEnd = task.endTime!;
      } else {
        final start = lastEnd.isAfter(task.dueDate!) ? lastEnd : task.dueDate!;
        final end = start.add(Duration(minutes: task.durationMinutes));
        if (end.isAfter(dayEnd)) {
          return false; // Exceeds day boundary
        }
        lastEnd = end;
      }
    }

    return true;
  }

  static List<Task> _applyCascadePush(List<Task> tasks, DateTime date) {
    DateTime lastEnd = getDayStart(date);

    for (final task in tasks) {
      if (task.isFixed) {
        lastEnd = task.endTime!;
      } else {
        if (lastEnd.isAfter(task.dueDate!)) {
          task.dueDate = lastEnd;
        }
        lastEnd = task.endTime!;
      }
    }

    return tasks;
  }

  static bool _tasksOverlap(Task a, Task b) {
    if (a.dueDate == null || b.dueDate == null) return false;
    return !(a.endTime!.isBefore(b.dueDate!) ||
            b.endTime!.isBefore(a.dueDate!)) &&
        a.id != b.id;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _ReorganizeResult {
  final List<Task> tasks;
  final int movedCount;

  _ReorganizeResult(this.tasks, this.movedCount);
}
