// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskRepositoryHash() => r'3abc10bd934884de6a6a55097f54a33967e303fa';

/// See also [taskRepository].
@ProviderFor(taskRepository)
final taskRepositoryProvider = AutoDisposeProvider<TaskRepository>.internal(
  taskRepository,
  name: r'taskRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TaskRepositoryRef = AutoDisposeProviderRef<TaskRepository>;
String _$tasksHash() => r'e5e86d9aeaff3ed4f139b46bbc7580be763333d9';

/// See also [tasks].
@ProviderFor(tasks)
final tasksProvider = AutoDisposeStreamProvider<List<Task>>.internal(
  tasks,
  name: r'tasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TasksRef = AutoDisposeStreamProviderRef<List<Task>>;
String _$tasksByDateHash() => r'00a8c8da638906f9f572802e1232fa4431d3b2ec';

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

/// See also [tasksByDate].
@ProviderFor(tasksByDate)
const tasksByDateProvider = TasksByDateFamily();

/// See also [tasksByDate].
class TasksByDateFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [tasksByDate].
  const TasksByDateFamily();

  /// See also [tasksByDate].
  TasksByDateProvider call(
    DateTime date,
  ) {
    return TasksByDateProvider(
      date,
    );
  }

  @override
  TasksByDateProvider getProviderOverride(
    covariant TasksByDateProvider provider,
  ) {
    return call(
      provider.date,
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
  String? get name => r'tasksByDateProvider';
}

/// See also [tasksByDate].
class TasksByDateProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// See also [tasksByDate].
  TasksByDateProvider(
    DateTime date,
  ) : this._internal(
          (ref) => tasksByDate(
            ref as TasksByDateRef,
            date,
          ),
          from: tasksByDateProvider,
          name: r'tasksByDateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tasksByDateHash,
          dependencies: TasksByDateFamily._dependencies,
          allTransitiveDependencies:
              TasksByDateFamily._allTransitiveDependencies,
          date: date,
        );

  TasksByDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    Stream<List<Task>> Function(TasksByDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksByDateProvider._internal(
        (ref) => create(ref as TasksByDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _TasksByDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TasksByDateRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _TasksByDateProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>> with TasksByDateRef {
  _TasksByDateProviderElement(super.provider);

  @override
  DateTime get date => (origin as TasksByDateProvider).date;
}

String _$tasksGroupedByDateHash() =>
    r'd5d8b1d1d20098d38fdc5ce761ba7caa84ba1d1f';

/// See also [tasksGroupedByDate].
@ProviderFor(tasksGroupedByDate)
final tasksGroupedByDateProvider =
    AutoDisposeStreamProvider<Map<DateTime, List<Task>>>.internal(
  tasksGroupedByDate,
  name: r'tasksGroupedByDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksGroupedByDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TasksGroupedByDateRef
    = AutoDisposeStreamProviderRef<Map<DateTime, List<Task>>>;
String _$userPreferencesHash() => r'ed3cdb156380c61cda5fe6166c9e3757576a58b1';

/// See also [userPreferences].
@ProviderFor(userPreferences)
final userPreferencesProvider =
    AutoDisposeStreamProvider<UserPreferences?>.internal(
  userPreferences,
  name: r'userPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserPreferencesRef = AutoDisposeStreamProviderRef<UserPreferences?>;
String _$currentPreferencesHash() =>
    r'52584dba90a0de6c0d7b1d30507817cd9f3052f1';

/// See also [currentPreferences].
@ProviderFor(currentPreferences)
final currentPreferencesProvider =
    AutoDisposeFutureProvider<UserPreferences>.internal(
  currentPreferences,
  name: r'currentPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentPreferencesRef = AutoDisposeFutureProviderRef<UserPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
