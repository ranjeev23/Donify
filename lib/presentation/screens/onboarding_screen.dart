import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/domain/providers/task_provider.dart';
import 'package:remindlyf/data/models/user_preferences.dart';
import 'package:remindlyf/presentation/screens/home_screen.dart';
import 'package:gap/gap.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Gap(40),

              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const Gap(24),

              Text(
                'Welcome to Remindly',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Let\'s set up your daily schedule',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),

              const Gap(48),

              // Steps
              Expanded(
                child: _currentStep == 0
                    ? _buildWakeUpStep(context)
                    : _buildSleepStep(context),
              ),

              // Progress & Navigation
              Row(
                children: [
                  // Step indicators
                  Row(
                    children: [
                      _StepDot(
                        isActive: _currentStep >= 0,
                        isCurrent: _currentStep == 0,
                      ),
                      const Gap(8),
                      _StepDot(
                        isActive: _currentStep >= 1,
                        isCurrent: _currentStep == 1,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    ),
                  const Gap(8),
                  FilledButton(
                    onPressed: _currentStep == 0 ? _nextStep : _complete,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(_currentStep == 0 ? 'Next' : 'Start'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWakeUpStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.wb_sunny, size: 64, color: Colors.orange.shade400),
        const Gap(24),
        Text(
          'When do you wake up?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        Text(
          'This helps us schedule your tasks during waking hours',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(32),
        _TimePickerButton(
          time: _wakeUpTime,
          label: 'Wake up time',
          color: Colors.orange,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _wakeUpTime,
            );
            if (time != null) {
              setState(() => _wakeUpTime = time);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSleepStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.nightlight_round, size: 64, color: Colors.indigo.shade400),
        const Gap(24),
        Text(
          'When do you go to sleep?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        Text(
          'We\'ll make sure not to schedule tasks during your rest time',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(32),
        _TimePickerButton(
          time: _sleepTime,
          label: 'Sleep time',
          color: Colors.indigo,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _sleepTime,
            );
            if (time != null) {
              setState(() => _sleepTime = time);
            }
          },
        ),
        const Gap(24),
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: colorScheme.primary, size: 20),
              const Gap(8),
              Text(
                'Available: ${_formatHours()}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatHours() {
    final wakeMinutes = _wakeUpTime.hour * 60 + _wakeUpTime.minute;
    final sleepMinutes = _sleepTime.hour * 60 + _sleepTime.minute;
    final totalMinutes = sleepMinutes > wakeMinutes
        ? sleepMinutes - wakeMinutes
        : (24 * 60 - wakeMinutes) + sleepMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes > 0 ? '$hours hours $minutes mins' : '$hours hours';
  }

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _complete() async {
    final repository = ref.read(taskRepositoryProvider);
    final prefs = UserPreferences()
      ..wakeUpHour = _wakeUpTime.hour
      ..wakeUpMinute = _wakeUpTime.minute
      ..sleepHour = _sleepTime.hour
      ..sleepMinute = _sleepTime.minute
      ..onboardingCompleted = true;

    await repository.savePreferences(prefs);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }
}

class _StepDot extends StatelessWidget {
  final bool isActive;
  final bool isCurrent;

  const _StepDot({required this.isActive, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCurrent ? 24 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final TimeOfDay time;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TimePickerButton({
    required this.time,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60), width: 2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
            const Gap(8),
            Text(
              time.format(context),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Gap(4),
            Text(
              'Tap to change',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
