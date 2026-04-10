import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../providers/health_provider.dart';

import '../../providers/auth_provider.dart';

class HealthDashboard extends StatefulWidget {
  const HealthDashboard({super.key});

  @override
  State<HealthDashboard> createState() => _HealthDashboardState();
}

class _HealthDashboardState extends State<HealthDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _ctrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadRecords(days: 30);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = AppTheme.textPrimaryOf(context);
    final textSec = AppTheme.textSecondaryOf(context);
    final bg = AppTheme.bgOf(context);
    final card = AppTheme.cardBg(context);
    final card2 = AppTheme.cardBg2(context);
    final border = AppTheme.borderColor(context);

    final bpRecords = health.records
        .where((r) => r['data'] != null && r['data']['systolic'] != null)
        .toList();
    final sugarRecords = health.records
        .where((r) => r['data'] != null && (r['data']['glucose_value'] != null || r['data']['sugar_fasting'] != null))
        .toList();

    // lastBP / lastSugar derived on demand from health.lastBPStatus

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 20,
            title: Row(
              children: [
                Expanded(
                  child: Text('Health Tracking',
                      style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: textPri)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.history_rounded,
                        size: 14, color: AppTheme.primaryTeal),
                    const SizedBox(width: 4),
                    Text('30 days',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Summary strip ──
                _SummaryStrip(
                  totalLogs: health.records.length,
                  bpStatus: health.lastBPStatus?['status'] as String?,
                  isDark: isDark,
                  card: card2,
                  border: border,
                  textPri: textPri,
                  textSec: textSec,
                ),

                const SizedBox(height: 20),

                // ── Section header ──
                Text('Vitals',
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: textPri)),
                const SizedBox(height: 12),

                // ── Metric cards grid ──
                Row(children: [
                  Expanded(child: _AnimatedMetric(
                    ctrl: _ctrl, delayMs: 0,
                    child: _VitalCard(
                      gradient: AppTheme.bpGradient,
                      icon: Icons.favorite_outline_rounded,
                      title: 'Blood Pressure',
                      value: bpRecords.isNotEmpty
                          ? '${bpRecords.last['data']?['systolic']}/${bpRecords.last['data']?['diastolic']}'
                          : '--',
                      unit: 'mmHg',
                      status: health.lastBPStatus?['status'] as String?,
                      isDark: isDark,
                      card: card,
                      border: border,
                      textPri: textPri,
                      textSec: textSec,
                      onAdd: () => _showBPSheet(context),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _AnimatedMetric(
                    ctrl: _ctrl, delayMs: 150,
                    child: _VitalCard(
                      gradient: AppTheme.sugarGradient,
                      icon: Icons.water_drop_outlined,
                      title: 'Blood Sugar',
                      value: sugarRecords.isNotEmpty
                          ? '${sugarRecords.last['data']?['glucose_value'] ?? sugarRecords.last['data']?['sugar_fasting'] ?? '--'}'
                          : '--',
                      unit: 'mg/dL',
                      status: health.lastSugarStatus?['status'] as String?,
                      isDark: isDark,
                      card: card,
                      border: border,
                      textPri: textPri,
                      textSec: textSec,
                      onAdd: () => _showSugarSheet(context),
                    ),
                  )),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _AnimatedMetric(
                    ctrl: _ctrl, delayMs: 0,
                    child: _VitalCard(
                      gradient: AppTheme.weightGradient,
                      icon: Icons.monitor_weight_outlined,
                      title: 'Weight & BMI',
                      value: '${context.watch<AuthProvider>().user?['weight_kg'] ?? '--'}',
                      unit: 'kg',
                      isDark: isDark,
                      card: card,
                      border: border,
                      textPri: textPri,
                      textSec: textSec,
                      onAdd: () => _showWeightSheet(context),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _AnimatedMetric(
                    ctrl: _ctrl, delayMs: 150,
                    child: _VitalCard(
                      gradient: AppTheme.symptomsGradient,
                      icon: Icons.sick_outlined,
                      title: 'Symptoms',
                      value: '--',
                      unit: 'logged',
                      isDark: isDark,
                      card: card,
                      border: border,
                      textPri: textPri,
                      textSec: textSec,
                      onAdd: () => _showSymptomSheet(context),
                    ),
                  )),
                ]),



                // ── Recent readings ──
                Row(children: [
                  Text('Recent Readings',
                      style: GoogleFonts.outfit(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: textPri)),
                  const Spacer(),
                  if (health.isLoading)
                    const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primaryTeal)),
                ]),
                const SizedBox(height: 12),

                if (health.records.isEmpty)
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: border),
                    ),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.health_and_safety_outlined,
                            size: 28, color: AppTheme.textMutedOf(context)),
                        const SizedBox(height: 6),
                        Text('No readings yet — tap + to log',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textMutedOf(context))),
                      ]),
                    ),
                  )
                else
                  ...health.records.take(5).map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ReadingTile(
                      record: r,
                      isDark: isDark,
                      card: card,
                      border: border,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                  )),

                const SizedBox(height: 24),

                // ── Health Tips ──
                Text('Health Tips',
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: textPri)),
                const SizedBox(height: 12),
                ..._tips.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AnimatedMetric(
                    ctrl: _ctrl,
                    delayMs: 400 + e.key * 80,
                    child: _TipCard(
                      tip: e.value,
                      isDark: isDark,
                      card: card,
                      border: border,
                      textPri: textPri,
                      textSec: textSec,
                    ),
                  ),
                )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────────

  void _showBPSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (c) => _BPSheet(health: ctx.read<HealthProvider>()),
    );
  }

  void _showSugarSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (c) => _SugarSheet(health: ctx.read<HealthProvider>()),
    );
  }

  void _showWeightSheet(BuildContext ctx) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (c) {
        final textPri = AppTheme.textPrimaryOf(c);
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, MediaQuery.of(c).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Log Weight',
                style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: textPri)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(fontSize: 14, color: textPri),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 16),
            _GradientBtn(
              label: 'Save',
              gradient: AppTheme.weightGradient,
              loading: false,
              onTap: () async {
                final weight = double.tryParse(ctrl.text);
                if (weight == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Enter a valid weight'),
                    backgroundColor: AppTheme.accentRed,
                  ));
                  return;
                }
                final result = await ctx.read<HealthProvider>().logWeight(weight);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (result != null) {
                  final bmi = result['values']?['bmi'];
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Weight logged!${bmi != null ? ' BMI: $bmi' : ''}'),
                    backgroundColor: AppTheme.primaryTeal,
                  ));
                }
              },
            ),
          ]),
        );
      },
    );
  }

  void _showSymptomSheet(BuildContext ctx) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (c) {
        final textPri = AppTheme.textPrimaryOf(c);
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, MediaQuery.of(c).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.textMuted,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Log Symptoms',
                style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: textPri)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, color: textPri),
              decoration: const InputDecoration(
                labelText: 'Describe your symptoms...',
                prefixIcon: Icon(Icons.sick_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.symptomsGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: TextButton(
                onPressed: () async {
                  if (ctrl.text.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Please enter a symptom'),
                      backgroundColor: AppTheme.accentRed,
                    ));
                    return;
                  }
                  
                  final result = await ctx.read<HealthProvider>().logSymptom(ctrl.text);
                  if (!c.mounted) return;
                  Navigator.pop(c);
                  
                  if (result != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Symptoms logged successfully!'),
                      backgroundColor: AppTheme.primaryTeal,
                    ));
                  }
                },
                child: Text('Save', style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: Colors.white)),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── Tips data ────────────────────────────────────────────────────────────
  static const _tips = [
    (Icons.water_drop_rounded, AppTheme.accentBlue,
        'Stay Hydrated',
        'Drink 8-10 glasses of water daily. Proper hydration supports kidney function and maintains blood pressure levels.'),
    (Icons.directions_walk_rounded, AppTheme.accentGreen,
        '30 Mins Daily Walk',
        'ICMR recommends 30 minutes of moderate physical activity daily to reduce risk of diabetes and heart disease.'),
    (Icons.nightlight_rounded, AppTheme.accentPurple,
        'Quality Sleep',
        'Aim for 7-8 hours of sleep. Poor sleep increases cortisol levels and risk of metabolic syndrome.'),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class _SummaryStrip extends StatelessWidget {
  final int totalLogs;
  final String? bpStatus;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _SummaryStrip({
    required this.totalLogs, required this.bpStatus,
    required this.isDark, required this.card, required this.border,
    required this.textPri, required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Strip('$totalLogs', 'Total Logs', AppTheme.primaryTeal, textPri, textSec),
          _VDivider(isDark: isDark),
          _Strip(bpStatus ?? '—', 'BP Status',
              AppTheme.healthStatusColor(bpStatus), textPri, textSec),
          _VDivider(isDark: isDark),
          _Strip('30d', 'Period', AppTheme.accentBlue, textPri, textSec),
        ],
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  final String value, label;
  final Color color, textPri, textSec;
  const _Strip(this.value, this.label, this.color, this.textPri, this.textSec);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: textSec)),
    ]);
  }
}

