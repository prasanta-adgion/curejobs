import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';

/// Job keyword field, location field and the "Find jobs" button.
class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({
    super.key,
    required this.keywordController,
    required this.locationController,
    this.onSearch,
    this.onUseCurrentLocation,
  });

  final TextEditingController keywordController;
  final TextEditingController locationController;
  final VoidCallback? onSearch;
  final VoidCallback? onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              _SearchField(
                controller: keywordController,
                icon: Icons.search_rounded,
                hint: 'Job title, skill or hospital',
                textInputAction: TextInputAction.next,
              ),
              Divider(
                height: 1,
                indent: 48,
                color: scheme.outlineVariant,
              ),
              _SearchField(
                controller: locationController,
                icon: Icons.location_on_outlined,
                hint: 'City, state or area',
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearch?.call(),
                trailing: IconButton(
                  onPressed: onUseCurrentLocation,
                  tooltip: 'Use current location',
                  icon: Icon(
                    Icons.my_location_rounded,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: onSearch,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
            ),
            icon: const Icon(Icons.search_rounded, size: 20),
            label: const Text('Find jobs'),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.textInputAction,
    this.onSubmitted,
    this.trailing,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(icon, size: 20, color: scheme.primary),
          suffixIcon: trailing,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
