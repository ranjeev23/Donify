import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/core/services/scheduling_service.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const AddTaskSheet({super.key, this.initialDate});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _autoSchedule = true;
  double _duration = 30;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
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
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
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

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_task,
                        color: colorScheme.onPrimary,
                        size: 22,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      'New Task',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // Task title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'What needs to be done?',
                    hintText: 'Enter task title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(
                      50,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ).animate().fadeIn(delay: 50.ms),
                const Gap(20),

                // Schedule toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(80),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _autoSchedule = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _autoSchedule
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: _autoSchedule
                                      ? Colors.white
                                      : colorScheme.outline,
                                ),
                                const Gap(6),
                                Text(
                                  'Auto',
                                  style: TextStyle(
                                    color: _autoSchedule
                                        ? Colors.white
                                        : colorScheme.outline,
                                    fontWeight: _autoSchedule
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _autoSchedule = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_autoSchedule
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_calendar,
                                  size: 16,
                                  color: !_autoSchedule
                                      ? Colors.white
                                      : colorScheme.outline,
                                ),
                                const Gap(6),
                                Text(
                                  'Manual',
                                  style: TextStyle(
                                    color: !_autoSchedule
                                        ? Colors.white
                                        : colorScheme.outline,
                                    fontWeight: !_autoSchedule
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const Gap(20),

                // Date selector
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const Gap(12),
                        Text(
                          _selectedDate == null
                              ? 'Select Date'
                              : DateFormat.MMMEd().format(_selectedDate!),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const Gap(20),

                if (_autoSchedule) ...[
                  // Duration slider for auto mode
                  Text(
                    'Duration',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatDuration(_duration.round()),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Gap(16),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: colorScheme.primary,
                            inactiveTrackColor:
                                colorScheme.surfaceContainerHighest,
                            thumbColor: colorScheme.primary,
                            overlayColor: colorScheme.primary.withAlpha(30),
                            trackHeight: 6,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                          ),
                          child: Slider(
                            value: _duration,
                            min: 5,
                            max: 180,
                            divisions: 35,
                            onChanged: (value) {
                              setState(
                                () => _duration = (value / 5).round() * 5.0,
                              );
                            },
                          ),
                        ),
                        const Gap(8),
                        // Quick options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [15, 30, 60, 90].map((mins) {
                            final isSelected = _duration.round() == mins;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _duration = mins.toDouble()),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _formatDuration(mins),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ] else ...[
                  // Manual time selection
                  Row(
                    children: [
                      Expanded(
                        child: _TimeSelector(
                          label: 'Start',
                          time: _startTime,
                          color: Colors.green,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _startTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = time;
                                if (_endTime == null) {
                                  final endMinutes =
                                      time.hour * 60 + time.minute + 30;
                                  _endTime = TimeOfDay(
                                    hour: (endMinutes ~/ 60) % 24,
                                    minute: endMinutes % 60,
                                  );
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: _TimeSelector(
                          label: 'End',
                          time: _endTime,
                          color: Colors.red,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _endTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() => _endTime = time);
                            }
                          },
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  // Show availability info when start time is selected
                  if (_startTime != null) ...[
                    const Gap(12),
                    FutureBuilder(
                      future: _getAvailabilityInfo(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final info = snapshot.data!;
                        final hasSpace = info.maxMinutes > 0;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: hasSpace
                                ? Colors.blue.withAlpha(15)
                                : Colors.red.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasSpace
                                  ? Colors.blue.withAlpha(50)
                                  : Colors.red.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    hasSpace
                                        ? Icons.info_outline
                                        : Icons.warning_amber,
                                    size: 16,
                                    color: hasSpace ? Colors.blue : Colors.red,
                                  ),
                                  const Gap(8),
                                  Text(
                                    hasSpace
                                        ? 'Max duration: ${_formatDuration(info.maxMinutes)}'
                                        : 'No space available',
                                    style: TextStyle(
                                      color: hasSpace
                                          ? Colors.blue
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              if (info.reason.isNotEmpty) ...[
                                const Gap(4),
                                Text(
                                  info.reason,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ],
                              if (!hasSpace) ...[
                                const Gap(8),
                                Text(
                                  'Delete or shorten existing tasks to make room',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.red.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  if (_startTime != null && _endTime != null) ...[
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const Gap(8),
                          Text(
                            'Duration: ${_formatDuration(_calculateDuration())}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const Gap(24),

                // Add button
                FilledButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 250.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
                const Gap(8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateDuration() {
    if (_startTime == null || _endTime == null) return 0;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    return endMinutes - startMinutes;
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  void _addTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Please select a date');
      return;
    }

    final repository = ref.read(taskRepositoryProvider);

    if (_autoSchedule) {
      // Auto-schedule mode
      final allTasks = await repository.getAllTasks();
      final dayTasks = allTasks
          .where(
            (t) =>
                t.dueDate != null &&
                t.dueDate!.year == _selectedDate!.year &&
                t.dueDate!.month == _selectedDate!.month &&
                t.dueDate!.day == _selectedDate!.day,
          )
          .toList();

      // Get user preferences and set day boundaries
      final prefs = await repository.getPreferences();
      SchedulingService.setDayBoundaries(
        wakeHour: prefs.wakeUpHour,
        wakeMinute: prefs.wakeUpMinute,
        sleepHour: prefs.sleepHour,
        sleepMinute: prefs.sleepMinute,
      );

      // Create a temporary task for scheduling
      final newTask = Task()
        ..title = _titleController.text.trim()
        ..durationMinutes = _duration.round()
        ..isFixed = false;

      final result = SchedulingService.autoAssignTime(
        newTask,
        dayTasks,
        _selectedDate!,
      );

      if (!result.success) {
        _showError(result.message);
        return;
      }

      // The task now has the assigned time from scheduling service
      await repository.addTask(newTask);
      if (mounted) Navigator.pop(context);
    } else {
      // Manual mode
      if (_startTime == null || _endTime == null) {
        _showError('Please select start and end times');
        return;
      }

      final duration = _calculateDuration();
      if (duration <= 0) {
        _showError('End time must be after start time');
        return;
      }

      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      // Check for conflicts
      final allTasks = await repository.getAllTasks();
      final dayTasks = allTasks
          .where(
            (t) =>
                t.dueDate != null &&
                t.dueDate!.year == _selectedDate!.year &&
                t.dueDate!.month == _selectedDate!.month &&
                t.dueDate!.day == _selectedDate!.day,
          )
          .toList();

      // Get user preferences for wake/sleep times
      final prefs = await repository.getPreferences();
      final wakeUpTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        prefs.wakeUpHour,
        prefs.wakeUpMinute,
      );
      final sleepTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        prefs.sleepHour,
        prefs.sleepMinute,
      );
      final newEnd = startDateTime.add(Duration(minutes: duration));

      // Check if task is within wake/sleep boundaries
      if (startDateTime.isBefore(wakeUpTime)) {
        _showError(
          'Task cannot start before wake up time (${TimeOfDay(hour: prefs.wakeUpHour, minute: prefs.wakeUpMinute).format(context)})',
        );
        return;
      }
      if (newEnd.isAfter(sleepTime)) {
        _showError(
          'Task cannot end after sleep time (${TimeOfDay(hour: prefs.sleepHour, minute: prefs.sleepMinute).format(context)})',
        );
        return;
      }

      // Create the fixed task
      final fixedTask = Task()
        ..title = _titleController.text.trim()
        ..dueDate = startDateTime
        ..durationMinutes = duration
        ..isFixed = true;

      // Use smart scheduling to insert and reschedule conflicting tasks
      final result = SchedulingService.insertFixedTaskWithReschedule(
        fixedTask: fixedTask,
        dayTasks: dayTasks,
        date: _selectedDate!,
      );

      if (!result.success) {
        _showError(result.message);
        return;
      }

      // Apply the changes - update all tasks
      for (final task in result.updatedTasks) {
        if (task.id == 0) {
          // New task
          await repository.addTask(task);
        } else {
          await repository.updateTask(task);
        }
      }

      if (mounted) Navigator.pop(context);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 40),
        title: const Text('Cannot Add Task'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<({int maxMinutes, String reason})> _getAvailabilityInfo() async {
    if (_startTime == null || _selectedDate == null) {
      return (maxMinutes: 0, reason: 'Select start time');
    }

    final repository = ref.read(taskRepositoryProvider);

    // Load user preferences and set day boundaries
    final prefs = await repository.getPreferences();
    SchedulingService.setDayBoundaries(
      wakeHour: prefs.wakeUpHour,
      wakeMinute: prefs.wakeUpMinute,
      sleepHour: prefs.sleepHour,
      sleepMinute: prefs.sleepMinute,
    );

    final allTasks = await repository.getAllTasks();

    final dayTasks = allTasks
        .where(
          (t) =>
              t.dueDate != null &&
              t.dueDate!.year == _selectedDate!.year &&
              t.dueDate!.month == _selectedDate!.month &&
              t.dueDate!.day == _selectedDate!.day,
        )
        .toList();

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final result = SchedulingService.getMaxFixedTaskDuration(
      startTime: startDateTime,
      dayTasks: dayTasks,
      date: _selectedDate!,
    );

    return (maxMinutes: result.maxMinutes, reason: result.reason);
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final Color color;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: time != null
              ? color.withAlpha(20)
              : colorScheme.surfaceContainerHighest.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: time != null
                ? color.withAlpha(80)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  label == 'Start' ? Icons.play_arrow : Icons.stop,
                  size: 16,
                  color: time != null ? color : colorScheme.outline,
                ),
                const Gap(6),
                Text(
                  label,
                  style: TextStyle(
                    color: time != null ? color : colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              time?.format(context) ?? '--:--',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: time != null ? color : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
