// lib/screens/admin/qol_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/admin_theme.dart';
import '../../../models/fleet_data.dart';
import '../../../widgets/admin_widgets.dart';

class QolScreen extends StatefulWidget {
  const QolScreen({super.key});

  @override
  State<QolScreen> createState() => _QolScreenState();
}

class _QolScreenState extends State<QolScreen> {
  // Limp mode toggles per critical vehicle
  final Map<String, bool> _limpModes = {};

  // Threshold values
  double _cellImbalanceThreshold = 50.0;    // mV
  double _thermalGradientThreshold = 5.0;   // °C
  double _socAlertThreshold = 20.0;         // %
  double _cycleCountThreshold = 1200.0;     // cycles

  // Smart charge targets
  final List<_ChargeSchedule> _schedules = [
    _ChargeSchedule(vehicleId: 'EV-204', soc: 12, imbalance: 0.095, scheduled: '02:00 AM', offPeak: true),
    _ChargeSchedule(vehicleId: 'EV-317', soc: 52, imbalance: 0.058, scheduled: '03:30 AM', offPeak: true),
    _ChargeSchedule(vehicleId: 'EV-402', soc: 28, imbalance: 0.110, scheduled: 'HOLD - Safety', offPeak: false),
    _ChargeSchedule(vehicleId: 'EV-550', soc: 44, imbalance: 0.067, scheduled: '01:00 AM', offPeak: true),
  ];

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
                  _buildLimpModeCard(context),
                  const SizedBox(height: 16),
                  _buildSmartChargeCard(context),
                  const SizedBox(height: 16),
                  _buildExportCard(context),
                  const SizedBox(height: 16),
                  _buildThresholdCard(),
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fleet Controls',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AdminTheme.textPrimary, letterSpacing: -0.4,
              )),
          Text('Remote actions & configuration',
              style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLimpModeCard(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AdminTheme.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.speed_rounded,
                    color: AdminTheme.red, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Remote Limp Mode',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AdminTheme.textPrimary,
                        )),
                    Text('Derate speed/power — safe return to depot',
                        style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Activates when Gas/CO or Insulation failure detected. '
                'Limits max speed to 40 km/h and power to 30% until vehicle reaches base.',
            style: TextStyle(
              fontSize: 11, color: AdminTheme.textSecondary, height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ...FleetData.criticalVehicles.map((v) {
            _limpModes.putIfAbsent(v.id, () => false);
            final isActive = _limpModes[v.id]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AdminTheme.amber.withOpacity(0.08)
                      : AdminTheme.bgCardSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? AdminTheme.amber.withOpacity(0.3)
                        : AdminTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.id,
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AdminTheme.textPrimary,
                            )),
                        Text(v.location,
                            style: const TextStyle(
                              fontSize: 10, color: AdminTheme.textMuted,
                            )),
                      ],
                    ),
                    const Spacer(),
                    if (isActive)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text('⚠ ACTIVE — 40 km/h limit',
                            style: TextStyle(
                              fontSize: 10, color: AdminTheme.amber,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    Switch(
                      value: isActive,
                      onChanged: (val) {
                        setState(() => _limpModes[v.id] = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? '${v.id}: Limp mode activated — derated to 40 km/h'
                                  : '${v.id}: Limp mode deactivated',
                            ),
                            backgroundColor: val
                                ? AdminTheme.amber.withOpacity(0.9)
                                : AdminTheme.bgCard,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      activeColor: AdminTheme.amber,
                      activeTrackColor: AdminTheme.amber.withOpacity(0.3),
                      inactiveThumbColor: AdminTheme.textMuted,
                      inactiveTrackColor: AdminTheme.border,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSmartChargeCard(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AdminTheme.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: AdminTheme.green, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Smart Charge Scheduling',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AdminTheme.textPrimary,
                        )),
                    Text('Off-peak hours · Prioritised by SoC & imbalance',
                        style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('AUTO',
                    style: TextStyle(
                      color: AdminTheme.green, fontSize: 9, fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Off-peak window
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminTheme.bgCardSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.nightlight_rounded,
                    color: AdminTheme.cyan, size: 16),
                const SizedBox(width: 8),
                const Text('Off-peak window: ',
                    style: TextStyle(
                      fontSize: 11, color: AdminTheme.textSecondary,
                    )),
                const Text('12:00 AM – 06:00 AM',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: AdminTheme.cyan,
                    )),
                const Spacer(),
                const Text('Est. saving: ₹2,840/mo',
                    style: TextStyle(
                      fontSize: 10, color: AdminTheme.green,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Schedule list
          ..._schedules.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(s.vehicleId,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AdminTheme.textPrimary,
                    )),
                const SizedBox(width: 10),
                _miniLabel('SoC ${s.soc.toInt()}%',
                    s.soc < 25 ? AdminTheme.red : AdminTheme.textMuted),
                const SizedBox(width: 6),
                _miniLabel('Imbalance ${(s.imbalance * 1000).toInt()}mV',
                    s.imbalance > 0.08 ? AdminTheme.amber : AdminTheme.textMuted),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: s.offPeak
                        ? AdminTheme.green.withOpacity(0.1)
                        : AdminTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(s.scheduled,
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: s.offPeak ? AdminTheme.green : AdminTheme.red,
                      )),
                ),
              ],
            ),
          )),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Smart charging schedule pushed to all depot chargers.'),
                backgroundColor: AdminTheme.bgCard,
                behavior: SnackBarBehavior.floating,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AdminTheme.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Push Schedule to All Chargers',
                    style: TextStyle(
                      color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildExportCard(BuildContext context) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(title: 'EXPORT REPORTS'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _exportButton(
                  context, 'Monthly Health\nReport (PDF)',
                  Icons.picture_as_pdf_rounded, AdminTheme.red,
                  'Generating PDF report...'),
              ),
              const SizedBox(width: 10),
              Expanded(child: _exportButton(
                  context, 'Cycle Count\nData (CSV)',
                  Icons.table_chart_rounded, AdminTheme.green,
                  'Exporting CSV...'),
              ),
              const SizedBox(width: 10),
              Expanded(child: _exportButton(
                  context, 'Energy Usage\nReport (CSV)',
                  Icons.bar_chart_rounded, AdminTheme.blue,
                  'Exporting energy data...'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminTheme.bgCardSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: AdminTheme.textMuted, size: 14),
                const SizedBox(width: 8),
                const Text('Last export: ',
                    style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                const Text('Today, 9:00 AM',
                    style: TextStyle(
                      fontSize: 11, color: AdminTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    )),
                const Spacer(),
                const Text('Auto-export: Monthly',
                    style: TextStyle(fontSize: 10, color: AdminTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exportButton(BuildContext context, String label, IconData icon,
      Color color, String message) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AdminTheme.bgCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: AdminTheme.textPrimary, height: 1.4,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdCard() {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(title: 'CUSTOM ALERT THRESHOLDS'),
          const SizedBox(height: 4),
          const Text(
            'Adjust sensitivity to reduce false alerts. Changes apply fleet-wide.',
            style: TextStyle(fontSize: 11, color: AdminTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          _buildSlider(
            'Cell Imbalance Alert',
            '${_cellImbalanceThreshold.toInt()} mV',
            _cellImbalanceThreshold,
            20, 150,
                (v) => setState(() => _cellImbalanceThreshold = v),
            AdminTheme.amber,
            'Alert when imbalance exceeds threshold',
          ),
          _buildSlider(
            'Thermal Gradient Alert',
            '${_thermalGradientThreshold.toStringAsFixed(1)} °C',
            _thermalGradientThreshold,
            2, 10,
                (v) => setState(() => _thermalGradientThreshold = v),
            AdminTheme.red,
            'Alert on cell temp spread above threshold',
          ),
          _buildSlider(
            'Low SoC Warning',
            '${_socAlertThreshold.toInt()}%',
            _socAlertThreshold,
            5, 50,
                (v) => setState(() => _socAlertThreshold = v),
            AdminTheme.blue,
            'Notify driver when charge drops below',
          ),
          _buildSlider(
            'Cycle Count EOL Warning',
            '${_cycleCountThreshold.toInt()}',
            _cycleCountThreshold,
            800, 1450,
                (v) => setState(() => _cycleCountThreshold = v),
            AdminTheme.cyan,
            'Flag vehicle when cycles approach limit',
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thresholds saved and applied to all fleet alerts.'),
                backgroundColor: AdminTheme.bgCard,
                behavior: SnackBarBehavior.floating,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AdminTheme.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('Save Thresholds',
                    style: TextStyle(
                      color: Colors.white, fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
      String label,
      String valueLabel,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged,
      Color color,
      String description,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AdminTheme.textPrimary,
                    )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(valueLabel,
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: color,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: AdminTheme.border,
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Text(description,
              style: const TextStyle(
                fontSize: 10, color: AdminTheme.textMuted,
              )),
          const SizedBox(height: 8),
          Divider(height: 1, color: AdminTheme.border),
        ],
      ),
    );
  }
}

class _ChargeSchedule {
  final String vehicleId;
  final double soc;
  final double imbalance;
  final String scheduled;
  final bool offPeak;

  const _ChargeSchedule({
    required this.vehicleId,
    required this.soc,
    required this.imbalance,
    required this.scheduled,
    required this.offPeak,
  });
}