import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _ringAnim;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _dotFade;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));

    _ringAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOut)));
    _taglineSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic)));
    _dotFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _contentCtrl,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    _ringCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300),
        () { if (mounted) _contentCtrl.forward(); });

    // Navigate after 2.8s
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    // Wait up to 2 seconds for auth check to finish (fixes race condition)
    int waited = 0;
    while (auth.isLoading && waited < 2000) {
      await Future.delayed(const Duration(milliseconds: 100));
      waited += 100;
    }
    if (!mounted) return;

    if (auth.isLoggedIn) {
      // Guest users who haven't completed onboarding go back to it
      if (auth.needsOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background gradient blob
          Positioned(
            top: -100,
            right: -80,
            child: AnimatedBuilder(
              animation: _ringAnim,
              builder: (context, child) => Opacity(
                opacity: (_ringAnim.value * 0.6).clamp(0, 1),
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.primaryTeal.withValues(alpha: 0.2),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: AnimatedBuilder(
              animation: _ringAnim,
              builder: (context, child) => Opacity(
                opacity: (_ringAnim.value * 0.5).clamp(0, 1),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.accentPurple.withValues(alpha: 0.15),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated ring + logo
                AnimatedBuilder(
                  animation: _ringAnim,
                  builder: (_, child) => CustomPaint(
                    painter: _RingPainter(progress: _ringAnim.value),
                    child: child,
                  ),
                  child: AnimatedBuilder(
                    animation: _contentCtrl,
                    builder: (context, child) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value.clamp(0, 1),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: AppTheme.glowTeal(blur: 32, opacity: 0.4),
                          ),
                          child: const Center(
                            child: Icon(Icons.favorite_rounded,
                                size: 52, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (context, child) => Opacity(
                    opacity: _logoFade.value.clamp(0, 1),
                    child: ShaderMask(
                      shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                      child: Text(
                        'Aarogya Sathi',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Tagline
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (context, child) => FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Text(
                        'Your AI health companion',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading dots
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (context, child) => Opacity(
                    opacity: _dotFade.value.clamp(0, 1),
                    child: _LoadingDots(isDark: isDark),
                  ),
                ),
              ],
            ),
          ),

          // Bottom tagline
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _contentCtrl,
              builder: (context, child) => Opacity(
                opacity: _dotFade.value.clamp(0, 1),
                child: Text(
                  'ICMR-Guided · Privacy-First · Made for India',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ring painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 + 18;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.primaryTeal.withValues(alpha: progress * 0.4)
      ..shader = SweepGradient(
        colors: [
          AppTheme.primaryTeal.withValues(alpha: progress),
          AppTheme.primaryCyan.withValues(alpha: progress * 0.3),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );

    // Outer glow ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.primaryTeal.withValues(alpha: progress * 0.15);
    canvas.drawCircle(center, radius + 12, glowPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ── Loading dots ─────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  final bool isDark;
  const _LoadingDots({required this.isDark});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_ctrl.value - i * 0.15) % 1.0).clamp(0.0, 1.0);
          final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.translate(
              offset: Offset(0, -8 * bounce),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryTeal
                      .withValues(alpha: 0.4 + 0.6 * bounce),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
