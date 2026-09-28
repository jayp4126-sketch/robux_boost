import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// The Robux logo, gated by the `show_full_experience` remote flag.
///
/// Renders nothing when the flag is off, so every call site drops the artwork
/// without each one having to check the flag itself.
class RobuxIcon extends StatelessWidget {
  const RobuxIcon({super.key, required this.size, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!AppStrings.showRobuxIcons) return const SizedBox.shrink();
    return Image.asset(
      'assets/images/robux_logo.png',
      width: size,
      height: size,
      color: color,
    );
  }
}
