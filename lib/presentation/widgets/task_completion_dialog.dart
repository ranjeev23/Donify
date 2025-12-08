import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskCompletionDialog extends StatefulWidget {
  final String taskTitle;
  final Function(String? note, String? photoPath) onComplete;

  const TaskCompletionDialog({
    super.key,
    required this.taskTitle,
    required this.onComplete,
  });

  @override
  State<TaskCompletionDialog> createState() => _TaskCompletionDialogState();
}

class _TaskCompletionDialogState extends State<TaskCompletionDialog> {
  final _noteController = TextEditingController();
  String? _photoPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 32),
            ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
            const Gap(16),

            Text(
              'Great Job! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(4),
            Text(
              'You completed "${widget.taskTitle}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            // Photo section
            Text(
              'Add a photo (optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),

            if (_photoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.file(
                      File(_photoPath!),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _photoPath = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _PhotoButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: _pickPhoto,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: _PhotoButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: _pickFromGallery,
                    ),
                  ),
                ],
              ),
            ],
            const Gap(16),

            // Note section
            Text(
              'Add a note (optional)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'How did it go?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const Gap(24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onComplete(null, null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            final note = _noteController.text.trim().isEmpty
                                ? null
                                : _noteController.text.trim();
                            widget.onComplete(note, _photoPath);
                            Navigator.pop(context);
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: colorScheme.primary),
              const Gap(6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
