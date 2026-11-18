part of 'subscription_packages_bloc.dart';

enum PackagesLoadStatus { loading, success, failure }

class SubscriptionPackagesState extends Equatable {
  const SubscriptionPackagesState({
    this.status = PackagesLoadStatus.loading,
    this.packages = const [],
    this.selectedId,
    this.failure,
  });

  final PackagesLoadStatus status;

  /// Sorted cheapest first.
  final List<SubscriptionPackage> packages;
  final String? selectedId;
  final Failure? failure;

  SubscriptionPackage? get selected {
    for (final p in packages) {
      if (p.id == selectedId) return p;
    }
    return null;
  }

  /// The paid plan with the most applications, shown as "Most popular".
  String? get recommendedId {
    SubscriptionPackage? best;
    for (final p in packages) {
      if (p.isFree) continue;
      if (best == null ||
          (p.monthlyApplications ?? 0) > (best.monthlyApplications ?? 0)) {
        best = p;
      }
    }
    return best?.id;
  }

  SubscriptionPackagesState copyWith({String? selectedId}) =>
      SubscriptionPackagesState(
        status: status,
        packages: packages,
        selectedId: selectedId ?? this.selectedId,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, packages, selectedId, failure];
}
