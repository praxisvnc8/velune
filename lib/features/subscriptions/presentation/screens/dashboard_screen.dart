import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';
import 'add_subscription_screen.dart';

/// VELUNE Dashboard Screen: A calm, spacious, and minimalist overview of recurring commitments.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsState = ref.watch(subscriptionsNotifierProvider);
    final totalMonthly = ref.watch(totalMonthlySpendingProvider);
    final totalYearly = ref.watch(totalYearlySpendingProvider);
    final activeCount = ref.watch(activeSubscriptionCountProvider);
    final upcomingPayments = ref.watch(upcomingPaymentsProvider);

    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'VELUNE',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
            const SizedBox(height: 2),
            Text(
              'Your money, at peace.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 70,
      ),
      body: subscriptionsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: AppTheme.edgeInsetsScreen,
            child: Text(
              'Unable to retrieve commitments: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (_) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Metrics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppTheme.edgeInsetsScreen,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: AppTheme.edgeInsetsCard,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.surfaceElevated,
                            AppColors.card,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppTheme.borderRadiusXLarge,
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MONTHLY OUTLAY',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                      letterSpacing: 2.0,
                                      fontSize: 12,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: AppTheme.borderRadiusCircular,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  '$activeCount ACTIVE',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: AppColors.accentGold,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormatter.format(totalMonthly),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppColors.accentGold,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MetricItem(
                                label: 'ANNUAL PROJECTION',
                                value: currencyFormatter.format(totalYearly),
                              ),
                              _MetricItem(
                                label: 'ACTIVE SUBSCRIPTIONS',
                                value: '$activeCount Commitments',
                                crossAxisAlignment: CrossAxisAlignment.end,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Upcoming Payments Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UPCOMING PAYMENTS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.8,
                              fontSize: 12,
                            ),
                      ),
                      Text(
                        'Next ${upcomingPayments.length > 4 ? 4 : upcomingPayments.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Upcoming Payments List or Empty State
              if (upcomingPayments.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: AppTheme.edgeInsetsScreen,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppTheme.borderRadiusLarge,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          size: 48,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Active Commitments',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your subscriptions to experience calm, organized financial tracking.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final subscription = upcomingPayments[index];
                        return Hero(
                          tag: 'sub_${subscription.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: SubscriptionCard(
                              subscription: subscription,
                              onTap: () {
                                // Detailed view navigation placeholder
                              },
                            ),
                          ),
                        );
                      },
                      childCount: upcomingPayments.length > 4 ? 4 : upcomingPayments.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),

      // Add Subscription Floating Action Button
      floatingActionButton: Hero(
        tag: 'add_subscription_fab',
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AddSubscriptionScreen(),
              ),
            );
          },
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.background,
          elevation: 4,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'NEW SUBSCRIPTION',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _MetricItem({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
