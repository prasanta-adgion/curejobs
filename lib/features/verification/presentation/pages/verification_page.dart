import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../media_preview/presentation/models/media_file_type.dart';
import '../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../../subscription_packages/domain/entities/current_subscription.dart';
import '../../../subscription_packages/domain/entities/subscription_package.dart';
import '../../../subscription_packages/presentation/bloc/current_plan_bloc.dart';
import '../../../subscription_packages/presentation/pages/subscription_packages_page.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart'
    show PackageFormat;
import '../../domain/entities/verification_document_type.dart';
import '../../domain/entities/verification_request_detail.dart';
import '../bloc/verification_bloc.dart';
import '../widgets/common/verification_bottom_bar.dart';
import '../widgets/common/verification_scaffold.dart';
import '../widgets/delete_document_dialog.dart';
import '../widgets/documents/added_document.dart';
import '../widgets/steps/badge_step.dart';
import '../widgets/steps/documents_step.dart';
import '../widgets/steps/plan_step.dart';
import '../widgets/steps/review_step.dart';
import '../widgets/steps/start_step.dart';
import '../widgets/verification_stepper.dart';

/// "Get verified": Plan → Documents → Review → Badge.
///
/// UI only. [CurrentPlanBloc] says whether the user has a plan with the
/// badge; [VerificationBloc] owns the rest of the flow (API calls, step
/// rules). This page renders their state, asks for confirmation and
/// navigates.
class VerificationPage extends StatelessWidget {
  const VerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<CurrentPlanBloc>()..add(const CurrentPlanRequested()),
        ),
        BlocProvider(create: (_) => sl<VerificationBloc>()),
      ],
      child: const _VerificationView(),
    );
  }
}

/// An active plan that includes the verified badge.
bool _hasVerificationPlan(CurrentSubscription? s) =>
    s != null && s.isActive && s.has(PackageFeature.verifiedBadge);

String? _date(DateTime? d) => d == null ? null : PackageFormat.date(d);

class _VerificationView extends StatelessWidget {
  const _VerificationView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Plan confirmed → load the verification.
        BlocListener<CurrentPlanBloc, CurrentPlanState>(
          listenWhen: (prev, curr) =>
              curr.status == CurrentPlanStatus.success &&
              prev.status != CurrentPlanStatus.success,
          listener: (context, state) {
            if (_hasVerificationPlan(state.subscription)) {
              context.read<VerificationBloc>().add(
                const VerificationLoadRequested(),
              );
            }
          },
        ),
        // One-off errors.
        BlocListener<VerificationBloc, VerificationState>(
          listenWhen: (_, curr) => curr.message != null,
          listener: (context, state) =>
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message!))),
        ),
      ],
      child: BlocBuilder<CurrentPlanBloc, CurrentPlanState>(
        builder: (context, planState) {
          final plan = planState.subscription;
          if (plan == null) return _PlanLoadingView(state: planState);
          if (!_hasVerificationPlan(plan)) {
            return const _StepView(step: VerificationStep.plan);
          }
          return BlocBuilder<VerificationBloc, VerificationState>(
            builder: (context, state) {
              final step = state.step;
              if (step == null) return _VerificationLoadingView(state: state);
              return _StepView(step: step, plan: plan);
            },
          );
        },
      ),
    );
  }
}

class _PlanLoadingView extends StatelessWidget {
  const _PlanLoadingView({required this.state});

