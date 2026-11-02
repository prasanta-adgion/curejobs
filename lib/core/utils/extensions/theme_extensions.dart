import 'package:flutter/material.dart';

extension ThemeContextExtension on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
