/// Tabs shown in the dashboard bottom navigation bar, in display order.
enum DashboardTab {
  home('Home', 'home'),
  jobs('Jobs', 'jobs'),
  applied('Applied', 'applied'),
  resume('Resume', 'resume'),
  profile('Profile', 'profile');

  const DashboardTab(this.label, this._iconName);

  final String label;
  final String _iconName;

  /// PNG icon for this tab (grey normally, primary colour when selected).
  String iconAsset({required bool selected}) =>
      'assets/icons/nav/$_iconName${selected ? '_active' : ''}.png';
}
