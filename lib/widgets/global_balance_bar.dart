import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/robux_tier.dart';
import '../services/award_events.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import 'robux_icon.dart';

/// Balance pill pinned to the top-right of every screen, plus the coin that
/// flies into it whenever the user earns points.
///
/// Mounted from `MaterialApp.builder` so it sits above the Navigator and stays
/// on screen through pushes, pops and dialogs.
class GlobalBalanceBar extends StatefulWidget {
  const GlobalBalanceBar({super.key});

  @override
  State<GlobalBalanceBar> createState() => _GlobalBalanceBarState();
}

class _GlobalBalanceBarState extends State<GlobalBalanceBar>
    with TickerProviderStateMixin {
  final List<_Flight> _flights = [];

  /// Pulses the pill as each coin lands.
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    AwardEvents().tick.addListener(_onAward);
  }

  @override
  void dispose() {
    AwardEvents().tick.removeListener(_onAward);
    for (final f in _flights) {
      f.ctrl.dispose();
    }
    _pulse.dispose();
    super.dispose();
  }

  void _onAward() {
    if (!mounted) return;
    final amount = AwardEvents().lastCoins;

    final ctrl = AnimationController(
      duration: const Duration(milliseconds: 1250),
      vsync: this,
    );
    final flight = _Flight(ctrl: ctrl, amount: amount);
    setState(() => _flights.add(flight));

    // Pulse the pill just as the coin arrives.
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _pulse.forward(from: 0);
    });

    ctrl.forward().then((_) {
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() => _flights.remove(flight));
      ctrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    // Splash and pre-onboarding have no account yet — nothing to show.
    if (user == null) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    final topPad = media.padding.top;
    final robux = robuxEarned(user.coins) + user.bonusRobux;

    // Where the coins land: the centre of the pill.
    final targetX = media.size.width - 72;
    final targetY = topPad + 26;

    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            for (final f in _flights)
              _FlyingCoin(
                flight: f,
                targetX: targetX,
                targetY: targetY,
                screen: media.size,
              ),
            Positioned(
              top: topPad + 8,
              right: 12,
              child: _pill(robux),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(int robux) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) {
        final t = math.sin(_pulse.value * math.pi);
        return Transform.scale(scale: 1 + t * 0.18, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.purpleGlow,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.38),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RobuxIcon(size: 15, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              formatAmount(robux),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings.currency,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Flight {
  _Flight({required this.ctrl, required this.amount});
  final AnimationController ctrl;
  final int amount;
}

class _FlyingCoin extends StatelessWidget {
  const _FlyingCoin({
    required this.flight,
    required this.targetX,
    required this.targetY,
    required this.screen,
  });

  final _Flight flight;
  final double targetX, targetY;
  final Size screen;

  @override
  Widget build(BuildContext context) {
    // Phase 1 (0–0.30): the coin pops in mid-screen.
    // Phase 2 (0.38–1.0): it arcs up into the balance pill.
    final pop = CurvedAnimation(
      parent: flight.ctrl,
      curve: const Interval(0.0, 0.30, curve: Curves.elasticOut),
    );
    final fly = CurvedAnimation(
      parent: flight.ctrl,
      curve: const Interval(0.38, 1.0, curve: Curves.easeInCubic),
    );
    final labelFade = CurvedAnimation(
      parent: flight.ctrl,
      curve: const Interval(0.38, 0.70, curve: Curves.easeOut),
    );

    final startX = screen.width / 2;
    final startY = screen.height * 0.5;

    return AnimatedBuilder(
      animation: flight.ctrl,
      builder: (_, __) {
        final t = fly.value;
        final x = startX + (targetX - startX) * t;
        final y = startY +
            (targetY - startY) * t -
            math.sin(t * math.pi) * screen.height * 0.07;
        final scale = (0.3 + pop.value * 0.7) * (1 - t * 0.68);

        return Stack(
          children: [
            Positioned(
              left: x - 30,
              top: y - 30,
              child: Transform.scale(
                scale: scale.clamp(0.0, 2.0),
                child: _coin(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: startY + 44,
              child: Opacity(
                opacity: (1 - labelFade.value).clamp(0.0, 1.0) *
                    pop.value.clamp(0.0, 1.0),
                child: Center(child: _label()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _coin() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: AppColors.goldGlow,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.7),
            blurRadius: 22,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(child: RobuxIcon(size: 32, color: Colors.white)),
    );
  }

  Widget _label() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 14),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RobuxIcon(size: 17, color: AppColors.textDark),
          const SizedBox(width: 7),
          Text(
            '+${formatAmount(flight.amount)} pts',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
