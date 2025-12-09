import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/data/models/subscription.dart';
import 'package:remindlyf/data/models/subscription_category.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';

part 'subscription_provider.g.dart';

// Stream all subscription categories
@riverpod
Stream<List<SubscriptionCategory>> subscriptionCategories(
  SubscriptionCategoriesRef ref,
) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchCategories();
}

// Stream all subscriptions
@riverpod
Stream<List<Subscription>> subscriptions(SubscriptionsRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);
  yield* repository.watchSubscriptions();
}

// Get subscriptions grouped by category
@riverpod
Stream<Map<SubscriptionCategory, List<Subscription>>> subscriptionsByCategory(
  SubscriptionsByCategoryRef ref,
) async* {
  final repository = ref.watch(taskRepositoryProvider);

  // Watch both categories and subscriptions
  await for (final subscriptions in repository.watchSubscriptions()) {
    final categories = await repository.getAllCategories();
    final Map<SubscriptionCategory, List<Subscription>> grouped = {};

    // Initialize all categories with empty lists
    for (final category in categories) {
      grouped[category] = [];
    }

    // Group subscriptions by category
    for (final subscription in subscriptions) {
      final category = categories.firstWhere(
        (c) => c.id == subscription.categoryId,
        orElse: () => SubscriptionCategory()
          ..id = 0
          ..name = 'Uncategorized'
          ..colorValue = 0xFF9E9E9E,
      );

      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(subscription);
    }

    yield grouped;
  }
}

// Get subscriptions expiring within N days (default 7)
@riverpod
Stream<List<Subscription>> upcomingExpiries(
  UpcomingExpiriesRef ref, {
  int days = 7,
}) async* {
  final repository = ref.watch(taskRepositoryProvider);

  await for (final subscriptions in repository.watchSubscriptions()) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: days));

    final upcoming = subscriptions.where((s) {
      if (!s.isActive) return false;
      final expiry = DateTime(
        s.expiryDate.year,
        s.expiryDate.month,
        s.expiryDate.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      return expiry.isAfter(today.subtract(const Duration(days: 1))) &&
          expiry.isBefore(cutoff);
    }).toList();

    // Sort by expiry date (soonest first)
    upcoming.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    yield upcoming;
  }
}

// Get subscriptions expiring today
@riverpod
Stream<List<Subscription>> expiringToday(ExpiringTodayRef ref) async* {
  final repository = ref.watch(taskRepositoryProvider);

  await for (final subscriptions in repository.watchSubscriptions()) {
    final now = DateTime.now();

    final expiringToday = subscriptions.where((s) {
      if (!s.isActive) return false;
      return s.expiryDate.year == now.year &&
          s.expiryDate.month == now.month &&
          s.expiryDate.day == now.day;
    }).toList();

    yield expiringToday;
  }
}
