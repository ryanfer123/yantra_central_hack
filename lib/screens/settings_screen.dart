// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: AppTheme.backgroundLight,
              elevation: 0,
              title: const Text('Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.8,
                  )),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildVehicleSection(context),
                  const SizedBox(height: 16),
                  _buildPreferencesSection(context),
                  const SizedBox(height: 16),
                  _buildAboutSection(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'VEHICLE'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _buildSettingsRow(
                  'Vehicle Name', 'Cyber Truck', Icons.directions_car_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsRow('VIN', '5YJ3E1EA1NF000001',
                  Icons.credit_card_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsRow(
                  'Firmware', 'v2024.44.30.6', Icons.system_update_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PREFERENCES'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _buildSettingsRow(
                  'Units', 'Metric (km, °C)', Icons.straighten_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsRow(
                  'Notifications', 'All Enabled', Icons.notifications_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsRow('Refresh Rate', '5 seconds', Icons.refresh_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsToggleRow(context, 'Dark Mode', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ABOUT'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _buildSettingsRow(
                  'App Version', '1.0.0', Icons.info_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsRow(
                  'Build', 'Production', Icons.build_rounded),
              const Divider(height: 1, indent: 56, color: AppTheme.divider),
              _buildSettingsRow(
                  'License', 'Proprietary', Icons.gavel_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Text(value,
              style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary,
              )),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textTertiary, size: 18),
        ],
      ),
    );
  }

  Widget _buildSettingsToggleRow(
      BuildContext context, String label, bool value) {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dark_mode_rounded,
                  color: AppTheme.primaryBlue, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  )),
            ),
            Switch(
              value: value,
              onChanged: (v) => setState(() => value = v),
              activeColor: AppTheme.primaryBlue,
            ),
          ],
        ),
      );
    });
  }
}