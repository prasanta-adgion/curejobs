import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';

/// Main button pinned to the bottom, above the keyboard.
class ExperienceSaveBar extends StatelessWidget {
  const ExperienceSaveBar({
    super.key,
    required this.label,
    required this.isSaving,
    this.onSave,
  });

  final String label;
  final bool isSaving;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Saving…'),
                      ],
                    )
                  : Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

/// Amber "Unsaved" tag shown in the app bar while there are edits.
class ExperienceUnsavedTag extends StatelessWidget {
  const ExperienceUnsavedTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Unsaved',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFB45309),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
