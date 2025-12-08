import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/core/services/scheduling_service.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _descriptionController;
  late double _currentDuration;
  late int _maxIncrease;
  bool _isEditingTitle = false;
  bool _isEditingDescription = false;
  bool _isEditingDuration = false;

  final int _minDuration = 5;
  final int _maxDuration = 180;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
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
    _descriptionController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = widget.task.isCompleted;
    final maxAllowedDuration = (widget.task.durationMinutes + _maxIncrease)
        .clamp(_minDuration, _maxDuration);

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle - easy to close
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const Gap(16),

              // Title row with edit button
              Row(
                children: [
                  Expanded(
                    child: _isEditingTitle
                        ? TextField(
                            controller: _titleController,
                            autofocus: true,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Task title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _saveTitle(),
                          )
                        : Text(
                            widget.task.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted ? colorScheme.outline : null,
                            ),
                          ),
                  ),
                  const Gap(8),
                  // Edit title button
                  IconButton(
                    onPressed: () {
                      if (_isEditingTitle) {
                        _saveTitle();
                      } else {
                        setState(() => _isEditingTitle = true);
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isEditingTitle
                            ? Colors.green.withAlpha(20)
                            : colorScheme.primaryContainer.withAlpha(100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isEditingTitle ? Icons.check : Icons.edit,
                        size: 18,
                        color: _isEditingTitle
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                  // Delete button
                  IconButton(
                    onPressed: _showDeleteConfirmation,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(14),

              // Description section - hidden by default, only show if has description or editing
              if (_isEditingDescription)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withAlpha(50),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notes,
                            size: 18,
                            color: colorScheme.outline,
                          ),
                          const Gap(8),
                          Text(
                            'Note',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      TextField(
                        controller: _descriptionController,
                        autofocus: true,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add notes about this task...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _descriptionController.text =
                                    widget.task.description ?? '';
                                setState(() => _isEditingDescription = false);
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _saveDescription,
                              child: const Text('Save Note'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else if (widget.task.description?.isNotEmpty == true)
                // Show existing description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes, size: 16, color: colorScheme.outline),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          widget.task.description!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isEditingDescription = true),
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Just show "Add note" link
                GestureDetector(
                  onTap: () => setState(() => _isEditingDescription = true),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16, color: colorScheme.outline),
                        const Gap(6),
                        Text(
                          'Add note',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Gap(14),

              // Mark as Complete/Incomplete button
              GestureDetector(
                onTap: _toggleCompletion,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [Colors.orange.shade400, Colors.orange.shade600]
                          : [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (isCompleted ? Colors.orange : Colors.green)
                            .withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCompleted ? Icons.replay : Icons.check_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const Gap(10),
                      Text(
                        isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(14),

              // Time info - Scheduled Time
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withAlpha(50),
                  ),
                ),
                child: Column(
                  children: [
                    // Scheduled Time
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const Gap(10),
                        Text(
                          'Scheduled Time',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${DateFormat.jm().format(widget.task.dueDate!)} - ${DateFormat.jm().format(widget.task.endTime!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Fixed badge
                    if (widget.task.isFixed) ...[
                      const Gap(10),
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withAlpha(50),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            size: 18,
                            color: Colors.orange,
                          ),
                          const Gap(10),
                          Text(
                            'Fixed Time',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Cannot be moved',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Completed at info
                    if (isCompleted && widget.task.completedAt != null) ...[
                      const Gap(10),
                      Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withAlpha(50),
                      ),
                      const Gap(10),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          ),
                          const Gap(10),
                          Text(
                            'Completed at',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat.jm().format(widget.task.completedAt!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(14),

              // Duration section - with edit capability (only for non-completed tasks)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withAlpha(50),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.timer : Icons.timelapse,
                          size: 18,
                          color: isCompleted
                              ? Colors.green
                              : colorScheme.secondary,
                        ),
                        const Gap(10),
                        Text(
                          isCompleted ? 'Time Taken' : 'Duration',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const Spacer(),
                        if (!isCompleted && !_isEditingDuration)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isEditingDuration = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: colorScheme.primary,
                                  ),
                                  const Gap(4),
                                  Text(
                                    'Change',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (!_isEditingDuration)
                          Text(
                            _formatMinutes(widget.task.durationMinutes),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? Colors.green : null,
                            ),
                          ),
                      ],
                    ),
                    if (_isEditingDuration && !isCompleted) ...[
                      const Gap(16),
                      // Duration display
                      Text(
                        _formatMinutes(_currentDuration.round()),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Max: ${_formatMinutes(maxAllowedDuration)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      const Gap(12),
                      // Slider
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
                          value: _currentDuration.clamp(
                            _minDuration.toDouble(),
                            maxAllowedDuration.toDouble(),
                          ),
                          min: _minDuration.toDouble(),
                          max: maxAllowedDuration.toDouble(),
                          divisions: (maxAllowedDuration - _minDuration) ~/ 5,
                          onChanged: (value) {
                            setState(() {
                              _currentDuration = (value / 5).round() * 5.0;
                            });
                          },
                        ),
                      ),
                      // Quick buttons
                      const Gap(8),
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
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : isAvailable
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.surfaceContainerHighest
                                          .withAlpha(50),
                                borderRadius: BorderRadius.circular(6),
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
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(14),
                      // Save/Cancel buttons for duration
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _currentDuration = widget.task.durationMinutes
                                      .toDouble();
                                  _isEditingDuration = false;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _saveDuration,
                              child: const Text('Save Duration'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (!isCompleted && !_isEditingDuration) ...[
                      // Show current duration when not editing
                      const Gap(8),
                      Text(
                        _formatMinutes(widget.task.durationMinutes),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(14),

              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTitle() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) {
      _showMessage('Please enter a title');
      return;
    }

    final repository = ref.read(taskRepositoryProvider);
    final updatedTask = widget.task.copyWith(title: newTitle);
    await repository.updateTask(updatedTask);

    setState(() => _isEditingTitle = false);
    _showMessage('Title updated');
  }

  void _saveDescription() async {
    final newDescription = _descriptionController.text.trim();
    final repository = ref.read(taskRepositoryProvider);

    // Update the task's description field directly
    widget.task.description = newDescription.isEmpty ? null : newDescription;
    await repository.updateTask(widget.task);

    setState(() => _isEditingDescription = false);
    _showMessage(newDescription.isEmpty ? 'Note removed' : 'Note saved');
  }

  void _saveDuration() async {
    final repository = ref.read(taskRepositoryProvider);
    final durationChange =
        _currentDuration.round() - widget.task.durationMinutes;

    if (durationChange == 0) {
      setState(() => _isEditingDuration = false);
      return;
    }

    if (durationChange > 0) {
      final result = SchedulingService.increaseDuration(
        widget.task,
        durationChange,
        widget.dayTasks,
        widget.selectedDate,
      );

      if (result.success) {
        for (final task in result.updatedTasks) {
          await repository.updateTask(task);
        }
        setState(() => _isEditingDuration = false);
        _showMessage('Duration updated');
      } else {
        _showMessage(result.message);
      }
    } else {
      final result = SchedulingService.decreaseDuration(
        widget.task,
        durationChange.abs(),
        widget.dayTasks,
        widget.selectedDate,
        cascadePull: true,
      );

      if (result.success) {
        for (final task in result.updatedTasks) {
          await repository.updateTask(task);
        }
        setState(() => _isEditingDuration = false);
        _showMessage('Duration updated');
      } else {
        _showMessage(result.message);
      }
    }
  }

  void _toggleCompletion() async {
    final repository = ref.read(taskRepositoryProvider);
    final wasCompleted = widget.task.isCompleted;

    if (wasCompleted) {
      final updatedTask = widget.task.copyWith(
        isCompleted: false,
        completedAt: null,
      );
      await repository.updateTask(updatedTask);
      _showMessage('Task marked as incomplete');
    } else {
      final updatedTask = widget.task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await repository.updateTask(updatedTask);
      _showMessage('Task completed! 🎉');
    }

    if (mounted) Navigator.pop(context);
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
