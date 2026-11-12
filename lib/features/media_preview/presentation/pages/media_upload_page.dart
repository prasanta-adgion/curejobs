import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/picked_file.dart';
import '../../../crop_image/presentation/widgets/crop_controls.dart';
import '../../domain/enums/media_upload_purpose.dart';
import '../bloc/media_upload_bloc.dart';

/// Uploads [file] and shows progress. Pops with the finalized result, or null
/// if cancelled, which also stops the upload.
class MediaUploadPage extends StatelessWidget {
  const MediaUploadPage({super.key, required this.file, required this.purpose});

  final PickedFile file;
  final MediaUploadPurpose purpose;

  MediaUploadRequested get _request =>
      MediaUploadRequested(file: file, purpose: purpose);

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return BlocProvider(
      create: (_) => sl<MediaUploadBloc>()..add(_request),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: SafeArea(
            child: BlocConsumer<MediaUploadBloc, MediaUploadState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                if (state.status == MediaUploadStatus.success) {
                  navigator.pop(state.result);
                }
              },
              builder: (context, state) {
                final failed = state.status == MediaUploadStatus.failure;

                return Column(
                  children: [
                    CropTopBar(
                      title: failed ? 'Upload failed' : 'Uploading',
                      subtitle: file.name,
                      icon: AppIcons.close,
                      tooltip: 'Cancel',
                      onLeading: navigator.pop,
                    ),
                    Expanded(child: _UploadStatus(state: state)),
                    CropActions(
                      secondaryLabel: 'Cancel',
                      primaryLabel: 'Try again',
                      onSecondary: navigator.pop,
                      onPrimary: failed
                          ? () => context.read<MediaUploadBloc>().add(_request)
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadStatus extends StatelessWidget {
  const _UploadStatus({required this.state});

  final MediaUploadState state;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(color: AppColors.darkTextPrimary);
    final error = state.errorMessage;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: error != null
            ? Text(error, textAlign: TextAlign.center, style: style)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: state.progress,
                    color: AppColors.darkPrimary,
                    backgroundColor: AppColors.darkInputBorder,
                  ),
                  const SizedBox(height: 12),
                  Text('${(state.progress * 100).round()}%', style: style),
                ],
              ),
      ),
    );
  }
}
