// lib/screens/diagnostics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../widgets/glass_widgets.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _buildOverallStatusCard(),
                  const SizedBox(height: 16),
                  _buildSafetyMonitor(),
                  const SizedBox(height: 16),
                  _buildThermalManagementCard(),
                  const SizedBox(height: 16),
                  _buildThermalComparisonChart(),
                  const SizedBox(height: 16),
                  _buildRawDataList(),
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
          Text('Diagnostics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                letterSpacing: -0.8,
              )),
          Text('Safety & Nerd Mode',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              )),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.successGreen.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: AppTheme.successGreen, size: 8),
                SizedBox(width: 5),
                Text('All Clear',
                    style: TextStyle(
                      color: AppTheme.successGreen,
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

  Widget _buildOverallStatusCard() {
    return DarkCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.successGreen.withOpacity(0.3), width: 1.5),
            ),
            child: const Icon(Icons.shield_rounded,
                color: AppTheme.successGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('System Healthy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    )),
                SizedBox(height: 4),
                Text('0 active alerts · Last scan: 2 min ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    )),
                SizedBox(height: 10),
                Text('3 sensors monitored · All nominal',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white38,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMonitor() {
    // Evaluate safety statuses from sensor data
    final thermalStatus = BatteryData.thermalGradient < 3.0
        ? SafetyStatus.safe
        : BatteryData.thermalGradient < 5.0
        ? SafetyStatus.warning
        : SafetyStatus.danger;

    final gasStatus = BatteryData.gasCoLevel < 0.1
        ? SafetyStatus.safe
        : BatteryData.gasCoLevel < 0.5
        ? SafetyStatus.warning
        : SafetyStatus.danger;

    final isolationStatus = BatteryData.insulationResistance > 100
        ? SafetyStatus.safe
        : BatteryData.insulationResistance > 50
        ? SafetyStatus.warning
        : SafetyStatus.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'SAFETY MONITOR',
          subtitle: 'Traffic light system',
        ),
        const SizedBox(height: 8),
        SafetyIndicator(
          label: 'Thermal Runaway Risk',
          value:
          'Gradient: ${BatteryData.thermalGradient}°C across cells (safe <5°C)',
          status: thermalStatus,
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 10),
        SafetyIndicator(
          label: 'Gas / Venting Status',
          value:
          'CO Level: ${BatteryData.gasCoLevel} ppm · No venting detected',
          status: gasStatus,
          icon: Icons.air_rounded,
        ),
        const SizedBox(height: 10),
        SafetyIndicator(
          label: 'Isolation Status',
          value:
          '${BatteryData.insulationResistance.toInt()} MΩ · No chassis shorts',
          status: isolationStatus,
          icon: Icons.electrical_services_rounded,
        ),
      ],
    );
  }

  Widget _buildThermalManagementCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'THERMAL MANAGEMENT'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Pack Temperature',
                value: '${BatteryData.packTemp}',
                unit: '°C',
                icon: Icons.thermostat_rounded,
                iconColor: BatteryData.packTemp > 40
                    ? AppTheme.dangerRed
                    : BatteryData.packTemp > 30
                    ? AppTheme.warningAmber
                    : AppTheme.successGreen,
                valueColor: BatteryData.packTemp > 40
                    ? AppTheme.dangerRed
                    : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Inverter Temp',
                value: '${BatteryData.inverterTemp}',
                unit: '°C',
                icon: Icons.memory_rounded,
                iconColor: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Coolant Flow',
                value: '${BatteryData.coolantFlow}',
                unit: 'L/min',
                icon: Icons.water_drop_rounded,
                iconColor: AppTheme.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Thermal Gradient',
                value: '${BatteryData.thermalGradient}',
                unit: '°C Δ',
                icon: Icons.gradient_rounded,
                iconColor: BatteryData.thermalGradient < 3
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
                valueColor: BatteryData.thermalGradient < 3
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThermalComparisonChart() {
    // Simulated pack temp vs ambient temp over time
    final packTempData = BatteryData.packTempHistory;
    final ambientTempData = List.generate(
        packTempData.length, (i) => BatteryData.ambientTemp + (i * 0.1));

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pack vs Ambient Temperature',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              )),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLegendDot(AppTheme.primaryBlue),
              const SizedBox(width: 4),
              const Text('Pack Temp',
                  style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary,
                  )),
              const SizedBox(width: 12),
              _buildLegendDot(AppTheme.warningAmber),
              const SizedBox(width: 4),
              const Text('Ambient',
                  style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.divider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}°',
                          style: const TextStyle(
                            fontSize: 9, color: AppTheme.textTertiary,
                          )),
                      interval: 4,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: packTempData.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.primaryBlue,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: ambientTempData.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.warningAmber,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dashArray: [4, 4],
                    dotData: const FlDotData(show: false),
                  ),
                ],
                minY: 18,
                maxY: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRawDataList() {
    final rawParams = [
      _RawParam('Pack Voltage ', '${BatteryData.packVoltage} V',
          Icons.bolt_rounded),
      _RawParam('Pack Current ', '${BatteryData.packCurrent} A',
          Icons.electrical_services_rounded),
      _RawParam('Pack Power ', '${BatteryData.packPower} kW',
          Icons.power_rounded),
      _RawParam('State of Charge ', '${BatteryData.stateOfCharge}%',
          Icons.battery_full_rounded),
      _RawParam('Energy Consumed ', '${BatteryData.energyConsumed} kWh',
          Icons.speed_rounded),
      _RawParam('Regen Energy ', '${BatteryData.regenEnergy} kWh',
          Icons.recycling_rounded),
      _RawParam('Internal Resistance ',
          '${BatteryData.internalResistance} mΩ', Icons.electric_bolt_rounded),
      _RawParam('Cycle Count ', '${BatteryData.cycleCount}',
          Icons.repeat_rounded),
      _RawParam('Avg DoD ',
          '${(BatteryData.depthOfDischarge * 100).toInt()}%',
          Icons.arrow_downward_rounded),
      _RawParam('Max Cell Voltage ', '${BatteryData.maxCellVoltage} V',
          Icons.arrow_upward_rounded),
      _RawParam('Min Cell Voltage ', '${BatteryData.minCellVoltage} V',
          Icons.arrow_downward_rounded),
      _RawParam('Cell Imbalance ',
          '${(BatteryData.cellImbalance * 1000).toInt()} mV',
          Icons.balance_rounded),
      _RawParam('Coulombic Efficiency ',
          '${BatteryData.coulombicEfficiency}%', Icons.science_rounded),
      _RawParam('Pack Temp ', '${BatteryData.packTemp}°C',
          Icons.thermostat_rounded),
      _RawParam('Thermal Gradient ', '${BatteryData.thermalGradient}°C',
          Icons.gradient_rounded),
      _RawParam('Inverter Temp ', '${BatteryData.inverterTemp}°C',
          Icons.memory_rounded),
      _RawParam('Ambient Temp ', '${BatteryData.ambientTemp}°C',
          Icons.wb_sunny_rounded),
      _RawParam('Coolant Flow ', '${BatteryData.coolantFlow} L/min',
          Icons.water_drop_rounded),
      _RawParam('Insulation Resistance ',
          '${BatteryData.insulationResistance.toInt()} MΩ',
          Icons.electrical_services_rounded),
      _RawParam('Gas/CO Level ', '${BatteryData.gasCoLevel} ppm',
          Icons.air_rounded),
      _RawParam('Throttle Gradient ',
          '${(BatteryData.throttleGradient * 100).toInt()}%',
          Icons.speed_rounded),
      _RawParam('Brake Pedal Pos ',
          '${(BatteryData.brakePedalPos * 100).toInt()}%',
          Icons.album_rounded),
      _RawParam('State of Power ', BatteryData.stateOfPower,
          Icons.verified_rounded),
      _RawParam('Projected Range ', '${BatteryData.projectedRange} km',
          Icons.navigation_rounded),
      _RawParam('Battery Stress Index ',
          '${BatteryData.batteryStressIndex.toInt()}/100',
          Icons.stacked_bar_chart_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'RAW SENSOR DATA',
          subtitle: 'All 26 BMS parameters',
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: rawParams.asMap().entries.map((entry) {
              final param = entry.value;
              final isLast = entry.key == rawParams.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(param.icon,
                              color: AppTheme.textSecondary, size: 15),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(param.label,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                              )),
                        ),
                        Text(param.value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 60,
                      color: AppTheme.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RawParam {
  final String label;
  final String value;
  final IconData icon;

  const _RawParam(this.label, this.value, this.icon);
}