import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/health_provider.dart';
import 'providers/fitness_provider.dart';
import 'providers/reminder_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: const AarogyaSathiApp(),
    ),
  );
}

class AarogyaSathiApp extends StatefulWidget {
  const AarogyaSathiApp({super.key});
  @override
  State<AarogyaSathiApp> createState() => _AarogyaSathiAppState();
}

class _AarogyaSathiAppState extends State<AarogyaSathiApp> {
  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    Future.microtask(() => context.read<AuthProvider>().checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aarogya Sathi',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
