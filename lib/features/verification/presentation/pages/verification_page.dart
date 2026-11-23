import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/picked_file.dart';
import '../../domain/entities/verification_eligibility.dart';
import '../../domain/usecases/get_document_types_usecase.dart';
import '../../domain/usecases/get_verification_eligibility_usecase.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../subscription_packages/domain/entities/current_subscription.dart';
import '../../../subscription_packages/domain/entities/subscription_package.dart';
import '../../../subscription_packages/presentation/bloc/current_plan_bloc.dart';
import '../../../subscription_packages/presentation/pages/subscription_packages_page.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart'
    show PackageFormat;
import '../../../../shared/widgets/app_back_button.dart';
import '../../../profile/shared/widgets/profile_section.dart';
import '../../domain/entities/verification_document_type.dart';
import '../widgets/document_source_sheet.dart';
import '../widgets/document_upload_section.dart';
import '../widgets/verification_parts.dart';
import '../widgets/verification_stepper.dart';

/// "Get verified": Plan → Documents → Review → Badge. Loads its own data and
/// handles its own actions; the fields below get filled once the APIs are
/// connected.
class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late final CurrentPlanBloc _planBloc = sl<CurrentPlanBloc>()
    ..add(const CurrentPlanRequested());

  @override
  void dispose() {
    _planBloc.close();
    super.dispose();
  }

  /// An active plan that includes the verified badge.
  static bool _hasVerificationPlan(CurrentSubscription? s) =>
      s != null && s.isActive && s.has(PackageFeature.verifiedBadge);

  // Eligibility is loaded after the plan, only when the plan has the badge.
  VerificationEligibility? _eligibility;
  Failure? _eligibilityFailure;
  bool _loadingEligibility = false;

  Future<void> _loadEligibility() async {
    setState(() {
      _loadingEligibility = true;
      _eligibilityFailure = null;
    });
    final (result, types) = await (
      sl<GetVerificationEligibilityUseCase>()(),
      sl<GetDocumentTypesUseCase>()(),
    ).wait;
    if (!mounted) return;
    setState(() {
      _loadingEligibility = false;
      types.fold((t) => documentTypes = t, (f) => _eligibilityFailure = f);
      if (_eligibilityFailure != null) return;
      result.fold((e) => _eligibility = e, (f) => _eligibilityFailure = f);
    });
  }

  /// Purchase needed → plan; badge live → badge; documents sent or approved
  /// → review; not sent or rejected → upload documents.
  static VerificationStep _stepFor(VerificationEligibility e) {
    if (e.requiresPurchase) return VerificationStep.plan;
    if (e.badgeActive) return VerificationStep.badge;
    return switch (e.documentStatus) {
      VerificationDocumentStatus.pending ||
      VerificationDocumentStatus.approved => VerificationStep.review,
      VerificationDocumentStatus.notSubmitted ||
      VerificationDocumentStatus.rejected => VerificationStep.documents,
    };
  }

  String planName = 'Advanced';
  String planPrice = '₹49';
  String planPeriod = '30 days';
  List<String> planBenefits = const [
    'Verified badge',
    'Profile and resume visibility',
    'Job alerts',
  ];
  String? planActiveUntil;

  List<VerificationDocumentType> documentTypes = const [];

  /// Files already sent, keyed by document type id (review step).
  Map<String, PickedFile> submittedFiles = const {};
  String? submittedAt;
  String? expectedBy;

  String? verifiedAt;
  String? profileName;
  String? profileSubtitle;
  bool autoRenew = true;

  /// Opens the plans page, then reloads the plan in case it changed.
  Future<void> onUpgrade() async {
    await Navigator.of(context).push(SubscriptionPackagesPage.route());
    if (!mounted) return;
    // Recheck both: the plan may have changed, and with it eligibility.
    setState(() => _eligibility = null);
    _planBloc.add(const CurrentPlanRequested());
  }

  Future<void> onComparePlans() => onUpgrade();

  // TODO: pick with ImagePickerService / DocumentPickerService.
  Future<PickedFile?> onPickDocument(
    VerificationDocumentType type,
    DocumentSource source,
  ) async => null;

  // TODO: upload each file and send it with its `type.id`, then move to the
  // review step.
  void onSubmit(List<AddedDocument> documents) {}

  // TODO: open the profile page.
  void onViewProfile() {}

  /// Documents added in the upload step, each with its type.
  final List<AddedDocument> _added = [];

  List<VerificationDocumentType> get _missingRequired {
    final addedIds = {for (final d in _added) d.type.id};
    return documentTypes
        .where((t) => t.isRequired && !addedIds.contains(t.id))
        .toList();
  }

  bool get _canSubmit => _added.isNotEmpty && _missingRequired.isEmpty;

  Future<PickedFile?> _pick(VerificationDocumentType type) async {
    final source = await showDocumentSourceSheet(
      context,
      documentName: type.name,
    );
    if (source == null || !mounted) return null;
    return onPickDocument(type, source);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrentPlanBloc, CurrentPlanState>(
      bloc: _planBloc,
      listenWhen: (prev, curr) =>
          curr.status == CurrentPlanStatus.success &&
          prev.status != CurrentPlanStatus.success,
      listener: (context, state) {
        if (_hasVerificationPlan(state.subscription)) _loadEligibility();
      },
      builder: (context, state) {
        final s = state.subscription;
        if (s == null) {
          return _scaffold(
            subtitle: 'Checking your plan',
            body: state.status == CurrentPlanStatus.failure
                ? AppErrorView(
                    failure: state.failure!,
                    onRetry: () => _planBloc.add(const CurrentPlanRequested()),
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        }
        if (!_hasVerificationPlan(s)) return _content(VerificationStep.plan);

        planName = PackageFormat.shortName(s.package.name);
        final end = s.expiresAt;
        planActiveUntil = end == null ? null : PackageFormat.date(end);
        autoRenew = s.autoRenew && !s.cancelAtPeriodEnd;

        final e = _eligibility;
        if (e == null) {
          final failure = _eligibilityFailure;
          return _scaffold(
            subtitle: 'Checking your verification',
            body: failure != null && !_loadingEligibility
                ? AppErrorView(failure: failure, onRetry: _loadEligibility)
                : const Center(child: CircularProgressIndicator()),
          );
        }
        final sent = e.currentRequest?.submittedAt;
        submittedAt = sent == null ? null : PackageFormat.date(sent.toLocal());
        return _content(_stepFor(e));
      },
    );
  }

  Widget _scaffold({
    required String subtitle,
    required Widget body,
    Widget? bottomBar,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        leading: AppBackButton.leadingOf(context, color: AppColors.white),
        titleSpacing: 0,
        backgroundColor: AppColors.logoNavy,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get verified',
              style: TextStyle(color: AppColors.white),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: body,
      bottomNavigationBar: bottomBar,
    );
  }

  Widget _content(VerificationStep step) {
    final scheme = Theme.of(context).colorScheme;

    final (subtitle, sections, bar) = switch (step) {
      VerificationStep.plan => (
        'Upgrade to unlock your badge',
        _planSections(),
        VerificationBottomBar(label: 'Upgrade plan', onPressed: onUpgrade),
      ),
      VerificationStep.documents => (
        'Upload documents for review',
        _documentSections(),
        VerificationBottomBar(
          label: _added.isEmpty
              ? 'Submit for review'
              : 'Submit ${_added.length} '
                    '${_added.length == 1 ? 'document' : 'documents'}',
          onPressed: _canSubmit ? () => onSubmit(List.of(_added)) : null,
          helper: _canSubmit
              ? 'Review usually takes up to 2 working days'
              : _missingRequired.isNotEmpty
              ? 'Add ${_missingRequired.map((t) => t.name).join(', ')} '
                    'to continue'
              : 'Add a document to continue',
        ),
      ),
      VerificationStep.review => (
        'Waiting for admin review',
        _reviewSections(),
        VerificationBottomBar(
          label: 'Back to profile',
          outlined: true,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      VerificationStep.badge => (
        'Your badge is active',
        _badgeSections(),
        VerificationBottomBar(
          label: 'View my profile',
          onPressed: onViewProfile,
        ),
      ),
    };

    return _scaffold(
      subtitle: subtitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        // Each section on white; the grey page shows as the bands.
        children: [
          for (final section in [
            VerificationStepper(current: step),
            ...sections,
          ])
            Material(color: scheme.surface, child: section),
        ],
      ),
      bottomBar: bar,
    );
  }

  // ── Step 1: plan ──────────────────────────────────────────────────────────

  List<Widget> _planSections() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return [
      ProfileSection(
        title: 'Why verify',
        child: const VerificationHero(
          icon: Icons.verified_outlined,
          title: 'Stand out to recruiters',
          subtitle: 'Verified profiles get a badge on every application.',
        ),
      ),
      ProfileSection(
        title: 'Recommended plan',
        action: TextButton(
          onPressed: onComparePlans,
          child: const Text('Compare plans'),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    planName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    planPrice,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' / ${planPeriod}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            for (final b in planBenefits) VerificationCheckLine(b),
          ],
        ),
      ),
    ];
  }

  // ── Step 2: documents ─────────────────────────────────────────────────────

  List<Widget> _documentSections() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final types = documentTypes;

    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: VerificationNote(
          icon: Icons.check_circle_outline_rounded,
          text: planActiveUntil == null
              ? '${planName} plan active'
              : '${planName} plan active · until '
                    '${planActiveUntil}',
          color: isDark ? AppColors.successDark : const Color(0xFF166534),
          background: isDark
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.successLight,
        ),
      ),
      if (types.isNotEmpty)
        ProfileSection(
          title: 'What to upload',
          child: DocumentChecklist(types: types, added: _added),
        ),
      if (_added.isNotEmpty)
        ProfileSection(
          title: 'Added documents',
          count: _added.length,
          child: AddedDocumentList(
            documents: _added,
            onRemove: (d) => setState(() => _added.remove(d)),
          ),
        ),
      ProfileSection(
        title: 'Add a document',
        child: types.isEmpty
            ? Text(
                'No document types are available right now.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            : AddDocumentForm(
                types: types,
                onPickFile: _pick,
                onAdd: (d) => setState(() => _added.add(d)),
              ),
      ),
      ProfileSection(
        title: 'Privacy',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Only our verification team sees your documents.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // ── Step 3: review ────────────────────────────────────────────────────────

  List<Widget> _reviewSections() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final amber = isDark ? AppColors.warning : const Color(0xFFB45309);
    final amberBg = isDark
        ? AppColors.warning.withValues(alpha: 0.15)
        : AppColors.warningLight;
    final sent = documentTypes
        .where((t) => submittedFiles.containsKey(t.id))
        .toList();

    return [
      ProfileSection(
        title: 'Status',
        child: VerificationHero(
          icon: Icons.hourglass_top_rounded,
          color: amber,
          background: amberBg,
          title: 'Under review',
          subtitle: "Usually within 2 working days. We'll notify you.",
        ),
      ),
      if (sent.isNotEmpty)
        ProfileSection(
          title: 'Submitted documents',
          child: Column(
            children: [
              for (var i = 0; i < sent.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: i < sent.length - 1
                        ? Border(
                            bottom: BorderSide(color: scheme.outlineVariant),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      const ProfileIconTile(icon: Icons.description_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sent[i].name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              submittedFiles[sent[i].id]!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      VerificationTag(
                        label: 'In review',
                        color: amber,
                        background: amberBg,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      if (submittedAt != null || expectedBy != null)
        ProfileSection(
          title: 'Timeline',
          child: Column(
            children: [
              if (submittedAt != null)
                VerificationInfoRow(
                  label: 'Submitted',
                  value: submittedAt!,
                  showDivider: expectedBy != null,
                ),
              if (expectedBy != null)
                VerificationInfoRow(
                  label: 'Expected by',
                  value: expectedBy!,
                  showDivider: false,
                ),
            ],
          ),
        ),
    ];
  }

  // ── Step 4: badge ─────────────────────────────────────────────────────────

  List<Widget> _badgeSections() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final green = isDark ? AppColors.successDark : AppColors.success;
    final greenBg = isDark
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.successLight;

    final details = [
      if (verifiedAt != null) ('Verified on', verifiedAt!, null),
      if (planActiveUntil != null) ('Active until', planActiveUntil!, null),
      ('Renews', autoRenew ? 'Automatically' : 'Off', autoRenew ? green : null),
    ];

    return [
      ProfileSection(
        title: 'Badge',
        child: VerificationHero(
          icon: Icons.verified_outlined,
          color: green,
          background: greenBg,
          title: "You're verified",
          subtitle: 'Your badge shows on your profile and applications.',
        ),
      ),
      if (profileName != null)
        ProfileSection(
          title: 'How recruiters see you',
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  _initials(profileName!),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profileName!,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified, size: 18, color: scheme.primary),
                      ],
                    ),
                    if (profileSubtitle != null)
                      Text(
                        profileSubtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ProfileSection(
        title: 'Details',
        child: Column(
          children: [
            for (var i = 0; i < details.length; i++)
              VerificationInfoRow(
                label: details[i].$1,
                value: details[i].$2,
                valueColor: details[i].$3,
                showDivider: i < details.length - 1,
              ),
          ],
        ),
      ),
    ];
  }

  static String _initials(String name) {
    final parts = name
        .replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
