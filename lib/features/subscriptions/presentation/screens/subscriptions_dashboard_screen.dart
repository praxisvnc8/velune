import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';
import 'add_subscription_screen.dart';

class SubscriptionsDashboardScreen extends ConsumerWidget {
  const SubscriptionsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsState = ref.watch(subscriptionsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VELUNE'),
      ),
      body: subscriptionsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading subscriptions: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (subscriptions) {
          final totalMonthly = subscriptions.fold<double>(
            0.0,
            (sum, item) => sum + item.price,
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceVariant,
                          AppColors.card,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL MONTHLY OUTLAY',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 2.0,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '\$${totalMonthly.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppColors.accentGold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${subscriptions.length} active recurring subscriptions',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'ACTIVE SUBSCRIPTIONS',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sub = subscriptions[index];
                      return SubscriptionCard(subscription: sub);
                    },
                    childCount: subscriptions.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
          );
        },
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text(
          'NEW SUBSCRIPTION',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ),
    );
  }
}
