import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

/// Google Fit–style arc ring showing health score, steps, and calories.
class HealthScoreRing extends StatefulWidget {
  final double score;   // 0–100
  final int steps;
  final int calories;

  const HealthScoreRing({
    super.key,
    required this.score,
    required this.steps,
    required this.calories,
  });

  @override
  State<HealthScoreRing> createState() => _HealthScoreRingState();
}

class _HealthScoreRingState extends State<HealthScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _progress = Tween<double>(begin: 0, end: (widget.score / 100).clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(HealthScoreRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _progress = Tween<double>(
        begin: _progress.value,
        end: (widget.score / 100).clamp(0, 1),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl
        ..reset()
        ..forward();
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
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ring
              SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: _progress.value,
                    isDark: isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.score.toStringAsFixed(0),
                          style: GoogleFonts.outfit(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryTeal,
                            height: 1,
                          ),
                        ),
                        Text(
                          'Health Score',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textSec,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(
                    icon: Icons.directions_walk_rounded,
                    color: AppTheme.primaryTeal,
                    value: _fmt(widget.steps),
                    label: 'Steps',
                    textPri: textPri,
                    textSec: textSec,
                  ),
                  _VDivider(isDark: isDark),
                  _Stat(
                    icon: Icons.local_fire_department_rounded,
                    color: AppTheme.accentOrange,
                    value: _fmt(widget.calories),
                    label: 'Kcal',
                    textPri: textPri,
                    textSec: textSec,
                  ),
                  _VDivider(isDark: isDark),
                  _Stat(
                    icon: Icons.favorite_rounded,
                    color: AppTheme.accentRed,
                    value: '--',
                    label: 'BPM',
                    textPri: textPri,
                    textSec: textSec,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int v) =>
      v > 999 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, label;
  final Color textPri, textSec;
  const _Stat({
    required this.icon, required this.color, required this.value,
    required this.label, required this.textPri, required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: textPri)),
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: textSec)),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  final bool isDark;
  const _VDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 36,
      color: isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle,
    );
  }
}

// ── Ring Painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _RingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final outerR = size.width / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: outerR);

    // Track ring
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = isDark
          ? const Color(0xFF1A2436)
          : const Color(0xFFE5EEF5);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, trackPaint);

    // Progress arc (gradient)
    if (progress > 0) {
      final gradPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi,
          colors: const [
            AppTheme.primaryTeal,
            AppTheme.primaryCyan,
            AppTheme.primaryTeal,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect);

      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, gradPaint);

      // Glowing tip
      final tipAngle = -math.pi / 2 + 2 * math.pi * progress;
      final tipX = center.dx + outerR * math.cos(tipAngle);
      final tipY = center.dy + outerR * math.sin(tipAngle);
      final glowPaint = Paint()
        ..color = AppTheme.primaryTeal.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(tipX, tipY), 10, glowPaint);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(tipX, tipY), 5, dotPaint);
    }

    // Inner light ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = isDark
          ? AppTheme.primaryTeal.withValues(alpha: 0.1)
          : AppTheme.primaryTeal.withValues(alpha: 0.07);
    canvas.drawCircle(center, outerR - 24, innerPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
