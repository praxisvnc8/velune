import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PREFERENCES'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_none, color: AppColors.accentGold),
            title: const Text('Notifications & Reminders'),
            subtitle: const Text('Configure upcoming payment alerts'),
            onTap: () {},
          ),
          const Divider(color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.currency_exchange, color: AppColors.accentGold),
            title: const Text('Base Currency'),
            subtitle: const Text('USD (\$)'),
            onTap: () {},
          ),
          const Divider(color: AppColors.divider),
          ListTile(
            leading: const Icon(Icons.cloud_outlined, color: AppColors.accentGold),
            title: const Text('Supabase Sync'),
            subtitle: const Text('Cloud backup status'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
