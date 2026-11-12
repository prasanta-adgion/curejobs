import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

/// Tabs shown in the dashboard bottom navigation bar, in display order.
enum DashboardTab {
  home('Home', Icons.home_outlined, Icons.home_rounded),
  jobs('Jobs', AppIcons.work, Icons.work_rounded),
  applied('Applied', Icons.send_outlined, Icons.send_rounded),
  resume('Resume', Icons.description_outlined, Icons.description_rounded),
  profile('Profile', Icons.person_outline_rounded, Icons.person_rounded);

  const DashboardTab(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
