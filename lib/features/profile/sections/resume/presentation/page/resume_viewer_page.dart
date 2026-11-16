import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/resume.dart';
import '../bloc/resume_viewer_bloc.dart';
import '../widget/resume_viewer_error.dart';
import '../widget/resume_viewer_loading.dart';

/// Full-screen in-app viewer for the resume's generated PDF: vertical
/// scrolling, pinch zoom, a page counter and a download action.
class ResumeViewerPage extends StatelessWidget {
  const ResumeViewerPage({super.key, required this.resume});

  /// Must have a generated file ([Resume.hasFile]).
  final Resume resume;

  static Route<void> route(Resume resume) =>
      MaterialPageRoute(builder: (_) => ResumeViewerPage(resume: resume));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ResumeViewerBloc>()
            ..add(ResumeViewerUrlRequested(resume.generatedFileId!)),
      child: _ResumeViewerView(resume: resume),
    );
  }
}

class _ResumeViewerView extends StatefulWidget {
  const _ResumeViewerView({required this.resume});

  final Resume resume;

  @override
  State<_ResumeViewerView> createState() => _ResumeViewerViewState();
}

class _ResumeViewerViewState extends State<_ResumeViewerView> {
  /// Set once the PDF has loaded; null while loading or after an error.
  int? _pageCount;
  int _currentPage = 1;

  void _retry() {
    setState(() {
      _pageCount = null;
      _currentPage = 1;
    });
    context.read<ResumeViewerBloc>().add(
      ResumeViewerUrlRequested(widget.resume.generatedFileId!),
    );
  }

  Future<void> _download(String url) async {
    final uri = Uri.tryParse(url);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) AppSnackbar.error(title: 'Couldn\'t download CV');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = widget.resume.title.isEmpty
        ? 'My Resume'
        : widget.resume.title;

    return BlocBuilder<ResumeViewerBloc, ResumeViewerState>(
      builder: (context, state) {
        final url = state.url;
        final loaded = url != null && _pageCount != null;

        return Scaffold(
          backgroundColor: scheme.surfaceContainerLow,
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Icons.download_outlined),
                onPressed: loaded ? () => _download(url) : null,
              ),
            ],
          ),
          body: switch (state.status) {
            ResumeViewerStatus.initial ||
            ResumeViewerStatus.loading => const ResumeViewerLoading(),
            ResumeViewerStatus.failure => ResumeViewerError(
              message: state.failure?.message,
              onRetry: _retry,
            ),
            ResumeViewerStatus.ready => Stack(
              children: [
                PdfViewer.uri(
                  // New key per URL so a retry reloads the document.
                  key: ValueKey(url),
                  Uri.parse(url!),
                  params: PdfViewerParams(
                    backgroundColor: scheme.surfaceContainerLow,
                    loadingBannerBuilder: (context, downloaded, total) =>
                        ResumeViewerLoading(
                          progress: total == null || total == 0
                              ? null
                              : downloaded / total,
                        ),
                    errorBannerBuilder: (context, error, stackTrace, ref) =>
                        ResumeViewerError(onRetry: _retry),
                    onViewerReady: (document, controller) =>
                        setState(() => _pageCount = document.pages.length),
                    onPageChanged: (page) {
                      if (page != null && mounted) {
                        setState(() => _currentPage = page);
                      }
                    },
                  ),
                ),
                if (loaded && _pageCount! > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Center(
                      child: _PageCounter(
                        current: _currentPage,
                        total: _pageCount!,
                      ),
                    ),
                  ),
              ],
            ),
          },
        );
      },
    );
  }
}

class _PageCounter extends StatelessWidget {
  const _PageCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.inverseSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$current / $total',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
