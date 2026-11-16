import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../../media_preview/presentation/pages/file_viewer_page.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../bloc/resume_bloc.dart';
import '../widget/add_cv_options.dart';
import '../widget/cv_card.dart';
import '../widget/delete_cv_dialog.dart';
import '../widget/empty_cv.dart';
import '../widget/resume_load_error.dart';

/// Resume tab: an "Add a CV" section (create or upload) on top, then
/// "Your CVs" with the default CV first.
class ResumeTab extends StatelessWidget {
  const ResumeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ResumeBloc>()..add(const ResumesRequested()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<ResumeBloc, ResumeState>(
            listenWhen: (prev, curr) =>
                curr.downloadUrl != null || curr.actionFailure != null,
            listener: _onDownloadState,
          ),
          BlocListener<ResumeBloc, ResumeState>(
            listenWhen: (prev, curr) =>
                curr.defaultChanged || curr.defaultFailure != null,
            listener: _onDefaultState,
          ),
          BlocListener<ResumeBloc, ResumeState>(
            listenWhen: (prev, curr) =>
                curr.deleted || curr.deleteFailure != null,
            listener: _onDeleteState,
          ),
        ],
        child: BlocBuilder<ResumeBloc, ResumeState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ResumeBloc>()
                  ..add(const ResumesRequested());
                await bloc.stream.firstWhere((s) => !s.isLoading);
              },
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ProfileSection(
                    title: 'Add a CV',
                    showDivider: false,
                    child: AddCvOptions(
                      onCreate: () => _comingSoon('Create CV'),
                      onUpload: () => _comingSoon('Upload CV'),
                    ),
                  ),
                  ProfileSection(
                    title: 'Your CVs',
                    count: state.status == ResumeStatus.success
                        ? state.items.length
                        : null,
                    child: _CvList(state: state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onDefaultState(BuildContext context, ResumeState state) {
    final failure = state.defaultFailure;
    if (failure != null) {
      AppSnackbar.error(
        title: 'Couldn\'t set default CV',
        message: failure.message,
      );
      return;
    }
    AppSnackbar.success(
      title: 'Default CV updated',
      message: 'This CV will be sent when you apply.',
    );
  }

  void _onDeleteState(BuildContext context, ResumeState state) {
    final failure = state.deleteFailure;
    if (failure != null) {
      AppSnackbar.error(title: 'Couldn\'t delete CV', message: failure.message);
      return;
    }
    AppSnackbar.success(title: 'CV deleted');
  }

  /// Hands the signed URL to the system (browser / downloads).
  Future<void> _onDownloadState(BuildContext context, ResumeState state) async {
    final failure = state.actionFailure;
    if (failure != null) {
      AppSnackbar.error(
        title: 'Couldn\'t download CV',
        message: failure.message,
      );
      return;
    }
    final uri = Uri.tryParse(state.downloadUrl ?? '');
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) AppSnackbar.error(title: 'Couldn\'t download CV');
  }
}

class _CvList extends StatelessWidget {
  const _CvList({required this.state});

  final ResumeState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == ResumeStatus.failure) {
      return ResumeLoadError(
        message: state.failure?.message,
        onRetry: () => context.read<ResumeBloc>().add(const ResumesRequested()),
      );
    }

    final resumes = state.sorted;
    if (resumes.isEmpty) return const EmptyCv();

    return Column(
      children: [
        for (final resume in resumes) ...[
          CvCard(
            resume: resume,
            isBusy: state.isBusy(resume.id),
            onView: () => Navigator.of(context).push(
              FileViewerPage.route(
                fileId: resume.generatedFileId!,
                title: resume.title.isEmpty ? 'My Resume' : resume.title,
              ),
            ),
            onDownload: () =>
                context.read<ResumeBloc>().add(ResumeDownloadRequested(resume)),
            onEdit: () => _comingSoon('Editing CVs'),
            onSetDefault: () => context.read<ResumeBloc>().add(
              ResumeSetDefaultRequested(resume),
            ),
            onRename: () => _comingSoon('Renaming CVs'),
            onDelete: () async {
              final bloc = context.read<ResumeBloc>();
              if (await showDeleteCvDialog(context, resume)) {
                bloc.add(ResumeDeleteRequested(resume));
              }
            },
          ),
          if (resume != resumes.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Placeholder until the create, upload and manage APIs are wired.
void _comingSoon(String feature) {
  AppSnackbar.info(title: 'Coming soon', message: '$feature is on its way.');
}
