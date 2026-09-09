import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/subscription_model.dart';
import '../providers/subscription_providers.dart';

/// AddSubscriptionScreen: A sleek, minimal screen for creating new subscription commitments.
class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _currency = '₹';
  String _billingFrequency = 'monthly';
  String _category = 'General';
  DateTime _nextPaymentDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  final List<String> _currencies = ['₹', '\$', '€', '£'];
  final List<Map<String, String>> _frequencies = [
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'quarterly', 'label': 'Quarterly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  final List<String> _categories = [
    'General',
    'Entertainment',
    'Productivity',
    'Utilities',
    'Cloud',
    'Music',
    'Finance',
    'Health',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectNextPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accentGold,
              onPrimary: AppColors.background,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surfaceElevated,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _nextPaymentDate) {
      setState(() {
        _nextPaymentDate = picked;
      });
    }
  }

  Future<void> _saveSubscription() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final subscription = Subscription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        currency: _currency,
        billingFrequency: _billingFrequency,
        nextPaymentDate: _nextPaymentDate,
        category: _category,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      try {
        await ref
            .read(subscriptionsNotifierProvider.notifier)
            .add(subscription);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add commitment: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'NEW COMMITMENT',
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              children: [
                // Service Name Input
                _buildSectionLabel(context, 'SERVICE NAME'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Spotify, Netflix, iCloud',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a service name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Amount & Currency Inputs
                _buildSectionLabel(context, 'AMOUNT & CURRENCY'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Currency Dropdown
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppTheme.borderRadiusMedium,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currency,
                          isExpanded: true,
                          alignment: Alignment.center,
                          dropdownColor: AppColors.surfaceElevated,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          items: _currencies.map((curr) {
                            return DropdownMenuItem<String>(
                              value: curr,
                              child: Center(
                                child: Text(
                                  curr,
                                  style: const TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _currency = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Amount Text Field
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '$_currency ',
                          prefixStyle: const TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Billing Frequency
                _buildSectionLabel(context, 'BILLING FREQUENCY'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _billingFrequency,
                  decoration: const InputDecoration(),
                  dropdownColor: AppColors.surfaceElevated,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                  items: _frequencies.map((freq) {
                    return DropdownMenuItem<String>(
                      value: freq['value'],
                      child: Text(
                        freq['label']!,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _billingFrequency = val);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Next Payment Date
                _buildSectionLabel(context, 'NEXT PAYMENT DATE'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectNextPaymentDate(context),
                  borderRadius: AppTheme.borderRadiusMedium,
                  child: Container(
                    padding: AppTheme.edgeInsetsButton,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppTheme.borderRadiusMedium,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateFormat.format(_nextPaymentDate),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.accentGold,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Selection
                _buildSectionLabel(context, 'CATEGORY'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(),
                  dropdownColor: AppColors.surfaceElevated,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(
                        cat,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _category = val);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Optional Notes
                _buildSectionLabel(context, 'NOTES (OPTIONAL)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Account details, plan type, cancellation rules...',
                  ),
                ),
                const SizedBox(height: 36),

                // Save Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadiusMedium,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : Text(
                            'CONFIRM COMMITMENT',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
    );
  }
}
