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

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.health_and_safety, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text('Aarogya Sathi', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                const SizedBox(height: 8),
                Text('Your AI Health Companion', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 40),

                // Error
                if (auth.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppTheme.accentRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(auth.error!, style: const TextStyle(color: AppTheme.accentRed)),
                  ),

                // Email
                TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : () async {
                      final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
                      if (ok && mounted) Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: auth.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.inter(color: AppTheme.textSecondary),
                      children: [TextSpan(text: 'Register', style: GoogleFonts.inter(color: AppTheme.primaryTeal, fontWeight: FontWeight.w600))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
