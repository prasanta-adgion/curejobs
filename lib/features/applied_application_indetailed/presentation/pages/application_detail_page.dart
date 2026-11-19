import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../apply_job/presentation/widgets/apply_flow_widgets.dart';
import '../../../applied_application/domain/entities/job_application.dart';
import '../../../applied_application/presentation/widgets/withdraw_application_sheet.dart';
import '../../../job_details/presentation/pages/job_details_page.dart';
import '../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../domain/entities/application_detail.dart';
import '../cubit/application_detail_cubit.dart';
import '../widgets/application_detail_sections.dart';

/// Full details of one application, from
/// `GET api/v1/applications/me/:id`.
///
/// Pops with `true` when the application was withdrawn here, so the list
/// can refresh.
class ApplicationDetailPage extends StatelessWidget {
  const ApplicationDetailPage({super.key, required this.applicationId});

  final String applicationId;

  static Route<bool> route(String applicationId) => MaterialPageRoute(
    builder: (_) => ApplicationDetailPage(applicationId: applicationId),
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ApplicationDetailCubit>()..load(applicationId),
      child: _ApplicationDetailView(applicationId: applicationId),
    );
  }
}

class _ApplicationDetailView extends StatefulWidget {
  const _ApplicationDetailView({required this.applicationId});

  final String applicationId;

  @override
  State<_ApplicationDetailView> createState() => _ApplicationDetailViewState();
}

class _ApplicationDetailViewState extends State<_ApplicationDetailView> {
  bool _withdrawn = false;

  Future<void> _withdraw(ApplicationDetail detail) async {
    final cubit = context.read<ApplicationDetailCubit>();
    final job = detail.job;
    final confirmed = await showWithdrawApplicationSheet(
      context,
      JobApplication(
        id: detail.id,
        jobId: job.id,
        jobSlug: job.slug,
        jobTitle: job.title,
        city: job.city ?? '',
        state: job.state,
        country: job.country,
        status: detail.status,
        appliedAt: detail.appliedAt,
        withdrawnAt: detail.withdrawnAt,
        isJobOpen: !job.isClosed,
      ),
    );
    if (!confirmed) return;

    final failure = await cubit.withdraw();
    if (failure == null) {
      _withdrawn = true;
      AppSnackbar.success(title: 'Application withdrawn');
    } else {
      AppSnackbar.error(
        title: "Couldn't withdraw application",
        message: failure.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_withdrawn);
      },
      child: BlocBuilder<ApplicationDetailCubit, ApplicationDetailState>(
        builder: (context, state) {
          final detail = state.detail;
          return Scaffold(
            backgroundColor: ApplyFlowColors.page(context),
            appBar: ApplyStepAppBar(
              title: 'Application details',
              subtitle: detail?.job.organization.name,
            ),
            body: switch (state.status) {
              ApplicationDetailStatus.loading when detail == null =>
                const Center(child: CircularProgressIndicator()),
              ApplicationDetailStatus.failure when detail == null =>
                AppErrorView(
                  failure: state.failure!,
                  onRetry: () => context.read<ApplicationDetailCubit>().load(
                    widget.applicationId,
                  ),
                ),
              _ => RefreshIndicator(
                onRefresh: () => context.read<ApplicationDetailCubit>().load(
                  widget.applicationId,
                ),
                child: _Body(detail: detail!),
              ),
            },
            bottomNavigationBar: detail != null && detail.status.isActive
                ? _WithdrawBar(
                    isLoading: state.isWithdrawing,
                    onPressed: () => _withdraw(detail),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail});

  final ApplicationDetail detail;

  @override
  Widget build(BuildContext context) {
    final resume = detail.resume;
    final fileId = resume?.generatedFileId;
    final sections = <Widget>[
      ApplicationProgressSection(detail: detail),
      ApplicationJobOverviewSection(
        detail: detail,
        onViewJob: () =>
            Navigator.of(context).push(JobDetailsPage.route(detail.job)),
      ),
      if (detail.screening case final s? when s.checks.isNotEmpty)
        EligibilitySection(screening: s),
      if (detail.answers.isNotEmpty)
        ScreeningAnswersSection(answers: detail.answers),
      if (resume != null)
        SubmittedResumeSection(
          resume: resume,
          onView: fileId == null
              ? null
              : () => Navigator.of(context).push(
                  FileViewerPage.route(fileId: fileId, title: resume.title),
                ),
        ),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ApplicationDetailHeader(detail: detail),
        if (detail.job.isClosed)
          JobClosedStrip(stillActive: detail.status.isActive),
        for (final s in sections) ...[const ApplySectionGap(), s],
      ],
    );
  }
}

class _WithdrawBar extends StatelessWidget {
  const _WithdrawBar({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final red = dark ? AppColors.errorDark : AppColors.error;
    return ApplyBottomBar(
      child: SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: red,
            side: BorderSide(color: red.withValues(alpha: 0.6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: red),
                )
              : const Icon(Icons.undo_rounded, size: 18),
          label: const Text('Withdraw application'),
        ),
      ),
    );
  }
}
