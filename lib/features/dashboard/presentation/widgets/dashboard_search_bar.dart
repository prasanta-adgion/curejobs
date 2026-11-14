import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

/// Job keyword field, location field and the "Find jobs" button. Sits on the
/// navy dashboard header, so the box is always white with dark text.
class DashboardSearchBar extends StatelessWidget {
  const DashboardSearchBar({
    super.key,
    required this.keywordController,
    required this.locationController,
    this.keywordFocusNode,
    this.onSearch,
    this.onUseCurrentLocation,
    this.onKeywordTap,
    this.onLocationTap,
  });

  final TextEditingController keywordController;
  final TextEditingController locationController;
  final FocusNode? keywordFocusNode;
  final VoidCallback? onSearch;
  final VoidCallback? onUseCurrentLocation;

  /// When set, the keyword field is read-only and opens the search screen.
  final VoidCallback? onKeywordTap;

  /// When set, the location field is read-only and opens the search screen.
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            children: [
              _SearchField(
                controller: keywordController,
                focusNode: keywordFocusNode,
                icon: Icons.search_rounded,
                hint: 'Job title, skill or hospital',
                textInputAction: TextInputAction.next,
                onTap: onKeywordTap,
              ),
              const Divider(
                height: 1,
                indent: 48,
                color: AppColors.lightBorder,
              ),
              _SearchField(
                controller: locationController,
                icon: Icons.location_on_outlined,
                hint: 'City, state or area',
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onSearch?.call(),
                onTap: onLocationTap,
                trailing: IconButton(
                  onPressed: onUseCurrentLocation,
                  tooltip: 'Use current location',
                  icon: const Icon(
                    Icons.my_location_rounded,
                    size: 20,
                    color: AppColors.lightIconSecondary,
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
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
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
    this.focusNode,
    this.onSubmitted,
    this.trailing,
    this.onTap,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final IconData icon;
  final String hint;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        readOnly: onTap != null,
        onTap: onTap,
        cursorColor: AppColors.primary,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextTertiary,
          ),
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          suffixIcon: trailing,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
