import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/core/services/scheduling_service.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImmediateTaskSheet extends ConsumerStatefulWidget {
  final Task? currentRunningTask;
  final List<Task> dayTasks;
  final DateTime selectedDate;

  const ImmediateTaskSheet({
    super.key,
    required this.currentRunningTask,
    required this.dayTasks,
    required this.selectedDate,
  });

  @override
  ConsumerState<ImmediateTaskSheet> createState() => _ImmediateTaskSheetState();
}

class _ImmediateTaskSheetState extends ConsumerState<ImmediateTaskSheet> {
  final _titleController = TextEditingController();
  double _duration = 15;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasRunningTask = widget.currentRunningTask != null;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
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
                const Gap(16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.orange.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urgent Task',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Insert a task right now',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
                const Gap(20),

                // Available time info
                Builder(
                  builder: (context) {
                    // Calculate available time
                    final now = DateTime.now();
                    int availableMinutes = 0;

                    // Load day boundaries
                    final dayEnd = DateTime(
                      widget.selectedDate.year,
                      widget.selectedDate.month,
                      widget.selectedDate.day,
                      23,
                      0, // Will be updated with actual prefs
                    );

                    // Find next fixed task
                    final nextFixedTask =
                        widget.dayTasks
                            .where((t) => t.isFixed && t.dueDate!.isAfter(now))
                            .toList()
                          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

                    if (nextFixedTask.isNotEmpty) {
                      availableMinutes = nextFixedTask.first.dueDate!
                          .difference(now)
                          .inMinutes;
                    } else {
                      // Calculate from gaps until day end
                      availableMinutes = dayEnd.difference(now).inMinutes;
                      for (final task in widget.dayTasks.where(
                        (t) => !t.isCompleted && t.endTime!.isAfter(now),
                      )) {
                        availableMinutes -= task.durationMinutes;
                      }
                    }
                    availableMinutes = availableMinutes.clamp(0, 999);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Time',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                Text(
                                  _formatDuration(availableMinutes),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (nextFixedTask.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Until ${nextFixedTask.first.title}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const Gap(12),

                // What happens preview
                if (hasRunningTask)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            '"${widget.currentRunningTask!.title}" will be paused and continued after this task',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 50.ms)
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Colors.green,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            'You\'re free! This task will start immediately.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 50.ms),
                const Gap(16),

                // Task title
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
                ).animate().fadeIn(delay: 100.ms),
                const Gap(20),

                // Duration
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
                          color: Colors.orange,
                        ),
                      ),
                      const Gap(12),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor:
                              colorScheme.surfaceContainerHighest,
                          thumbColor: Colors.orange,
                          overlayColor: Colors.orange.withAlpha(30),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                        ),
                        child: Slider(
                          value: _duration,
                          min: 5,
                          max: 120,
                          divisions: 23,
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
                        children: [5, 10, 15, 30, 60].map((mins) {
                          final isSelected = _duration.round() == mins;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _duration = mins.toDouble()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
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
                ).animate().fadeIn(delay: 150.ms),
                const Gap(24),

                // Add button
                FilledButton.icon(
                  onPressed: _addImmediateTask,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Add Urgent Task'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const Gap(8),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addImmediateTask() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = ref.read(taskRepositoryProvider);

    // Get user preferences and set day boundaries
    final prefs = await repository.getPreferences();
    SchedulingService.setDayBoundaries(
      wakeHour: prefs.wakeUpHour,
      wakeMinute: prefs.wakeUpMinute,
      sleepHour: prefs.sleepHour,
      sleepMinute: prefs.sleepMinute,
    );

    // Create the immediate task
    final immediateTask = Task()
      ..title = _titleController.text.trim()
      ..durationMinutes = _duration.round()
      ..isFixed = false;

    // Use the scheduling service
    final result = SchedulingService.insertImmediateTask(
      immediateTask: immediateTask,
      currentRunningTask: widget.currentRunningTask,
      dayTasks: widget.dayTasks,
      date: widget.selectedDate,
    );

    if (!result.success) {
      _showError(result.message);
      return;
    }

    // Apply the changes
    // Delete tasks first
    for (final task in result.tasksToDelete) {
      await repository.deleteTask(task.id);
    }

    // Add new tasks
    for (final task in result.tasksToAdd) {
      await repository.addTask(task);
    }

    // Update existing tasks
    for (final task in result.tasksToUpdate) {
      await repository.updateTask(task);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
