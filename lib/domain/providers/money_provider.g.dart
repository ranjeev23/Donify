// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseCategoriesHash() => r'2cbee6e7b875e43e27ed07b8bb3fdab3ecfeb62f';

/// See also [expenseCategories].
@ProviderFor(expenseCategories)
final expenseCategoriesProvider =
    AutoDisposeStreamProvider<List<ExpenseCategory>>.internal(
  expenseCategories,
  name: r'expenseCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExpenseCategoriesRef
    = AutoDisposeStreamProviderRef<List<ExpenseCategory>>;
String _$expensesHash() => r'a3a1d30d5e70a36a6cac0c2cf9ba5c0102a31aa8';

/// See also [expenses].
@ProviderFor(expenses)
final expensesProvider = AutoDisposeStreamProvider<List<Expense>>.internal(
  expenses,
  name: r'expensesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$expensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExpensesRef = AutoDisposeStreamProviderRef<List<Expense>>;
String _$incomesHash() => r'fd99d55b2afaa775bbd8ecac5b13f73ea56bf82a';

/// See also [incomes].
@ProviderFor(incomes)
final incomesProvider = AutoDisposeStreamProvider<List<Income>>.internal(
  incomes,
  name: r'incomesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$incomesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IncomesRef = AutoDisposeStreamProviderRef<List<Income>>;
String _$categoriesByTypeHash() => r'b00976713dafd00f5c1938669e0b13db3327fb9f';

/// See also [categoriesByType].
@ProviderFor(categoriesByType)
final categoriesByTypeProvider =
    AutoDisposeStreamProvider<Map<ExpenseType, List<ExpenseCategory>>>.internal(
  categoriesByType,
  name: r'categoriesByTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoriesByTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoriesByTypeRef
    = AutoDisposeStreamProviderRef<Map<ExpenseType, List<ExpenseCategory>>>;
String _$currentMonthExpensesHash() =>
    r'a32b63ec1b74a3cecf53ddadb0516acfa6243eda';

/// See also [currentMonthExpenses].
@ProviderFor(currentMonthExpenses)
final currentMonthExpensesProvider =
    AutoDisposeStreamProvider<List<Expense>>.internal(
  currentMonthExpenses,
  name: r'currentMonthExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMonthExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentMonthExpensesRef = AutoDisposeStreamProviderRef<List<Expense>>;
String _$taskExpensesHash() => r'3c32629738cf96bf44616ce8a0e047a234ee2858';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [taskExpenses].
@ProviderFor(taskExpenses)
const taskExpensesProvider = TaskExpensesFamily();

/// See also [taskExpenses].
class TaskExpensesFamily extends Family<AsyncValue<List<Expense>>> {
  /// See also [taskExpenses].
  const TaskExpensesFamily();

  /// See also [taskExpenses].
  TaskExpensesProvider call(
    int taskId,
  ) {
    return TaskExpensesProvider(
      taskId,
    );
  }

  @override
  TaskExpensesProvider getProviderOverride(
    covariant TaskExpensesProvider provider,
  ) {
    return call(
      provider.taskId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskExpensesProvider';
}

/// See also [taskExpenses].
class TaskExpensesProvider extends AutoDisposeFutureProvider<List<Expense>> {
  /// See also [taskExpenses].
  TaskExpensesProvider(
    int taskId,
  ) : this._internal(
          (ref) => taskExpenses(
            ref as TaskExpensesRef,
            taskId,
          ),
          from: taskExpensesProvider,
          name: r'taskExpensesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$taskExpensesHash,
          dependencies: TaskExpensesFamily._dependencies,
          allTransitiveDependencies:
              TaskExpensesFamily._allTransitiveDependencies,
          taskId: taskId,
        );

  TaskExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  Override overrideWith(
    FutureOr<List<Expense>> Function(TaskExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskExpensesProvider._internal(
        (ref) => create(ref as TaskExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Expense>> createElement() {
    return _TaskExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskExpensesProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TaskExpensesRef on AutoDisposeFutureProviderRef<List<Expense>> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _TaskExpensesProviderElement
    extends AutoDisposeFutureProviderElement<List<Expense>>
    with TaskExpensesRef {
  _TaskExpensesProviderElement(super.provider);

  @override
  int get taskId => (origin as TaskExpensesProvider).taskId;
}

String _$monthlyStatsHash() => r'0f2395b6b91f7f3c4e14e6b7e0a35250c02717d1';

/// See also [monthlyStats].
@ProviderFor(monthlyStats)
final monthlyStatsProvider = AutoDisposeStreamProvider<MonthlyStats>.internal(
  monthlyStats,
  name: r'monthlyStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$monthlyStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyStatsRef = AutoDisposeStreamProviderRef<MonthlyStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
