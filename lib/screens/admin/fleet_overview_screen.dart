// lib/screens/admin/fleet_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/admin_theme.dart';
import '../../models/fleet_data.dart';
import '../../widgets/admin_widgets.dart';
import '../role_selection_screen.dart';

class FleetOverviewScreen extends StatelessWidget {
  const FleetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  AlertTicker(alerts: FleetData.alertMessages),
                  const SizedBox(height: 16),
                  _buildReadinessCard(),
                  const SizedBox(height: 16),
                  AdminSectionHeader(title: 'FLEET STATUS BREAKDOWN'),
                  const SizedBox(height: 8),
                  _buildStatusGrid(),
                  const SizedBox(height: 16),
                  AdminSectionHeader(title: 'ASSET VALUE TREND — INTERNAL RESISTANCE [#7]'),
                  const SizedBox(height: 8),
                  _buildResistanceTrendCard(),
                  const SizedBox(height: 16),
                  AdminSectionHeader(title: 'CRITICAL VEHICLES — IMMEDIATE ACTION'),
                  const SizedBox(height: 8),
                  _buildCriticalVehiclesList(),
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
      backgroundColor: AdminTheme.bg,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fleet Sentinel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AdminTheme.textPrimary,
                letterSpacing: -0.5,
              )),
          Text('${FleetData.totalVehicles} vehicles · ${FleetData.criticalCount} critical',
              style: TextStyle(
                fontSize: 11,
                color: FleetData.criticalCount > 0
                    ? AdminTheme.red
                    : AdminTheme.textSecondary,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
      actions: [
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
              color: AdminTheme.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminTheme.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.swap_horiz_rounded,
                    color: AdminTheme.blue, size: 14),
                SizedBox(width: 5),
                Text('Switch Role',
                    style: TextStyle(
                      color: AdminTheme.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadinessCard() {
    final score = FleetData.fleetReadinessScore;
    final scoreColor = score > 75
        ? AdminTheme.green
        : score > 50
        ? AdminTheme.amber
        : AdminTheme.red;

    return AdminCard(
      borderColor: scoreColor.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FLEET READINESS SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AdminTheme.textMuted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    )),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                          letterSpacing: -2,
                          height: 1,
                        )),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 3),
                      child: Text('%',
                          style: TextStyle(
                            fontSize: 20,
                            color: AdminTheme.textMuted,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  score > 75
                      ? 'Fleet is operational — monitor warnings'
                      : score > 50
                      ? 'Degraded performance — action required'
                      : 'Critical fleet status — immediate response',
                  style: TextStyle(
                    fontSize: 12,
                    color: scoreColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                AdminProgressBar(value: score / 100, color: scoreColor, height: 8),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Donut mini chart
          SizedBox(
            width: 90,
            height: 90,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 26,
                sections: [
                  PieChartSectionData(
                    value: FleetData.criticalCount.toDouble(),
                    color: AdminTheme.red,
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: FleetData.warningCount.toDouble(),
                    color: AdminTheme.amber,
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: FleetData.healthyCount.toDouble(),
                    color: AdminTheme.green,
                    radius: 18,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return Row(
      children: [
        Expanded(child: AdminStatTile(
          label: 'Critical', value: '${FleetData.criticalCount}',
          unit: 'vehicles', icon: Icons.emergency_rounded,
          color: AdminTheme.red, delta: '+1 today',
        )),
        const SizedBox(width: 10),
        Expanded(child: AdminStatTile(
          label: 'Warning', value: '${FleetData.warningCount}',
          unit: 'vehicles', icon: Icons.warning_rounded,
          color: AdminTheme.amber,
        )),
        const SizedBox(width: 10),
        Expanded(child: AdminStatTile(
          label: 'Healthy', value: '${FleetData.healthyCount}',
          unit: 'vehicles', icon: Icons.check_circle_rounded,
          color: AdminTheme.green,
        )),
      ],
    );
  }

  Widget _buildResistanceTrendCard() {
    final trend = FleetData.resistanceTrend;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Avg Resistance: ${FleetData.avgInternalResistance.toStringAsFixed(1)} mΩ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AdminTheme.textPrimary,
                          letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 2),
                    const Text('↑ Rising = Fleet resale value declining',
                        style: TextStyle(
                          fontSize: 11, color: AdminTheme.red,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminTheme.redDim.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('+19.1% YTD',
                    style: TextStyle(
                      color: AdminTheme.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AdminTheme.border,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 4,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                          style: const TextStyle(
                            fontSize: 9, color: AdminTheme.textMuted,
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
                        if (i < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(months[i],
                                style: const TextStyle(
                                  fontSize: 8, color: AdminTheme.textMuted,
                                )),
                          );
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AdminTheme.red,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, index) =>
                          FlDotCirclePainter(
                            radius: index == trend.length - 1 ? 4 : 0,
                            color: AdminTheme.red,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AdminTheme.red.withOpacity(0.15),
                          AdminTheme.red.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 40,
                maxY: 58,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminTheme.bgCardSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AdminTheme.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.insights_rounded, color: AdminTheme.amber, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Financial Forecast: 3 packs approaching replacement. Est. budget ₹12.4L in Q3.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AdminTheme.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalVehiclesList() {
    return Column(
      children: FleetData.criticalVehicles.map((v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AdminCard(
          borderColor: AdminTheme.red.withOpacity(0.4),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AdminTheme.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AdminTheme.red.withOpacity(0.4)),
                ),
                child: const Icon(Icons.warning_rounded,
                    color: AdminTheme.red, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(v.id,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AdminTheme.textPrimary,
                              letterSpacing: -0.2,
                            )),
                        const SizedBox(width: 8),
                        Text('· ${v.driverName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdminTheme.textSecondary,
                            )),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(v.predictedFailure,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminTheme.red,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${v.soc.toInt()}% SoC',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AdminTheme.textSecondary,
                      )),
                  const SizedBox(height: 3),
                  Text('${v.battTemp}°C',
                      style: TextStyle(
                        fontSize: 11,
                        color: v.battTemp > 45 ? AdminTheme.red : AdminTheme.amber,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}