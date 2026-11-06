import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Position of the photo behind the round crop frame. [offset] is measured
/// in frame widths, so it doesn't depend on the screen or the output size.
class CropTransform {
  const CropTransform({
    this.zoom = minZoom,
    this.offset = Offset.zero,
    this.quarterTurns = 0,
    this.flipped = false,
  });

  static const minZoom = 1.0;
  static const maxZoom = 4.0;

  final double zoom;
  final Offset offset;
  final int quarterTurns;
  final bool flipped;

  CropTransform copyWith({double? zoom, Offset? offset}) => CropTransform(
    zoom: zoom ?? this.zoom,
    offset: offset ?? this.offset,
    quarterTurns: quarterTurns,
    flipped: flipped,
  );

  CropTransform rotated() => CropTransform(
    zoom: zoom,
    offset: Offset(-offset.dy, offset.dx),
    // A mirrored photo turns the other way, so step backwards.
    quarterTurns: (quarterTurns + (flipped ? 3 : 1)) % 4,
    flipped: flipped,
  );

  CropTransform mirrored() => CropTransform(
    zoom: zoom,
    offset: Offset(-offset.dx, offset.dy),
    quarterTurns: quarterTurns,
    flipped: !flipped,
  );

  /// Keeps the frame fully covered by the photo.
  CropTransform clampedTo(ui.Image image) {
    final shortSide = math.min(image.width, image.height);
    final sideways = quarterTurns.isOdd;
    final width = sideways ? image.height : image.width;
    final height = sideways ? image.width : image.height;
    final maxX = (width * zoom / shortSide - 1) / 2;
    final maxY = (height * zoom / shortSide - 1) / 2;

    return copyWith(
      offset: Offset(
        offset.dx.clamp(-maxX, maxX),
        offset.dy.clamp(-maxY, maxY),
      ),
    );
  }

  /// Draws [image] for a frame of size [frame] centred on [centre].
  void paint(
    Canvas canvas,
    ui.Image image, {
    required double frame,
    required Offset centre,
  }) {
    final scale = frame * zoom / math.min(image.width, image.height);

    canvas
      ..save()
      ..translate(centre.dx + offset.dx * frame, centre.dy + offset.dy * frame)
      ..scale(flipped ? -1 : 1, 1)
      ..rotate(quarterTurns * math.pi / 2)
      ..scale(scale)
      ..drawImage(
        image,
        Offset(-image.width / 2, -image.height / 2),
        Paint()..filterQuality = FilterQuality.high,
      )
      ..restore();
  }

  /// Renders the area inside the frame as a square PNG.
  Future<Uint8List> export(ui.Image image, {int size = 1024}) async {
    final recorder = ui.PictureRecorder();
    final side = size.toDouble();
    paint(
      Canvas(recorder),
      image,
      frame: side,
      centre: Offset(side / 2, side / 2),
    );
    final cropped = await recorder.endRecording().toImage(size, size);
    final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
    cropped.dispose();
    return data!.buffer.asUint8List();
  }
}
