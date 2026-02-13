// lib/screens/battery_health_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../models/simulation_service.dart';
import '../widgets/glass_widgets.dart';

class BatteryHealthScreen extends StatelessWidget {
  const BatteryHealthScreen({super.key});

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
                        _buildHealthScoreCard(context, data),
                        const SizedBox(height: 16),
                        _buildInternalResistanceCard(context, data),
                        const SizedBox(height: 16),
                        _buildCoulombicEfficiencyCard(context, data),
                        const SizedBox(height: 16),
                        _buildLifespanSection(context, data),
                        const SizedBox(height: 16),
                        _buildDodHistogramCard(context, data),
                        const SizedBox(height: 16),
                        _buildCellBalanceCard(context, data),
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
          Text('My Battery',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryC(context),
                letterSpacing: -0.8,
              )),
          Text('Health & Long-term Value',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryC(context),
                fontWeight: FontWeight.w400,
              )),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context, BatteryData data) {
    final score = ((100 - (data.internalResistance - 35) * 2)
        .clamp(0, 100)
        .toInt());

    return DarkCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRUE HEALTH SCORE',
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
                            fontSize: 18,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  score > 85 ? 'Excellent — Like New' : score > 70 ? 'Good — Normal Aging' : 'Degraded — Service Advised',
                  style: TextStyle(
                    fontSize: 13,
                    color: score > 85 ? AppTheme.successGreen : score > 70 ? AppTheme.warningAmber : AppTheme.dangerRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                AppProgressBar(
                  value: score / 100,
                  color: score > 85
                      ? AppTheme.successGreen
                      : score > 70
                      ? AppTheme.warningAmber
                      : AppTheme.dangerRed,
                  trackColor: Colors.white10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.favorite_rounded,
                color: AppTheme.successGreen, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalResistanceCard(BuildContext context, BatteryData data) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.electric_bolt_rounded,
                    color: AppTheme.primaryBlue, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Internal Resistance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryC(context),
                        )),
                    Text('Low resistance = Like New',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondaryC(context),
                        )),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${data.internalResistance.toInt()}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryC(context),
                        letterSpacing: -1,
                        height: 1,
                      ),
                    ),
                    TextSpan(
                      text: ' m\u03A9',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryC(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('RESISTANCE TREND',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textTertiaryC(context),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              )),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.dividerC(context),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Now'];
                        if (value.toInt() < labels.length) {
                          return Text(labels[value.toInt()],
                              style: TextStyle(
                                fontSize: 9,
                                color: AppTheme.textTertiaryC(context),
                              ));
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}',
                          style: TextStyle(
                            fontSize: 9, color: AppTheme.textTertiaryC(context),
                          )),
                      interval: 2,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.resistanceHistory.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, index) =>
                          FlDotCirclePainter(
                            radius: index == data.resistanceHistory.length - 1
                                ? 4 : 2,
                            color: AppTheme.primaryBlue,
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
                          AppTheme.primaryBlue.withOpacity(0.15),
                          AppTheme.primaryBlue.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                minY: 35,
                maxY: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoulombicEfficiencyCard(BuildContext context, BatteryData data) {
    final efficiency = data.coulombicEfficiency;
    final isHealthy = efficiency >= 99.0;
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chemistry Integrity',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryC(context),
                    )),
                const SizedBox(height: 2),
                Text('Coulombic Efficiency',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondaryC(context),
                    )),
                const SizedBox(height: 12),
                Text(
                  isHealthy
                      ? 'Healthy cell chemistry'
                      : 'Degradation detected — service soon',
                  style: TextStyle(
                    fontSize: 12,
                    color: isHealthy ? AppTheme.successGreen : AppTheme.warningAmber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                '$efficiency%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: isHealthy ? AppTheme.successGreen : AppTheme.warningAmber,
                  letterSpacing: -1,
                ),
              ),
              Text(
                isHealthy ? 'Optimal' : 'Check',
                style: TextStyle(
                  fontSize: 11, color: AppTheme.textTertiaryC(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifespanSection(BuildContext context, BatteryData data) {
    const totalLifeCycles = 1500;
    final cycleProgress = data.cycleCount / totalLifeCycles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'LIFESPAN TRACKING'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cycle Count',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryC(context),
                            )),
                        const SizedBox(height: 2),
                        Text(
                          '${data.cycleCount} / $totalLifeCycles cycles used',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryC(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(cycleProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryC(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppProgressBar(
                value: cycleProgress,
                color: cycleProgress < 0.5
                    ? AppTheme.successGreen
                    : cycleProgress < 0.75
                    ? AppTheme.warningAmber
                    : AppTheme.dangerRed,
                height: 10,
              ),
              const SizedBox(height: 10),
              Text(
                '~${(totalLifeCycles - data.cycleCount)} cycles remaining — est. ${((totalLifeCycles - data.cycleCount) / 250).toStringAsFixed(1)} years',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryC(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDodHistogramCard(BuildContext context, BatteryData data) {
    final dodData = data.dodHistogram;
    final maxVal = dodData.reduce((a, b) => a > b ? a : b);
    final labels = ['0–20%', '20–40%', '40–60%', '60–80%', '80–100%'];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Depth of Discharge History',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryC(context),
              )),
          const SizedBox(height: 2),
          Text('How deep you usually drain the pack',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryC(context),
              )),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.dividerC(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(labels[value.toInt()],
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppTheme.textTertiaryC(context),
                                )),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dodData.asMap().entries.map((e) {
                  final isHighlighted = e.key == 3;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        color: isHighlighted
                            ? AppTheme.warningAmber
                            : AppTheme.primaryBlue.withOpacity(0.6),
                      ),
                    ],
                  );
                }).toList(),
                maxY: maxVal + 5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.warningAmber.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: AppTheme.warningAmber, size: 14),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tip: Try to charge before hitting 20% to improve battery life.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.warningAmber,
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

  Widget _buildCellBalanceCard(BuildContext context, BatteryData data) {
    final imbalance = data.cellImbalance;
    final isBalanced = imbalance < 0.02;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CELL BALANCE MONITOR'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cell Imbalance',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryC(context),
                          )),
                      const SizedBox(height: 2),
                      Text(
                        '${data.minCellVoltage}V min \u2194 ${data.maxCellVoltage}V max',
                        style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondaryC(context),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${(imbalance * 1000).toInt()} mV',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isBalanced ? AppTheme.successGreen : AppTheme.warningAmber,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 20,
                  color: AppTheme.dividerC(context),
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        color: AppTheme.successGreen,
                      ),
                      Container(
                        width: 8,
                        color: isBalanced ? AppTheme.successGreen : AppTheme.warningAmber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min: ${data.minCellVoltage}V',
                      style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondaryC(context),
                      )),
                  Text('Max: ${data.maxCellVoltage}V',
                      style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondaryC(context),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              AppActionButton(
                label: isBalanced ? 'Cells Balanced' : 'Perform Balancing Charge',
                icon: isBalanced
                    ? Icons.check_circle_rounded
                    : Icons.battery_charging_full_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBalanced
                            ? 'All cells are balanced!'
                            : 'Balancing charge initiated...',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: isBalanced
                          ? AppTheme.successGreen
                          : AppTheme.primaryBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                isPrimary: !isBalanced,
                color: isBalanced ? AppTheme.successGreen.withOpacity(0.1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
