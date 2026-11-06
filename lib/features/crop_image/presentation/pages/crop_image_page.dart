import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/picked_file.dart';
import '../models/crop_transform.dart';
import '../widgets/crop_controls.dart';
import '../widgets/crop_preview.dart';
import '../widgets/crop_stage.dart';

/// What the user decided on the crop screen.
class CropImageResult {
  const CropImageResult.cropped(PickedFile this.file);
  const CropImageResult.retake() : file = null;

  /// The cropped photo, or null if the user wants to pick another.
  final PickedFile? file;
}

class CropImagePage extends StatefulWidget {
  const CropImagePage({
    super.key,
    required this.path,
    this.retakeLabel = 'Retake',
    this.name,
    this.subtitle,
  });

  final String path;
  final String retakeLabel;

  /// Shown on the preview, when known.
  final String? name;
  final String? subtitle;

  @override
  State<CropImagePage> createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  /// Longest side kept in memory; far above the exported size.
  static const _maxDecodedSide = 2048;

  ui.Image? _image;
  bool _failed = false;
  bool _isBusy = false;
  CropTransform _transform = const CropTransform();
  Uint8List? _cropped;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final buffer = await ui.ImmutableBuffer.fromFilePath(widget.path);
      final codec = await ui.instantiateImageCodecWithSize(
        buffer,
        getTargetSize: (width, height) {
          final ratio = _maxDecodedSide / math.max(width, height);
          if (ratio >= 1) return const ui.TargetImageSize();
          return ui.TargetImageSize(
            width: (width * ratio).round(),
            height: (height * ratio).round(),
          );
        },
      );
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _setZoom(double zoom) {
    setState(() {
      _transform = _transform.copyWith(zoom: zoom).clampedTo(_image!);
    });
  }

  Future<void> _continue() async {
    setState(() => _isBusy = true);
    final bytes = await _transform.export(_image!);
    if (!mounted) return;
    setState(() {
      _cropped = bytes;
      _isBusy = false;
    });
  }

  Future<void> _usePhoto() async {
    final bytes = _cropped!;
    setState(() => _isBusy = true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final name = 'profile_photo_$stamp.png';
    final file = File('${Directory.systemTemp.path}/$name');
    await file.writeAsBytes(bytes);
    if (!mounted) return;
    Navigator.of(context).pop(
      CropImageResult.cropped(
        PickedFile(path: file.path, name: name, sizeInBytes: bytes.length),
      ),
    );
  }

  void _retake() => Navigator.of(context).pop(const CropImageResult.retake());

  @override
  Widget build(BuildContext context) {
    final cropped = _cropped;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: cropped == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _cropped = null);
        },
        child: Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: SafeArea(
            child: cropped == null ? _buildAdjust() : _buildPreview(cropped),
          ),
        ),
      ),
    );
  }

  Widget _buildAdjust() {
    final image = _image;

    return Column(
      children: [
        CropTopBar(
          title: 'Adjust your photo',
          subtitle: 'Step 1 of 2',
          icon: Icons.close_rounded,
          tooltip: 'Cancel',
          onLeading: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: image != null
              ? CropStage(
                  image: image,
                  transform: _transform,
                  onChanged: (value) => setState(() => _transform = value),
                )
              : _buildPlaceholder(),
        ),
        if (image != null)
          CropTools(
            zoom: _transform.zoom,
            onZoomChanged: _setZoom,
            onRotate: () => setState(() {
              _transform = _transform.rotated().clampedTo(image);
            }),
            onFlip: () => setState(() {
              _transform = _transform.mirrored().clampedTo(image);
            }),
            onReset: () => setState(() => _transform = const CropTransform()),
          ),
        CropActions(
          secondaryLabel: widget.retakeLabel,
          primaryLabel: 'Continue',
          onSecondary: _retake,
          onPrimary: image == null || _isBusy ? null : _continue,
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    if (!_failed) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.darkPrimary),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "That photo couldn't be opened. Try another one.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }

  Widget _buildPreview(Uint8List bytes) {
    return Column(
      children: [
        CropTopBar(
          title: 'Preview',
          subtitle: 'Step 2 of 2',
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onLeading: () => setState(() => _cropped = null),
        ),
        Expanded(
          child: Center(
            child: CropPreview(
              bytes: bytes,
              name: widget.name,
              subtitle: widget.subtitle,
            ),
          ),
        ),
        CropActions(
          secondaryLabel: 'Adjust',
          primaryLabel: 'Use this photo',
          onSecondary: _isBusy ? null : () => setState(() => _cropped = null),
          onPrimary: _isBusy ? null : _usePhoto,
        ),
      ],
    );
  }
}
