class Subscription {
  final String id;
  final String? userId;
  final String name;
  final double amount;
  final String currency;
  final String billingFrequency;
  final DateTime nextPaymentDate;
  final String category;
  final String? notes;
  final bool isActive;

  const Subscription({
    required this.id,
    this.userId,
    required this.name,
    required this.amount,
    this.currency = 'USD',
    required this.billingFrequency,
    required this.nextPaymentDate,
    required this.category,
    this.notes,
    this.isActive = true,
  });

  // Convenience getters for UI components
  double get price => amount;
  DateTime get nextBillingDate => nextPaymentDate;

  /// Calculated estimated monthly cost for this specific subscription
  double get estimatedMonthlyAmount {
    switch (billingFrequency.toLowerCase()) {
      case 'weekly':
        return amount * 52 / 12;
      case 'quarterly':
        return amount / 3;
      case 'yearly':
      case 'annually':
        return amount / 12;
      case 'monthly':
      default:
        return amount;
    }
  }

  /// Calculated estimated yearly cost for this specific subscription
  double get estimatedYearlyAmount => estimatedMonthlyAmount * 12;

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? currency,
    String? billingFrequency,
    DateTime? nextPaymentDate,
    String? category,
    String? notes,
    bool? isActive,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingFrequency: billingFrequency ?? this.billingFrequency,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      currency: json['currency'] as String? ?? 'USD',
      billingFrequency: json['billing_frequency'] as String? ??
          json['billing_period'] as String? ??
          'monthly',
      nextPaymentDate: json['next_payment_date'] != null
          ? DateTime.parse(json['next_payment_date'] as String)
          : (json['next_billing_date'] != null
              ? DateTime.parse(json['next_billing_date'] as String)
              : DateTime.now()),
      category: json['category'] as String? ?? 'General',
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ??
          (json['is_paused'] != null ? !(json['is_paused'] as bool) : true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'amount': amount,
      'currency': currency,
      'billing_frequency': billingFrequency,
      'next_payment_date': nextPaymentDate.toIso8601String(),
      'category': category,
      if (notes != null) 'notes': notes,
      'is_active': isActive,
    };
  }
}
