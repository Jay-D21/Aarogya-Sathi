import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/health_provider.dart';

class HealthDashboard extends StatelessWidget {
  const HealthDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(context, Icons.bloodtype, 'Blood Pressure', 'Log & track your BP readings', AppTheme.accentRed, () => _showBPDialog(context)),
            const SizedBox(height: 12),
            _buildCard(context, Icons.water_drop, 'Blood Sugar', 'Monitor glucose levels', AppTheme.accentOrange, () => _showSugarDialog(context)),
            const SizedBox(height: 12),
            _buildCard(context, Icons.monitor_weight, 'Weight', 'Track weight & BMI', AppTheme.primaryTeal, () => _showWeightDialog(context)),
            const SizedBox(height: 12),
            _buildCard(context, Icons.sick, 'Symptoms', 'Log how you\'re feeling', AppTheme.accentYellow, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext ctx, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showBPDialog(BuildContext context) {
    final sysCtrl = TextEditingController();
    final diaCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Log Blood Pressure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: sysCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Systolic (e.g. 120)')),
            const SizedBox(height: 12),
            TextField(controller: diaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Diastolic (e.g. 80)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final sys = int.tryParse(sysCtrl.text);
              final dia = int.tryParse(diaCtrl.text);
              if (sys != null && dia != null) {
                final result = await context.read<HealthProvider>().logBP(sys, dia);
                Navigator.pop(ctx);
                if (result != null) {
                  final status = result['status'] as Map<String, dynamic>?;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('BP logged! Status: ${status?['status'] ?? 'Recorded'}'),
                    backgroundColor: _statusColor(status?['color']),
                  ));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSugarDialog(BuildContext context) {
    final valueCtrl = TextEditingController();
    String type = 'fasting';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Log Blood Sugar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: valueCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Glucose (mg/dL)')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(hintText: 'Reading Type'),
                items: const [
                  DropdownMenuItem(value: 'fasting', child: Text('Fasting')),
                  DropdownMenuItem(value: 'random', child: Text('Random')),
                  DropdownMenuItem(value: 'post_meal', child: Text('Post-meal')),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final val = int.tryParse(valueCtrl.text);
                if (val != null) {
                  final result = await context.read<HealthProvider>().logSugar(val, type);
                  Navigator.pop(ctx);
                  if (result != null) {
                    final status = result['status'] as Map<String, dynamic>?;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sugar logged! Status: ${status?['status'] ?? 'Recorded'}')));
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Log Weight'),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Weight (kg)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight logged!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String? color) {
    switch (color) {
      case 'green': return AppTheme.accentGreen;
      case 'yellow': return AppTheme.accentYellow;
      case 'orange': return AppTheme.accentOrange;
      case 'red': return AppTheme.accentRed;
      default: return AppTheme.primaryTeal;
    }
  }
}
