import 'package:flutter/material.dart';

import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';

import '../common/plan_active_note.dart';
import '../common/privacy_section.dart';
import '../common/verification_scaffold.dart';
import 'verification_start_card.dart';

/// Step 2a — plan is active but no request was started yet. Shows what's
/// about to happen; "Start verification" (bottom bar) creates the request
/// and loads the document types, after which [DocumentsStep] takes over.
class StartStep extends StatelessWidget {
  const StartStep({
    super.key,
    required this.planName,
    required this.planActiveUntil,
    required this.error,
    required this.onRetry,
  });

  final String? planName;
  final String? planActiveUntil;

  /// Why the last start failed, if it did.
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return VerificationSections(
      children: [
        PlanActiveNote(planName: planName, activeUntil: planActiveUntil),
        ProfileSection(
          title: 'Before you start',
          child: VerificationStartCard(error: error, onRetry: onRetry),
        ),
        const VerificationPrivacySection(),
      ],
    );
  }
}
