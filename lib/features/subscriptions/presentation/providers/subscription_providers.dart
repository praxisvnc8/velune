import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/subscription_repository.dart';
import '../../domain/subscription_model.dart';

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

  Future<void> deleteSubscription(String id) async {
    try {
      await _repository.deleteSubscription(id);
      await loadSubscriptions();
    } catch (e) {
      final current = state.value ?? [];
      state = AsyncValue.data(current.where((s) => s.id != id).toList());
    }
  }

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
