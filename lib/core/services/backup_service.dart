import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remindlyf/data/repositories/task_repository.dart';
import 'package:share_plus/share_plus.dart';

class BackupService {
  final TaskRepository _repository;

  BackupService(this._repository);

  /// Automatically creates a daily backup if one doesn't exist for today.
  Future<void> performDailyAutoBackup() async {
    try {
      final backupDir = await _getBackupDirectory();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final backupFileName = 'remindly_backup_$today.isar';
      final backupFile = File('${backupDir.path}/$backupFileName');

      if (!await backupFile.exists()) {
        debugPrint('Creating daily auto-backup: $backupFileName');
        await _repository.createBackup(backupFile.path);

        // Clean up old backups (keep last 7 days)
        await _cleanupOldBackups(backupDir);
      } else {
        debugPrint('Daily backup already exists: $backupFileName');
      }
    } catch (e) {
      debugPrint('Error performing auto-backup: $e');
    }
  }

  /// Exports the current database to a file and opens the share sheet.
  Future<void> exportBackup() async {
    try {
      final backupDir = await _getBackupDirectory();
      final now = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());
      final backupFileName = 'remindly_manual_backup_$now.isar';
      final backupFile = File('${backupDir.path}/$backupFileName');

      await _repository.createBackup(backupFile.path);

      await Share.shareXFiles([
        XFile(backupFile.path),
      ], text: 'Remindly Backup $now');
    } catch (e) {
      debugPrint('Error exporting backup: $e');
      rethrow;
    }
  }

  /// Opens file picker to select a backup file and restores it.
  Future<bool> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // .isar files might not have a standard mime type
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _repository.restoreBackup(file);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing backup: $e');
      rethrow;
    }
  }

  /// Gets the directory where backups are stored.
  /// On iOS, this is in the Documents directory which is visible via iTunes/Files app.
  Future<Directory> _getBackupDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDocDir.path}/Backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Deletes backups older than 7 days to save space.
  Future<void> _cleanupOldBackups(Directory backupDir) async {
    try {
      final files = backupDir.listSync();
      final now = DateTime.now();
      for (final entity in files) {
        if (entity is File) {
          final lastModified = await entity.lastModified();
          if (now.difference(lastModified).inDays > 7) {
            await entity.delete();
            debugPrint('Deleted old backup: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old backups: $e');
    }
  }
}
