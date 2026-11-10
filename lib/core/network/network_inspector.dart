import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:network_logger/network_logger.dart';

import '../../app/config/app_config.dart';

/// In-app network inspector (request / response viewer) powered by
/// `network_logger`. Active only in dev and staging builds; in production
/// nothing is recorded and no button is shown.
abstract final class NetworkInspector {
  static bool get isEnabled => !AppConfig.current.isProduction;

  static OverlayEntry? _entry;

  /// Dio interceptor that records traffic for the inspector screen.
  static Interceptor interceptor() => DioNetworkLogger();

  /// Shows the floating, draggable inspector button above every screen.
  ///
  /// The entry goes straight into the Navigator's own overlay, so the button
  /// sits below the Navigator and can push the inspector screen.
  static void attach(NavigatorState navigator) {
    if (!isEnabled || _entry != null) return;
    final overlay = navigator.overlay;
    if (overlay == null) return;

    _entry = OverlayEntry(builder: (_) => const _DraggableInspectorButton());
    overlay.insert(_entry!);
  }
}

class _DraggableInspectorButton extends StatefulWidget {
  const _DraggableInspectorButton();

  @override
  State<_DraggableInspectorButton> createState() =>
      _DraggableInspectorButtonState();
}

class _DraggableInspectorButtonState extends State<_DraggableInspectorButton> {
  static const _size = 56.0;
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final position =
        _position ??
        Offset(screen.width - _size - 16, screen.height - _size - 96);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() {
          final next = position + details.delta;
          _position = Offset(
            next.dx.clamp(0, screen.width - _size),
            next.dy.clamp(padding.top, screen.height - _size - padding.bottom),
          );
        }),
        child: NetworkLoggerButton(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
