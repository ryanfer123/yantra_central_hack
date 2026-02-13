// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../models/simulation_service.dart';
import '../widgets/glass_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      body: SafeArea(
        child: ValueListenableBuilder<BatteryData>(
          valueListenable: SimulationService.instance.data,
          builder: (context, data, _) {
            return RefreshIndicator(
              onRefresh: () async {
                SimulationService.instance.refresh();
                await Future.delayed(const Duration(milliseconds: 400));
              },
              color: AppTheme.primaryBlue,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        _buildHeroCard(context, data),
                        const SizedBox(height: 16),
                        _buildDriveModeCard(context),
                        const SizedBox(height: 16),
                        _buildLiveTilesRow(context, data),
                        const SizedBox(height: 16),
                        _buildRangeCard(context, data),
                        const SizedBox(height: 16),
                        _buildQuickActions(context, data),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: AppTheme.scaffoldBg(context),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryC(context),
                letterSpacing: -0.8,
              )),
          Text(' · Online',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.successGreen,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
      actions: [
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined,
                  color: AppTheme.textPrimaryC(context), size: 24),
              Positioned(
                top: -2, right: -2,
                child: Container(
                  width: 8, height: 8,
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
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
            child: const Text('CT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, BatteryData data) {
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
                    const Text('State of Charge',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                        )),
                    const SizedBox(height: 4),
                    const Text('Your EV',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        )),
                    const SizedBox(height: 12),
                    _buildChargingStatus(data),
                  ],
                ),
              ),
              CircularGauge(
                value: data.stateOfCharge,
                size: 120,
                arcColor: data.stateOfCharge > 60
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroStat('Pack Voltage', '${data.packVoltage} V',
                  Icons.bolt_rounded),
              const SizedBox(width: 12),
              _buildHeroStat('Pack Current', '${data.packCurrent.abs()} A',
                  Icons.electrical_services_rounded),
              const SizedBox(width: 12),
              _buildHeroStat('Temp', '${data.packTemp}°C',
                  Icons.thermostat_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargingStatus(BatteryData data) {
    if (data.isCharging) {
      return StatusPill(
        label: 'Charging · ${data.chargeRate} kW',
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
            Text(value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                )),
            Text(label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDriveModeCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionHeader(title: 'DRIVE MODE'),
        SizedBox(height: 8),
        DriveModeSelector(),
      ],
    );
  }

  Widget _buildLiveTilesRow(BuildContext context, BatteryData data) {
    final powerPositive = data.packPower >= 0;
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
                value: data.packPower.abs().toStringAsFixed(1),
                unit: 'kW',
                icon: Icons.bolt_rounded,
                iconColor: powerPositive
                    ? AppTheme.successGreen
                    : AppTheme.dangerRed,
                valueColor: powerPositive
                    ? AppTheme.successGreen
                    : AppTheme.dangerRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'State of Power',
                value: data.stateOfPower,
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
                value: data.regenEnergy.toStringAsFixed(1),
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
                value: '${data.ambientTemp}',
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

  Widget _buildRangeCard(BuildContext context, BatteryData data) {
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedNumber(
                          value: data.projectedRange,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimaryC(context),
                            letterSpacing: -2,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(' km',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondaryC(context),
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Based on current driving pattern',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryC(context),
                        )),
                    const SizedBox(height: 14),
                    AppProgressBar(
                      value: data.stateOfCharge / 100,
                      color: data.stateOfCharge > 60
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

  Widget _buildQuickActions(BuildContext context, BatteryData data) {
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
                        'Pre-conditioning at ${data.ambientTemp}°C ambient',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: AppTheme.primaryBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Trip started! Drive safely.',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      backgroundColor: AppTheme.successGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