class _VDivider extends StatelessWidget {
  final bool isDark;
  const _VDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 32,
      color: isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderLightModeSubtle,
    );
  }
}

class _VitalCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title, value, unit;
  final String? status;
  final bool isDark;
  final Color card, border, textPri, textSec;
  final VoidCallback onAdd;
  const _VitalCard({
    required this.gradient, required this.icon, required this.title,
    required this.value, required this.unit, required this.isDark,
    required this.card, required this.border, required this.textPri,
    required this.textSec, required this.onAdd, this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.healthStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: gradient.colors.first.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_rounded, size: 16,
                  color: gradient.colors.first),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 11, color: textSec, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w800, color: textPri)),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(unit,
                  style: GoogleFonts.inter(fontSize: 10, color: textSec)),
            ),
          ],
        ),
        if (status != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status!,
                style: GoogleFonts.outfit(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: statusColor)),
          ),
        ],
      ]),
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final Map<String, dynamic> record;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _ReadingTile({
    required this.record, required this.isDark,
    required this.card, required this.border,
    required this.textPri, required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    final type = record['record_type'] as String? ?? 'record';
    final data = record['data'] as Map<String, dynamic>? ?? {};
    final at = record['recorded_at'] as String?;
    final date = at != null
        ? DateTime.tryParse(at)?.toLocal()
        : null;
    final dateStr = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : '—';

    String value = '—';
    IconData icon = Icons.health_and_safety_outlined;
    LinearGradient grad = AppTheme.primaryGradient;
    String typeStr = type.replaceAll('_', ' ').toUpperCase();

    if (data['systolic'] != null) {
      value = '${data['systolic'] ?? '--'}/${data['diastolic'] ?? '--'} mmHg';
      icon = Icons.favorite_rounded;
      grad = AppTheme.bpGradient;
      typeStr = 'BLOOD PRESSURE';
    } else if (data['glucose_value'] != null || data['sugar_fasting'] != null) {
      value = '${data['glucose_value'] ?? data['sugar_fasting'] ?? '--'} mg/dL';
      icon = Icons.water_drop_rounded;
      grad = AppTheme.sugarGradient;
      typeStr = 'BLOOD SUGAR';
    } else if (data['weight_kg'] != null) {
      value = '${data['weight_kg'] ?? '--'} kg';
      icon = Icons.monitor_weight_rounded;
      grad = AppTheme.weightGradient;
      typeStr = 'WEIGHT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: grad,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(typeStr,
              style: GoogleFonts.outfit(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: grad.colors.first)),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w600, color: textPri)),
        ])),
        Text(dateStr,
            style: GoogleFonts.inter(fontSize: 11, color: textSec)),
      ]),
    );
  }
}

