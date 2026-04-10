import 'package:flutter/material.dart';
import 'dart:math' as math;

class AarogyaLogoDynamic extends StatefulWidget {
  final double size;
  final bool animate;

  const AarogyaLogoDynamic({
    super.key,
    this.size = 120,
    this.animate = true,
  });

  @override
  State<AarogyaLogoDynamic> createState() => _AarogyaLogoDynamicState();
}

class _AarogyaLogoDynamicState extends State<AarogyaLogoDynamic> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AarogyaLogoDynamic oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DYNAMIC THEME AWARENESS
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _AarogyaLogoPainter(
            animationValue: Curves.easeInOut.transform(_controller.value),
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _AarogyaLogoPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  _AarogyaLogoPainter({
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 512;
    
    // NOTE: Transparent background! We are NOT drawing a background rect anymore.

    final double cx = 256 * scale;
    final double cy = 340 * scale;

    final double innerPulse = 1.0 + (animationValue * 0.1);
    final double outerPulse = 1.0 + (animationValue * 0.05);

    // Inner Arc & Dot are always Teal in both themes
    final Color tealColor = const Color(0xFF10B981);
    
    // Outer arc depends on the theme!
    // Cream in Dark Mode, Deep Navy in Light Mode
    final Color outerColor = isDark ? const Color(0xFFFEF3C7) : const Color(0xFF111827);

    final Paint innerPaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40 * scale
      ..strokeCap = StrokeCap.round;
      
    final innerRect = Rect.fromCircle(center: Offset(cx, cy), radius: 66 * scale * innerPulse);
    canvas.drawArc(innerRect, math.pi, math.pi, false, innerPaint);

    final Paint dotPaint = Paint()
      ..color = tealColor
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(cx, cy), 24 * scale * innerPulse, dotPaint);

    final Paint outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40 * scale
      ..strokeCap = StrokeCap.round;
      
    final outerRect = Rect.fromCircle(center: Offset(cx, cy), radius: 136 * scale * outerPulse);
    canvas.drawArc(outerRect, math.pi, math.pi, false, outerPaint);
  }

  @override
  bool shouldRepaint(covariant _AarogyaLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isDark != isDark;
  }
}
