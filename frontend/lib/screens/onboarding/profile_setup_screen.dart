import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0;
  
  // Step 1
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Male';

  // Step 2
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _city = 'Delhi';
  final _cities = ['Delhi', 'Mumbai', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad', 'Pune'];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_nameCtrl.text.trim().isEmpty || _ageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _finish() async {
    if (_heightCtrl.text.trim().isEmpty || _weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final height = double.tryParse(_heightCtrl.text) ?? 170.0;
    final weight = double.tryParse(_weightCtrl.text) ?? 70.0;
    final heightM = height / 100.0;
    final bmi = double.parse((weight / (heightM * heightM)).toStringAsFixed(1));

    await auth.updateProfile({
      'first_name': _nameCtrl.text.trim(),
      'age': int.tryParse(_ageCtrl.text) ?? 25,
      'gender': _gender,
      'height_cm': height,
      'weight_kg': weight,
      'bmi': bmi,
      'preferred_city': _city,
    });

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppTheme.bgOf(context);
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                children: [
                  Expanded(child: _ProgressBar(active: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _ProgressBar(active: _step >= 1)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0 ? _buildStep1(textPri, textSec) : _buildStep2(textPri, textSec),
                ),
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_step == 0 ? _nextStep : _finish),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_step == 0 ? 'Continue' : 'Start My Journey', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(Color textPri, Color textSec) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Let\'s get to know you', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: textPri, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('We use this data to tailor your health insights.', style: GoogleFonts.inter(fontSize: 14, color: textSec)),
        const SizedBox(height: 32),
        
        TextField(
          controller: _nameCtrl,
          style: GoogleFonts.inter(color: textPri),
          decoration: const InputDecoration(labelText: 'First Name', prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ageCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(color: textPri),
          decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake_outlined)),
        ),
        const SizedBox(height: 24),
        Text('Gender', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textSec)),
        const SizedBox(height: 12),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g),
                selected: _gender == g,
                onSelected: (val) { if (val) setState(() => _gender = g); },
                selectedColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
                labelStyle: GoogleFonts.inter(color: _gender == g ? AppTheme.primaryTeal : textPri),
                showCheckmark: false,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2(Color textPri, Color textSec) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Physical Profile', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: textPri, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Required for BMI and calorie estimations.', style: GoogleFonts.inter(fontSize: 14, color: textSec)),
        const SizedBox(height: 32),
        
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: textPri),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(color: textPri),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('City (For AQI & Weather)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textSec)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _cities.contains(_city) ? _city : null,
                    hint: Text(_city, style: GoogleFonts.inter(color: textPri, fontSize: 14)),
                    isExpanded: true,
                    dropdownColor: AppTheme.cardBg(context),
                    style: GoogleFonts.inter(color: textPri, fontSize: 14),
                    items: _cities.map((String c) {
                      return DropdownMenuItem<String>(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (String? val) {
                      if (val != null) setState(() => _city = val);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.my_location_rounded, color: AppTheme.primaryTeal),
              tooltip: 'Detect City',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                    const SnackBar(content: Text('Detecting location...')));
                final city = await LocationService.getCityName();
                if (!context.mounted) return;

                if (city != null) {
                  // Defer setState to next frame to avoid DropdownButton assertion
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      if (!_cities.contains(city)) _cities.add(city);
                      _city = city;
                    });
                  });
                  messenger.showSnackBar(
                      SnackBar(content: Text('Detected: $city')));
                } else {
                  messenger.showSnackBar(const SnackBar(
                      content: Text(
                          'Could not detect location. Please select manually.')));
                }
              },
            )
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final bool active;
  const _ProgressBar({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryTeal : AppTheme.borderColor(context),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
