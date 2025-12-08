import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/core/services/scheduling_service.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DraftsSheet extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const DraftsSheet({super.key, required this.selectedDate});

  @override
  ConsumerState<DraftsSheet> createState() => _DraftsSheetState();
}

class _DraftsSheetState extends ConsumerState<DraftsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) return 'Today';
    if (_isSameDay(date, now.add(const Duration(days: 1)))) return 'Tomorrow';
    return DateFormat.MMMd().format(date);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tasksAsync = ref.watch(tasksProvider);

    final dateLabel = _getDateLabel(widget.selectedDate);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
                const Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ideas & Drafts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'For $dateLabel, ${DateFormat.EEEE().format(widget.selectedDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(12),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: colorScheme.onPrimary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: dateLabel), // Selected day
                const Tab(text: 'Global Ideas'),
              ],
            ),
          ),
          const Gap(12),

          // Add new draft
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Add idea for $dateLabel...',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(
                        80,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addDraft(),
                  ),
                ),
                const Gap(8),
                IconButton.filled(
                  onPressed: _addDraft,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),

          // Drafts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Selected day's drafts
                tasksAsync.when(
                  data: (tasks) {
                    final dayDrafts = tasks.where((t) {
                      if (!t.isDraft) return false;
                      if (t.dueDate == null) return false;
                      return _isSameDay(t.dueDate!, widget.selectedDate);
                    }).toList();
                    return _buildDraftsList(dayDrafts, forSelectedDay: true);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
                // Global drafts (no date)
                tasksAsync.when(
                  data: (tasks) {
                    final globalDrafts = tasks
                        .where((t) => t.isDraft && t.dueDate == null)
                        .toList();
                    return _buildDraftsList(
                      globalDrafts,
                      forSelectedDay: false,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftsList(List<Task> drafts, {required bool forSelectedDay}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateLabel = _getDateLabel(widget.selectedDate);

    if (drafts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 48, color: colorScheme.outline),
            const Gap(12),
            Text(
              forSelectedDay ? 'No ideas for $dateLabel' : 'No global ideas',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const Gap(4),
            Text(
              'Add your first idea above',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        final draft = drafts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withAlpha(50)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
            ),
            title: Text(
              draft.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: draft.dueDate != null
                ? Text(
                    DateFormat.MMMd().format(draft.dueDate!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  )
                : Text(
                    'Global idea',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Schedule button
                IconButton(
                  icon: Icon(
                    Icons.schedule,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: () => _scheduleDraft(draft),
                  tooltip: 'Schedule',
                ),
                // Delete button
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: colorScheme.error,
                    size: 20,
                  ),
                  onPressed: () => _deleteDraft(draft),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addDraft() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final repository = ref.read(taskRepositoryProvider);

    // Determine if this is for selected day or global based on current tab
    final isForSelectedDay = _tabController.index == 0;

    final draft = Task()
      ..title = title
      ..isDraft = true
      ..dueDate = isForSelectedDay
          ? DateTime(
              widget.selectedDate.year,
              widget.selectedDate.month,
              widget.selectedDate.day,
            )
          : null;

    await repository.addTask(draft);
    _titleController.clear();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _scheduleDraft(Task draft) async {
    final repository = ref.read(taskRepositoryProvider);

    // Get preferences for day boundaries
    final prefs = await repository.getPreferences();
    SchedulingService.setDayBoundaries(
      wakeHour: prefs.wakeUpHour,
      wakeMinute: prefs.wakeUpMinute,
      sleepHour: prefs.sleepHour,
      sleepMinute: prefs.sleepMinute,
    );

    // Get tasks for selected date
    final allTasks = await repository.getAllTasks();
    final dayTasks = allTasks
        .where(
          (t) =>
              t.dueDate != null &&
              !t.isDraft &&
              _isSameDay(t.dueDate!, widget.selectedDate),
        )
        .toList();

    // Convert draft to scheduled task
    draft.isDraft = false;
    draft.dueDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    final result = SchedulingService.autoAssignTime(
      draft,
      dayTasks,
      widget.selectedDate,
    );

    if (!result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await repository.updateTask(draft);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Scheduled "${draft.title}" for ${DateFormat.jm().format(draft.dueDate!)}',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteDraft(Task draft) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.deleteTask(draft.id);
  }
}
