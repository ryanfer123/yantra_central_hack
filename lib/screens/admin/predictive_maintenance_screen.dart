// lib/screens/admin/predictive_maintenance_screen.dart
import 'package:flutter/material.dart';
import '../../../theme/admin_theme.dart';
import '../../../models/fleet_data.dart';
import '../../../widgets/admin_widgets.dart';

class PredictiveMaintenanceScreen extends StatelessWidget {
  const PredictiveMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = FleetData.maintenanceTickets;
    final immediate = tickets.where((t) => t.status == MaintenanceStatus.immediate).toList();
    final scheduled = tickets.where((t) => t.status == MaintenanceStatus.scheduled).toList();
    final monitoring = tickets.where((t) => t.status == MaintenanceStatus.monitoring).toList();

    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(tickets.length, immediate.length),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildSummaryRow(immediate.length, scheduled.length, monitoring.length),
                  const SizedBox(height: 16),
                  if (immediate.isNotEmpty) ...[
                    _buildTicketGroup('IMMEDIATE ACTION REQUIRED', AdminTheme.red, immediate),
                    const SizedBox(height: 16),
                  ],
                  if (scheduled.isNotEmpty) ...[
                    _buildTicketGroup('SCHEDULED MAINTENANCE', AdminTheme.amber, scheduled),
                    const SizedBox(height: 16),
                  ],
                  if (monitoring.isNotEmpty) ...[
                    _buildTicketGroup('MONITORING', AdminTheme.textMuted, monitoring),
                    const SizedBox(height: 16),
                  ],
                  _buildMaintenanceMatrix(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(int total, int immediate) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: AdminTheme.bg,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Predictive Maintenance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AdminTheme.textPrimary,
                letterSpacing: -0.4,
              )),
          Text('$total open tickets · $immediate critical',
              style: TextStyle(
                fontSize: 11,
                color: immediate > 0 ? AdminTheme.red : AdminTheme.textSecondary,
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(int imm, int sched, int mon) {
    return Row(
      children: [
        Expanded(child: AdminStatTile(
          label: 'Immediate', value: '$imm',
          unit: 'tickets', icon: Icons.emergency_rounded,
          color: AdminTheme.red,
        )),
        const SizedBox(width: 10),
        Expanded(child: AdminStatTile(
          label: 'Scheduled', value: '$sched',
          unit: 'tickets', icon: Icons.calendar_today_rounded,
          color: AdminTheme.amber,
        )),
        const SizedBox(width: 10),
        Expanded(child: AdminStatTile(
          label: 'Monitoring', value: '$mon',
          unit: 'items', icon: Icons.radar_rounded,
          color: AdminTheme.textSecondary,
        )),
      ],
    );
  }

  Widget _buildTicketGroup(String title, Color color, List<MaintenanceTicket> tickets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(title: title),
        const SizedBox(height: 8),
        ...tickets.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildTicketCard(t, color),
        )),
      ],
    );
  }

  Widget _buildTicketCard(MaintenanceTicket ticket, Color groupColor) {
    return AdminCard(
      borderColor: groupColor.withOpacity(0.25),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AdminTheme.bgCardSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: Text(ticket.vehicleId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AdminTheme.textPrimary,
                      letterSpacing: -0.2,
                    )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(ticket.metric,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AdminTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              PriorityBadge(priority: ticket.priority),
            ],
          ),
          const SizedBox(height: 10),
          // Condition
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: groupColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: groupColor.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sensors_rounded, color: groupColor, size: 13),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(ticket.condition,
                      style: TextStyle(
                        fontSize: 11,
                        color: groupColor,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Action
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AdminTheme.textMuted, size: 10),
              const SizedBox(width: 6),
              Expanded(
                child: Text(ticket.action,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminTheme.textSecondary,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionButton('Acknowledge', AdminTheme.blue),
              const SizedBox(width: 8),
              _actionButton('Assign Tech', AdminTheme.bgCardSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color bg) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: bg == AdminTheme.bgCardSecondary
              ? Border.all(color: AdminTheme.border)
              : null,
        ),
        child: Text(label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textPrimary,
            )),
      ),
    );
  }

  Widget _buildMaintenanceMatrix() {
    final rows = [
      ['Cell Imbalance [#12]', '>50mV consistent', 'Balance Required', 'Overnight slow charge'],
      ['Thermal Gradient [#16]', 'Spike >5°C', 'Cooling Anomaly', 'Inspect thermal paste'],
      ['Coolant Flow [#19]', 'Drop vs RPM', 'Pump Failure Risk', 'Order part #TM-4821'],
      ['Cycle Count [#8]', '>1200 cycles', 'End of Life Soon', 'Budget Q3 replacement'],
      ['Insulation [#20]', '<50 MΩ', 'Shock Risk', 'Ground vehicle now'],
    ];

    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionHeader(title: 'AUTOMATED DETECTION MATRIX'),
          const SizedBox(height: 12),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AdminTheme.bgCardSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('METRIC', style: TextStyle(fontSize: 9, color: AdminTheme.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.6))),
                Expanded(flex: 2, child: Text('TRIGGER', style: TextStyle(fontSize: 9, color: AdminTheme.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.6))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 9, color: AdminTheme.textMuted, fontWeight: FontWeight.w700, letterSpacing: 0.6))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...rows.asMap().entries.map((entry) {
            final row = entry.value;
            final isLast = entry.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(row[0],
                          style: const TextStyle(fontSize: 10, color: AdminTheme.textPrimary, fontWeight: FontWeight.w500))),
                      Expanded(flex: 2, child: Text(row[1],
                          style: const TextStyle(fontSize: 10, color: AdminTheme.amber))),
                      Expanded(flex: 2, child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AdminTheme.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(row[2],
                            style: const TextStyle(fontSize: 9, color: AdminTheme.blue, fontWeight: FontWeight.w600)),
                      )),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, color: AdminTheme.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}