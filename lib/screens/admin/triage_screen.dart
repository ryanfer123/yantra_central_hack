// lib/screens/admin/triage_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/admin_theme.dart';
import '../../../models/fleet_data.dart';
import '../../../widgets/admin_widgets.dart';

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Critical', 'Warning', 'Healthy'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<VehicleData> get _filteredVehicles {
    // Always sort by urgency: critical first
    final sorted = List<VehicleData>.from(FleetData.vehicles)
      ..sort((a, b) {
        final order = {
          VehicleStatus.critical: 0,
          VehicleStatus.warning: 1,
          VehicleStatus.healthy: 2
        };
        return order[a.status]!.compareTo(order[b.status]!);
      });

    switch (_tabController.index) {
      case 1: return sorted.where((v) => v.status == VehicleStatus.critical).toList();
      case 2: return sorted.where((v) => v.status == VehicleStatus.warning).toList();
      case 3: return sorted.where((v) => v.status == VehicleStatus.healthy).toList();
      default: return sorted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildVehicleList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vehicle Triage',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AdminTheme.textPrimary,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 2),
          Text('${FleetData.totalVehicles} vehicles sorted by urgency',
              style: const TextStyle(
                fontSize: 11,
                color: AdminTheme.textSecondary,
              )),
          const SizedBox(height: 12),
          // Summary pills
          Row(
            children: [
              _summaryPill('${FleetData.criticalCount} Critical', AdminTheme.red),
              const SizedBox(width: 8),
              _summaryPill('${FleetData.warningCount} Warning', AdminTheme.amber),
              const SizedBox(width: 8),
              _summaryPill('${FleetData.healthyCount} Healthy', AdminTheme.green),
              const SizedBox(width: 8),
              _summaryPill('${FleetData.chargingCount} Charging', AdminTheme.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AdminTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AdminTheme.border),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AdminTheme.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AdminTheme.textMuted,
          labelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
          ),
          dividerColor: Colors.transparent,
          tabs: _tabs.map((t) => Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (t == 'Critical')
                  Container(
                    width: 6, height: 6, margin: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                      color: AdminTheme.red, shape: BoxShape.circle,
                    ),
                  ),
                Text(t),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    final vehicles = _filteredVehicles;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildVehicleCard(vehicles[index]),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleData v) {
    Color borderColor;
    switch (v.status) {
      case VehicleStatus.critical: borderColor = AdminTheme.red.withOpacity(0.35); break;
      case VehicleStatus.warning: borderColor = AdminTheme.amber.withOpacity(0.25); break;
      default: borderColor = AdminTheme.border;
    }

    return AdminCard(
      borderColor: borderColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Row 1: ID + Status + Location
          Row(
            children: [
              Text(v.id,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.textPrimary,
                    letterSpacing: -0.3,
                  )),
              const SizedBox(width: 10),
              AdminBadge(status: v.status),
              const Spacer(),
              if (v.isCharging)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdminTheme.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('⚡ Charging',
                      style: TextStyle(
                        color: AdminTheme.blue,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Driver + Location
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  color: AdminTheme.textMuted, size: 12),
              const SizedBox(width: 4),
              Text(v.driverName,
                  style: const TextStyle(
                    fontSize: 11, color: AdminTheme.textSecondary,
                  )),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_rounded,
                  color: AdminTheme.textMuted, size: 12),
              const SizedBox(width: 4),
              Text(v.location,
                  style: const TextStyle(
                    fontSize: 11, color: AdminTheme.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          // Metrics row
          Row(
            children: [
              _metricChip('SoC', '${v.soc.toInt()}%',
                  v.soc < 20 ? AdminTheme.red : AdminTheme.textSecondary),
              const SizedBox(width: 8),
              _metricChip('Range', '${v.range.toInt()}km', AdminTheme.textSecondary),
              const SizedBox(width: 8),
              _metricChip('Temp', '${v.battTemp}°C',
                  v.battTemp > 40 ? AdminTheme.red : v.battTemp > 35 ? AdminTheme.amber : AdminTheme.textSecondary),
              const SizedBox(width: 8),
              _metricChip('Score', '${v.driverScore}/100',
                  v.driverScore < 55 ? AdminTheme.red : v.driverScore < 70 ? AdminTheme.amber : AdminTheme.green),
            ],
          ),
          if (v.predictedFailure != 'None') ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AdminTheme.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminTheme.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.report_rounded,
                      color: AdminTheme.red, size: 12),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Predicted: ${v.predictedFailure}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminTheme.red,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AdminTheme.bgCardSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  letterSpacing: -0.2,
                )),
            Text(label,
                style: const TextStyle(
                  fontSize: 9,
                  color: AdminTheme.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}