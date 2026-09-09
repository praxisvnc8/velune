import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_model.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SupabaseSubscriptionRepository(Supabase.instance.client);
});

final subscriptionsListProvider =
    AsyncNotifierProvider<SubscriptionListNotifier, List<Subscription>>(() {
  return SubscriptionListNotifier();
});

class SubscriptionListNotifier extends AsyncNotifier<List<Subscription>> {
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

  Future<void> loadSubscriptions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchSubscriptions());
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
