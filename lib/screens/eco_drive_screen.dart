// lib/screens/eco_drive_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../models/simulation_service.dart';
import '../widgets/glass_widgets.dart';

class EcoDriveScreen extends StatelessWidget {
  const EcoDriveScreen({super.key});

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
                        _buildDailyScorecardCard(context, data),
                        const SizedBox(height: 16),
                        _buildDrivingStyleCard(context, data),
                        const SizedBox(height: 16),
                        _buildEfficiencyMetrics(context, data),
                        const SizedBox(height: 16),
                        _buildStressHistoryCard(context, data),
                        const SizedBox(height: 16),
                        _buildTripLog(context, data),
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
          Text('Eco-Drive',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryC(context),
                letterSpacing: -0.8,
              )),
          Text('Performance & Gamification',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryC(context),
              )),
        ],
      ),
    );
  }

  Widget _buildDailyScorecardCard(BuildContext context, BatteryData data) {
    final score = data.batteryStressIndex.toInt();
    final grade = score > 85 ? 'A' : score > 70 ? 'B' : score > 55 ? 'C' : 'D';
    final gradeColor = score > 85
        ? AppTheme.successGreen
        : score > 70
        ? AppTheme.primaryBlue
        : score > 55
        ? AppTheme.warningAmber
        : AppTheme.dangerRed;

    return DarkCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DAILY SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white38,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    )),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedNumber(
                      value: score.toDouble(),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -3,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 4),
                      child: Text('/100',
                          style: TextStyle(
                            fontSize: 18, color: Colors.white38,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Battery Stress Index',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    )),
                const SizedBox(height: 14),
                const Text('Keep smooth to earn maximum score!',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white38,
                    )),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: gradeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gradeColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(grade,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: gradeColor,
                        letterSpacing: -1,
                      )),
                ),
              ),
              const SizedBox(height: 8),
              Text('Grade',
                  style: TextStyle(
                    fontSize: 11,
                    color: gradeColor.withOpacity(0.7),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrivingStyleCard(BuildContext context, BatteryData data) {
    final smoothness =
    ((1 - (data.throttleGradient + data.brakePedalPos) / 2) * 100).clamp(0, 100);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Driving Style Analysis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryC(context),
              )),
          const SizedBox(height: 2),
          Text('Throttle & brake behavior this session',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryC(context),
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              const Column(
                children: [
                  Icon(Icons.waves_rounded,
                      color: AppTheme.successGreen, size: 18),
                  SizedBox(height: 4),
                  Text('Smooth',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.successGreen,
                              AppTheme.warningAmber,
                              AppTheme.dangerRed,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final pos = (1 - smoothness / 100) * constraints.maxWidth;
                          return Stack(
                            children: [
                              Container(height: 16),
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                left: pos.clamp(0, constraints.maxWidth - 16),
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppTheme.textPrimaryC(context),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.isDarkMode(context) ? Colors.black : Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Column(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      color: AppTheme.dangerRed, size: 18),
                  SizedBox(height: 4),
                  Text('Aggressive',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.dangerRed,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStyleStat(context,
                  'Throttle Response',
                  '${(data.throttleGradient * 100).toInt()}%',
                  Icons.speed_rounded),
              const SizedBox(width: 12),
              _buildStyleStat(context,
                  'Brake Pressure',
                  '${(data.brakePedalPos * 100).toInt()}%',
                  Icons.album_rounded),
              const SizedBox(width: 12),
              _buildStyleStat(context,
                  'Smoothness',
                  '${smoothness.toInt()}%',
                  Icons.waves_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleStat(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.scaffoldBg(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textSecondaryC(context), size: 16),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryC(context),
                  letterSpacing: -0.5,
                )),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: AppTheme.textTertiaryC(context),
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetrics(BuildContext context, BatteryData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'EFFICIENCY METRICS'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.regenGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.recycling_rounded,
                          color: AppTheme.regenGreen, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${data.regenEnergy} kWh',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.regenGreen,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Reclaimed Today',
                        style: TextStyle(
                          fontSize: 11, color: AppTheme.textTertiaryC(context),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Free Fuel!',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.regenGreen.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: AppTheme.primaryBlue, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${data.energyConsumed} kWh',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryC(context),
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Energy Used',
                        style: TextStyle(
                          fontSize: 11, color: AppTheme.textTertiaryC(context),
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Current trip total',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondaryC(context).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStressHistoryCard(BuildContext context, BatteryData data) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Battery Stress Trend',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryC(context),
              )),
          const SizedBox(height: 2),
          Text('Last 9 sessions — lower is better',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryC(context),
              )),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.dividerC(context), strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.stressHistory.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.15),
                          AppTheme.primaryBlue.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 30,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripLog(BuildContext context, BatteryData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'TRIP LOG',
          subtitle: 'Recent sessions with efficiency ratings',
        ),
        const SizedBox(height: 8),
        ...data.recentTrips.map((trip) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTripCard(context, trip),
        )),
      ],
    );
  }

  Widget _buildTripCard(BuildContext context, TripData trip) {
    final effColor = trip.efficiency < 140
        ? AppTheme.successGreen
        : trip.efficiency < 160
        ? AppTheme.warningAmber
        : AppTheme.dangerRed;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.scaffoldBg(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${trip.score}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryC(context),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.destination,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryC(context),
                    )),
                const SizedBox(height: 2),
                Text(trip.date,
                    style: TextStyle(
                      fontSize: 11, color: AppTheme.textSecondaryC(context),
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${trip.distance} km',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryC(context),
                  )),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: effColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${trip.efficiency} Wh/km',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: effColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
