import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/repositories/task_repository.dart';
import 'package:remindlyf/data/models/task.dart';
import 'package:remindlyf/data/models/expense.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/income.dart';
import 'package:intl/intl.dart';

class BackupInspectorScreen extends ConsumerStatefulWidget {
  final File backupFile;

  const BackupInspectorScreen({super.key, required this.backupFile});

  @override
  ConsumerState<BackupInspectorScreen> createState() =>
      _BackupInspectorScreenState();
}

class _BackupInspectorScreenState extends ConsumerState<BackupInspectorScreen> {
  late Future<Map<String, List<dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = TaskRepository().inspectBackup(widget.backupFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Inspector')),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final tasks = data['Tasks'] as List<Task>;
          final expenses = data['Expenses'] as List<Expense>;
          final subscriptions = data['Subscriptions'] as List<Subscription>;
          final incomes = data['Incomes'] as List<Income>;

          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Tasks (${tasks.length})'),
                    Tab(text: 'Expenses (${expenses.length})'),
                    Tab(text: 'Subs (${subscriptions.length})'),
                    Tab(text: 'Income (${incomes.length})'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTaskList(tasks),
                      _buildExpenseList(expenses),
                      _buildSubscriptionList(subscriptions),
                      _buildIncomeList(incomes),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) return const Center(child: Text('No Tasks'));
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(
            task.dueDate != null
                ? DateFormat.yMMMd().add_jm().format(task.dueDate!)
                : 'No Date',
          ),
          trailing: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted ? Colors.green : Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    if (expenses.isEmpty) return const Center(child: Text('No Expenses'));
    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ListTile(
          title: Text(
            expense.note?.isEmpty ?? true ? 'Expense' : expense.note!,
          ),
          subtitle: Text(DateFormat.yMMMd().format(expense.expenseDate)),
          trailing: Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionList(List<Subscription> subs) {
    if (subs.isEmpty) return const Center(child: Text('No Subscriptions'));
    return ListView.builder(
      itemCount: subs.length,
      itemBuilder: (context, index) {
        final sub = subs[index];
        return ListTile(
          title: Text(sub.name),
          subtitle: Text(
            sub.expiryDate != null
                ? 'Expires: ${DateFormat.yMMMd().format(sub.expiryDate!)}'
                : 'No Expiry',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }

  Widget _buildIncomeList(List<Income> incomes) {
    if (incomes.isEmpty) return const Center(child: Text('No Income Records'));
    return ListView.builder(
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return ListTile(
          title: Text(income.typeLabel),
          subtitle: Text(DateFormat.yMMMd().format(income.incomeDate)),
          trailing: Text(
            '\$${income.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }
}
