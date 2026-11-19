import 'package:flutter/material.dart';

/// Thick grey band between sections, matching the profile screen.
class SectionBand extends StatelessWidget {
  const SectionBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
