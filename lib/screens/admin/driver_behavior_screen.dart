// lib/screens/admin/driver_behavior_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/admin_theme.dart';
import '../../../models/fleet_data.dart';
import '../../../widgets/admin_widgets.dart';

class DriverBehaviorScreen extends StatelessWidget {
  const DriverBehaviorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildKeyStats(),
                  const SizedBox(height: 16),
                  _buildLeadFootLeaderboard(),
                  const SizedBox(height: 16),
                  _buildRegenReport(),
                  const SizedBox(height: 16),
                  _buildWarrantyVoidCard(context),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: false, floating: true,
      backgroundColor: AdminTheme.bg, elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Driver Behavior',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AdminTheme.textPrimary, letterSpacing: -0.4,
              )),
          Text('Risk Management & Liability',
              style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildKeyStats() {
    final avgScore = FleetData.driverRecords
        .map((d) => d.score)
        .reduce((a, b) => a + b) /
        FleetData.driverRecords.length;

    final aggressiveCount =
        FleetData.driverRecords.where((d) => d.throttleGradient > 0.6).length;

    return Row(
      children: [
        Expanded(child: AdminStatTile(
          label: 'Avg Driver Score', value: avgScore.toStringAsFixed(0),
          unit: '/100', icon: Icons.speed_rounded,
          color: avgScore > 75 ? AdminTheme.green : AdminTheme.amber,
        )),
        const SizedBox(width: 10),
        Expanded(child: AdminStatTile(
          label: 'Aggressive Drivers', value: '$aggressiveCount',
          unit: 'drivers', icon: Icons.local_fire_department_rounded,
          color: AdminTheme.red, delta: 'Asset Risk',
        )),
        const SizedBox(width: 10),
        Expanded(child: AdminStatTile(
          label: 'Fleet Regen', value: FleetData.totalRegenEnergy.toStringAsFixed(1),
          unit: 'kWh', icon: Icons.recycling_rounded,
          color: AdminTheme.green,
        )),
      ],
    );
  }

  Widget _buildLeadFootLeaderboard() {
    final drivers = FleetData.driverRecords; // already sorted worst→best

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(title: '"LEAD FOOT" LEADERBOARD — WORST FIRST'),
          const SizedBox(height: 12),
          // Score bar chart
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AdminTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                          style: const TextStyle(
                            fontSize: 8, color: AdminTheme.textMuted,
                          )),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < drivers.length) {
                          final name = drivers[i].name.split(' ')[0];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(name,
                                style: const TextStyle(
                                  fontSize: 8, color: AdminTheme.textMuted,
                                )),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: drivers.asMap().entries.map((e) {
                  final score = e.value.score.toDouble();
                  final color = score < 55
                      ? AdminTheme.red
                      : score < 70
                      ? AdminTheme.amber
                      : AdminTheme.green;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: score,
                        width: 18,
                        color: color.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                      ),
                    ],
                  );
                }).toList(),
                maxY: 100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Top 5 worst drivers
          const Text('HIGH RISK DRIVERS',
              style: TextStyle(
                fontSize: 9, color: AdminTheme.textMuted,
                fontWeight: FontWeight.w700, letterSpacing: 0.8,
              )),
          const SizedBox(height: 8),
          ...drivers.take(5).map((d) => _buildDriverRow(d)),
        ],
      ),
    );
  }

  Widget _buildDriverRow(DriverRecord d) {
    final scoreColor = d.score < 55
        ? AdminTheme.red
        : d.score < 70
        ? AdminTheme.amber
        : AdminTheme.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(d.name,
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: AdminTheme.textPrimary,
                            )),
                        const SizedBox(width: 6),
                        Text(d.vehicleId,
                            style: const TextStyle(
                              fontSize: 11, color: AdminTheme.textMuted,
                            )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _miniTag('Throttle ${(d.throttleGradient * 100).toInt()}%',
                            d.throttleGradient > 0.6 ? AdminTheme.red : AdminTheme.textMuted),
                        const SizedBox(width: 6),
                        _miniTag('Brake ${(d.brakeGradient * 100).toInt()}%',
                            d.brakeGradient > 0.5 ? AdminTheme.amber : AdminTheme.textMuted),
                        const SizedBox(width: 6),
                        _miniTag('${d.trips} trips', AdminTheme.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${d.score}',
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: scoreColor, letterSpacing: -0.5,
                      )),
                  Text(
                    d.excessConsumption > 0
                        ? '+${d.excessConsumption.toStringAsFixed(1)}% usage'
                        : '${d.excessConsumption.toStringAsFixed(1)}% usage',
                    style: TextStyle(
                      fontSize: 10,
                      color: d.excessConsumption > 0 ? AdminTheme.red : AdminTheme.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          AdminProgressBar(
            value: d.score / 100,
            color: scoreColor,
            height: 4,
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: AdminTheme.border),
        ],
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
            fontSize: 9, color: color, fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget _buildRegenReport() {
    final total = FleetData.totalRegenEnergy;
    final costSaved = total * 9.5; // ₹ per kWh estimate

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(title: '"FREE FUEL" REPORT — ESG / GREEN REPORTING'),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: AdminTheme.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminTheme.green.withOpacity(0.3)),
                ),
                child: const Icon(Icons.recycling_rounded,
                    color: AdminTheme.green, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${total.toStringAsFixed(1)} kWh',
                        style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w700,
                          color: AdminTheme.green, letterSpacing: -1.5, height: 1,
                        )),
                    const Text('Regen energy captured this month',
                        style: TextStyle(
                          fontSize: 11, color: AdminTheme.textSecondary,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _regenStat('Cost Saved',
                  '₹${costSaved.toStringAsFixed(0)}', AdminTheme.green)),
              Container(width: 1, height: 40, color: AdminTheme.border),
              Expanded(child: _regenStat('CO₂ Avoided',
                  '${(total * 0.82).toStringAsFixed(1)} kg', AdminTheme.cyan)),
              Container(width: 1, height: 40, color: AdminTheme.border),
              Expanded(child: _regenStat('Best Driver',
                  'Mohan D.', AdminTheme.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _regenStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: color, letterSpacing: -0.5,
            )),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10, color: AdminTheme.textMuted,
            )),
      ],
    );
  }

  Widget _buildWarrantyVoidCard(BuildContext context) {
    final atRiskVehicles = FleetData.vehicles
        .where((v) => v.driverScore < 55 || v.gasCoLevel > 0.3)
        .toList();

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: AdminSectionHeader(title: 'WARRANTY VOID CHECK')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('${atRiskVehicles.length} At Risk',
                    style: const TextStyle(
                      color: AdminTheme.red, fontSize: 10, fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Vehicles operating outside safe thresholds risk voiding battery warranty. '
                'Flagged conditions: repeated SoP violations, chronic high-stress driving, or safety limit breaches.',
            style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 12),
          ...atRiskVehicles.map((v) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.redDim.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminTheme.red.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded,
                      color: AdminTheme.red, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${v.id} — ${v.driverName}',
                            style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: AdminTheme.textPrimary,
                            )),
                        Text(
                          v.gasCoLevel > 0.3
                              ? 'Gas venting detected — liability risk'
                              : 'Chronic aggressive driving — asset damage',
                          style: const TextStyle(
                            fontSize: 10, color: AdminTheme.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Report generated for ${v.id}'),
                        backgroundColor: AdminTheme.bgCard,
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AdminTheme.bgCardSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AdminTheme.border),
                      ),
                      child: const Text('Report',
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: AdminTheme.textPrimary,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}