import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/expense.dart';
import 'package:remindlyf/data/models/expense_category.dart';
import 'package:remindlyf/data/models/income.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';

part 'money_provider.g.dart';

// Stream all expense categories
@riverpod
Stream<List<ExpenseCategory>> expenseCategories(
  ExpenseCategoriesRef ref,
) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchExpenseCategories();
}

// Stream all expenses
@riverpod
Stream<List<Expense>> expenses(ExpensesRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchExpenses();
}

// Stream all incomes
@riverpod
Stream<List<Income>> incomes(IncomesRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchIncomes();
}

// Get expenses grouped by category type (Needs, Wants, Savings)
@riverpod
Stream<Map<ExpenseType, List<ExpenseCategory>>> categoriesByType(
  CategoriesByTypeRef ref,
) async* {
  final repository = ref.watch(taskRepositoryProvider);

  await for (final categories in repository.watchExpenseCategories()) {
    final Map<ExpenseType, List<ExpenseCategory>> grouped = {
      ExpenseType.needs: [],
      ExpenseType.wants: [],
      ExpenseType.savings: [],
    };

    for (final category in categories) {
      if (category.isActive) {
        grouped[category.type]!.add(category);
      }
    }

    yield grouped;
  }
}

// Get expenses for current month
@riverpod
Stream<List<Expense>> currentMonthExpenses(CurrentMonthExpensesRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  await for (final allExpenses in repository.watchExpenses()) {
    final monthExpenses = allExpenses.where((e) {
      return e.expenseDate.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          e.expenseDate.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList();
    yield monthExpenses;
  }
}

// Get expenses for a specific task
@riverpod
Future<List<Expense>> taskExpenses(TaskExpensesRef ref, int taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getExpensesByTask(taskId);
}

// Monthly statistics provider with income - reacts to both expenses and incomes
@riverpod
Stream<MonthlyStats> monthlyStats(MonthlyStatsRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  // Watch both expenses and incomes streams
  await for (final allExpenses in repository.watchExpenses()) {
    // Re-fetch incomes each time expenses change
    // Also invalidate when incomes provider changes
    final allIncomes = await repository.getIncomesByDateRange(
      startOfMonth,
      endOfMonth,
    );
    final categories = await repository.getAllExpenseCategories();

    final monthExpenses = allExpenses.where((e) {
      return e.expenseDate.isAfter(
            startOfMonth.subtract(const Duration(seconds: 1)),
          ) &&
          e.expenseDate.isBefore(endOfMonth.add(const Duration(seconds: 1)));
    }).toList();

    double needsTotal = 0;
    double wantsTotal = 0;
    double savingsTotal = 0;
    double cashSpent = 0;
    double upiSpent = 0;
    final Map<int, double> categoryTotals = {};

    for (final expense in monthExpenses) {
      // Track spending by payment method
      if (expense.paymentMethod == PaymentMethod.cash) {
        cashSpent += expense.amount;
      } else {
        upiSpent += expense.amount;
      }

      if (expense.categoryId != null) {
        categoryTotals[expense.categoryId!] =
            (categoryTotals[expense.categoryId!] ?? 0) + expense.amount;

        final category = categories.firstWhere(
          (c) => c.id == expense.categoryId,
          orElse: () => ExpenseCategory()..type = ExpenseType.needs,
        );

        switch (category.type) {
          case ExpenseType.needs:
            needsTotal += expense.amount;
            break;
          case ExpenseType.wants:
            wantsTotal += expense.amount;
            break;
          case ExpenseType.savings:
            savingsTotal += expense.amount;
            break;
        }
      }
    }

    // Calculate income totals by type
    double cashIncome = 0;
    double upiIncome = 0;
    for (final income in allIncomes) {
      if (income.type == IncomeType.cash) {
        cashIncome += income.amount;
      } else {
        upiIncome += income.amount;
      }
    }

    final totalIncome = cashIncome + upiIncome;
    final totalSpent = needsTotal + wantsTotal + savingsTotal;

    yield MonthlyStats(
      totalSpent: totalSpent,
      needsTotal: needsTotal,
      wantsTotal: wantsTotal,
      savingsTotal: savingsTotal,
      categoryTotals: categoryTotals,
      expenseCount: monthExpenses.length,
      totalIncome: totalIncome,
      cashIncome: cashIncome,
      upiIncome: upiIncome,
      cashSpent: cashSpent,
      upiSpent: upiSpent,
      remainingBalance: totalIncome - totalSpent,
    );
  }
}

// Data class for monthly statistics
class MonthlyStats {
  final double totalSpent;
  final double needsTotal;
  final double wantsTotal;
  final double savingsTotal;
  final Map<int, double> categoryTotals;
  final int expenseCount;
  final double totalIncome;
  final double cashIncome;
  final double upiIncome;
  final double cashSpent;
  final double upiSpent;
  final double remainingBalance;

  MonthlyStats({
    required this.totalSpent,
    required this.needsTotal,
    required this.wantsTotal,
    required this.savingsTotal,
    required this.categoryTotals,
    required this.expenseCount,
    required this.totalIncome,
    required this.cashIncome,
    required this.upiIncome,
    required this.cashSpent,
    required this.upiSpent,
    required this.remainingBalance,
  });

  // Remaining balances by payment method
  double get cashRemaining => cashIncome - cashSpent;
  double get upiRemaining => upiIncome - upiSpent;

  // Percentage helpers
  double get needsPercentage =>
      totalSpent > 0 ? (needsTotal / totalSpent) * 100 : 0;
  double get wantsPercentage =>
      totalSpent > 0 ? (wantsTotal / totalSpent) * 100 : 0;
  double get savingsPercentage =>
      totalSpent > 0 ? (savingsTotal / totalSpent) * 100 : 0;

  // Income percentage of total (how much is spent)
  double get spentPercentage =>
      totalIncome > 0 ? (totalSpent / totalIncome) * 100 : 0;
}
