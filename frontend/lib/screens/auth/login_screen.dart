import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _emailTouched = false;
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Login failed'),
        backgroundColor: AppTheme.accentRed,
      ));
    }
  }

  void _guestLogin() {
    context.read<AuthProvider>().skipLogin();
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final bg = AppTheme.bgOf(context);
    final card = AppTheme.cardBg(context);
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo + brand
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: AppTheme.glowTeal(blur: 20, opacity: 0.35),
                            ),
                            child: const Icon(Icons.favorite_rounded,
                                size: 36, color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          ShaderMask(
                            shaderCallback: (b) =>
                                AppTheme.primaryGradient.createShader(b),
                            child: Text(
                              'Aarogya Sathi',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your AI Health Companion',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textSec,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        border: Border.all(
                            color: AppTheme.borderColor(context), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome back',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: textPri,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to continue your health journey',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textSec,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: textPri),
                            decoration: InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              errorText: _emailTouched &&
                                      _emailCtrl.text.isNotEmpty &&
                                      !_emailCtrl.text.contains('@')
                                  ? 'Enter a valid email'
                                  : null,
                            ),
                            onChanged: (_) {
                              if (!_emailTouched) setState(() => _emailTouched = true);
                            },
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email is required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: textPri),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Sign In button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusMd)),
                              ).copyWith(
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.white),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: auth.isLoading
                                      ? null
                                      : AppTheme.primaryGradient,
                                  color: auth.isLoading
                                      ? (isDark ? AppTheme.surfaceL2 : AppTheme.surfaceL2Light)
                                      : null,
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.primaryTeal,
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Create account
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: Text(
                              "Don't have an account? Create one",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(children: [
                      Expanded(
                          child: Divider(
                              color: AppTheme.borderColor(context))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: textSec)),
                      ),
                      Expanded(
                          child: Divider(
                              color: AppTheme.borderColor(context))),
                    ]),

                    const SizedBox(height: 20),

                    // Guest login
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _guestLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppTheme.borderColor(context), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 18, color: textSec),
                            const SizedBox(width: 8),
                            Text(
                              'Continue as Guest',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Disclaimer
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy. '
                      'This app is for informational purposes only — not medical diagnosis.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMutedOf(context),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
