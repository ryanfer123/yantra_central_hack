// lib/widgets/admin_widgets.dart
import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';
import '../models/fleet_data.dart';

// ── Admin Card ────────────────────────────────────────────────────────────────
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  const AdminCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AdminTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AdminTheme.border,
          width: 1,
        ),
      ),
      padding: padding ?? const EdgeInsets.all(18),
      child: child,
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class AdminBadge extends StatelessWidget {
  final VehicleStatus status;

  const AdminBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case VehicleStatus.critical: return AdminTheme.red;
      case VehicleStatus.warning: return AdminTheme.amber;
      case VehicleStatus.healthy: return AdminTheme.green;
    }
  }

  String get _label {
    switch (status) {
      case VehicleStatus.critical: return '● CRITICAL';
      case VehicleStatus.warning: return '● WARNING';
      case VehicleStatus.healthy: return '● HEALTHY';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(_label,
          style: TextStyle(
            color: _color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          )),
    );
  }
}

// ── Priority Badge ────────────────────────────────────────────────────────────
class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case 'HIGH': return AdminTheme.red;
      case 'MEDIUM': return AdminTheme.amber;
      default: return AdminTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(priority,
          style: TextStyle(
            color: _color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          )),
    );
  }
}

// ── Admin Stat Tile ───────────────────────────────────────────────────────────
class AdminStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;
  final String? delta;

  const AdminStatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              if (delta != null)
                Flexible(
                  child: Text(delta!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: delta!.startsWith('+')
                            ? AdminTheme.red
                            : AdminTheme.green,
                        fontWeight: FontWeight.w600,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminTheme.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                fontSize: 10,
                color: AdminTheme.textSecondary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              )),
        ],
      ),
    );
  }
}

// ── Admin Section Header ──────────────────────────────────────────────────────
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(width: 3, height: 14,
              decoration: BoxDecoration(
                color: AdminTheme.blue,
                borderRadius: BorderRadius.circular(2),
              )),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 11,
                color: AdminTheme.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              )),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Admin Progress Bar ────────────────────────────────────────────────────────
class AdminProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const AdminProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AdminTheme.border,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: constraints.maxWidth * value.clamp(0.0, 1.0),
            height: height,
            decoration: BoxDecoration(
              color: color ?? AdminTheme.blue,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Scrolling Alert Ticker ────────────────────────────────────────────────────
class AlertTicker extends StatefulWidget {
  final List<String> alerts;

  const AlertTicker({super.key, required this.alerts});

  @override
  State<AlertTicker> createState() => _AlertTickerState();
}

class _AlertTickerState extends State<AlertTicker>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!mounted) return;
    setState(() => _isScrolling = true);
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted || !_scrollController.hasClients) break;
      final maxScroll = _scrollController.position.maxScrollExtent;
      await _scrollController.animateTo(
        maxScroll,
        duration: Duration(milliseconds: (maxScroll * 12).toInt()),
        curve: Curves.linear,
      );
      if (!mounted) break;
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) break;
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AdminTheme.red.withOpacity(0.08),
        border: Border.all(color: AdminTheme.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AdminTheme.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                bottomLeft: Radius.circular(9),
              ),
            ),
            child: const Text('LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.alerts.map((alert) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(alert,
                      style: const TextStyle(
                        color: AdminTheme.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      )),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}