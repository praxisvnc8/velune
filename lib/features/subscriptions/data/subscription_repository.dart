import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getSubscriptions();
  Future<void> addSubscription(Subscription subscription);
  Future<void> updateSubscription(Subscription subscription);
  Future<void> deleteSubscription(String id);
}

class SupabaseSubscriptionRepository implements SubscriptionRepository {
  final SupabaseClient _client;

  SupabaseSubscriptionRepository(this._client);

  @override
  Future<List<Subscription>> getSubscriptions() async {
    final response = await _client.from('subscriptions').select();
    return (response as List)
        .map((e) => Subscription.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addSubscription(Subscription subscription) async {
    await _client.from('subscriptions').insert(subscription.toJson());
  }

  @override
  Future<void> updateSubscription(Subscription subscription) async {
    await _client
        .from('subscriptions')
        .update(subscription.toJson())
        .eq('id', subscription.id);
  }

  @override
  Future<void> deleteSubscription(String id) async {
    await _client.from('subscriptions').delete().eq('id', id);
  }
}

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SupabaseSubscriptionRepository(Supabase.instance.client);
});
