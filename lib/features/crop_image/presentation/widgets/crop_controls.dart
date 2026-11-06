import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/crop_transform.dart';

/// Title row shared by the adjust and preview screens.
class CropTopBar extends StatelessWidget {
  const CropTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tooltip,
    required this.onLeading,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String tooltip;
  final VoidCallback onLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeading,
            tooltip: tooltip,
            style: IconButton.styleFrom(
              foregroundColor: AppColors.white,
              minimumSize: const Size.square(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.darkInputBorder),
              ),
            ),
            icon: Icon(icon, size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Zoom slider with rotate, flip and reset.
class CropTools extends StatelessWidget {
  const CropTools({
    super.key,
    required this.zoom,
    required this.onZoomChanged,
    required this.onRotate,
    required this.onFlip,
    required this.onReset,
  });

  final double zoom;
  final ValueChanged<double> onZoomChanged;
  final VoidCallback onRotate;
  final VoidCallback onFlip;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.remove_rounded,
                color: AppColors.darkTextSecondary,
              ),
              Expanded(
                child: Slider(
                  value: zoom,
                  min: CropTransform.minZoom,
                  max: CropTransform.maxZoom,
                  label: 'Zoom',
                  activeColor: AppColors.darkPrimary,
                  inactiveColor: AppColors.darkInputBorder,
                  thumbColor: AppColors.white,
                  onChanged: onZoomChanged,
                ),
              ),
              const Icon(Icons.add_rounded, color: AppColors.darkTextSecondary),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _ToolButton(
                icon: Icons.rotate_right_rounded,
                label: 'Rotate',
                onTap: onRotate,
              ),
              const SizedBox(width: 8),
              _ToolButton(
                icon: Icons.flip_rounded,
                label: 'Flip',
                onTap: onFlip,
              ),
              const SizedBox(width: 8),
              _ToolButton(
                icon: Icons.restart_alt_rounded,
                label: 'Reset',
                onTap: onReset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size(0, 42),
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.darkInputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, size: 17, color: AppColors.darkPrimary),
        label: Text(label),
      ),
    );
  }
}

/// Secondary and main actions at the bottom of both screens.
class CropActions extends StatelessWidget {
  const CropActions({
    super.key,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback? onSecondary;

  /// Null shows the button as busy.
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkTextPrimary,
              minimumSize: const Size(96, 52),
              side: const BorderSide(color: AppColors.darkInputBorder),
            ),
            child: Text(secondaryLabel),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton(
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: onPrimary == null
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(primaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