  final CurrentPlanState state;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    return VerificationScaffold(
      subtitle: 'Checking your plan',
      body: state.status == CurrentPlanStatus.failure && failure != null
          ? AppErrorView(
              failure: failure,
              onRetry: () => context.read<CurrentPlanBloc>().add(
                const CurrentPlanRequested(),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _VerificationLoadingView extends StatelessWidget {
  const _VerificationLoadingView({required this.state});

  final VerificationState state;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    return VerificationScaffold(
      subtitle: 'Checking your verification',
      body: state.status == VerificationStatus.failure && failure != null
          ? AppErrorView(
              failure: failure,
              onRetry: () => context.read<VerificationBloc>().add(
                const VerificationLoadRequested(),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

/// Stepper + the step's body + its bottom-bar action, in the shared frame.
class _StepView extends StatelessWidget {
  const _StepView({required this.step, this.plan});

  final VerificationStep step;

  /// The user's plan; null on the plan step (they have none with the badge).
  final CurrentSubscription? plan;

  @override
  Widget build(BuildContext context) {
    // The plan step needs no verification data.
    final state = step == VerificationStep.plan
        ? const VerificationState()
        : context.watch<VerificationBloc>().state;
    final actions = _Actions(context, state);

    // Already started: skip the start card, spin until the form is ready.
    // On failure the start card shows the error and Retry.
    final load = state.typesLoad;
    if (step == VerificationStep.documents &&
        state.alreadyStarted &&
        !load.isLoaded &&
        load.error == null) {
      return const VerificationScaffold(
        subtitle: 'Upload documents for review',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final planName = plan == null
        ? null
        : PackageFormat.shortName(plan!.package.name);
    final planActiveUntil = _date(plan?.expiresAt);

    final (subtitle, body, bar) = switch (step) {
      VerificationStep.plan => (
        'Upgrade to unlock your badge',
        PlanStep(onComparePlans: actions.upgrade),
        VerificationBottomBar(
          label: 'Upgrade plan',
          onPressed: actions.upgrade,
        ),
      ),
      VerificationStep.documents when !load.isLoaded => (
        'Upload documents for review',
        StartStep(
          planName: planName,
          planActiveUntil: planActiveUntil,
          error: load.error,
          onRetry: actions.start,
        ),
        VerificationBottomBar(
          label: load.isLoading
              ? 'Getting things ready…'
              : 'Start verification',
          loading: load.isLoading,
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: load.isLoading ? null : actions.start,
          helper: load.isLoading
              ? 'Loading document types'
              : 'You can stop and come back anytime',
        ),
      ),
      VerificationStep.documents => (
        'Upload documents for review',
        DocumentsStep(
          planName: planName,
          planActiveUntil: planActiveUntil,
          types: state.documentTypes,
          documents: state.documents,
          isDraft: state.request?.isDraft ?? false,
          rejectionReason: state.request?.rejectionReason,
          fileNames: state.fileNames,
          deletingIds: state.deletingIds,
          onView: actions.view,
          onDelete: actions.delete,
          onUpload: actions.attach,
        ),
        // Off until a document is attached to the request.
        VerificationBottomBar(
          label: state.submitting ? 'Submitting…' : 'Submit for review',
          loading: state.submitting,
          onPressed: state.hasActiveDocument && !state.submitting
              ? actions.submit
              : null,
          helper: state.hasActiveDocument
              ? 'Review usually takes up to 2 working days'
              : 'Upload a document to continue',
        ),
      ),
      VerificationStep.review => (
        'Waiting for admin review',
        ReviewStep(
          types: state.documentTypes,
          documents: state.documents,
          rejectionReason: state.request?.rejectionReason,
          fileNames: state.fileNames,
          deletingIds: state.deletingIds,
          onView: actions.view,
          onDelete: actions.delete,
          reviewedAt: _date(state.request?.reviewedAt?.toLocal()),
          submittedAt: _date(
            (state.request?.submittedAt ??
                    state.eligibility?.currentRequest?.submittedAt)
                ?.toLocal(),
          ),
        ),
        VerificationBottomBar(
          label: 'Back to profile',
          outlined: true,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      VerificationStep.badge => (
        'Your badge is active',
        BadgeStep(
          autoRenew:
              (plan?.autoRenew ?? false) && !(plan?.cancelAtPeriodEnd ?? false),
          verifiedAt: _date(
            state.myVerification?.documentVerifiedAt?.toLocal(),
          ),
          planActiveUntil: planActiveUntil,
        ),
        // TODO: open the profile page.
        VerificationBottomBar(
          label: 'View my profile',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    };

    return VerificationScaffold(
      subtitle: subtitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          VerificationSections(children: [VerificationStepper(current: step)]),
          body,
        ],
      ),
      bottomBar: bar,
    );
  }
}

/// What the user can do on the page: UI work (dialogs, navigation) here,
/// everything else forwarded to [VerificationBloc].
class _Actions {
  const _Actions(this.context, this.state);

  final BuildContext context;
  final VerificationState state;

  VerificationBloc get _bloc => context.read<VerificationBloc>();

  void start() => _bloc.add(const VerificationStartRequested());

  void submit() => _bloc.add(const VerificationSubmitRequested());

  /// Completes with whether the document was attached, so the upload form
  /// knows to clear itself.
  Future<bool> attach(AddedDocument document) {
    final result = Completer<bool>();
    _bloc.add(VerificationDocumentAttached(document, result));
    return result.future;
  }

  Future<void> delete(VerificationDocument document) async {
    final bloc = _bloc;
    final confirmed = await showDeleteDocumentDialog(context);
    if (confirmed) bloc.add(VerificationDocumentDeleted(document));
  }

  /// Opens the plans page, then rechecks the plan and the verification.
  Future<void> upgrade() async {
    final planBloc = context.read<CurrentPlanBloc>();
    final bloc = _bloc;
    await Navigator.of(context).push(SubscriptionPackagesPage.route());
    planBloc.add(const CurrentPlanRequested());
    bloc.add(const VerificationLoadRequested());
  }

  /// Opens the document full screen (PDF or image).
  void view(VerificationDocument document) {
    final fileName = state.fileNames[document.fileId];
    final typeName = state.documentTypes
        .where((t) => t.id == document.documentTypeId)
        .firstOrNull
        ?.name;
    Navigator.of(context).push(
      FileViewerPage.route(
        fileId: document.fileId,
        title: typeName ?? fileName ?? 'Document',
        // Known for files uploaded in this session; otherwise the viewer
        // works it out from the file URL.
        type: fileName == null ? null : MediaFileType.fromName(fileName),
      ),
    );
  }
}
