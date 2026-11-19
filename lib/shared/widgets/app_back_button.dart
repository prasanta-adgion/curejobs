import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';

/// Square, translucent back button for dark (navy) headers.
///
/// Pops the current route by default; pass [onPressed] to override.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(8),
    this.size = 40,
  });

  /// Fixed width and height of the square button.
  final double size;

  /// For an `AppBar.leading`: the button when the route can pop, else null
  /// (so root and tab screens show no back button). Defaults to the app
  /// bar's foreground colour, for light app bars.
  static Widget? leadingOf(BuildContext context, {Color? color}) {
    if (!(ModalRoute.of(context)?.canPop ?? false)) return null;
    return AppBackButton(
      color:
          color ??
          Theme.of(context).appBarTheme.foregroundColor ??
          Theme.of(context).colorScheme.onSurface,
    );
  }

  final VoidCallback? onPressed;

  /// Icon colour; the fill and border are derived from it.
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: IconButton(
          onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tight(Size.square(size)),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Image.asset(
            AssetPaths.backArrow,
            width: 18,
            height: 18,
            color: color,
          ),
          tooltip: 'Back',
        ),
      ),
    );
  }
}
