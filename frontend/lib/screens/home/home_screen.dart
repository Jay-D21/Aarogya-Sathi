import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fitness_provider.dart';
import '../../providers/reminder_provider.dart';
import '../chat/chat_screen.dart';
import '../health/health_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data on home open
    Future.microtask(() {
      context.read<FitnessProvider>().loadSummary();
      context.read<ReminderProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeDashboard(),
      const ChatScreen(),
      const HealthDashboard(),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outlined), activeIcon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard() {
    final fitness = context.watch<FitnessProvider>();
    final reminders = context.watch<ReminderProvider>();
    final auth = context.watch<AuthProvider>();
    final name = auth.user?['first_name'] ?? 'Friend';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text('Hello, $name! 👋', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('How are you feeling today?', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAction(Icons.bloodtype, 'Log BP', AppTheme.accentRed, () => setState(() => _currentIndex = 2)),
                _quickAction(Icons.chat_bubble, 'Chat', AppTheme.primaryTeal, () => setState(() => _currentIndex = 1)),
                _quickAction(Icons.directions_walk, 'Steps', AppTheme.accentGreen, () {}),
                _quickAction(Icons.alarm, 'Reminders', AppTheme.accentOrange, () {}),
              ],
            ),
            const SizedBox(height: 24),

            // Activity Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today\'s Activity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _activityStat('🚶', '${fitness.dailySummary?['steps'] ?? 0}', 'Steps'),
                      _activityStat('🔥', '${fitness.dailySummary?['calories_total'] ?? 0}', 'Calories'),
                      _activityStat('💪', '${(fitness.dailySummary?['workouts'] as List?)?.length ?? 0}', 'Workouts'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Upcoming Reminders
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm, color: AppTheme.accentOrange, size: 20),
                        const SizedBox(width: 8),
                        Text('Upcoming Reminders', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (reminders.todaySchedule.isEmpty)
                      const Text('No reminders for today', style: TextStyle(color: AppTheme.textSecondary))
                    else
                      ...reminders.todaySchedule.take(3).map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, color: AppTheme.primaryTeal, size: 8),
                                const SizedBox(width: 8),
                                Text('${r['reminder_time']} — ${r['title']}'),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _activityStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildProfileTab() {
    final auth = context.watch<AuthProvider>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryTeal,
              child: Text(
                (auth.user?['first_name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(auth.user?['first_name'] ?? '', style: Theme.of(context).textTheme.headlineMedium),
            Text(auth.user?['email'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (mounted) Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: AppTheme.accentRed),
                label: const Text('Logout', style: TextStyle(color: AppTheme.accentRed)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentRed)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
