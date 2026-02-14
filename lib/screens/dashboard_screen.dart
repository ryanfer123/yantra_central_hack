// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../widgets/glass_widgets.dart';
import 'role_selection_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildHeroCard(),
                  const SizedBox(height: 16),

                  // 🔥 DRIVE MODE REMOVED

                  _buildLiveTilesRow(),
                  const SizedBox(height: 16),
                  _buildRangeCard(),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          Text(
            ' · Online',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.successGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppTheme.textPrimary,
                size: 24,
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.dangerRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
                  (route) => false,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.swap_horiz_rounded,
                    color: AppTheme.primaryBlue, size: 14),
                SizedBox(width: 5),
                Text(
                  'Switch Role',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return DarkCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'State of Charge',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your EV',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildChargingStatus(),
                  ],
                ),
              ),
              CircularGauge(
                value: BatteryData.stateOfCharge,
                size: 120,
                arcColor: BatteryData.stateOfCharge > 60
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroStat(
                  'Pack Voltage', '${BatteryData.packVoltage} V', Icons.bolt_rounded),
              const SizedBox(width: 12),
              _buildHeroStat('Pack Current', '${BatteryData.packCurrent.abs()} A',
                  Icons.electrical_services_rounded),
              const SizedBox(width: 12),
              _buildHeroStat('Temp', '${BatteryData.packTemp}°C',
                  Icons.thermostat_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargingStatus() {
    if (BatteryData.isCharging) {
      return StatusPill(
        label: 'Charging • ${BatteryData.chargeRate} kW',
        color: AppTheme.successGreen,
        icon: Icons.bolt_rounded,
      );
    }
    return const StatusPill(
      label: 'Discharging',
      color: Colors.white70,
      icon: Icons.battery_6_bar_rounded,
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white54, size: 14),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white38,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🚗 DRIVE MODE REMOVED → This function was deleted

  Widget _buildLiveTilesRow() {
    final powerPositive = BatteryData.packPower >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'LIVE STATUS'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Current Power',
                value: BatteryData.packPower.abs().toStringAsFixed(1),
                unit: 'kW',
                icon: Icons.bolt_rounded,
                iconColor:
                powerPositive ? AppTheme.successGreen : AppTheme.dangerRed,
                valueColor:
                powerPositive ? AppTheme.successGreen : AppTheme.dangerRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'State of Power',
                value: BatteryData.stateOfPower,
                unit: '',
                icon: Icons.verified_rounded,
                iconColor: AppTheme.successGreen,
                valueColor: AppTheme.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Regen Energy',
                value: BatteryData.regenEnergy.toStringAsFixed(1),
                unit: 'kWh',
                icon: Icons.recycling_rounded,
                iconColor: AppTheme.regenGreen,
                valueColor: AppTheme.regenGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Ambient Temp',
                value: '${BatteryData.ambientTemp}',
                unit: '°C',
                icon: Icons.device_thermostat_rounded,
                iconColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PROJECTED RANGE'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: '${BatteryData.projectedRange.toInt()}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -2,
                            height: 1,
                          ),
                        ),
                        const TextSpan(
                          text: ' km',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Based on current driving pattern',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppProgressBar(
                      value: BatteryData.stateOfCharge / 100,
                      color: BatteryData.stateOfCharge > 60
                          ? AppTheme.successGreen
                          : AppTheme.warningAmber,
                      height: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.15),
                      AppTheme.primaryBlue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.navigation_rounded,
                  color: AppTheme.primaryBlue,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'QUICK ACTIONS'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppActionButton(
                label: 'Pre-condition',
                icon: Icons.ac_unit_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pre-conditioning at ${BatteryData.ambientTemp}°C ambient',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: AppTheme.primaryBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppActionButton(
                label: 'Start Trip',
                icon: Icons.play_arrow_rounded,
                isPrimary: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Trip started! Drive safely.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: AppTheme.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
