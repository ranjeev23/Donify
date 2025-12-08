import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/core/services/scheduling_service.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;
  final List<Task> dayTasks;
  final DateTime selectedDate;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.dayTasks,
    required this.selectedDate,
  });

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet> {
  late TextEditingController _titleController;
  late double _currentDuration;
  late int _maxIncrease;
  final int _minDuration = 5;
  final int _maxDuration = 180;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _currentDuration = widget.task.durationMinutes.toDouble();
    _maxIncrease = SchedulingService.getMaxPossibleIncrease(
      widget.task,
      widget.dayTasks,
      widget.selectedDate,
    );
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
    final maxAllowedDuration = (widget.task.durationMinutes + _maxIncrease)
        .clamp(_minDuration, _maxDuration);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 16,
        ),
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

            // Header with delete button
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
                  child: Icon(Icons.edit_note, color: colorScheme.onPrimary),
                ),
                const Gap(12),
                Text(
                  'Edit Task',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showDeleteConfirmation,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.1),
            const Gap(24),

            // Task time info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: colorScheme.primary),
                  const Gap(10),
                  Text(
                    '${DateFormat.jm().format(widget.task.dueDate!)} - ${DateFormat.jm().format(widget.task.endTime!)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (widget.task.isFixed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, size: 12, color: Colors.orange),
                          Gap(4),
                          Text(
                            'Fixed',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 50.ms),
            const Gap(20),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
              ),
              textCapitalization: TextCapitalization.sentences,
            ).animate().fadeIn(delay: 100.ms),
            const Gap(24),

            // Duration slider
            Text(
              'Duration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withAlpha(50),
                    colorScheme.secondaryContainer.withAlpha(30),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withAlpha(50)),
              ),
              child: Column(
                children: [
                  // Duration display
                  Text(
                    _formatMinutes(_currentDuration.round()),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Max available: ${_formatMinutes(maxAllowedDuration)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const Gap(16),
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colorScheme.primary,
                      inactiveTrackColor: colorScheme.surfaceContainerHighest,
                      thumbColor: colorScheme.primary,
                      overlayColor: colorScheme.primary.withAlpha(30),
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: _currentDuration.clamp(
                        _minDuration.toDouble(),
                        maxAllowedDuration.toDouble(),
                      ),
                      min: _minDuration.toDouble(),
                      max: maxAllowedDuration.toDouble(),
                      divisions: (maxAllowedDuration - _minDuration) ~/ 5,
                      onChanged: (value) {
                        setState(() {
                          _currentDuration =
                              (value / 5).round() *
                              5.0; // Round to 5 min intervals
                        });
                      },
                    ),
                  ),
                  // Quick buttons
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [15, 30, 60, 90].map((mins) {
                      final isAvailable = mins <= maxAllowedDuration;
                      final isSelected = _currentDuration.round() == mins;
                      return GestureDetector(
                        onTap: isAvailable
                            ? () => setState(
                                () => _currentDuration = mins.toDouble(),
                              )
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : isAvailable
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.surfaceContainerHighest.withAlpha(
                                    50,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatMinutes(mins),
                            style: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : isAvailable
                                  ? colorScheme.onSurface
                                  : colorScheme.outline,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
            const Gap(28),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check),
                    label: const Text('Save Changes'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
          'Are you sure you want to delete "${widget.task.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repository = ref.read(taskRepositoryProvider);
              await repository.deleteTask(widget.task.id);
              if (mounted) {
                Navigator.pop(context);
                _showMessage('Task deleted');
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) {
      _showMessage('Please enter a title');
      return;
    }

    final repository = ref.read(taskRepositoryProvider);
    final durationChange =
        _currentDuration.round() - widget.task.durationMinutes;

    if (durationChange != 0 || newTitle != widget.task.title) {
      if (durationChange > 0) {
        final result = SchedulingService.increaseDuration(
          widget.task,
          durationChange,
          widget.dayTasks,
          widget.selectedDate,
        );

        if (result.success) {
          for (final task in result.updatedTasks) {
            if (task.id == widget.task.id) {
              task.title = newTitle;
            }
            await repository.updateTask(task);
          }
          if (mounted) {
            Navigator.pop(context);
            _showMessage('Task updated');
          }
        } else {
          _showMessage(result.message);
        }
      } else if (durationChange < 0) {
        final result = SchedulingService.decreaseDuration(
          widget.task,
          durationChange.abs(),
          widget.dayTasks,
          widget.selectedDate,
          cascadePull: true,
        );

        if (result.success) {
          for (final task in result.updatedTasks) {
            if (task.id == widget.task.id) {
              task.title = newTitle;
            }
            await repository.updateTask(task);
          }
          if (mounted) {
            Navigator.pop(context);
            _showMessage('Task updated');
          }
        } else {
          _showMessage(result.message);
        }
      } else {
        // Only title changed
        final updatedTask = widget.task.copyWith(title: newTitle);
        await repository.updateTask(updatedTask);
        if (mounted) {
          Navigator.pop(context);
          _showMessage('Task updated');
        }
      }
    } else {
      Navigator.pop(context);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
