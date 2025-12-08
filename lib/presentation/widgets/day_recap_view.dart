import 'dart:io';
import 'package:flutter/material.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

class DayRecapView extends StatefulWidget {
  final DateTime date;
  final List<Task> tasks;

  const DayRecapView({super.key, required this.date, required this.tasks});

  @override
  State<DayRecapView> createState() => _DayRecapViewState();
}

class _DayRecapViewState extends State<DayRecapView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Task> get completedTasks =>
      widget.tasks.where((t) => t.isCompleted).toList();
  List<Task> get tasksWithPhotos =>
      completedTasks.where((t) => t.completionPhotoPath != null).toList();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalTasks = widget.tasks.length;
    final completed = completedTasks.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withAlpha(80),
                  colorScheme.secondaryContainer.withAlpha(50),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.history, color: colorScheme.onPrimary),
                    ),
                    const Gap(16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day Recap',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMMEEEEd().format(widget.date),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(20),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.task_alt,
                        label: 'Completed',
                        value: '$completed/$totalTasks',
                        color: Colors.green,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.camera_alt,
                        label: 'Photos',
                        value: '${tasksWithPhotos.length}',
                        color: Colors.blue,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.percent,
                        label: 'Rate',
                        value: totalTasks > 0
                            ? '${((completed / totalTasks) * 100).round()}%'
                            : '-',
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          const Gap(24),

          // Photo carousel (if any)
          if (tasksWithPhotos.isNotEmpty) ...[
            Text(
              'Memories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: tasksWithPhotos.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final task = tasksWithPhotos[index];
                  return _PhotoCard(task: task);
                },
              ),
            ),
            if (tasksWithPhotos.length > 1) ...[
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  tasksWithPhotos.length,
                  (index) => Container(
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
            const Gap(24),
          ],

          // Task summary list
          Text(
            'Tasks Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),

          if (widget.tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: colorScheme.outline),
                  const Gap(12),
                  Text(
                    'No tasks were scheduled',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          else
            ...widget.tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return _RecapTaskTile(
                task: task,
              ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.05);
            }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const Gap(6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
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

class _PhotoCard extends StatelessWidget {
  final Task task;

  const _PhotoCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(task.completionPhotoPath!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(180)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (task.completionNote != null &&
                        task.completionNote!.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        task.completionNote!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Gap(4),
                    Text(
                      task.completedAt != null
                          ? 'Completed at ${DateFormat.jm().format(task.completedAt!)}'
                          : '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
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
}

class _RecapTaskTile extends StatelessWidget {
  final Task task;

  const _RecapTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.green.withAlpha(10)
            : Colors.orange.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? Colors.green.withAlpha(50)
              : Colors.orange.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? Colors.green.withAlpha(20)
                  : Colors.orange.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              task.isCompleted ? Icons.check_circle : Icons.cancel_outlined,
              size: 20,
              color: task.isCompleted ? Colors.green : Colors.orange,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.isCompleted ? colorScheme.outline : null,
                  ),
                ),
                const Gap(4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: colorScheme.outline),
                    const Gap(4),
                    Text(
                      task.dueDate != null
                          ? DateFormat.jm().format(task.dueDate!)
                          : '-',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const Gap(12),
                    Icon(Icons.timer, size: 12, color: colorScheme.outline),
                    const Gap(4),
                    Text(
                      '${task.durationMinutes}m',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    if (task.completionPhotoPath != null) ...[
                      const Gap(12),
                      Icon(Icons.camera_alt, size: 12, color: Colors.blue),
                    ],
                  ],
                ),
                if (task.completionNote != null &&
                    task.completionNote!.isNotEmpty) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            task.completionNote!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
