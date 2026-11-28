import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/subscription_package.dart';
import '../bloc/package_request_cubit.dart';
import 'plan_format.dart';

/// Bottom sheet for plans that can't be paid online: an optional note to
/// admin and a Send button.
///
/// Resolves to the (trimmed, possibly empty) message when the user taps
/// Send, or null when they close the sheet.
abstract final class RequestPlanSheet {
  static Future<String?> show(
    BuildContext context,
    SubscriptionPackage package,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _RequestPlanBody(package: package),
    );
  }
}

class _RequestPlanBody extends StatefulWidget {
  const _RequestPlanBody({required this.package});

  final SubscriptionPackage package;

  @override
  State<_RequestPlanBody> createState() => _RequestPlanBodyState();
}

class _RequestPlanBodyState extends State<_RequestPlanBody> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final name = PackageFormat.shortName(widget.package.name);

    return SafeArea(
      child: Padding(
        // Keep the field above the keyboard.
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Request $name',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Online payment isn't available for this plan. Send a request "
              'and our team will review it and get back to you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 2,
              maxLength: PackageRequestCubit.maxMessageLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Message (optional)',
                hintText: 'Tell us why you need this plan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_controller.text.trim()),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Send request'),
            ),
          ],
        ),
      ),
    );
  }
}
