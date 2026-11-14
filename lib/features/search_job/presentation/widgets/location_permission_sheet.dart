import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';

enum LocationPermissionChoice { openSettings, typeCity }

/// Shown when location access is off. The user can open settings or just
/// type a city, so the search is never blocked.
class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({super.key});

  static Future<LocationPermissionChoice?> show(BuildContext context) =>
      showModalBottomSheet<LocationPermissionChoice>(
        context: context,
        showDragHandle: true,
        builder: (_) => const LocationPermissionSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                Icons.location_off_outlined,
                color: scheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text('Location is off', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Turn it on to see jobs near you, or type a city instead.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context)
                        .pop(LocationPermissionChoice.openSettings),
                child: const Text('Open settings'),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(LocationPermissionChoice.typeCity),
              child: const Text('Type a city'),
            ),
          ],
        ),
      ),
    );
  }
}
