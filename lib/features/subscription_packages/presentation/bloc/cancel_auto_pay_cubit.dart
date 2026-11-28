import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/current_subscription.dart';
import '../../domain/usecases/cancel_auto_renew_usecase.dart';
import 'purchase_messages.dart';

enum CancelAutoPayStatus { idle, cancelling, success, failure }

class CancelAutoPayState extends Equatable {
  const CancelAutoPayState({
    this.status = CancelAutoPayStatus.idle,
    this.message,
  });

  final CancelAutoPayStatus status;
  final String? message;

  bool get isBusy => status == CancelAutoPayStatus.cancelling;

  @override
  List<Object?> get props => [status, message];
}

/// Turns off auto-pay for the current paid plan. One action, so a Cubit.
class CancelAutoPayCubit extends Cubit<CancelAutoPayState> {
  CancelAutoPayCubit(this._cancelAutoRenew) : super(const CancelAutoPayState());

  final CancelAutoRenewUseCase _cancelAutoRenew;

  Future<void> cancel(CurrentSubscription subscription) async {
    if (state.isBusy || !subscription.canCancelAutoRenew) return;
    emit(const CancelAutoPayState(status: CancelAutoPayStatus.cancelling));

    final result = await _cancelAutoRenew(subscription);
    if (isClosed) return;

    result.fold(
      (_) => emit(
        const CancelAutoPayState(
          status: CancelAutoPayStatus.success,
          message: "You won't be charged again.",
        ),
      ),
      (f) => emit(
        CancelAutoPayState(
          status: CancelAutoPayStatus.failure,
          message: PurchaseMessages.fromFailure(f),
        ),
      ),
    );
  }

  /// The UI has shown the outcome.
  void reset() => emit(const CancelAutoPayState());
}
