import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';
import 'add_subscription_screen.dart';
import 'subscription_detail_screen.dart';

/// SubscriptionListScreen: A clean, elegant list displaying all user subscriptions.
class SubscriptionListScreen extends ConsumerStatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  ConsumerState<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends ConsumerState<SubscriptionListScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SUBSCRIPTIONS',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: AppTheme.edgeInsetsScreen,
            child: Text(
              'Error loading commitments: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (subscriptions) {
          final categories = ['All', ...{...subscriptions.map((s) => s.category)}];

          final filteredSubscriptions = _selectedCategory == 'All'
              ? subscriptions
              : subscriptions.where((s) => s.category == _selectedCategory).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Category Filter Horizontal List
              if (categories.length > 2)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat == _selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedCategory = cat);
                            },
                            backgroundColor: AppColors.surface,
                            selectedColor: AppColors.accentGold,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.background : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.borderRadiusCircular,
                              side: BorderSide(
                                color: isSelected ? AppColors.accentGold : AppColors.border,
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Empty State
              if (filteredSubscriptions.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppTheme.borderRadiusLarge,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Subscriptions Found',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory == 'All'
                              ? 'Tap + to track your first recurring payment.'
                              : 'No commitments found in "$_selectedCategory".',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: AppTheme.edgeInsetsScreen,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subscription = filteredSubscriptions[index];

                        return Hero(
                          tag: 'sub_${subscription.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: SubscriptionCard(
                              subscription: subscription,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SubscriptionDetailScreen(
                                      subscription: subscription,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      childCount: filteredSubscriptions.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddSubscriptionScreen(),
            ),
          );
        },
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'NEW SUBSCRIPTION',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.background,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
        ),
      ),
    );
  }
}
