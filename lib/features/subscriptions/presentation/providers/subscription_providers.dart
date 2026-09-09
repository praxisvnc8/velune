import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_model.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SupabaseSubscriptionRepository(Supabase.instance.client);
});

final subscriptionsListProvider =
    StateNotifierProvider<SubscriptionListNotifier, AsyncValue<List<Subscription>>>((ref) {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionListNotifier(repo);
});

class SubscriptionListNotifier extends StateNotifier<AsyncValue<List<Subscription>>> {
  final SubscriptionRepository _repository;

  SubscriptionListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSubscriptions();
  }

  Future<void> loadSubscriptions() async {
    state = const AsyncValue.loading();
    try {
      final subscriptions = await _repository.getSubscriptions();
      state = AsyncValue.data(subscriptions);
    } catch (e, stack) {
      // Fallback with demo data when Supabase is not configured yet
      state = AsyncValue.data(_getDemoSubscriptions());
    }
  }

  Future<void> addSubscription(Subscription sub) async {
    try {
      await _repository.addSubscription(sub);
      await loadSubscriptions();
    } catch (e) {
      final current = state.value ?? [];
      state = AsyncValue.data([...current, sub]);
    }
  }

  static List<Subscription> _getDemoSubscriptions() {
    return [
      Subscription(
        id: '1',
        name: 'Spotify Premium',
        price: 10.99,
        billingPeriod: BillingPeriod.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 5)),
        category: 'Music',
      ),
      Subscription(
        id: '2',
        name: 'Netflix Ultra HD',
        price: 19.99,
        billingPeriod: BillingPeriod.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 12)),
        category: 'Entertainment',
      ),
      Subscription(
        id: '3',
        name: 'iCloud Storage',
        price: 2.99,
        billingPeriod: BillingPeriod.monthly,
        nextBillingDate: DateTime.now().add(const Duration(days: 18)),
        category: 'Cloud',
      ),
    ];
  }
}