class _TipCard extends StatelessWidget {
  final (IconData, Color, String, String) tip;
  final bool isDark;
  final Color card, border, textPri, textSec;
  const _TipCard({
    required this.tip, required this.isDark,
    required this.card, required this.border,
    required this.textPri, required this.textSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: border),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: tip.$2.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(tip.$1, color: tip.$2, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tip.$3,
              style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 3),
          Text(tip.$4,
              style: GoogleFonts.inter(
                  fontSize: 12, color: textSec, height: 1.4)),
        ])),
      ]),
    );
  }
}

class _AnimatedMetric extends StatelessWidget {
  final AnimationController ctrl;
  final int delayMs;
  final Widget child;
  const _AnimatedMetric({
    required this.ctrl, required this.delayMs, required this.child});

  @override
  Widget build(BuildContext context) {
    final double fraction = (delayMs / 800).clamp(0, 0.9);
    final anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(fraction, (fraction + 0.4).clamp(0, 1.0),
            curve: Curves.easeOutCubic),
      ),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - anim.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

// ── BP Log Sheet ─────────────────────────────────────────────────────────────

class _BPSheet extends StatefulWidget {
  final HealthProvider health;
  const _BPSheet({required this.health});

  @override
  State<_BPSheet> createState() => _BPSheetState();
}

class _BPSheetState extends State<_BPSheet> {
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final sys = int.tryParse(_sysCtrl.text);
    final dia = int.tryParse(_diaCtrl.text);
    if (sys == null || dia == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter valid values'),
        backgroundColor: AppTheme.accentRed,
      ));
      return;
    }
    setState(() => _loading = true);
    final result = await widget.health.logBP(sys, dia,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    if (result != null) {
      final status = result['status']?['status'] ?? 'Logged';
      final color = AppTheme.healthStatusColor(result['status']?['status']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('BP logged: $sys/$dia — $status'),
        backgroundColor: color,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppTheme.textPrimaryOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(),
        const SizedBox(height: 16),
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.bpGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text('Log Blood Pressure',
              style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w700, color: textPri)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextField(
            controller: _sysCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 14, color: textPri),
            decoration: const InputDecoration(
              labelText: 'Systolic',
              hintText: '120',
              prefixIcon: Icon(Icons.arrow_upward_rounded, size: 18),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: TextField(
            controller: _diaCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(fontSize: 14, color: textPri),
            decoration: const InputDecoration(
              labelText: 'Diastolic',
              hintText: '80',
              prefixIcon: Icon(Icons.arrow_downward_rounded, size: 18),
            ),
          )),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          style: GoogleFonts.inter(fontSize: 14, color: textPri),
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            prefixIcon: Icon(Icons.note_outlined),
          ),
        ),
        const SizedBox(height: 20),
        _GradientBtn(
          label: 'Save Reading',
          gradient: AppTheme.bpGradient,
          loading: _loading,
          onTap: _save,
        ),
      ]),
    );
  }
}

