import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// Compact animated metric card with gradient icon, arc progress, and value.
class AnimatedMetricCard extends StatefulWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final double progress; // 0.0 – 1.0
  final int delay;       // ms before animation starts

  const AnimatedMetricCard({
    super.key,
    required this.gradient,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.progress,
    this.delay = 0,
  });

  @override
  State<AnimatedMetricCard> createState() => _AnimatedMetricCardState();
}

class _AnimatedMetricCardState extends State<AnimatedMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _arcAnim;
  late Animation<double> _fadeAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900));

    _arcAnim = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _ctrl.forward();
      });
    } else {
      _ctrl.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedMetricCard old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _arcAnim = Tween<double>(
        begin: _arcAnim.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.reset();
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = AppTheme.cardBg(context);
    final border = AppTheme.borderColor(context);
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: AppTheme.durationFast,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) => Opacity(
            opacity: _fadeAnim.value.clamp(0, 1),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: border),
                boxShadow: isDark ? AppTheme.cardShadow : AppTheme.cardShadowLight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + arc progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: widget.gradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 16),
                      ),
                      // Mini arc
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CustomPaint(
                          painter: _ArcPainter(
                            progress: _arcAnim.value,
                            color: widget.gradient.colors.first,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Value
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.value,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPri,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          widget.unit,
                          style: GoogleFonts.inter(fontSize: 9, color: textSec),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textMutedOf(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mini arc CustomPainter ────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;
  _ArcPainter({required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: r);

    // Track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = isDark
          ? color.withValues(alpha: 0.15)
          : color.withValues(alpha: 0.1);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);

    // Progress
    if (progress > 0) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(
          rect, -math.pi / 2, 2 * math.pi * progress.clamp(0, 1), false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
