import 'package:flutter/material.dart';
import '../config/theme.dart';

/// A surface card — clean solid background with optional border and gradient accent.
/// Theme-aware: adapts to dark/light mode automatically.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool withBorder;
  final Color? overrideColor;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.withBorder = true,
    this.overrideColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = overrideColor ??
        (isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light);
    final border = isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle;
    final radius = borderRadius ?? BorderRadius.circular(AppTheme.radiusLg);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppTheme.sp16),
      decoration: BoxDecoration(
        color: gradient == null ? bg : null,
        gradient: gradient,
        borderRadius: radius,
        border: withBorder ? Border.all(color: border, width: 1) : null,
        boxShadow: isDark ? AppTheme.cardShadow : AppTheme.cardShadowLight,
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
          child: card,
        ),
      );
    }

    return card;
  }
}
