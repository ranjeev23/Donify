import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remindlyf/core/services/backup_service.dart';
import 'package:remindlyf/data/repositories/task_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:remindlyf/presentation/screens/backup_inspector_screen.dart';
import 'package:path_provider/path_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  // This assumes you have a provider for TaskRepository.
  // If not, we'll need to instantiate it or get it from GetIt/Riverpod.
  // For now, I'll create a new instance as it's a singleton-ish repo.
  return BackupService(TaskRepository());
});

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;

  Future<void> _handleExport() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(backupServiceProvider).exportBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleImport() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(backupServiceProvider).importBackup();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup restored! Please restart the app.'),
            ),
          );
        } else {
          // User cancelled
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleInspectAutoBackup() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupFile = File('${dir.path}/Backups/latest_backup.isar');

      if (await backupFile.exists()) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  BackupInspectorScreen(backupFile: backupFile),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No auto-backup found yet. Try adding some data first.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening auto-backup: $e')),
        );
      }
    }
  }

  Future<void> _handleInspect() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BackupInspectorScreen(backupFile: file),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.cloud_sync, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Automatic Daily Backup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your data is automatically backed up to your device every day. '
                      'You can also manually export a backup to save it to Google Drive, iCloud, or another safe place.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _handleExport,
                icon: const Icon(Icons.upload),
                label: const Text('Export Backup Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _handleImport,
                icon: const Icon(Icons.download),
                label: const Text('Restore from Backup'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _handleInspect,
                icon: const Icon(Icons.folder_open),
                label: const Text('Inspect External Backup File'),
                style: TextButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _handleInspectAutoBackup,
                icon: const Icon(Icons.history),
                label: const Text('Inspect Latest Auto-Backup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<DateTime?>(
                valueListenable: TaskRepository().lastBackupTime,
                builder: (context, lastBackup, child) {
                  if (lastBackup == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Last Auto-Backup: ${lastBackup.hour}:${lastBackup.minute.toString().padLeft(2, '0')}:${lastBackup.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await TaskRepository().forceBackupNow();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup forced successfully!'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Force backup failed: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.save_alt),
                label: const Text('Force Backup Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              'Note: Restoring a backup will overwrite all current data.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
