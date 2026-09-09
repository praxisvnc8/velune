import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_model.dart';

/// Notifier managing active subscriptions list with optimistic UI updates.
class SubscriptionsNotifier extends AsyncNotifier<List<Subscription>> {
  late final SubscriptionRepository _repository;

  @override
  Future<List<Subscription>> build() async {
    _repository = ref.watch(subscriptionRepositoryProvider);
    return _fetchSubscriptions();
  }

  Future<List<Subscription>> _fetchSubscriptions() async {
    try {
      return await _repository.getSubscriptions();
    } catch (e) {
      // Fallback with demo data when Supabase is not configured yet
      return _getDemoSubscriptions();
    }
  }

  /// Adds a subscription with optimistic UI update
  Future<void> add(Subscription sub) async {
    final previousState = state;
    final currentList = state.value ?? [];

    // Optimistic update
    state = AsyncValue.data([...currentList, sub]);

    try {
      await _repository.addSubscription(sub);
    } catch (e) {
      // Revert on error
      state = previousState;
      rethrow;
    }
  }

  /// Alias for add
  Future<void> addSubscription(Subscription sub) => add(sub);

  /// Updates a subscription with optimistic UI update
  Future<void> update(Subscription sub) async {
    final previousState = state;
    final currentList = state.value ?? [];

    // Optimistic update
    state = AsyncValue.data(
      currentList.map((item) => item.id == sub.id ? sub : item).toList(),
    );

    try {
      await _repository.updateSubscription(sub);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  /// Alias for update
  Future<void> updateSubscription(Subscription sub) => update(sub);

  /// Removes a subscription with optimistic UI update
  Future<void> remove(String id) async {
    final previousState = state;
    final currentList = state.value ?? [];

    // Optimistic update
    state = AsyncValue.data(
      currentList.where((item) => item.id != id).toList(),
    );

    try {
      await _repository.deleteSubscription(id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  /// Alias for remove
  Future<void> deleteSubscription(String id) => remove(id);

  static List<Subscription> _getDemoSubscriptions() {
    return [
      Subscription(
        id: '1',
        name: 'Spotify Premium',
        amount: 10.99,
        billingFrequency: 'monthly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 5)),
        category: 'Music',
        notes: 'Family plan',
      ),
      Subscription(
        id: '2',
        name: 'Netflix Ultra HD',
        amount: 19.99,
        billingFrequency: 'monthly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 12)),
        category: 'Entertainment',
      ),
      Subscription(
        id: '3',
        name: 'iCloud Storage',
        amount: 2.99,
        billingFrequency: 'monthly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 18)),
        category: 'Cloud',
      ),
    ];
  }
}

/// Provider for the SubscriptionsNotifier
final subscriptionsNotifierProvider =
    AsyncNotifierProvider<SubscriptionsNotifier, List<Subscription>>(() {
  return SubscriptionsNotifier();
});

/// Alias provider for dashboard list consumption
final subscriptionsListProvider = subscriptionsNotifierProvider;

// -----------------------------------------------------------------------------
// DERIVED METRIC PROVIDERS
// -----------------------------------------------------------------------------

/// Calculates total monthly spending based on billing frequency
final totalMonthlySpendingProvider = Provider<double>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionsNotifierProvider);

  return subscriptionsAsync.maybeWhen(
    data: (subscriptions) {
      return subscriptions.fold<double>(0.0, (total, sub) {
        switch (sub.billingFrequency.toLowerCase()) {
          case 'weekly':
            return total + (sub.amount * 52 / 12);
          case 'quarterly':
            return total + (sub.amount / 3);
          case 'yearly':
          case 'annually':
            return total + (sub.amount / 12);
          case 'monthly':
          default:
            return total + sub.amount;
        }
      });
    },
    orElse: () => 0.0,
  );
});

/// Calculates projected total yearly spending
final totalYearlySpendingProvider = Provider<double>((ref) {
  final monthlyTotal = ref.watch(totalMonthlySpendingProvider);
  return monthlyTotal * 12;
});

/// Total active subscription count
final activeSubscriptionCountProvider = Provider<int>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionsNotifierProvider);

  return subscriptionsAsync.maybeWhen(
    data: (subscriptions) => subscriptions.length,
    orElse: () => 0,
  );
});

/// Subscriptions sorted by nearest next_payment_date
final upcomingPaymentsProvider = Provider<List<Subscription>>((ref) {
  final subscriptionsAsync = ref.watch(subscriptionsNotifierProvider);

  return subscriptionsAsync.maybeWhen(
    data: (subscriptions) {
      final sortedList = List<Subscription>.from(subscriptions);
      sortedList.sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));
      return sortedList;
    },
    orElse: () => [],
  );
});
