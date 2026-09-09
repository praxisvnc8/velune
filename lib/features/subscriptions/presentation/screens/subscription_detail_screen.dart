import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/subscription_model.dart';
import '../providers/subscription_providers.dart';

/// SubscriptionDetailScreen: A spacious, elegant view displaying full subscription details and actions.
class SubscriptionDetailScreen extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscription,
  });

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.borderRadiusLarge,
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REMOVE COMMITMENT',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 1.5,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to remove "${subscription.name}" from VELUNE? This action cannot be undone.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(dialogContext).pop(); // Close dialog

                        try {
                          await ref
                              .read(subscriptionsNotifierProvider.notifier)
                              .remove(subscription.id);

                          if (context.mounted) {
                            Navigator.of(context).pop(); // Exit detail screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${subscription.name}" removed'),
                                backgroundColor: AppColors.surfaceElevated,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _togglePauseStatus(BuildContext context, WidgetRef ref) async {
    final updatedSubscription = subscription.copyWith(
      isActive: !subscription.isActive,
    );

    try {
      await ref
          .read(subscriptionsNotifierProvider.notifier)
          .update(updatedSubscription);

      if (context.mounted) {
        final message = updatedSubscription.isActive
            ? '"${subscription.name}" resumed'
            : '"${subscription.name}" paused';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final currencySymbol = subscription.currency;
    final formattedMonthly =
        '$currencySymbol${subscription.estimatedMonthlyAmount.toStringAsFixed(2)}';
    final formattedYearly =
        '$currencySymbol${subscription.estimatedYearlyAmount.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          subscription.name.toUpperCase(),
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: 20,
              ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Remove',
            onPressed: () => _showDeleteConfirmationDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: AppTheme.edgeInsetsScreen,
          child: Hero(
            tag: 'sub_${subscription.id}',
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Hero Avatar & Status Banner
                  Container(
                    padding: AppTheme.edgeInsetsCard,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppTheme.borderRadiusXLarge,
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Center(
                                child: Text(
                                  subscription.name.isNotEmpty
                                      ? subscription.name[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subscription.name,
                                    style: Theme.of(context).textTheme.displaySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: subscription.isActive
                                          ? AppColors.surfaceVariant
                                          : AppColors.surface,
                                      borderRadius: AppTheme.borderRadiusCircular,
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      subscription.isActive ? 'ACTIVE' : 'PAUSED',
                                      style: TextStyle(
                                        color: subscription.isActive
                                            ? AppColors.accentGold
                                            : AppColors.textMuted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 20),

                        // Amount & Frequency Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'DIRECT COST',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$currencySymbol${subscription.amount.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        color: AppColors.accentGold,
                                      ),
                                ),
                                Text(
                                  ' / ${subscription.billingFrequency}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calculated Financial Impact Card
                  Text(
                    'CALCULATED IMPACT',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.8,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: AppTheme.edgeInsetsCard,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppTheme.borderRadiusLarge,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ImpactTile(
                            label: 'ESTIMATED MONTHLY',
                            value: formattedMonthly,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.divider,
                        ),
                        Expanded(
                          child: _ImpactTile(
                            label: 'ESTIMATED YEARLY',
                            value: formattedYearly,
                            alignment: CrossAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details Grid
                  Text(
                    'COMMITMENT DETAILS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.8,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: AppTheme.edgeInsetsCard,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppTheme.borderRadiusLarge,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Next Payment Date',
                          value: dateFormat.format(subscription.nextPaymentDate),
                        ),
                        const Divider(color: AppColors.divider, height: 24),
                        _DetailRow(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: subscription.category,
                        ),
                        const Divider(color: AppColors.divider, height: 24),
                        _DetailRow(
                          icon: Icons.repeat,
                          label: 'Billing Cycle',
                          value: subscription.billingFrequency.toUpperCase(),
                        ),
                        if (subscription.notes != null &&
                            subscription.notes!.isNotEmpty) ...[
                          const Divider(color: AppColors.divider, height: 24),
                          _DetailRow(
                            icon: Icons.notes_outlined,
                            label: 'Notes',
                            value: subscription.notes!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Actions Row (Pause/Resume & Delete)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _togglePauseStatus(context, ref),
                          icon: Icon(
                            subscription.isActive
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 18,
                          ),
                          label: Text(
                            subscription.isActive ? 'PAUSE' : 'RESUME',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.textPrimary,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(context, ref),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('DELETE'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  const _ImpactTile({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accentGold),
        const SizedBox(width: 16),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
