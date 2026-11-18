import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_subscription_packages_usecase.dart';

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

class SubscriptionPackagesCubit extends Cubit<SubscriptionPackagesState> {
  SubscriptionPackagesCubit(this._getPackages)
    : super(const SubscriptionPackagesState());

  final GetSubscriptionPackagesUseCase _getPackages;

  Future<void> load([PackageType type = PackageType.candidate]) async {
    emit(const SubscriptionPackagesState());
    final result = await _getPackages(type);
    if (isClosed) return;
    result.fold(
      (packages) {
        final sorted = [...packages]
          ..sort((a, b) => a.priceMinor.compareTo(b.priceMinor));
        final loaded = SubscriptionPackagesState(
          status: PackagesLoadStatus.success,
          packages: sorted,
        );
        // Pre-select the recommended paid plan, else the first one.
        emit(
          loaded.copyWith(
            selectedId:
                loaded.recommendedId ??
                (sorted.isEmpty ? null : sorted.first.id),
          ),
        );
      },
      (f) => emit(
        SubscriptionPackagesState(
          status: PackagesLoadStatus.failure,
          failure: f,
        ),
      ),
    );
  }

  void select(String id) => emit(state.copyWith(selectedId: id));
}
