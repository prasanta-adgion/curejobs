import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/picked_file.dart';
import '../models/media_file_type.dart';
import 'file_viewer_error.dart';
import 'file_viewer_loading.dart';

/// Preview of a picked document before upload. A PDF is shown page by page
/// (scroll, pinch zoom, page counter), like `FileViewerPage` but from the
/// local file. Word and other files can't be rendered, so they show an icon,
/// name, type and size instead.
class DocumentPreview extends StatelessWidget {
  const DocumentPreview({super.key, required this.file, required this.type});

  final PickedFile file;
  final MediaFileType type;

  @override
  Widget build(BuildContext context) {
    if (type != MediaFileType.pdf) {
      return Center(
        child: _FileCard(file: file, type: type),
      );
    }
    return Column(
      children: [
        Expanded(child: _PdfPages(path: file.path)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: _FileInfoRow(file: file, type: type),
        ),
      ],
    );
  }
}

class _PdfPages extends StatefulWidget {
  const _PdfPages({required this.path});

  final String path;

  @override
  State<_PdfPages> createState() => _PdfPagesState();
}

class _PdfPagesState extends State<_PdfPages> {
  /// Set once the PDF has loaded.
  int? _pageCount;
  int _currentPage = 1;

  /// Bumped on retry so the viewer reloads the file.
  int _attempt = 0;

  void _retry() {
    if (!mounted) return;

    setState(() {
      _pageCount = null;
      _currentPage = 1;
      _attempt++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _pageCount;

    return Stack(
      children: [
        PdfViewer.file(
          // New key per file / retry so the document reloads.
          key: ValueKey('${widget.path}#$_attempt'),
          widget.path,
          params: PdfViewerParams(
            backgroundColor: AppColors.darkBackground,
            loadingBannerBuilder: (context, downloaded, total) =>
                const FileViewerLoading(),
            errorBannerBuilder: (context, error, stackTrace, ref) =>
                FileViewerError(
                  message: "This PDF couldn't be opened.",
                  onRetry: _retry,
                ),
            onViewerReady: (document, controller) {
              if (mounted) setState(() => _pageCount = document.pages.length);
            },
            onPageChanged: (page) {
              if (page != null && mounted) setState(() => _currentPage = page);
            },
          ),
        ),
        if (total != null && total > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: _PageCounter(current: _currentPage, total: total),
            ),
          ),
      ],
    );
  }
}

class _PageCounter extends StatelessWidget {
  const _PageCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkInputBorder),
      ),
      child: Text(
        '$current / $total',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.darkTextPrimary),
      ),
    );
  }
}

String _sizeLabel(PickedFile file) {
  final kilobytes = file.sizeInBytes / 1024;
  if (kilobytes < 1024) return '${kilobytes.ceil()} KB';
  return '${(kilobytes / 1024).toStringAsFixed(1)} MB';
}

/// Compact name + size line under the PDF pages.
class _FileInfoRow extends StatelessWidget {
  const _FileInfoRow({required this.file, required this.type});

  final PickedFile file;
  final MediaFileType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(type.icon, size: 20, color: AppColors.darkPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _sizeLabel(file),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
      ],
    );
  }
}

/// Icon, name, type and size for files that can't be rendered.
class _FileCard extends StatelessWidget {
  const _FileCard({required this.file, required this.type});

  final PickedFile file;
  final MediaFileType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkInputBorder),
            ),
            child: Icon(type.icon, size: 44, color: AppColors.darkPrimary),
          ),
          const SizedBox(height: 18),
          Text(
            file.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${type.label} · ${_sizeLabel(file)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Preview isn\'t available for this file type.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
