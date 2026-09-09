enum BillingPeriod { monthly, yearly, weekly, quarterly }

class Subscription {
  final String id;
  final String name;
  final double price;
  final String currency;
  final BillingPeriod billingPeriod;
  final DateTime nextBillingDate;
  final String category;
  final bool reminderEnabled;
  final String? iconUrl;

  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    this.currency = 'USD',
    required this.billingPeriod,
    required this.nextBillingDate,
    required this.category,
    this.reminderEnabled = true,
    this.iconUrl,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      billingPeriod: BillingPeriod.values.firstWhere(
        (e) => e.name == json['billing_period'],
        orElse: () => BillingPeriod.monthly,
      ),
      nextBillingDate: DateTime.parse(json['next_billing_date'] as String),
      category: json['category'] as String? ?? 'General',
      reminderEnabled: json['reminder_enabled'] as bool? ?? true,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'billing_period': billingPeriod.name,
      'next_billing_date': nextBillingDate.toIso8601String(),
      'category': category,
      'reminder_enabled': reminderEnabled,
      'icon_url': iconUrl,
    };
  }
}