// ── Sugar Log Sheet ──────────────────────────────────────────────────────────

class _SugarSheet extends StatefulWidget {
  final HealthProvider health;
  const _SugarSheet({required this.health});

  @override
  State<_SugarSheet> createState() => _SugarSheetState();
}

class _SugarSheetState extends State<_SugarSheet> {
  final _valCtrl = TextEditingController();
  String _type = 'fasting';
  bool _loading = false;

  @override
  void dispose() {
    _valCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = int.tryParse(_valCtrl.text);
    if (val == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Enter a valid glucose value'),
        backgroundColor: AppTheme.accentRed,
      ));
      return;
    }
    setState(() => _loading = true);
    final result = await widget.health.logSugar(val, _type);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    if (result != null) {
      final status = result['status']?['status'] ?? 'Logged';
      final color = AppTheme.healthStatusColor(result['status']?['status']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sugar logged: $val mg/dL — $status'),
        backgroundColor: color,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPri = AppTheme.textPrimaryOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _Handle(),
        const SizedBox(height: 16),
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.sugarGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text('Log Blood Sugar',
              style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w700, color: textPri)),
        ]),
        const SizedBox(height: 20),
        TextField(
          controller: _valCtrl,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 14, color: textPri),
          decoration: const InputDecoration(
            labelText: 'Glucose (mg/dL)',
            hintText: 'e.g. 95',
            prefixIcon: Icon(Icons.water_drop_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.cardBg2(context),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _type,
              isExpanded: true,
              dropdownColor: AppTheme.cardBg(context),
              style: GoogleFonts.inter(fontSize: 14, color: textPri),
              items: const [
                DropdownMenuItem(value: 'fasting', child: Text('Fasting')),
                DropdownMenuItem(value: 'post_meal', child: Text('Post Meal')),
                DropdownMenuItem(value: 'random', child: Text('Random')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'fasting'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _GradientBtn(
          label: 'Save Reading',
          gradient: AppTheme.sugarGradient,
          loading: _loading,
          onTap: _save,
        ),
      ]),
    );
  }
}

// ── Shared small components ───────────────────────────────────────────────────

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 4,
      decoration: BoxDecoration(
        color: AppTheme.textMuted,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _GradientBtn extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final bool loading;
  final VoidCallback onTap;
  const _GradientBtn({
    required this.label, required this.gradient,
    required this.loading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: loading ? null : gradient,
          color: loading
              ? (Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceL2 : AppTheme.surfaceL2Light)
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}
