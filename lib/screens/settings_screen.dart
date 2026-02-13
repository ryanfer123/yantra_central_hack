// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../models/simulation_service.dart';
import '../widgets/glass_widgets.dart';
import '../main.dart' show themeNotifier;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              backgroundColor: AppTheme.scaffoldBg(context),
              elevation: 0,
              title: Text('Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryC(context),
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
                  _buildDataSection(context),
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
              _buildSettingsRow(context, 'Vehicle Name', 'Cyber Truck',
                  Icons.directions_car_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildSettingsRow(context, 'VIN', '5YJ3E1EA1NF000001',
                  Icons.credit_card_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildSettingsRow(context, 'Firmware', 'v2024.44.30.6',
                  Icons.system_update_rounded),
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
              _buildSettingsRow(context, 'Units', 'Metric (km, °C)',
                  Icons.straighten_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildSettingsRow(context, 'Notifications', 'All Enabled',
                  Icons.notifications_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildSettingsRow(context, 'Refresh Rate', '2 seconds',
                  Icons.refresh_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildDarkModeToggle(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DATA'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _buildActionRow(
                context,
                'Refresh Sensor Data',
                'Trigger manual refresh',
                Icons.sensors_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  SimulationService.instance.refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sensor data refreshed'),
                      backgroundColor: AppTheme.cardColor(context),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
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
                  context, 'App Version', '1.0.0', Icons.info_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildSettingsRow(
                  context, 'Build', 'Production', Icons.build_rounded),
              Divider(
                  height: 1, indent: 56, color: AppTheme.dividerC(context)),
              _buildSettingsRow(
                  context, 'License', 'Proprietary', Icons.gavel_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryC(context),
                  fontWeight: FontWeight.w500,
                )),
          ),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryC(context),
              )),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded,
              color: AppTheme.textTertiaryC(context), size: 18),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dark_mode_rounded,
                    color: AppTheme.primaryBlue, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Dark Mode',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimaryC(context),
                      fontWeight: FontWeight.w500,
                    )),
              ),
              Switch(
                value: themeNotifier.isDark,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  themeNotifier.toggle();
                },
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    String label,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimaryC(context),
                        fontWeight: FontWeight.w500,
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textTertiaryC(context),
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textTertiaryC(context), size: 18),
          ],
        ),
      ),
    );
  }
}
