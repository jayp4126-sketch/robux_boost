import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/robux_icon.dart';

/// Plays a "+N Robux" burst that flies up into the balance pill at the top.
void showRobuxAward(BuildContext context, {int amount = 500}) =>
    insertRobuxAward(Overlay.of(context, rootOverlay: true), amount: amount);

/// Same, but against an overlay captured earlier — use this when the screen
/// that triggers the award is replaced before the animation should play.
void insertRobuxAward(OverlayState overlay, {int amount = 500}) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => RobuxAwardOverlay(
      amount: amount,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class RobuxAwardOverlay extends StatefulWidget {
  const RobuxAwardOverlay({super.key, required this.amount, required this.onDone});

  final int amount;
  final VoidCallback onDone;

  @override
  State<RobuxAwardOverlay> createState() => _RobuxAwardOverlayState();
}

class _RobuxAwardOverlayState extends State<RobuxAwardOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase 1 (0.0–0.45): badge pops in the middle of the screen.
  // Phase 2 (0.45–1.0): it shrinks and flies into the balance pill.
  late final Animation<double> _pop;
  late final Animation<double> _fly;
  late final Animation<double> _badgeFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1900),
      vsync: this,
    );
    _pop = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.28, curve: Curves.elasticOut),
    );
    _fly = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInCubic),
    );
    _badgeFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 0.78, curve: Curves.easeOut),
    );
    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    // Start: centre of the screen. End: the balance pill inside the header card.
    final startX = size.width / 2;
    final startY = size.height * 0.46;
    final endX = size.width * 0.28;
    final endY = topPad + 150;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _fly.value;
          // Slight arc on the way up.
          final x = startX + (endX - startX) * t;
          final y = startY +
              (endY - startY) * t -
              math.sin(t * math.pi) * size.height * 0.06;
          final scale = (0.2 + _pop.value * 0.8) * (1 - t * 0.72);

          return Stack(
            children: [
              // Dim flash behind the burst.
              Opacity(
                opacity: (1 - _ctrl.value) * 0.35,
                child: Container(color: Colors.black),
              ),
              Positioned(
                left: x - 60,
                top: y - 60,
                child: Transform.scale(
                  scale: scale.clamp(0.0, 2.0),
                  child: _coin(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: startY + 70,
                child: Opacity(
                  opacity: (1 - _badgeFade.value).clamp(0.0, 1.0) * _pop.value.clamp(0.0, 1.0),
                  child: Center(child: _label()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _coin() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: AppColors.goldGlow,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.75),
            blurRadius: 34,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: RobuxIcon(size: 64, color: Colors.white),
      ),
    );
  }

  Widget _label() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RobuxIcon(size: 22, color: AppColors.textDark),
          const SizedBox(width: 9),
          Text(
            '+${widget.amount} Robux',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
