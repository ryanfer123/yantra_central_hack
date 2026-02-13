// lib/screens/diagnostics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/battery_data.dart';
import '../models/simulation_service.dart';
import '../widgets/glass_widgets.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      body: ValueListenableBuilder<BatteryData>(
        valueListenable: SimulationService.instance.data,
        builder: (context, data, _) {
          return SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primaryBlue,
              backgroundColor: AppTheme.cardColor(context),
              onRefresh: () async {
                SimulationService.instance.refresh();
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, data),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        _buildOverallStatusCard(data),
                        const SizedBox(height: 16),
                        _buildSafetyMonitor(data),
                        const SizedBox(height: 16),
                        _buildThermalManagementCard(context, data),
                        const SizedBox(height: 16),
                        _buildThermalComparisonChart(context, data),
                        const SizedBox(height: 16),
                        _buildRawDataList(context, data),
                        const SizedBox(height: 24),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, BatteryData data) {
    // Determine overall status from safety sensors
    final hasWarning = data.thermalGradient >= 3.0 ||
        data.gasCoLevel >= 0.1 ||
        data.insulationResistance <= 100;
    final hasDanger = data.thermalGradient >= 5.0 ||
        data.gasCoLevel >= 0.5 ||
        data.insulationResistance <= 50;

    final statusColor = hasDanger
        ? AppTheme.dangerRed
        : hasWarning
            ? AppTheme.warningAmber
            : AppTheme.successGreen;
    final statusText = hasDanger
        ? 'Alert'
        : hasWarning
            ? 'Warning'
            : 'All Clear';

    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: AppTheme.scaffoldBg(context),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diagnostics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryC(context),
                letterSpacing: -0.8,
              )),
          Text('Safety & Nerd Mode',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryC(context),
              )),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, color: statusColor, size: 8),
                const SizedBox(width: 5),
                Text(statusText,
                    style: TextStyle(
                      color: statusColor,
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

  Widget _buildOverallStatusCard(BatteryData data) {
    final hasWarning = data.thermalGradient >= 3.0 ||
        data.gasCoLevel >= 0.1 ||
        data.insulationResistance <= 100;
    final hasDanger = data.thermalGradient >= 5.0 ||
        data.gasCoLevel >= 0.5 ||
        data.insulationResistance <= 50;

    final statusColor = hasDanger
        ? AppTheme.dangerRed
        : hasWarning
            ? AppTheme.warningAmber
            : AppTheme.successGreen;
    final statusText = hasDanger
        ? 'System Alert'
        : hasWarning
            ? 'System Warning'
            : 'System Healthy';
    final statusIcon = hasDanger
        ? Icons.warning_rounded
        : hasWarning
            ? Icons.info_rounded
            : Icons.shield_rounded;

    int alertCount = 0;
    if (data.thermalGradient >= 3.0) alertCount++;
    if (data.gasCoLevel >= 0.1) alertCount++;
    if (data.insulationResistance <= 100) alertCount++;

    return DarkCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 4),
                Text('$alertCount active alert${alertCount != 1 ? 's' : ''} · 3 sensors monitored',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    )),
                const SizedBox(height: 10),
                Text(
                    alertCount == 0
                        ? 'All nominal'
                        : '$alertCount sensor${alertCount != 1 ? 's' : ''} outside normal range',
                    style: const TextStyle(
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

  Widget _buildSafetyMonitor(BatteryData data) {
    final thermalStatus = data.thermalGradient < 3.0
        ? SafetyStatus.safe
        : data.thermalGradient < 5.0
            ? SafetyStatus.warning
            : SafetyStatus.danger;

    final gasStatus = data.gasCoLevel < 0.1
        ? SafetyStatus.safe
        : data.gasCoLevel < 0.5
            ? SafetyStatus.warning
            : SafetyStatus.danger;

    final isolationStatus = data.insulationResistance > 100
        ? SafetyStatus.safe
        : data.insulationResistance > 50
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
              'Gradient: ${data.thermalGradient.toStringAsFixed(1)}°C across cells (safe <5°C)',
          status: thermalStatus,
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 10),
        SafetyIndicator(
          label: 'Gas / Venting Status',
          value:
              'CO Level: ${data.gasCoLevel} ppm · No venting detected',
          status: gasStatus,
          icon: Icons.air_rounded,
        ),
        const SizedBox(height: 10),
        SafetyIndicator(
          label: 'Isolation Status',
          value:
              '${data.insulationResistance.toInt()} MΩ · No chassis shorts',
          status: isolationStatus,
          icon: Icons.electrical_services_rounded,
        ),
      ],
    );
  }

  Widget _buildThermalManagementCard(BuildContext context, BatteryData data) {
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
                value: '${data.packTemp}',
                unit: '°C',
                icon: Icons.thermostat_rounded,
                iconColor: data.packTemp > 40
                    ? AppTheme.dangerRed
                    : data.packTemp > 30
                        ? AppTheme.warningAmber
                        : AppTheme.successGreen,
                valueColor: data.packTemp > 40
                    ? AppTheme.dangerRed
                    : AppTheme.textPrimaryC(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Inverter Temp',
                value: '${data.inverterTemp}',
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
                value: '${data.coolantFlow}',
                unit: 'L/min',
                icon: Icons.water_drop_rounded,
                iconColor: AppTheme.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Thermal Gradient',
                value: '${data.thermalGradient}',
                unit: '°C Δ',
                icon: Icons.gradient_rounded,
                iconColor: data.thermalGradient < 3
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
                valueColor: data.thermalGradient < 3
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThermalComparisonChart(BuildContext context, BatteryData data) {
    final packTempData = data.packTempHistory;
    final ambientTempData = List.generate(
        packTempData.length, (i) => data.ambientTemp + (i * 0.1));

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pack vs Ambient Temperature',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryC(context),
              )),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildLegendDot(AppTheme.primaryBlue),
              const SizedBox(width: 4),
              Text('Pack Temp',
                  style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondaryC(context),
                  )),
              const SizedBox(width: 12),
              _buildLegendDot(AppTheme.warningAmber),
              const SizedBox(width: 4),
              Text('Ambient',
                  style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondaryC(context),
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
                      FlLine(color: AppTheme.dividerC(context), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, _) => Text('${value.toInt()}°',
                          style: TextStyle(
                            fontSize: 9, color: AppTheme.textTertiaryC(context),
                          )),
                      interval: 4,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: packTempData
                        .asMap()
                        .entries
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
                    spots: ambientTempData
                        .asMap()
                        .entries
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
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRawDataList(BuildContext context, BatteryData data) {
    final rawParams = [
      _RawParam('Pack Voltage ', '${data.packVoltage} V', Icons.bolt_rounded),
      _RawParam('Pack Current ', '${data.packCurrent} A',
          Icons.electrical_services_rounded),
      _RawParam('Pack Power ', '${data.packPower} kW', Icons.power_rounded),
      _RawParam('State of Charge ', '${data.stateOfCharge}%',
          Icons.battery_full_rounded),
      _RawParam('Energy Consumed ', '${data.energyConsumed} kWh',
          Icons.speed_rounded),
      _RawParam(
          'Regen Energy ', '${data.regenEnergy} kWh', Icons.recycling_rounded),
      _RawParam('Internal Resistance ', '${data.internalResistance} mΩ',
          Icons.electric_bolt_rounded),
      _RawParam('Cycle Count ', '${data.cycleCount}', Icons.repeat_rounded),
      _RawParam('Avg DoD ', '${(data.depthOfDischarge * 100).toInt()}%',
          Icons.arrow_downward_rounded),
      _RawParam('Max Cell Voltage ', '${data.maxCellVoltage} V',
          Icons.arrow_upward_rounded),
      _RawParam('Min Cell Voltage ', '${data.minCellVoltage} V',
          Icons.arrow_downward_rounded),
      _RawParam('Cell Imbalance ',
          '${(data.cellImbalance * 1000).toInt()} mV', Icons.balance_rounded),
      _RawParam('Coulombic Efficiency ', '${data.coulombicEfficiency}%',
          Icons.science_rounded),
      _RawParam(
          'Pack Temp ', '${data.packTemp}°C', Icons.thermostat_rounded),
      _RawParam('Thermal Gradient ', '${data.thermalGradient}°C',
          Icons.gradient_rounded),
      _RawParam(
          'Inverter Temp ', '${data.inverterTemp}°C', Icons.memory_rounded),
      _RawParam(
          'Ambient Temp ', '${data.ambientTemp}°C', Icons.wb_sunny_rounded),
      _RawParam('Coolant Flow ', '${data.coolantFlow} L/min',
          Icons.water_drop_rounded),
      _RawParam('Insulation Resistance ',
          '${data.insulationResistance.toInt()} MΩ',
          Icons.electrical_services_rounded),
      _RawParam(
          'Gas/CO Level ', '${data.gasCoLevel} ppm', Icons.air_rounded),
      _RawParam('Throttle Gradient ',
          '${(data.throttleGradient * 100).toInt()}%', Icons.speed_rounded),
      _RawParam('Brake Pedal Pos ',
          '${(data.brakePedalPos * 100).toInt()}%', Icons.album_rounded),
      _RawParam(
          'State of Power ', data.stateOfPower, Icons.verified_rounded),
      _RawParam('Projected Range ', '${data.projectedRange} km',
          Icons.navigation_rounded),
      _RawParam('Battery Stress Index ',
          '${data.batteryStressIndex.toInt()}/100',
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
                            color: AppTheme.scaffoldBg(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(param.icon,
                              color: AppTheme.textSecondaryC(context),
                              size: 15),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(param.label,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryC(context),
                                fontWeight: FontWeight.w400,
                              )),
                        ),
                        Text(param.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimaryC(context),
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: AppTheme.dividerC(context),
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
