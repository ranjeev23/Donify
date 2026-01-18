// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionCategoriesHash() =>
    r'19309010c39ac45f85e4aacee19cccde4179292e';

/// See also [subscriptionCategories].
@ProviderFor(subscriptionCategories)
final subscriptionCategoriesProvider =
    AutoDisposeStreamProvider<List<SubscriptionCategory>>.internal(
  subscriptionCategories,
  name: r'subscriptionCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionCategoriesRef
    = AutoDisposeStreamProviderRef<List<SubscriptionCategory>>;
String _$subscriptionsHash() => r'cb4f724d4ad085662af6c16400fedba3803b39f1';

/// See also [subscriptions].
@ProviderFor(subscriptions)
final subscriptionsProvider =
    AutoDisposeStreamProvider<List<Subscription>>.internal(
  subscriptions,
  name: r'subscriptionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionsRef = AutoDisposeStreamProviderRef<List<Subscription>>;
String _$subscriptionsByCategoryHash() =>
    r'f6eaaf80534368ff526dbe5b68e1b521799e4ba3';

/// See also [subscriptionsByCategory].
@ProviderFor(subscriptionsByCategory)
final subscriptionsByCategoryProvider = AutoDisposeStreamProvider<
    Map<SubscriptionCategory, List<Subscription>>>.internal(
  subscriptionsByCategory,
  name: r'subscriptionsByCategoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionsByCategoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionsByCategoryRef = AutoDisposeStreamProviderRef<
    Map<SubscriptionCategory, List<Subscription>>>;
String _$upcomingExpiriesHash() => r'250f67766b7ce9ec7caef8d080469c9b75f34d7b';

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

/// See also [upcomingExpiries].
@ProviderFor(upcomingExpiries)
const upcomingExpiriesProvider = UpcomingExpiriesFamily();

/// See also [upcomingExpiries].
class UpcomingExpiriesFamily extends Family<AsyncValue<List<Subscription>>> {
  /// See also [upcomingExpiries].
  const UpcomingExpiriesFamily();

  /// See also [upcomingExpiries].
  UpcomingExpiriesProvider call({
    int days = 7,
  }) {
    return UpcomingExpiriesProvider(
      days: days,
    );
  }

  @override
  UpcomingExpiriesProvider getProviderOverride(
    covariant UpcomingExpiriesProvider provider,
  ) {
    return call(
      days: provider.days,
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
  String? get name => r'upcomingExpiriesProvider';
}

/// See also [upcomingExpiries].
class UpcomingExpiriesProvider
    extends AutoDisposeStreamProvider<List<Subscription>> {
  /// See also [upcomingExpiries].
  UpcomingExpiriesProvider({
    int days = 7,
  }) : this._internal(
          (ref) => upcomingExpiries(
            ref as UpcomingExpiriesRef,
            days: days,
          ),
          from: upcomingExpiriesProvider,
          name: r'upcomingExpiriesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$upcomingExpiriesHash,
          dependencies: UpcomingExpiriesFamily._dependencies,
          allTransitiveDependencies:
              UpcomingExpiriesFamily._allTransitiveDependencies,
          days: days,
        );

  UpcomingExpiriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.days,
  }) : super.internal();

  final int days;

  @override
  Override overrideWith(
    Stream<List<Subscription>> Function(UpcomingExpiriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingExpiriesProvider._internal(
        (ref) => create(ref as UpcomingExpiriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        days: days,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Subscription>> createElement() {
    return _UpcomingExpiriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingExpiriesProvider && other.days == days;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, days.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpcomingExpiriesRef on AutoDisposeStreamProviderRef<List<Subscription>> {
  /// The parameter `days` of this provider.
  int get days;
}

class _UpcomingExpiriesProviderElement
    extends AutoDisposeStreamProviderElement<List<Subscription>>
    with UpcomingExpiriesRef {
  _UpcomingExpiriesProviderElement(super.provider);

  @override
  int get days => (origin as UpcomingExpiriesProvider).days;
}

String _$expiringTodayHash() => r'38b34fed3c336daa5dd8578c0e1b7a97bef80904';

/// See also [expiringToday].
@ProviderFor(expiringToday)
final expiringTodayProvider =
    AutoDisposeStreamProvider<List<Subscription>>.internal(
  expiringToday,
  name: r'expiringTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expiringTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExpiringTodayRef = AutoDisposeStreamProviderRef<List<Subscription>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
