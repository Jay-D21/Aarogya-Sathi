import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/health_provider.dart';
import 'providers/fitness_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_goals_provider.dart';
import 'screens/onboarding/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/home/home_screen.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => UserGoalsProvider()),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Keep status bar icons in sync with theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          themeProvider.isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor:
          themeProvider.isDark ? AppTheme.surfaceL1 : AppTheme.surfaceL1Light,
      systemNavigationBarIconBrightness:
          themeProvider.isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      title: 'Aarogya Sathi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/splash':   page = const SplashScreen();   break;
          case '/login':    page = const LoginScreen();    break;
          case '/register': page = const RegisterScreen(); break;
          case '/onboarding': page = const ProfileSetupScreen(); break;
          case '/home':     page = const HomeScreen();     break;
          default:          page = const SplashScreen();
        }
        return _FadeRoute(page: page, settings: settings);
      },
    );
  }
}

class _FadeRoute extends PageRouteBuilder {
  _FadeRoute({required Widget page, required RouteSettings settings})
      : super(
          settings: settings,
          pageBuilder: (context, anim1, anim2) => page,
          transitionDuration: AppTheme.durationMedium,
          reverseTransitionDuration: AppTheme.durationFast,
          transitionsBuilder: (context, anim, secondaryAnim, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
            );
          },
        );
}
