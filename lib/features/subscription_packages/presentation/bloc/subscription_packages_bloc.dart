import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

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
          ..sort((a, b) => a.amountMinor.compareTo(b.amountMinor));
        _logPurchaseFlags(sorted);
        // Pre-select the Free plan; with no free plan, the cheapest one.
        final defaultPlan =
            sorted.where((p) => p.isFree).firstOrNull ?? sorted.firstOrNull;
        emit(
          SubscriptionPackagesState(
            status: PackagesLoadStatus.success,
            packages: sorted,
            selectedId: defaultPlan?.id,
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

  /// Debug builds only: prints why each paid plan can or can't be bought,
  /// so a disabled "Continue" button can be traced to the server's flags.
  void _logPurchaseFlags(List<SubscriptionPackage> packages) {
    if (!kDebugMode) return;
    for (final p in packages.where((p) => !p.isFree)) {
      final options = p.billingOptions
          .map((o) => '${o.billingPeriod}:${o.purchaseAvailable}')
          .join(', ');
      debugPrint(
        '[Plans] ${p.name} canPurchase=${p.canPurchase} '
        'purchaseAvailable=${p.purchaseAvailable} '
        'paidCheckoutEnabled=${p.paidCheckoutEnabled} '
        'billingOptions=[$options]',
      );
    }
  }

  void _onSelected(
    SubscriptionPackageSelected event,
    Emitter<SubscriptionPackagesState> emit,
  ) => emit(state.copyWith(selectedId: event.id));
}
