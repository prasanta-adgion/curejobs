import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/usecases/get_subscription_packages_usecase.dart';

part 'subscription_packages_event.dart';
part 'subscription_packages_state.dart';

/// Loads the plans for a [PackageType] and tracks which one is selected.
class SubscriptionPackagesBloc
    extends Bloc<SubscriptionPackagesEvent, SubscriptionPackagesState> {
  SubscriptionPackagesBloc(this._getPackages)
    : super(const SubscriptionPackagesState()) {
    on<SubscriptionPackagesRequested>(_onRequested);
    on<SubscriptionPackageSelected>(_onSelected);
  }

  final GetSubscriptionPackagesUseCase _getPackages;

  Future<void> _onRequested(
    SubscriptionPackagesRequested event,
    Emitter<SubscriptionPackagesState> emit,
  ) async {
    emit(const SubscriptionPackagesState());
    final result = await _getPackages(event.type);
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

  void _onSelected(
    SubscriptionPackageSelected event,
    Emitter<SubscriptionPackagesState> emit,
  ) => emit(state.copyWith(selectedId: event.id));
}
