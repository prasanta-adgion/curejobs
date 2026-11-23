part of 'profile_visibility_bloc.dart';

sealed class ProfileVisibilityEvent extends Equatable {
  const ProfileVisibilityEvent();

  @override
  List<Object?> get props => [];
}

/// First load or refresh: plan → allowed sections.
final class ProfileVisibilityRequested extends ProfileVisibilityEvent {
  const ProfileVisibilityRequested();
}

final class MatchDiscoverableToggled extends ProfileVisibilityEvent {
  const MatchDiscoverableToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

final class ShareContactOnRevealToggled extends ProfileVisibilityEvent {
  const ShareContactOnRevealToggled(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}
