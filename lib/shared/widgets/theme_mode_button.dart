import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_cubit.dart';

/// Square icon button that opens a small menu to pick System, Light or Dark.
/// The icon shows the current choice. Drop it into any header or toolbar.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key, this.onDarkBackground = false});

  /// Use light-on-dark colours, for navy headers such as the profile.
  final bool onDarkBackground;

  static IconData _iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  static String _labelFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System default',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  Future<void> _changeTheme(BuildContext context, ThemeMode mode) async {
    try {
      await context.read<ThemeCubit>().changeTheme(mode);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save your appearance choice.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = onDarkBackground ? AppColors.white : scheme.onSurface;
    final outline = onDarkBackground
        ? AppColors.darkInputBorder
        : scheme.outlineVariant;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, current) => PopupMenuButton<ThemeMode>(
        tooltip: 'Appearance',
        initialValue: current,
        position: PopupMenuPosition.under,
        offset: const Offset(0, 6),
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        onSelected: (mode) {
          if (mode != current) _changeTheme(context, mode);
        },
        itemBuilder: (context) => [
          PopupMenuItem<ThemeMode>(
            enabled: false,
            height: 32,
            child: Text(
              'APPEARANCE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.outline,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          for (final mode in ThemeMode.values)
            PopupMenuItem<ThemeMode>(
              value: mode,
              height: 44,
              child: _MenuRow(
                icon: _iconFor(mode),
                label: _labelFor(mode),
                selected: mode == current,
              ),
            ),
        ],
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: outline),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _iconFor(current),
              key: ValueKey(current),
              size: 18,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected ? scheme.primary : scheme.onSurface,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        if (selected) Icon(Icons.check_rounded, size: 18, color: color),
      ],
    );
  }
}
