import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/file_access_cubit.dart';
import '../widgets/file_viewer_error.dart';
import '../widgets/file_viewer_loading.dart';

/// Full-screen in-app viewer for any uploaded PDF (CV, certificate, document):
/// vertical scrolling, pinch zoom, a page counter and a download action.
///
/// ```dart
/// Navigator.of(context).push(FileViewerPage.route(fileId: id, title: name));
/// ```
class FileViewerPage extends StatelessWidget {
  const FileViewerPage({super.key, required this.fileId, required this.title});

  final String fileId;

  /// Shown in the app bar.
  final String title;

  static Route<void> route({required String fileId, required String title}) =>
      MaterialPageRoute(
        builder: (_) => FileViewerPage(fileId: fileId, title: title),
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FileAccessCubit>()..load(fileId),
      child: _FileViewerView(fileId: fileId, title: title),
    );
  }
}

class _FileViewerView extends StatefulWidget {
  const _FileViewerView({required this.fileId, required this.title});

  final String fileId;
  final String title;

  @override
  State<_FileViewerView> createState() => _FileViewerViewState();
}

class _FileViewerViewState extends State<_FileViewerView> {
  /// Set once the PDF has loaded; null while loading or after an error.
  int? _pageCount;
  int _currentPage = 1;

  void _retry() {
    setState(() {
      _pageCount = null;
      _currentPage = 1;
    });
    context.read<FileAccessCubit>().load(widget.fileId);
  }

  Future<void> _download(String url) async {
    final uri = Uri.tryParse(url);
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) AppSnackbar.error(title: 'Couldn\'t download file');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<FileAccessCubit, FileAccessState>(
      builder: (context, state) {
        final url = state.url;
        final loaded = url != null && _pageCount != null;

        return Scaffold(
          backgroundColor: scheme.surfaceContainerLow,
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                tooltip: 'Download',
                icon: const Icon(Icons.download_outlined),
                onPressed: loaded ? () => _download(url) : null,
              ),
            ],
          ),
          body: switch (state.status) {
            FileAccessStatus.initial ||
            FileAccessStatus.loading => const FileViewerLoading(),
            FileAccessStatus.failure => FileViewerError(
              message: state.failure?.message,
              onRetry: _retry,
            ),
            FileAccessStatus.ready => Stack(
              children: [
                PdfViewer.uri(
                  // New key per URL so a retry reloads the document.
                  key: ValueKey(url),
                  Uri.parse(url!),
                  params: PdfViewerParams(
                    backgroundColor: scheme.surfaceContainerLow,
                    loadingBannerBuilder: (context, downloaded, total) =>
                        FileViewerLoading(
                          progress: total == null || total == 0
                              ? null
                              : downloaded / total,
                        ),
                    errorBannerBuilder: (context, error, stackTrace, ref) =>
                        FileViewerError(onRetry: _retry),
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
