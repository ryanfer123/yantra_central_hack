// lib/widgets/animations.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. PAGE TRANSITIONS
// ─────────────────────────────────────────────────────────────────────────────

/// Slide up + fade — use for going deeper (role → BT → main)
class SlideUpFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideUpFadeRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      final fade = Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Fade only — use for same-level switches (role selection)
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// Scale + fade — premium feel for dashboard entry
class ScaleFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  ScaleFadeRoute({required this.page})
      : super(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (_, animation, __, child) {
      final scale = Tween<double>(begin: 0.94, end: 1.0)
          .animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. STAGGERED ENTRY — cards slide in one by one
// ─────────────────────────────────────────────────────────────────────────────

class StaggeredEntry extends StatefulWidget {
  final Widget child;
  final int index;           // position in list → controls delay
  final double offsetY;      // how far it starts from (px)
  final Duration baseDuration;

  const StaggeredEntry({
    super.key,
    required this.child,
    required this.index,
    this.offsetY = 24,
    this.baseDuration = const Duration(milliseconds: 400),
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: widget.baseDuration,
      vsync: this,
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 200),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger delay based on index
    Future.delayed(Duration(milliseconds: 80 + (widget.index * 70)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. ANIMATED COUNTER — numbers count up from 0 to value
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedCounter extends StatefulWidget {
  final double value;
  final String suffix;
  final String prefix;
  final int decimals;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.prefix = '',
    this.decimals = 0,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: widget.duration, vsync: this);
    _anim = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _ctrl.forward();
    });
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (widget.value != _previousValue) {
      _anim = Tween<double>(begin: _previousValue, end: widget.value)
          .animate(CurvedAnimation(
          parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
      _previousValue = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final display = widget.decimals > 0
            ? _anim.value.toStringAsFixed(widget.decimals)
            : _anim.value.toInt().toString();
        return Text(
          '${widget.prefix}$display${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. LIVE PULSE DOT — shows data is live from BLE
// ─────────────────────────────────────────────────────────────────────────────

class LivePulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const LivePulseDot({
    super.key,
    this.color = AppTheme.successGreen,
    this.size = 8,
  });

  @override
  State<LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<LivePulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scale = Tween<double>(begin: 1.0, end: 2.2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.6, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple ring
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
          // Solid center dot
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. SHIMMER BOX — skeleton loading placeholder
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
    _anim = Tween<double>(begin: -1, end: 2).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              (_anim.value - 1).clamp(0.0, 1.0),
              _anim.value.clamp(0.0, 1.0),
              (_anim.value + 1).clamp(0.0, 1.0),
            ],
            colors: const [
              Color(0xFFEEEEEE),
              Color(0xFFF8F8F8),
              Color(0xFFEEEEEE),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. HAPTIC FEEDBACK WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class HapticTap extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final HapticFeedbackType type;

  const HapticTap({
    super.key,
    required this.child,
    required this.onTap,
    this.type = HapticFeedbackType.light,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        switch (type) {
          case HapticFeedbackType.light:
            HapticFeedback.lightImpact();
            break;
          case HapticFeedbackType.medium:
            HapticFeedback.mediumImpact();
            break;
          case HapticFeedbackType.heavy:
            HapticFeedback.heavyImpact();
            break;
          case HapticFeedbackType.selection:
            HapticFeedback.selectionClick();
            break;
        }
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

enum HapticFeedbackType { light, medium, heavy, selection }

// ─────────────────────────────────────────────────────────────────────────────
// 7. SCREEN ENTRY WRAPPER — wraps entire screen with fade+slide on mount
// ─────────────────────────────────────────────────────────────────────────────

class ScreenEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const ScreenEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<ScreenEntry> createState() => _ScreenEntryState();
}

class _ScreenEntryState extends State<ScreenEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}