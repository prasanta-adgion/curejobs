import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';

/// Six digit boxes built on [Pinput]. Highlights the active box, turns red
/// when [errorText] is set, and supports paste and SMS/email autofill.
class OtpCodeInput extends StatelessWidget {
  const OtpCodeInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.onChanged,
    required this.onCompleted,
    this.errorText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = errorText != null;

    final base = PinTheme(
      width: 48,
      height: 56,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: scheme.outlineVariant),
      ),
    );

    return Column(
      children: [
        Pinput(
          length: length,
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          autofocus: true,
          forceErrorState: hasError,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          separatorBuilder: (_) => const SizedBox(width: 8),
          defaultPinTheme: base,
          focusedPinTheme: base.copyDecorationWith(
            color: scheme.primaryContainer.withValues(alpha: 0.4),
            border: Border.all(color: scheme.primary, width: 2),
          ),
          submittedPinTheme: base.copyDecorationWith(
            border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
          ),
          errorPinTheme: base.copyDecorationWith(
            color: AppColors.errorLight.withValues(alpha: 0.5),
            border: Border.all(color: AppColors.error),
          ),
          cursor: Container(width: 2, height: 22, color: scheme.primary),
          onChanged: onChanged,
          onCompleted: onCompleted,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Semantics(
                    liveRegion: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: scheme.error,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            errorText!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
