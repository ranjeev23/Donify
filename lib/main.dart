import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/core/theme/app_theme.dart';
import 'package:remindlyf/presentation/screens/main_screen.dart';
import 'package:remindlyf/presentation/screens/onboarding_screen.dart';
import 'package:remindlyf/core/services/notification_service.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';

import 'package:remindlyf/core/services/backup_service.dart';
import 'package:remindlyf/data/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remindlyf/presentation/screens/backup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  // Initialize TaskRepository and run auto-backup
  final taskRepo = TaskRepository();
  final backupService = BackupService(taskRepo);
  // Run in background, don't await
  backupService.performDailyAutoBackup();

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

class AppStartup extends ConsumerStatefulWidget {
  const AppStartup({super.key});

  @override
  ConsumerState<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends ConsumerState<AppStartup> {
  bool _checkedFirstRun = false;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('is_first_run') ?? true;

    if (isFirstRun && mounted) {
      // Show restore dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRestoreDialog(prefs);
      });
    } else {
      setState(() => _checkedFirstRun = true);
    }
  }

  Future<void> _showRestoreDialog(SharedPreferences prefs) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Welcome Back!'),
        content: const Text(
          'Do you have a backup file (e.g., from iCloud or Google Drive) that you would like to restore?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Start Fresh'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Restore Backup'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      // Trigger restore
      try {
        final success = await ref.read(backupServiceProvider).importBackup();
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup restored successfully!')),
            );
          }
        }
      } catch (e) {
        // Ignore error or show snackbar
      }
    }

    // Mark first run as done
    await prefs.setBool('is_first_run', false);
    if (mounted) {
      setState(() => _checkedFirstRun = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checkedFirstRun) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final prefsAsync = ref.watch(currentPreferencesProvider);

    return prefsAsync.when(
      data: (prefs) {
        if (prefs.onboardingCompleted) {
          return const MainScreen();
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
