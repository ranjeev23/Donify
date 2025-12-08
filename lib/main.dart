import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/core/theme/app_theme.dart';
import 'package:remindlyf/presentation/screens/home_screen.dart';
import 'package:remindlyf/presentation/screens/onboarding_screen.dart';
import 'package:remindlyf/core/services/notification_service.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donify',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AppStartup(),
    );
  }
}

class AppStartup extends ConsumerWidget {
  const AppStartup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(currentPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        if (prefs.onboardingCompleted) {
          return const HomeScreen();
        }
        return const OnboardingScreen();
      },
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/donify_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
