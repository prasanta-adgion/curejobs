part of 'subscription_packages_bloc.dart';

sealed class SubscriptionPackagesEvent extends Equatable {
  const SubscriptionPackagesEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the plans for [type].
final class SubscriptionPackagesRequested extends SubscriptionPackagesEvent {
  const SubscriptionPackagesRequested([this.type = PackageType.candidate]);

  final PackageType type;

  @override
  List<Object?> get props => [type];
}

/// User tapped a plan card.
final class SubscriptionPackageSelected extends SubscriptionPackagesEvent {
  const SubscriptionPackageSelected(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
