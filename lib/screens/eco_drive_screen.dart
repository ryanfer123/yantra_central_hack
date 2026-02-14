// lib/screens/eco_drive_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../widgets/glass_widgets.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';

class EcoDriveScreen extends StatelessWidget {
  const EcoDriveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<VehicleProvider>(); // rebuild on every BLE packet
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildDailyScorecardCard(),
                  const SizedBox(height: 16),
                  _buildDrivingStyleCard(),
                  const SizedBox(height: 16),
                  _buildEfficiencyMetrics(),
                  const SizedBox(height: 16),
                  _buildStressHistoryCard(),
                  const SizedBox(height: 16),
                  _buildTripLog(),
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
      pinned: false,
      floating: true,
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Eco-Drive',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
              )),
          Text('Performance & Gamification',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              )),
        ],
      ),
    );
  }

  Widget _buildDailyScorecardCard() {
    final score = BatteryData.batteryStressIndex.toInt();
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
                    Text('$score',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -3,
                          height: 1,
                        )),
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

  Widget _buildDrivingStyleCard() {
    // throttleGradient 0-1, brakePedalPos 0-1
    // combined smoothness = inverse of aggressive behavior
    final smoothness =
    ((1 - (BatteryData.throttleGradient + BatteryData.brakePedalPos) / 2) * 100).clamp(0, 100);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Driving Style Analysis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 2),
          const Text('Throttle & brake behavior this session',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              )),
          const SizedBox(height: 20),
          // Style slider visualization
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.waves_rounded,
                      color: AppTheme.successGreen, size: 18),
                  const SizedBox(height: 4),
                  const Text('Smooth',
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
                      // Indicator
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final pos = (1 - smoothness / 100) * constraints.maxWidth;
                          return Stack(
                            children: [
                              Container(height: 16),
                              Positioned(
                                left: pos.clamp(0, constraints.maxWidth - 16),
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppTheme.textPrimary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white, width: 2,
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
              Column(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: AppTheme.dangerRed, size: 18),
                  const SizedBox(height: 4),
                  const Text('Aggressive',
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
              _buildStyleStat(
                  'Throttle Response',
                  '${(BatteryData.throttleGradient * 100).toInt()}%',
                  Icons.speed_rounded),
              const SizedBox(width: 12),
              _buildStyleStat(
                  'Brake Pressure',
                  '${(BatteryData.brakePedalPos * 100).toInt()}%',
                  Icons.album_rounded),
              const SizedBox(width: 12),
              _buildStyleStat(
                  'Smoothness',
                  '${smoothness.toInt()}%',
                  Icons.waves_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 16),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                )),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetrics() {
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
                      '${BatteryData.regenEnergy} kWh',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.regenGreen,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Reclaimed Today',
                        style: TextStyle(
                          fontSize: 11, color: AppTheme.textTertiary,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      '≈ Free Fuel! 🌱',
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
                      '${BatteryData.energyConsumed} kWh',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Energy Used',
                        style: TextStyle(
                          fontSize: 11, color: AppTheme.textTertiary,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Current trip total',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withOpacity(0.7),
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

  Widget _buildStressHistoryCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Battery Stress Trend',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 2),
          const Text('Last 9 sessions — lower is better',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
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
                      FlLine(color: AppTheme.divider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: BatteryData.stressHistory.asMap().entries
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
                minY: 50,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'TRIP LOG',
          subtitle: 'Recent sessions with efficiency ratings',
        ),
        const SizedBox(height: 8),
        ...BatteryData.recentTrips.map((trip) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTripCard(trip),
        )),
      ],
    );
  }

  Widget _buildTripCard(TripData trip) {
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
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${trip.score}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(trip.date,
                    style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${trip.distance} km',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
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