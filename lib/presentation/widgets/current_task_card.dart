import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class CurrentTaskCard extends StatefulWidget {
  final Task? currentTask;
  final Task? nextTask;
  final VoidCallback? onComplete;
  final VoidCallback? onAddImmediate;

  const CurrentTaskCard({
    super.key,
    this.currentTask,
    this.nextTask,
    this.onComplete,
    this.onAddImmediate,
  });

  @override
  State<CurrentTaskCard> createState() => _CurrentTaskCardState();
}

class _CurrentTaskCardState extends State<CurrentTaskCard> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(CurrentTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentTask != oldWidget.currentTask) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.currentTask == null || widget.currentTask!.dueDate == null) {
      return;
    }

    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final task = widget.currentTask;
    if (task == null || task.endTime == null) return;

    final now = DateTime.now();
    final endTime = task.endTime!;
    final startTime = task.dueDate!;

    if (now.isAfter(endTime)) {
      setState(() {
        _remainingTime = Duration.zero;
        _progress = 1.0;
      });
      return;
    }

    final totalDuration = endTime.difference(startTime);
    final elapsed = now.difference(startTime);

    setState(() {
      _remainingTime = endTime.difference(now);
      _progress = (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.currentTask == null) {
      return _buildNoCurrentTask(context);
    }

    final task = widget.currentTask!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withAlpha(80),
            colorScheme.secondaryContainer.withAlpha(40),
            colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withAlpha(100), width: 2),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 16,
                    ),
                    const Gap(6),
                    Text(
                      'NOW',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (task.isFixed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withAlpha(80)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 14, color: Colors.orange),
                      Gap(4),
                      Text(
                        'Fixed',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Gap(16),

          // Task title
          Text(
            task.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(20),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
          const Gap(16),

          // Time remaining and actions
          Row(
            children: [
              Expanded(
                child: _TimeCounter(
                  remainingTime: _remainingTime,
                  color: colorScheme.primary,
                ),
              ),

              Row(
                children: [
                  // Urgent task button
                  _ActionButton(
                    icon: Icons.flash_on,
                    label: 'Urgent',
                    onTap: widget.onAddImmediate ?? () {},
                    color: Colors.orange,
                  ),
                  const Gap(8),
                  // Done button
                  _ActionButton(
                    icon: Icons.check_circle,
                    label: 'Done',
                    onTap: widget.onComplete ?? () {},
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),

          // Next task preview
          if (widget.nextTask != null) ...[
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const Gap(8),
                  Text(
                    'Next: ',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.nextTask!.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildNoCurrentTask(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.withAlpha(30), Colors.teal.withAlpha(20)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withAlpha(50), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.self_improvement,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'re Free!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      widget.nextTask != null
                          ? 'Next task: ${widget.nextTask!.title}'
                          : 'No more tasks scheduled',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          // Add task now button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onAddImmediate,
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Add Task Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class _TimeCounter extends StatelessWidget {
  final Duration remainingTime;
  final Color color;

  const _TimeCounter({required this.remainingTime, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    final seconds = remainingTime.inSeconds % 60;

    final isUrgent = remainingTime.inMinutes < 5;

    return Row(
      children: [
        Icon(
          isUrgent ? Icons.warning_amber : Icons.timer,
          color: isUrgent ? Colors.red : color,
          size: 20,
        ),
        const Gap(8),
        if (hours > 0) ...[
          _TimeUnit(value: hours, label: 'h', color: color),
          const Gap(4),
        ],
        _TimeUnit(value: minutes, label: 'm', color: color),
        const Gap(4),
        _TimeUnit(value: seconds, label: 's', color: color, isSeconds: true),
        const Gap(8),
        Text(
          'remaining',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final bool isSeconds;

  const _TimeUnit({
    required this.value,
    required this.label,
    required this.color,
    this.isSeconds = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSeconds ? 14 : 16,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color.withAlpha(150),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const Gap(4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
