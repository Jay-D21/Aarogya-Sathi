import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (auth.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppTheme.accentRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(auth.error!, style: const TextStyle(color: AppTheme.accentRed)),
              ),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'First Name *', prefixIcon: Icon(Icons.person_outlined))),
            const SizedBox(height: 16),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email *', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 16),
            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone (+91...) *', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 16),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Password (min 8 chars) *', prefixIcon: Icon(Icons.lock_outlined))),
            const SizedBox(height: 16),
            TextField(controller: _cityCtrl, decoration: const InputDecoration(hintText: 'City (optional)', prefixIcon: Icon(Icons.location_city_outlined))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : () async {
                  final ok = await auth.register(
                    email: _emailCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    password: _passCtrl.text,
                    firstName: _nameCtrl.text.trim(),
                    city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
                  );
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful! Please login.')));
                    Navigator.pop(context);
                  }
                },
                child: auth.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
